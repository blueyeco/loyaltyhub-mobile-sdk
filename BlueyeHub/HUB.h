//
//  HUB.h
//  
//
//  Created by Deji Jimoh - Blueye Corporation on 7/2/13.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ClientDelegate.h"
#import <FacebookSDK/FacebookSDK.h>

@interface HUB : NSObject <ClientDelegate> {
    @private
        Client *rest;
        NSDictionary *auth;
}

@property (nonatomic, retain) NSString *token;
@property (nonatomic, retain) NSString *userId;
@property (nonatomic, retain) NSDictionary<FBGraphUser> *fbUser;

+(HUB *) sharedInstance;
+(void)connect:(NSString *)apiKey;
+(void)connect:(NSString *)apiKey userId:(id)userId;
+(void)connect:(NSString *)apiKey userId:(id)userId email:(NSString *)email;
+(void)connect:(NSString *)apiKey userId:(id)userId email:(NSString *)email name:(NSString *)name;

+(void)setUser:(id)userId email:(NSString *)email name:(NSString *)name;
+(void)setUserId:(id)userId;

+(void)track:(UIViewController *)view;
+(void)track:(NSString *)action properties:(NSDictionary *)properties;

+(void)trackItem:(NSString *)type;
+(void)trackItem:(NSString *)type itemId:(id)itemId;
+(void)trackItem:(NSString *)type itemId:(id)itemId action:(NSString *)action;
+(void)trackItem:(NSString *)type itemId:(id)itemId action:(NSString *)action title:(NSString *)title imgUrl:(NSString *)imgUrl;
+(void)trackItem:(NSString *)type itemId:(id)itemId action:(NSString *)action value:(NSNumber *)value;
+(void)trackItem:(NSString *)type itemId:(id)itemId action:(NSString *)action title:(NSString *)title imgUrl:(NSString *)imgUrl value:(NSNumber *)value;

- (Client *)client;

@end
