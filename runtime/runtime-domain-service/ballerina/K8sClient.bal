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

import ballerina/io;
import runtime_domain_service.model;
import ballerina/url;
import ballerina/log;
import ballerina/http;

const string K8S_API_ENDPOINT = "/api/v1";
final string token = check io:fileReadString(runtimeConfiguration.k8sConfiguration.serviceAccountPath + "/token");
final string caCertPath = runtimeConfiguration.k8sConfiguration.serviceAccountPath + "/ca.crt";
string namespaceFile = runtimeConfiguration.k8sConfiguration.serviceAccountPath + "/namespace";
final string currentNameSpace = check io:fileReadString(namespaceFile);
final http:Client k8sApiServerEp = check initializeK8sClient();

# This initialize the k8s Client.
# + return - k8s http client
public function initializeK8sClient() returns http:Client|error {
    http:Client k8sApiClient = check new ("https://" + runtimeConfiguration.k8sConfiguration.host,
    auth = {
        token: token
    },
        secureSocket = {
        cert: caCertPath

    }
    );
    return k8sApiClient;
}

# This returns ConfigMap value according to name and namespace.
#
# + name - Name of ConfigMap  
# + namespace - Namespace of Configmap
# + return - Return configmap value for name and namespace
isolated function getConfigMapValueFromNameAndNamespace(string name, string namespace) returns http:Response|error {
    string endpoint = "/api/v1/namespaces/" + namespace + "/configmaps/" + name;
    return k8sApiServerEp->get(endpoint, targetType = http:Response);
}

isolated function deleteAPICR(string name, string namespace) returns http:Response|http:ClientError {
    string endpoint = "/apis/dp.wso2.com/v1alpha1/namespaces/" + namespace + "/apis/" + name;
    return k8sApiServerEp->delete(endpoint, targetType = http:Response);
}

isolated function deleteAuthenticationCR(string name, string namespace) returns http:Response|http:ClientError {
    string endpoint = "/apis/dp.wso2.com/v1alpha1/namespaces/" + namespace + "/authentications/" + name;
    return k8sApiServerEp->delete(endpoint, targetType = http:Response);
}

isolated function deployAuthenticationCR(model:Authentication authentication, string namespace) returns http:Response|http:ClientError {
    string endpoint = "/apis/dp.wso2.com/v1alpha1/namespaces/" + namespace + "/authentications";
    return k8sApiServerEp->post(endpoint, authentication, targetType = http:Response);
}

isolated function getHttpRoute(string name, string namespace) returns model:Httproute|http:ClientError {
    string endpoint = "/apis/gateway.networking.k8s.io/v1beta1/namespaces/" + namespace + "/httproutes/" + name;
    return k8sApiServerEp->get(endpoint, targetType = model:Httproute);
}

isolated function deleteHttpRoute(string name, string namespace) returns http:Response|http:ClientError {
    string endpoint = "/apis/gateway.networking.k8s.io/v1beta1/namespaces/" + namespace + "/httproutes/" + name;
    return k8sApiServerEp->delete(endpoint, targetType = http:Response);
}

isolated function deleteConfigMap(string name, string namespace) returns http:Response|http:ClientError {
    string endpoint = "/api/v1/namespaces/" + namespace + "/configmaps/" + name;
    return k8sApiServerEp->delete(endpoint, targetType = http:Response);
}

isolated function deployAPICR(model:API api, string namespace) returns http:Response|http:ClientError {
    string endpoint = "/apis/dp.wso2.com/v1alpha1/namespaces/" + namespace + "/apis";
    return k8sApiServerEp->post(endpoint, api, targetType = http:Response);
}

isolated function deployServiceMappingCR(model:K8sServiceMapping serviceMapping, string namespace) returns http:Response|http:ClientError {
    string endpoint = "/apis/dp.wso2.com/v1alpha1/namespaces/" + namespace + "/servicemappings";
    return k8sApiServerEp->post(endpoint, serviceMapping, targetType = http:Response);

}

isolated function deployConfigMap(model:ConfigMap configMap, string namespace) returns http:Response|http:ClientError {
    string endpoint = "/api/v1/namespaces/" + namespace + "/configmaps";
    return k8sApiServerEp->post(endpoint, configMap, targetType = http:Response);
}

isolated function deployService(model:Service 'service, string namespace) returns http:Response|http:ClientError {
    string endpoint = "/api/v1/namespaces/" + namespace + "/services";
    return k8sApiServerEp->post(endpoint, 'service, targetType = http:Response);
}

isolated function deployHttpRoute(model:Httproute httproute, string namespace) returns http:Response|http:ClientError {
    string endpoint = "/apis/gateway.networking.k8s.io/v1beta1/namespaces/" + namespace + "/httproutes";
    return k8sApiServerEp->post(endpoint, httproute, targetType = http:Response);
}

isolated function retrieveAllAPIS(string? continueToken) returns model:APIList|http:ClientError {
    string? continueTokenValue = continueToken;
    string endpoint = "/apis/dp.wso2.com/v1alpha1/apis";
    if continueTokenValue is string {
        if continueTokenValue.length() > 0 {
            int? questionMarkIndex = endpoint.lastIndexOf("?");
            if questionMarkIndex is int {
                if questionMarkIndex > 0 {
                    endpoint = endpoint + "&continue=" + continueTokenValue;
                } else {
                    endpoint = endpoint + "?continue=" + continueTokenValue;
                }
            } else {
                endpoint = endpoint + "?continue=" + continueTokenValue;
            }
        }
    }

    return k8sApiServerEp->get(endpoint, targetType = model:APIList);
}

function retrieveAllServices(string? continueToken) returns model:ServiceList|http:ClientError {
    string? continueTokenValue = continueToken;
    string endpoint = "/api/v1/services";
    if continueTokenValue is string {
        if continueTokenValue.length() > 0 {
            int? questionMarkIndex = endpoint.lastIndexOf("?");
            if questionMarkIndex is int {
                if questionMarkIndex > 0 {
                    endpoint = endpoint + "&continue=" + continueTokenValue;
                } else {
                    endpoint = endpoint + "?continue=" + continueTokenValue;
                }
            } else {
                endpoint = endpoint + "?continue=" + continueTokenValue;
            }
        }
    }

    return k8sApiServerEp->get(endpoint, targetType = model:ServiceList);
}
isolated function deleteService(string name, string namespace) returns http:Response|http:ClientError{
    string endpoint = "/api/v1/namespaces/" + namespace + "/services/" + name;
    return k8sApiServerEp->delete(endpoint, targetType = http:Response);
}

isolated function getServiceByNameAndNamespace(string name, string namespace) returns model:Service|error {
    string endpoint = "/api/v1/namespaces/" + namespace + "/services/" + name;
    http:Response|http:ClientError response = k8sApiServerEp->get(endpoint);
    if response is http:Response {
        if response.statusCode == 200 {
            json jsonPayload = check response.getJsonPayload();
            return jsonPayload.cloneWithType(model:Service);
        } else if (response.statusCode == 404) {
            return error("Service not found");
        }
        log:printError("Internal Error occured while retrieving service", statuscode = response.statusCode, payload = check response.getTextPayload());
        return error("Internal Error occured");
    } else {
        return error(response.message());
    }
}

isolated function getK8sAPIByNameAndNamespace(string name, string namespace) returns json|error {
    string endpoint = "/apis/dp.wso2.com/v1alpha1/namespaces/" + namespace + "/apis/" + name;
    http:Response|http:ClientError response = k8sApiServerEp->get(endpoint);
    if response is http:Response {
        if response.statusCode == 200 {
            return response.getJsonPayload();
        } else if (response.statusCode == 404) {
            return error("API not found");
        }
    } else {
        return error(response.message());
    }
}

function retrieveAllServiceMappings(string? continueToken) returns model:ServiceMappingList|http:ClientError {
    string? continueTokenValue = continueToken;
    string endpoint = "/apis/dp.wso2.com/v1alpha1/servicemappings";
    if continueTokenValue is string {
        if continueTokenValue.length() > 0 {
            int? questionMarkIndex = endpoint.lastIndexOf("?");
            if questionMarkIndex is int {
                if questionMarkIndex > 0 {
                    endpoint = endpoint + "&continue=" + continueTokenValue;
                } else {
                    endpoint = endpoint + "?continue=" + continueTokenValue;
                }
            } else {
                endpoint = endpoint + "?continue=" + continueTokenValue;
            }
        }
    }

    return k8sApiServerEp->get(endpoint, targetType = model:ServiceMappingList);
}

isolated function deleteK8ServiceMapping(string name, string namespace) returns http:Response|http:ClientError {
    string endpoint = "/apis/dp.wso2.com/v1alpha1/namespaces/" + namespace + "/servicemappings/" + name;
    return k8sApiServerEp->delete(endpoint, targetType = http:Response);
}

isolated function getK8sServiceMapingsForAPI(string apiName, string apiVersion, string namespace) returns model:ServiceMappingList|http:ClientError|error {
    string endpoint = "/apis/dp.wso2.com/v1alpha1/namespaces/" + namespace + "/servicemappings?labelSelector=" + check generateUrlEncodedLabelSelector(apiName, apiVersion);
    return k8sApiServerEp->get(endpoint, targetType = model:ServiceMappingList);
}

isolated function getAuthenticationCrsForAPI(string apiName, string apiVersion, string namespace) returns model:AuthenticationList|http:ClientError|error {
    string endpoint = "/apis/dp.wso2.com/v1alpha1/namespaces/" + namespace + "/authentications?labelSelector=" + check generateUrlEncodedLabelSelector(apiName, apiVersion);
    return k8sApiServerEp->get(endpoint, targetType = model:AuthenticationList);
}

isolated function generateUrlEncodedLabelSelector(string apiName, string apiVersion) returns string|error {
    string labelSelector = string:'join("", "api-name=", apiName, ",api-version=", apiVersion);
    return url:encode(labelSelector, "UTF-8");
}

isolated function getBackendServicesForAPI(string apiName, string apiVersion, string namespace) returns model:ServiceList|http:ClientError|error {
    string endpoint = "/api/v1/namespaces/" + namespace + "/services?labelSelector=" + check generateUrlEncodedLabelSelector(apiName, apiVersion);
    return k8sApiServerEp->get(endpoint, targetType = model:ServiceList);
}
