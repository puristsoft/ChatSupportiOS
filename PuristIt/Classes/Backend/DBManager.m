//
//  DBManager.m
//  PuristIt
//
//  Created by Ramakrishnan Naidu on 17/01/15.
//  Copyright (c) 2015 PuristSoft Corp. All rights reserved.
//

#import "DBManager.h"

@interface DBManager ()

@end

#define kRegistrationStatus @"kRegistrationStatus"
#define kInitializationStatus @"kInitializationStatus"
#define kUsername @"kUsername"
#define kFullyQualifiedUsername @"kFullyQualifiedUsername"
#define kPassword @"kPassword"
#define kDomain @"kDomain"
#define kAPIKey @"kAPIKey"
#define kChatURL @"kChatURL"
#define kChatURLExpirationTimestamp @"kChatURLExpirationTimestamp"

@implementation DBManager


+ (BOOL) getRegistrationStatus
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    return [[NSUserDefaults standardUserDefaults] boolForKey:kRegistrationStatus];
}

+ (void) setRegistrationStatus:(BOOL)flag
{
    [[NSUserDefaults standardUserDefaults] setBool:flag forKey:kRegistrationStatus];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL) getInitializationStatus
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    return [[NSUserDefaults standardUserDefaults] boolForKey:kInitializationStatus];
}

+ (void) setInitializationStatus:(BOOL)flag
{
    [[NSUserDefaults standardUserDefaults] setBool:flag forKey:kInitializationStatus];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *) getUsername
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    return [[NSUserDefaults standardUserDefaults] stringForKey:kUsername];
}

+ (void) setUsername:(NSString *)username
{
    [[NSUserDefaults standardUserDefaults] setObject:username forKey:kUsername];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *) getFullyQualifiedUsername
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    return [[NSUserDefaults standardUserDefaults] stringForKey:kFullyQualifiedUsername];
}

+ (void) setFullyQualifiedUsername:(NSString *)fullyqualifiedusername
{
    [[NSUserDefaults standardUserDefaults] setObject:fullyqualifiedusername forKey:kFullyQualifiedUsername];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *) getPassword
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    return [[NSUserDefaults standardUserDefaults] stringForKey:kPassword];
}

+ (void) setPassword:(NSString *)password
{
    [[NSUserDefaults standardUserDefaults] setObject:password forKey:kPassword];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *) getDomain
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    return [[NSUserDefaults standardUserDefaults] stringForKey:kDomain];
}

+ (void) setDomain:(NSString *)domain
{
    [[NSUserDefaults standardUserDefaults] setObject:domain forKey:kDomain];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *) getAPIKey
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    return [[NSUserDefaults standardUserDefaults] stringForKey:kAPIKey];
}

+ (void) setAPIKey:(NSString *)apikey
{
    [[NSUserDefaults standardUserDefaults] setObject:apikey forKey:kAPIKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *) getChatURL
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    return [[NSUserDefaults standardUserDefaults] stringForKey:kChatURL];
}

+ (void) setChatURL:(NSString *)chaturl
{
    [[NSUserDefaults standardUserDefaults] setObject:chaturl forKey:kChatURL];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDate *) getChatURLExpirationTimestamp
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    return [[NSUserDefaults standardUserDefaults] objectForKey:kChatURLExpirationTimestamp];
}

+ (void) setChatURLExpirationTimestamp:(NSDate *)chaturlexpirationtimestamp
{
    [[NSUserDefaults standardUserDefaults] setObject:chaturlexpirationtimestamp forKey:kChatURLExpirationTimestamp];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
