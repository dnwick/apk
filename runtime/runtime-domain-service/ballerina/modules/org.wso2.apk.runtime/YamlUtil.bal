import ballerina/jballerina.java;
import runtime_domain_service.java.lang as javalang;
import runtime_domain_service.com.fasterxml.jackson.core as comfasterxmljacksoncore;

# Ballerina class mapping for the Java `org.wso2.apk.runtime.YamlUtil` class.
@java:Binding {'class: "org.wso2.apk.runtime.YamlUtil"}
public distinct class YamlUtil {

    *java:JObject;
    *javalang:Object;

    # The `handle` field that stores the reference to the `org.wso2.apk.runtime.YamlUtil` object.
    public handle jObj;

    # The init function of the Ballerina class mapping the `org.wso2.apk.runtime.YamlUtil` Java class.
    #
    # + obj - The `handle` value containing the Java reference of the object.
    public isolated function init(handle obj) {
        self.jObj = obj;
    }

    # The function to retrieve the string representation of the Ballerina class mapping the `org.wso2.apk.runtime.YamlUtil` Java class.
    #
    # + return - The `string` form of the Java object instance.
    public isolated function toString() returns string {
        return java:toString(self.jObj) ?: "null";
    }
    # The function that maps to the `equals` method of `org.wso2.apk.runtime.YamlUtil`.
    #
    # + arg0 - The `javalang:Object` value required to map with the Java method parameter.
    # + return - The `boolean` value returning from the Java mapping.
    public function 'equals(javalang:Object arg0) returns boolean {
        return org_wso2_apk_runtime_YamlUtil_equals(self.jObj, arg0.jObj);
    }

    # The function that maps to the `fromJsonStringToYaml` method of `org.wso2.apk.runtime.YamlUtil`.
    #
    # + arg0 - The `string` value required to map with the Java method parameter.
    # + return - The `string` or the `comfasterxmljacksoncore:JsonProcessingException` value returning from the Java mapping.
    public isolated function fromJsonStringToYaml(string arg0) returns string?|comfasterxmljacksoncore:JsonProcessingException {
        handle|error externalObj = org_wso2_apk_runtime_YamlUtil_fromJsonStringToYaml(self.jObj, java:fromString(arg0));
        if (externalObj is error) {
            comfasterxmljacksoncore:JsonProcessingException e = error comfasterxmljacksoncore:JsonProcessingException(comfasterxmljacksoncore:JSONPROCESSINGEXCEPTION, externalObj, message = externalObj.message());
            return e;
        } else {
            return java:toString(externalObj);
        }
    }

    # The function that maps to the `getClass` method of `org.wso2.apk.runtime.YamlUtil`.
    #
    # + return - The `javalang:Class` value returning from the Java mapping.
    public function getClass() returns javalang:Class {
        handle externalObj = org_wso2_apk_runtime_YamlUtil_getClass(self.jObj);
        javalang:Class newObj = new (externalObj);
        return newObj;
    }

    # The function that maps to the `hashCode` method of `org.wso2.apk.runtime.YamlUtil`.
    #
    # + return - The `int` value returning from the Java mapping.
    public function hashCode() returns int {
        return org_wso2_apk_runtime_YamlUtil_hashCode(self.jObj);
    }

    # The function that maps to the `notify` method of `org.wso2.apk.runtime.YamlUtil`.
    public function notify() {
        org_wso2_apk_runtime_YamlUtil_notify(self.jObj);
    }

    # The function that maps to the `notifyAll` method of `org.wso2.apk.runtime.YamlUtil`.
    public function notifyAll() {
        org_wso2_apk_runtime_YamlUtil_notifyAll(self.jObj);
    }

    # The function that maps to the `wait` method of `org.wso2.apk.runtime.YamlUtil`.
    #
    # + return - The `javalang:InterruptedException` value returning from the Java mapping.
    public function 'wait() returns javalang:InterruptedException? {
        error|() externalObj = org_wso2_apk_runtime_YamlUtil_wait(self.jObj);
        if (externalObj is error) {
            javalang:InterruptedException e = error javalang:InterruptedException(javalang:INTERRUPTEDEXCEPTION, externalObj, message = externalObj.message());
            return e;
        }
    }

    # The function that maps to the `wait` method of `org.wso2.apk.runtime.YamlUtil`.
    #
    # + arg0 - The `int` value required to map with the Java method parameter.
    # + return - The `javalang:InterruptedException` value returning from the Java mapping.
    public function wait2(int arg0) returns javalang:InterruptedException? {
        error|() externalObj = org_wso2_apk_runtime_YamlUtil_wait2(self.jObj, arg0);
        if (externalObj is error) {
            javalang:InterruptedException e = error javalang:InterruptedException(javalang:INTERRUPTEDEXCEPTION, externalObj, message = externalObj.message());
            return e;
        }
    }

    # The function that maps to the `wait` method of `org.wso2.apk.runtime.YamlUtil`.
    #
    # + arg0 - The `int` value required to map with the Java method parameter.
    # + arg1 - The `int` value required to map with the Java method parameter.
    # + return - The `javalang:InterruptedException` value returning from the Java mapping.
    public function wait3(int arg0, int arg1) returns javalang:InterruptedException? {
        error|() externalObj = org_wso2_apk_runtime_YamlUtil_wait3(self.jObj, arg0, arg1);
        if (externalObj is error) {
            javalang:InterruptedException e = error javalang:InterruptedException(javalang:INTERRUPTEDEXCEPTION, externalObj, message = externalObj.message());
            return e;
        }
    }

}

# The constructor function to generate an object of `org.wso2.apk.runtime.YamlUtil`.
#
# + return - The new `YamlUtil` class generated.
public isolated function newYamlUtil1() returns YamlUtil {
    handle externalObj = org_wso2_apk_runtime_YamlUtil_newYamlUtil1();
    YamlUtil newObj = new (externalObj);
    return newObj;
}

function org_wso2_apk_runtime_YamlUtil_equals(handle receiver, handle arg0) returns boolean = @java:Method {
    name: "equals",
    'class: "org.wso2.apk.runtime.YamlUtil",
    paramTypes: ["java.lang.Object"]
} external;

isolated function org_wso2_apk_runtime_YamlUtil_fromJsonStringToYaml(handle receiver, handle arg0) returns handle|error = @java:Method {
    name: "fromJsonStringToYaml",
    'class: "org.wso2.apk.runtime.YamlUtil",
    paramTypes: ["java.lang.String"]
} external;

function org_wso2_apk_runtime_YamlUtil_getClass(handle receiver) returns handle = @java:Method {
    name: "getClass",
    'class: "org.wso2.apk.runtime.YamlUtil",
    paramTypes: []
} external;

function org_wso2_apk_runtime_YamlUtil_hashCode(handle receiver) returns int = @java:Method {
    name: "hashCode",
    'class: "org.wso2.apk.runtime.YamlUtil",
    paramTypes: []
} external;

function org_wso2_apk_runtime_YamlUtil_notify(handle receiver) = @java:Method {
    name: "notify",
    'class: "org.wso2.apk.runtime.YamlUtil",
    paramTypes: []
} external;

function org_wso2_apk_runtime_YamlUtil_notifyAll(handle receiver) = @java:Method {
    name: "notifyAll",
    'class: "org.wso2.apk.runtime.YamlUtil",
    paramTypes: []
} external;

function org_wso2_apk_runtime_YamlUtil_wait(handle receiver) returns error? = @java:Method {
    name: "wait",
    'class: "org.wso2.apk.runtime.YamlUtil",
    paramTypes: []
} external;

function org_wso2_apk_runtime_YamlUtil_wait2(handle receiver, int arg0) returns error? = @java:Method {
    name: "wait",
    'class: "org.wso2.apk.runtime.YamlUtil",
    paramTypes: ["long"]
} external;

function org_wso2_apk_runtime_YamlUtil_wait3(handle receiver, int arg0, int arg1) returns error? = @java:Method {
    name: "wait",
    'class: "org.wso2.apk.runtime.YamlUtil",
    paramTypes: ["long", "int"]
} external;

isolated function org_wso2_apk_runtime_YamlUtil_newYamlUtil1() returns handle = @java:Constructor {
    'class: "org.wso2.apk.runtime.YamlUtil",
    paramTypes: []
} external;

