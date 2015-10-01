//
//  PushHandler.m
//  PuristIt
//
//  Created by Ramakrishnan Naidu on 17/01/15.
//  Copyright (c) 2015 PuristSoft Corp. All rights reserved.
//

#import "PushHandler.h"
#import "SynthesizeSingleton.h"
#import "TabBarManager.h"
#import "MainViewController.h"

@interface PushHandler ()
{
    NSDictionary *receivedPushMessage;
}

@end

@implementation PushHandler

SYNTHESIZE_SINGLETON_FOR_CLASS(PushHandler);

- (void) cleanupReceivedPushMessage
{
	PU_METHOD_LOG
	if(receivedPushMessage != nil)
	{
		[receivedPushMessage release];
		receivedPushMessage = nil;
		NSCParameterAssert(receivedPushMessage == nil);
	}
}

- (void) setReceivedPushMessage:(NSDictionary *)pushMsg
{
	PU_METHOD_LOG
	[self cleanupReceivedPushMessage];
	
	receivedPushMessage = [[NSDictionary alloc] initWithDictionary:pushMsg];
	NSCParameterAssert(receivedPushMessage != nil);
}

- (BOOL) isPushMessageReceived
{
	PU_METHOD_LOG
	if(receivedPushMessage != nil)
		return TRUE;
	
	return FALSE;
}

- (BOOL)isPushDisabled
{
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        //PU_DEBUG_ALERT(@"isPushDisabled (a): %d", (([[UIApplication sharedApplication] isRegisteredForRemoteNotifications] == 0)));
        if ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications] == 0)
            return TRUE;
    }
    else
    {
        //PU_DEBUG_ALERT(@"isPushDisabled (b): %d", ([[UIApplication sharedApplication] enabledRemoteNotificationTypes] == 0));
        if ([[UIApplication sharedApplication] enabledRemoteNotificationTypes] == 0)
            return TRUE;
    }
    
    return FALSE;
}

- (void)registerDevice
{
	PU_METHOD_LOG
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        //PU_DEBUG_ALERT(@"registerDevice (a)");
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
            
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        //PU_DEBUG_ALERT(@"registerDevice (b)");
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
             (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
}

- (void) didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken
{
	PU_METHOD_LOG
	
	NSString *deviceToken = [[[[devToken description] stringByReplacingOccurrencesOfString:@"<"withString:@""] 
							  stringByReplacingOccurrencesOfString:@">" withString:@""] 
							 stringByReplacingOccurrencesOfString: @" " withString: @""];
	PU_LOG(@"Device Token: %@", deviceToken);
	
    //PU_DEBUG_ALERT(@"%@", deviceToken);
    
	if ([self isPushDisabled]) 
	{
        PU_LOG(@"Notifications are disabled for this application.");
		
        [self setPushRegistrationStatus:kPushNotEnabled];
	}
    else
    {
        [self setPushID:deviceToken];
        [self setPushRegistrationStatus:kPushRegistered];
    }
}

- (NSString *)getTextComponentOfPush
{
    PU_METHOD_LOG
    if(receivedPushMessage!=nil)
    {
        NSDictionary *apsDictionary = [receivedPushMessage objectForKey:@"aps"];
        if(apsDictionary != nil)
        {
            NSObject *messageObject = [apsDictionary objectForKey:@"alert"];
            if([messageObject isKindOfClass:[NSString class]])
            {
                NSString *message = (NSString *)messageObject;
                if(message != nil && [message length] != 0)
                {
                    return message;
                }
            }
        }
    }
    
    return nil;
}

- (void)processReceivedNotification:(BOOL)receivedInApp
{
	PU_METHOD_LOG
	
    if(receivedPushMessage!=nil)
    {
        PU_LOG(@"Received message: %@", receivedPushMessage);
        //PU_DEBUG_ALERT(@"%@", receivedPushMessage);
        
        /*
         DIFFERENCE IN MESSAGE FORMAT WHEN RECEIVED IN APP vs. WHEN CLOSED
         CLOSED: {"": {"aps": {}}}
         INAPP: {"aps": {}}
         */
        if([receivedPushMessage objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"] != nil)
        {
            NSDictionary *receivedPushMessageTemp = [[NSDictionary alloc] initWithDictionary:[receivedPushMessage objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"]];
            [receivedPushMessage release];
            receivedPushMessage = [[NSDictionary alloc] initWithDictionary:receivedPushMessageTemp];
            [receivedPushMessageTemp release];
        }
        
        /*
         {"aps": {"alert": "xxx"}, "pcs":"chat", "pcs_room":"sales"}
         */
        
        NSString *pcsObject = [receivedPushMessage objectForKey:@"pcs"];
        //PU_DEBUG_ALERT(@"%@", pcsObject);
        if([pcsObject length] && [pcsObject isEqualToString:@"chat"])
        {
            NSString *pcsroomObject = [receivedPushMessage objectForKey:@"pcs_room"];
            //PU_DEBUG_ALERT(@"%@", pcsroomObject);
            if([pcsroomObject length])
            {
                NSString *message = [self getTextComponentOfPush];
                if([message length])
                {
                    if(receivedInApp)
                    {
                        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"PuristIt"
                                                                         message:message
                                                                        delegate:self
                                                               cancelButtonTitle:@"OK"
                                                               otherButtonTitles:nil] autorelease];
                        [alert show];
                    }
                }
                
                [[[TabBarManager shared] mainViewController] showChatUrlWithRoom:pcsroomObject
                                                                        roomlist:FALSE
                                                                          header:FALSE
                                                                         bgcolor:nil
                                                                         fgcolor:nil
                                                                     headercolor:nil];
                
                [self cleanupReceivedPushMessage];
                return;
            }
        }
            
        NSString *message = [self getTextComponentOfPush];
        if([message length])
        {
            if(receivedInApp)
            {
                UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"PuristIt"
                                                                 message:message
                                                                delegate:self
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil] autorelease];
                [alert show];
            }
        }
        
        [self cleanupReceivedPushMessage];
    }
}

- (void) resetBadge
{
    PU_METHOD_LOG
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

#define kPushRegistrationStatus @"kPushRegistrationStatus"
#define kPushID @"kPushID"

- (PushRegistrationStatus) getPushRegistrationStatus
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSString *pushStatus = [[NSUserDefaults standardUserDefaults] stringForKey:kPushRegistrationStatus];
    if(![pushStatus length])
        return kPushNotYetRegistered;
    
    return [pushStatus intValue];
}

- (void) setPushRegistrationStatus:(PushRegistrationStatus)pushregistrationstatus
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", pushregistrationstatus] forKey:kPushRegistrationStatus];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *) getPushID
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    return [[NSUserDefaults standardUserDefaults] stringForKey:kPushID];
}

- (void) setPushID:(NSString *)pushid
{
    [[NSUserDefaults standardUserDefaults] setObject:pushid forKey:kPushID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end