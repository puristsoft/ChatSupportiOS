//
//  PushHandler.h
//  PuristIt
//
//  Created by Ramakrishnan Naidu on 17/01/15.
//  Copyright (c) 2015 PuristSoft Corp. All rights reserved.
//

typedef enum {
    kPushRegistered = 10,
    kPushNotEnabled,
    kPushNotYetRegistered
} PushRegistrationStatus;

@interface PushHandler : NSObject 
{
}

+ (PushHandler *) shared;
- (void) setReceivedPushMessage:(NSDictionary *)pushMsg;
- (BOOL) isPushMessageReceived;
- (void) registerDevice;
- (void) didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken;
- (void) processReceivedNotification:(BOOL)receivedInApp;
- (void) resetBadge;

- (PushRegistrationStatus) getPushRegistrationStatus;
- (NSString *) getPushID;

@end
