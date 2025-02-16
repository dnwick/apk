/*
 *  Copyright (c) 2022, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package utils

import (
	"fmt"

	constants "github.com/wso2/apk/adapter/internal/operator/constants"
	"github.com/wso2/apk/adapter/pkg/utils/envutils"
	"github.com/wso2/apk/adapter/pkg/utils/stringutils"
	"k8s.io/apimachinery/pkg/types"
	"sigs.k8s.io/controller-runtime/pkg/client"
	"sigs.k8s.io/gateway-api/apis/v1beta1"
	gwapiv1b1 "sigs.k8s.io/gateway-api/apis/v1beta1"
)

// NamespacedName generates namespaced name for Kubernetes objects
func NamespacedName(obj client.Object) types.NamespacedName {
	return types.NamespacedName{
		Namespace: obj.GetNamespace(),
		Name:      obj.GetName(),
	}
}

// FilterByNamespaces takes a list of namespaces and returns a filter function
// which return true if the input object is in the given namespaces list,
// and returns false otherwise
func FilterByNamespaces(namespaces []string) func(object client.Object) bool {
	return func(object client.Object) bool {
		if namespaces == nil {
			return true
		}
		return stringutils.StringInSlice(object.GetNamespace(), namespaces)
	}
}

// GetNamespace reads namespace with a default value
func GetNamespace(namespace *v1beta1.Namespace, defaultNamespace string) string {
	if namespace != nil && *namespace != "" {
		return string(*namespace)
	}
	return defaultNamespace
}

// GetOperatorPodNamespace returns the namesapce of the operator pod
func GetOperatorPodNamespace() string {
	return envutils.GetEnv(constants.OperatorPodNamespace,
		constants.OperatorPodNamespaceDefaultValue)
}

// GroupPtr returns pointer to created v1beta1.Group object
func GroupPtr(name string) *v1beta1.Group {
	group := v1beta1.Group(name)
	return &group
}

// KindPtr returns a pointer to created v1beta1.Kind object
func KindPtr(name string) *v1beta1.Kind {
	kind := v1beta1.Kind(name)
	return &kind
}

// PathMatchTypePtr returns a pointer to created v1beta1.PathMatchType object
func PathMatchTypePtr(pType v1beta1.PathMatchType) *v1beta1.PathMatchType {
	return &pType
}

// StringPtr returns a pointer to created string
func StringPtr(val string) *string {
	return &val
}

// GetDefaultHostNameForBackend returns the host in <backend.name>.<namespace> format
func GetDefaultHostNameForBackend(backend gwapiv1b1.HTTPBackendRef,
	defaultNamespace string) string {
	return fmt.Sprintf("%s.%s", backend.Name,
		GetNamespace(backend.Namespace, defaultNamespace))
}
