//
//  AppDelegate.m
//  PuristIt
//
//  Created by Ramakrishnan Naidu on 17/01/15.
//  Copyright (c) 2015 PuristSoft Corp. All rights reserved.
//

#import "AppDelegate.h"
#import "ChatManager.h"
#import "LocationManager.h"
#import "TabBarManager.h"
#import "WindowManager.h"
#import "PushHandler.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    PU_METHOD_LOG
    
    // Override point for customization after application launch.
    UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    window.rootViewController = tabBarController;
    [[TabBarManager shared] addTabBarController:tabBarController];
    [tabBarController release];
    
    [window makeKeyAndVisible];
    
    [WindowManager shared].window = window;
    
    [window release];
    
    [[ChatManager shared] loadUserData];
    
    if(launchOptions != nil)
        [[PushHandler shared] setReceivedPushMessage:launchOptions];
    
    [[PushHandler shared] resetBadge];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    PU_METHOD_LOG
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    PU_METHOD_LOG
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    PU_METHOD_LOG

    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [[PushHandler shared] resetBadge];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    PU_METHOD_LOG
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [[LocationManager shared] startLocationServices];
    
    [[TabBarManager shared] loadAllViewControllers];
    
    if([[PushHandler shared] isPushMessageReceived])
        [[PushHandler shared] processReceivedNotification:FALSE];
    
    [[PushHandler shared] resetBadge];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    PU_METHOD_LOG
    
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken
{
    PU_METHOD_LOG
    
    //PU_DEBUG_ALERT(@"didRegisterForRemoteNotificationsWithDeviceToken");
                   
    [[PushHandler shared] didRegisterForRemoteNotificationsWithDeviceToken:devToken];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    PU_METHOD_LOG
    
    //PU_DEBUG_ALERT(@"didRegisterUserNotificationSettings");
    
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    PU_METHOD_LOG
    
    //PU_DEBUG_ALERT(@"handleActionWithIdentifier");
    
    if ([identifier isEqualToString:@"declineAction"])
    {
    }
    else if ([identifier isEqualToString:@"answerAction"])
    {
    }
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
    PU_METHOD_LOG
    
    //PU_DEBUG_ALERT(@"didFailToRegisterForRemoteNotificationsWithError");
    
    PU_LOG(@"Error in registration. Error: %@", err);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    PU_METHOD_LOG
    [[PushHandler shared] resetBadge];
    
    [[PushHandler shared] setReceivedPushMessage:userInfo];
    [[PushHandler shared] processReceivedNotification:TRUE];
}

#define OPEN_URL @"OPEN_URL"

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    PU_METHOD_LOG
    
    /*
     Different ways to open app
     puristit://
     puristit://some/path/here
     puristit://?param1=1&amp;param2=2
     puristit://some/path/here?param1=1&amp;param2=2
     */
    [[NSNotificationCenter defaultCenter] postNotificationName:OPEN_URL object:url];
    
    return YES;
}


@end
