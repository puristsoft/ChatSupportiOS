//
//  ChatManager.h
//  PuristIt
//
//  Created by Ramakrishnan Naidu on 17/01/15.
//  Copyright (c) 2015 PuristSoft Corp. All rights reserved.
//

typedef enum {
    kErrorNetworkUnavailable = 10,
    kNetworkSuccess
} APIResponseCode;

@interface ChatManager : NSObject

+ (ChatManager *) shared;

- (void) loadDefaultUserData;
- (void) loadUserData;
- (BOOL) isChatURLValid;
- (APIResponseCode) registrationAPI;
- (APIResponseCode) initializationAPI;

@end

