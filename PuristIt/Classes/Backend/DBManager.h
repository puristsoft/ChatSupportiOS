//
//  DBManager.h
//  PuristIt
//
//  Created by Ramakrishnan Naidu on 17/01/15.
//  Copyright (c) 2015 PuristSoft Corp. All rights reserved.
//

@interface DBManager : NSObject

+ (void) setRegistrationStatus:(BOOL)flag;
+ (void) setInitializationStatus:(BOOL)flag;
+ (BOOL) getRegistrationStatus;
+ (BOOL) getInitializationStatus;
+ (NSString *) getUsername;
+ (void) setUsername:(NSString *)username;
+ (NSString *) getFullyQualifiedUsername;
+ (void) setFullyQualifiedUsername:(NSString *)fullyqualifiedusername;
+ (NSString *) getPassword;
+ (void) setPassword:(NSString *)password;
+ (NSString *) getDomain;
+ (void) setDomain:(NSString *)domain;
+ (NSString *) getAPIKey;
+ (void) setAPIKey:(NSString *)apikey;
+ (NSString *) getChatURL;
+ (void) setChatURL:(NSString *)chaturl;
+ (NSDate *) getChatURLExpirationTimestamp;
+ (void) setChatURLExpirationTimestamp:(NSDate *)chaturlexpirationtimestamp;

@end

