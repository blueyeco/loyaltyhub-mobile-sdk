//
//  HUB.m
//  
//
//  Created by Deji Jimoh - Blueye Corporation on 7/2/13.
//
//

#import "HUB.h"
#import "Client.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

#define API_URL @"https://blueyehub.com/api.php"

@implementation HUB

static HUB *_sharedInstance;
static bool connected = false;
static NSString *GA_ID;

@synthesize token, userId, fbUser;

- (id)init
{
    if((self = [super init]))
    {
    }
    
    return self;
}

+ (HUB *) sharedInstance
{
	if (!_sharedInstance)
	{
		_sharedInstance = [[HUB alloc] init];
	}
	
	return _sharedInstance;
}

+(void)connect:(NSString *)apiKey {
    [HUB connect:apiKey userId:nil];
}

+(void)connect:(NSString *)apiKey userId:(id)userId {
    [HUB connect:apiKey userId:userId email:nil name:nil];
}

+(void)connect:(NSString *)apiKey userId:(id)userId email:(NSString *)email {
    [HUB connect:apiKey userId:userId email:email name:nil];
}

+(void)connect:(NSString *)apiKey userId:(id)userId email:(NSString *)email name:(NSString *)name {
    @try {
        NSLog(@"Blueye Hub Initializing with API Key: %@", apiKey);
        
        if(userId != nil && userId != NULL)
            [[HUB sharedInstance] setUserId:[NSString stringWithFormat:@"%@", userId]];
        
        if(!connected) {
            NSArray *keys = [NSArray arrayWithObjects:@"apiKey", @"uid", @"email", @"name", nil];
            NSArray *values = [NSArray arrayWithObjects:apiKey, userId, email, name, nil];
            [[HUB sharedInstance] callAPI:@"authenticate" keys:keys values:values];
        }
        else if(userId != nil && userId != NULL) {
            [HUB setUser:userId email:email name:name];
        }
    } @catch (NSException *e) {}
}

+(void)setUser:(id)userId email:(NSString *)email name:(NSString *)name {
    @try {
        [[HUB sharedInstance] setUserId:[NSString stringWithFormat:@"%@", userId]];
        
        NSArray *keys = [NSArray arrayWithObjects:@"uid", @"email", @"name", nil];
        NSArray *values = [NSArray arrayWithObjects:userId, email, name, nil];
        [[HUB sharedInstance] callAPI:@"setAppUser" keys:keys values:values];
    } @catch (NSException *e) {}
}

+(void)track:(UIViewController *)view {
    if(GA_ID != nil) {
        @try {
            NSString *viewName = NSStringFromClass([view class]);
            NSLog(@"Blueye Hub Tracking Screen: %@", viewName);
            
            id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:GA_ID];
            tracker.allowIDFACollection = YES;
            [tracker set:kGAIScreenName value:viewName];
            [tracker send:[[GAIDictionaryBuilder createAppView]  build]];
            
            NSString *user;
            
            if([[HUB sharedInstance] userId] != nil && [[HUB sharedInstance] userId] != NULL)
                user = [[HUB sharedInstance] userId];
            else
                user = @"0";
            
            NSString *fb = [[HUB sharedInstance] fbUser] != nil ? [NSString stringWithFormat:@", \"fb\":\"%@\"", [[[HUB sharedInstance] fbUser] objectForKey:@"id"]] : @"";
            
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"screen" action:viewName label:[NSString stringWithFormat:@"{ \"u\":\"%@\"%@ }", user, fb] value:nil] build]];
        } @catch (NSException *e) {
            NSLog(@"Error: Blueye Hub Failed to track screen");
        }
    }
}

+(void)track:(NSString *)action properties:(NSDictionary *)properties {
    if(GA_ID != nil) {
        @try {
            NSLog(@"Blueye Hub Event: %@", action);
            
            id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:GA_ID];
            tracker.allowIDFACollection = YES;
            
            NSString *user;
            
            if([[HUB sharedInstance] userId] != nil && [[HUB sharedInstance] userId] != NULL)
                user = [[HUB sharedInstance] userId];
            else
                user = @"0";
            
            NSString *fb = [[HUB sharedInstance] fbUser] != nil ? [NSString stringWithFormat:@", \"fb\":\"%@\"", [[[HUB sharedInstance] fbUser] objectForKey:@"id"]] : @"";
            
            NSMutableString *props = [[NSMutableString alloc] init];
            
            if(properties != nil && properties != NULL) {
                /*[props appendString:@", p:{"];
                
                NSArray *keys = [properties allKeys];
                int count = [keys count];
                
                for (int i = 0; i < count; i++) {
                    NSString *key = [keys objectAtIndex:i];
                    NSString *val = [properties objectForKey:key];
                    
                    [props appendFormat:@"\"%@\":\"%@\",", key, val];
                }
                
                [props deleteCharactersInRange:NSMakeRange([props length] - 1, 1)];
                [props appendString:@"}"];*/
                
                NSError *error;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:properties options:0 error:&error];
                
                if(jsonData)
                    [props appendFormat:@", \"p\":%@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
                else
                    NSLog(@"Error: Blueye Hub Failed to parse event properties - %@", error);
            }
            
            //NSLog(@"%@", [NSString stringWithFormat:@"{ \"u\":%@%@%@ }", user, fb, props]);
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:action action:@"view" label:[NSString stringWithFormat:@"{ \"u\":\"%@\"%@%@ }", user, fb, props] value:0] build]];
        } @catch (NSException *e) {
            NSLog(@"Error: Blueye Hub Failed to track event");
        }
    }
}

+(void)trackItem:(NSString *)type {
    [HUB trackItem:type itemId:0 action:@"view"];
}

+(void)trackItem:(NSString *)type itemId:(id)itemId {
    [HUB trackItem:type itemId:itemId action:@"view"];
}

+(void)trackItem:(NSString *)type itemId:(id)itemId action:(NSString *)action {
    [HUB trackItem:type itemId:itemId action:action title:nil imgUrl:nil value:0];
}

+(void)trackItem:(NSString *)type itemId:(id)itemId action:(NSString *)action title:(NSString *)title imgUrl:(NSString *)imgUrl {
    [HUB trackItem:type itemId:itemId action:action title:title imgUrl:imgUrl value:0];
}

+(void)trackItem:(NSString *)type itemId:(id)itemId action:(NSString *)action value:(NSNumber *)value {
    [HUB trackItem:type itemId:itemId action:action title:nil imgUrl:nil value:value];
}

+(void)trackItem:(NSString *)type itemId:(id)itemId action:(NSString *)action title:(NSString *)title imgUrl:(NSString *)imgUrl value:(NSNumber *)value {
    if(GA_ID != nil) {
        @try {
            NSLog(@"Blueye Hub Event: %@", action);
            
            id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:GA_ID];
            tracker.allowIDFACollection = YES;

            NSString *user;
            
            if([[HUB sharedInstance] userId] != nil && [[HUB sharedInstance] userId] != NULL)
                user = [[HUB sharedInstance] userId];
            else
                user = @"0";
            
            NSString *fb = [[HUB sharedInstance] fbUser] != nil ? [NSString stringWithFormat:@", \"fb\":\"%@\"", [[[HUB sharedInstance] fbUser] objectForKey:@"id"]] : @"";
            NSString *t = title != nil ? [NSString stringWithFormat:@", \"t\":\"%@\"", title] : @"";
            NSString *img = imgUrl != nil ? [NSString stringWithFormat:@", \"img\":\"%@\"", imgUrl] : @"";
            
            //NSLog([NSString stringWithFormat:@"Tracking Label { \"u\":\"%@\", \"i\":\"%@\"%@%@%@ }", user, itemId, fb, t, img]);
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:type action:action label:[NSString stringWithFormat:@"{ \"u\":\"%@\", \"i\":\"%@\"%@%@%@ }", user, itemId, fb, t, img] value:value] build]];
        } @catch (NSException *e) {
            NSLog(@"Error: Blueye Hub Failed to track event");
        }
    }
}

+(void)setUserId:(id)userId { //static method, different than property setUserId happening below
    [[HUB sharedInstance] setUserId:[userId stringValue]];
}

- (void)callAPI:(NSString *)action keys:(NSArray *)keys values:(NSArray *)values {
    @try {
        rest = [[HUB sharedInstance] client];
        NSURL *clientUrl = [NSURL URLWithString:API_URL];
        
        NSMutableString *json = [[NSMutableString alloc] init];
        [json appendString:@"{"];
        
        NSUInteger len = values.count;
        
        for(int i = 0; i < len; i++) {
            if([values objectAtIndex:i] != nil)
                [json appendFormat:@"\"%@\":\"%@\",", [keys objectAtIndex:i], [values objectAtIndex:i]];
        }

        if ([json length] > 1)
            [json deleteCharactersInRange:NSMakeRange([json length] - 1, 1)];
        
        [json appendFormat:@"}"];
        
        NSString *appToken = [[HUB sharedInstance] token] != nil ? [[HUB sharedInstance] token] : @"";
        
        //NSLog(@"%@", json);
        keys = [NSArray arrayWithObjects:@"action", @"token", @"info", nil];
        values = [NSArray arrayWithObjects:[@"public." stringByAppendingString:action], appToken, json, nil];

        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjects:values forKeys:keys];

        [rest sendRequestTo:clientUrl usingVerb:@"GET" withParameters:parameters];
    } @catch (NSException *e) {} 
}

- (Client *)client {
	if (!rest)
	{
		rest= [[Client alloc] init];
		rest.asynchronous = YES;
		rest.delegate = self;
	}
	
	return rest;
}

- (void)client:(Client*)client didRetrieveData:(NSData *)data
{
    @try {
        NSMutableString* jsonStr = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
        if([jsonStr length]) {
            [jsonStr deleteCharactersInRange:NSMakeRange(0, 9)];

            //NSLog(@"%@", jsonStr);

            NSDictionary *json = [NSJSONSerialization JSONObjectWithData: [jsonStr dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error:nil];
            NSLog(@"%@", json);
        
            NSInteger success = (NSInteger) [json objectForKey:@"success"];
            
            if(success && !connected) {
                auth = [json objectForKey:@"data"];
                connected = true;
                
                [[HUB sharedInstance] setToken:[NSString stringWithFormat:@"%@", [auth objectForKey:@"token"]]];
                NSString *ga = [auth objectForKey:@"gaId"];
                
                if(ga != nil && ga.length > 0) {
                    GA_ID = ga;
                    
                    //intialize google analytics
                    [GAI sharedInstance].trackUncaughtExceptions = YES;
                    [GAI sharedInstance].dispatchInterval = 20;
                    //[[GAI sharedInstance].logger setLogLevel:kGAILogLevelVerbose];
                    
                    //id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:GA_ID];
                    //[tracker set:kGAIScreenName value:@"HUB_CONNECT"];
                    //[tracker send:[[GAIDictionaryBuilder createAppView]  build]];

                    //initialize FB user
                    if(fbUser == nil) {
                        [self openFacebookSession];
                    }
                }
            }
        }
    }
    @catch (NSException *e) {}
}

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen: {
                FBRequest *me = [FBRequest requestForMe];
                [me startWithCompletionHandler: ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *fbGraphUser, NSError *error) {
                    NSLog(@"FB User: %@ %@", [fbGraphUser objectForKey:@"id"], [fbGraphUser objectForKey:@"name"]);//, session.accessToken);
                    
                    if([fbGraphUser objectForKey:@"id"] != NULL)
                        fbUser = fbGraphUser;
                }];
            }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:

            break;
        default:
            break;
    }
    
    if (error) {
        /*UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];*/
    }
}

- (void)openFacebookSession
{
    [FBSession openActiveSessionWithReadPermissions:nil
                                       allowLoginUI:NO
                                  completionHandler:
     ^(FBSession *session,
       FBSessionState state, NSError *error) {
         [self sessionStateChanged:session state:state error:error];
     }];
}

@end
