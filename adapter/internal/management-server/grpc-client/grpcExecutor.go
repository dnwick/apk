/*
 *  Copyright (c) 2022, WSO2 LLC. (http://www.wso2.org) All Rights Reserved.
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

package client

import (
	"context"
	"fmt"
	"time"

	"github.com/wso2/apk/adapter/config"
	logger "github.com/wso2/apk/adapter/internal/loggers"
	"github.com/wso2/apk/adapter/internal/management-server/utils"
	"github.com/wso2/apk/adapter/pkg/logging"
	"google.golang.org/grpc"
	grpcStatus "google.golang.org/grpc/status"
)

// RetryPolicy holds configuration for grpc connection retries
type RetryPolicy struct {
	// Maximum number of time a failed grpc call will be retried. Set negative value to try indefinitely.
	MaxAttempts int
	// Time delay between retries. (In milli seconds)
	BackOffInMilliSeconds int
}

// GetConnection creates and returns a grpc client connection
func GetConnection(address string) (*grpc.ClientConn, error) {
	transportCredentials, err := utils.GenerateTLSCredentials()
	if err != nil {
		return nil, err
	}
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	return grpc.DialContext(ctx, address, grpc.WithTransportCredentials(transportCredentials), grpc.WithBlock())
}

// ExecuteGRPCCall executes a grpc call
func ExecuteGRPCCall(call func() (interface{}, error)) (interface{}, error) {
	conf := config.ReadConfigs()
	maxAttempts := conf.ManagementServer.GRPCClient.MaxAttempts
	backOffInMilliSeconds := conf.ManagementServer.GRPCClient.BackOffInMilliSeconds
	retries := 0
	response, err := call()
	for {
		if err != nil {
			errStatus, _ := grpcStatus.FromError(err)
			logger.LoggerGRPCClient.ErrorC(logging.ErrorDetails{
				Message:   fmt.Sprintf("GRPC call failed. errorCode: %v errorMessage: %v", errStatus.Code().String(), errStatus.Message()),
				Severity:  logging.CRITICAL,
				ErrorCode: 2701,
			})
			if maxAttempts < 0 {
				// If max attempts has a negative value, retry indefinitely by setting retry less than max attempts.
				retries = maxAttempts - 1
			} else {
				retries++
			}
			if retries <= maxAttempts {
				// Retry grpc call after BackOffInMilliSeconds
				time.Sleep(time.Duration(backOffInMilliSeconds) * time.Millisecond)
				response, err = call()
			} else {
				return response, err
			}
		} else {
			return response, nil
		}
	}
}
