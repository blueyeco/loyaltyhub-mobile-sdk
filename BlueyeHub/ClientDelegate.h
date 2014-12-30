//
//  Client.m
//  Omni
//
//  Created by Deji Jimoh on 3/22/13.
//  Copyright 2013 Deji Jimoh. All rights reserved.
//


#import <Foundation/Foundation.h>

@class Client;

@protocol ClientDelegate

@required
- (void)client:(Client*)client didRetrieveData:(NSData *)data;

@optional
- (void)clientHasBadCredentials:(Client *)client;
- (void)client:(Client *)client didCreateResourceAtURL:(NSString *)url;
- (void)client:(Client *)client didFailWithError:(NSError *)error;
- (void)client:(Client *)client didReceiveStatusCode:(int)statusCode;

@end
