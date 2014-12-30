//
//  Client.h
//  BlueyeHub
//
//  Created by Deji Jimoh on 3/22/13.
//  Copyright 2013 Deji Jimoh. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "ClientDelegate.h"

@interface Client : NSObject
{
@private
    NSMutableData *receivedData;
    NSString *mimeType;
    NSURLConnection *conn;
    BOOL asynchronous;
    NSObject <ClientDelegate> __unsafe_unretained *delegate;
    NSString *username;
    NSString *password;
}

@property (nonatomic, readonly) NSData *receivedData;
@property (nonatomic) BOOL asynchronous;
@property (nonatomic, copy) NSString *mimeType;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, assign) NSObject<ClientDelegate> *delegate;

- (void)sendRequestTo:(NSURL *)url usingVerb:(NSString *)verb withParameters:(NSDictionary *)parameters;
- (void)uploadData:(NSData *)data toURL:(NSURL *)url;
- (void)cancelConnection;
- (NSDictionary *)responseAsPropertyList;
- (NSString *)responseAsText;

@end

