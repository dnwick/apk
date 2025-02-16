//
// Copyright (c) 2022, WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//
import ballerina/websocket;
import ballerina/lang.value;
import runtime_domain_service.model as model;
import ballerina/log;

isolated map<map<model:API>> apilist = {};
string resourceVersion = "";
websocket:Client|error|() apiClient = ();

class APIListingTask {
    function init(string resourceVersion) {
        apiClient = getClient(resourceVersion);
    }

    public function startListening() returns error? {

        worker WatchAPIThread {
            while true {
                do {
                    websocket:Client|error|() apiClientResult = apiClient;
                    if apiClientResult is websocket:Client {
                        boolean connectionOpen = apiClientResult.isOpen();
                        if !connectionOpen {
                            log:printDebug("Websocket Client connection closed conectionId: " + apiClientResult.getConnectionId() + " state: " + connectionOpen.toString());
                            apiClient = getClient(resourceVersion);
                            websocket:Client|error|() retryClient = apiClient;
                            if retryClient is websocket:Client {
                                log:printDebug("Reinitializing client..");
                                connectionOpen = retryClient.isOpen();
                                log:printDebug("Intializd new Client Connection conectionId: " + retryClient.getConnectionId() + " state: " + connectionOpen.toString());
                                _ = check readAPIEvent(retryClient);
                            } else if retryClient is error {
                                log:printError("error while reading message", retryClient);
                            }
                        } else {
                            _ = check readAPIEvent(apiClientResult);
                        }

                    } else if apiClientResult is error {
                        log:printError("error while reading message", apiClientResult);
                    }
                } on fail var e {
                    log:printError("Unable to read api messages", e);
                }
            }
        }
    }
}

# Description Retrieve Websocket client for watch API event.
#
# + resourceVersion - resource Version to watch after.
# + return - Return websocket Client.
public function getClient(string resourceVersion) returns websocket:Client|error {
    string requestURl = "wss://" + runtimeConfiguration.k8sConfiguration.host + "/apis/dp.wso2.com/v1alpha1/watch/apis";
    if resourceVersion.length() > 0 {
        requestURl = requestURl + "?resourceVersion=" + resourceVersion.toString();
    }
    return new (requestURl,
    auth = {
        token: token
    },
        secureSocket = {
        cert: caCertPath
    }
    );
}

isolated function getAPIs(string organization) returns model:API[] {
    lock {
        map<model:API>|error & readonly readOnlyAPImap = trap apilist.get(organization).cloneReadOnly();
        if readOnlyAPImap is map<model:API> & readonly{
            return readOnlyAPImap.toArray();
        } else {
            return [];
        }
    }
}

isolated function getAPI(string id, string organization) returns model:API|error {
    lock {
        map<model:API> & readonly apiMap = check trap apilist.get(organization).cloneReadOnly();
        return check trap apiMap.get(id);
    }
}

function putallAPIS(model:API[] apiData) {
    foreach model:API api in apiData {
        lock {
            map<model:API>|error orgmap = trap apilist.get(api.spec.organization);
            if orgmap is map<model:API> {
                orgmap[<string>api.metadata.uid] = api.clone();
            } else {
                map<model:API> apiMap = {};
                apiMap[<string>api.metadata.uid] = api.clone();
                apilist[api.spec.organization] = apiMap;
            }
        }
    }
}

function setResourceVersion(string resourceVersionValue) {
    resourceVersion = resourceVersionValue;
}

function readAPIEvent(websocket:Client apiWebsocketClient) returns error? {
    boolean connectionOpen = apiWebsocketClient.isOpen();

    log:printDebug("Using Client Connection conectionId: " + apiWebsocketClient.getConnectionId() + " state: " + connectionOpen.toString());
    if !connectionOpen {
        error err = error("connection closed");
        return err;
    }
    string|error message = check apiWebsocketClient->readMessage();
    if message is string {
        log:printDebug(message);
        json value = check value:fromJsonString(message);
        string eventType = <string>check value.'type;
        json eventValue = <json>check value.'object;
        json metadata = <json>check eventValue.metadata;
        string latestResourceVersion = <string>check metadata.resourceVersion;
        setResourceVersion(latestResourceVersion);
        model:API|error apiModel = eventValue.cloneWithType(model:API);
        if apiModel is model:API {
            if apiModel.metadata.namespace == getNameSpace(runtimeConfiguration.apiCreationNamespace) {
                if eventType == "ADDED" {
                    lock {
                        putAPI(apiModel.clone());
                    }
                } else if (eventType == "MODIFIED") {
                    lock {
                        updateAPI(apiModel.clone());
                    }
                } else if (eventType == "DELETED") {
                    lock {
                        removeAPI(apiModel);
                    }
                }
            }
        } else {
            log:printError("error while converting");
        }
    } else {
        log:printError("error while reading message", message);
    }

}

isolated function putAPI(model:API api) {
    lock {
        map<model:API>|error orgapiMap = trap apilist.get(api.spec.organization);
        if orgapiMap is map<model:API> {
            orgapiMap[<string>api.metadata.uid] = api.clone();
        } else {
            map<model:API> apiMap = {};
            apiMap[<string>api.metadata.uid] = api.clone();
            apilist[api.spec.organization] = apiMap;
        }
    }
}

isolated function updateAPI(model:API api) {
    lock {

        map<model:API>|error orgapiMap = trap apilist.get(api.spec.organization);
        if orgapiMap is map<model:API> {
            _ = orgapiMap.remove(<string>api.metadata.uid);
            orgapiMap[<string>api.metadata.uid] = api.clone();
        } else {
            map<model:API> apiMap = {};
            apiMap[<string>api.metadata.uid] = api.clone();
            apilist[api.spec.organization] = apiMap;
        }
    }
}

isolated function removeAPI(model:API api) {
    lock {
        map<model:API>|error orgapiMap = trap apilist.get(api.spec.organization);
        if orgapiMap is map<model:API> {
            _ = orgapiMap.remove(<string>api.metadata.uid);
        }
    }
}

isolated function getAPIByNameAndNamespace(string name, string namespace, string organization) returns model:API|() {
    foreach model:API api in getAPIs(organization) {
        if (api.metadata.name == name && api.metadata.namespace == namespace) {
            return api;
        }
    }
    json|error k8sAPIByNameAndNamespace = getK8sAPIByNameAndNamespace(name, namespace);
    if k8sAPIByNameAndNamespace is json {
        model:API|error k8sAPI = k8sAPIByNameAndNamespace.cloneWithType(model:API);
        if k8sAPI is model:API {
            return k8sAPI;
        } else {
            log:printError("Error occued while converting json", k8sAPI);
        }
    }
    return ();
}

isolated function isAPIVersionExist(string name, string 'newVersion, string organization) returns boolean {
    lock {
        map<model:API>|error apiMap = trap apilist.get(organization);
        if apiMap is map<model:API> {
            model:API[] & readonly readOnlyAPIList = apiMap.toArray().cloneReadOnly();
            foreach model:API & readonly api in readOnlyAPIList {
                if api.spec.apiDisplayName == name && api.spec.apiVersion == 'newVersion {
                    return true;
                }
            }
        }
    }
    return false;
}
