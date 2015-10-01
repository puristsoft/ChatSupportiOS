//
//  ChatManager.m
//  PuristIt
//
//  Created by Ramakrishnan Naidu on 17/01/15.
//  Copyright (c) 2015 PuristSoft Corp. All rights reserved.
//

#import "ChatManager.h"
#import "SynthesizeSingleton.h"
#import "DBManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "TBXML.h"
#import "DeviceUtility.h"
#import "LocationManager.h"
#import "PushHandler.h"

@interface ChatManager ()

@property (assign) long httpResponseCode;
@property (nonatomic, retain) NSString *httpResponseData;

@end

@implementation ChatManager

SYNTHESIZE_SINGLETON_FOR_CLASS(ChatManager);

- (void) loadDefaultUserData
{
    PU_METHOD_LOG
    
    [DBManager setUsername:@""];
    [DBManager setPassword:@""];
    [DBManager setAPIKey:@"<INSERT YOUR KEY HERE> -- example: eJ6R7R4Vabcdefghijklm2gyMV3IC2"];
    [DBManager setDomain:@"<INSERT YOUR DOMAIN HERE> -- example: puristsoft.com"];
    [DBManager setChatURL:@""];
    [DBManager setChatURLExpirationTimestamp:0];
    [DBManager setRegistrationStatus:FALSE];
    [DBManager setInitializationStatus:FALSE];
}

- (void) loadUserData
{
    PU_METHOD_LOG
    
    if(![[DBManager getUsername] length])
    {
        [self loadDefaultUserData];
    }
    else
    {
        //Initialized before. Check if chat url expired
        [self isChatURLValid];
    }
    
    [[PushHandler shared] registerDevice];
}

- (BOOL) isChatURLValid
{
    PU_METHOD_LOG
    
    if([DBManager getInitializationStatus])
    {
        NSDate *chaturlexpirationtimestamp = [DBManager getChatURLExpirationTimestamp];
        if([chaturlexpirationtimestamp timeIntervalSinceNow] > 0)
        {
            return TRUE;
        }
    }
    
    [DBManager setInitializationStatus:FALSE];
    [DBManager setChatURL:@""];
    [DBManager setChatURLExpirationTimestamp:0];
    
    return FALSE;
}

#define NETWORK_TIMEOUT_IN_SECONDS 30

- (APIResponseCode) registrationAPI
{
    PU_METHOD_LOG
    
    [DBManager setRegistrationStatus:FALSE];
    [DBManager setInitializationStatus:FALSE];
    [DBManager setChatURL:@""];
    [DBManager setChatURLExpirationTimestamp:0];
    
    self.httpResponseCode = -100000;

    /*
     curl ­i ­u 38500bd28a404bf99b14c45422b77171: \
     ­d 'username=jdoe&password=pass1234&name=John+Doe&loc_lat=48.858222&loc_long=2.294500' \ https://api.puristit.com/register.xml
     */
    
    NSDictionary *parameters = @{@"username": [DBManager getUsername], @"password": [DBManager getPassword], @"name": @"Nobody", @"loc_lat": [[LocationManager shared] currentLocationLatitude], @"loc_long": [[LocationManager shared] currentLocationLongitude]};
    
    PU_LOG(@"parameters: %@", parameters);
    
    APIResponseCode apiResponseCode = [self networkCall:@"https://api.puristit.com/register.xml"
                                             parameters:parameters
                                               authUser:[DBManager getAPIKey]
                                           authPassword:@""];
    
    if(apiResponseCode == kNetworkSuccess)
    {
        TBXML *sourceXML = [[TBXML alloc] initWithXMLString:self.httpResponseData error:nil];
        TBXMLElement *rootElement = sourceXML.rootXMLElement;
        TBXMLElement *usernameElement = [TBXML childElementNamed:@"p_username" parentElement:rootElement];
        NSString *fullyqualifiedusername = [TBXML textForElement:usernameElement];
        NSLog(@"------> %@", fullyqualifiedusername);
        
        [DBManager setFullyQualifiedUsername:fullyqualifiedusername];
        [DBManager setRegistrationStatus:TRUE];
    }
    
    return apiResponseCode;
}
 
- (APIResponseCode) initializationAPI
{
    PU_METHOD_LOG
    
    [DBManager setInitializationStatus:FALSE];
    [DBManager setChatURL:@""];
    [DBManager setChatURLExpirationTimestamp:0];
    
    self.httpResponseCode = -100000;
    
    /*
     curl ­i ­u 38500bd28a404bf99b14c45422b77171:pass1234 \
     ­d 'p_username=jdoe%40mycompany.puristit.com&platform=Android&validity=168' ­d 'loc_lat=48.858222&loc_long=2.294500&language=es' \ https://api.puristit.com/initialize.xml
     */
    
    int chatURLValidityInHours = 720;
    
    NSDictionary *parameters = @{@"p_username": [DBManager getFullyQualifiedUsername], @"platform": @"iOS" /*[DeviceUtility getDeviceClass]*/, @"validity": [NSString stringWithFormat:@"%d", chatURLValidityInHours], @"loc_lat": [[LocationManager shared] currentLocationLatitude], @"loc_long": [[LocationManager shared] currentLocationLongitude], @"language": [DeviceUtility getLanguage]};
    
    PU_LOG(@"parameters: %@", parameters);
    
    NSDate *chatURLExpirationTimestamp = [[NSDate date] dateByAddingTimeInterval:chatURLValidityInHours*3600];
    
    APIResponseCode apiResponseCode = [self networkCall:@"https://api.puristit.com/initialize.xml"
                                             parameters:parameters
                                               authUser:[DBManager getAPIKey]
                                           authPassword:[DBManager getPassword]];
    if(apiResponseCode == kNetworkSuccess)
    {
        TBXML *sourceXML = [[TBXML alloc] initWithXMLString:self.httpResponseData error:nil];
        TBXMLElement *rootElement = sourceXML.rootXMLElement;
        TBXMLElement *chaturlElement = [TBXML childElementNamed:@"chat_url" parentElement:rootElement];
        NSString *chatURL = [TBXML textForElement:chaturlElement];
        NSLog(@"------> %@", chatURL);
        
        [DBManager setChatURL:chatURL];
        [DBManager setChatURLExpirationTimestamp:chatURLExpirationTimestamp];
        [DBManager setInitializationStatus:TRUE];
    }
    
    return apiResponseCode;
}


- (APIResponseCode) networkCall:(NSString *)url parameters:(NSDictionary *)parameters authUser:(NSString *)authUser authPassword:(NSString *)authPassword
{
    PU_METHOD_LOG
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:authUser
                                                              password:authPassword];
    [manager.requestSerializer setValue:@"application/xml" forHTTPHeaderField:@"Accept"];
    //[manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/xml", nil];
    manager.responseSerializer = responseSerializer;
    
    [manager POST:url
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"responseObject: %@", responseObject);
              
              NSData *data = (NSData *)responseObject;
              NSString *fetchedXML = [NSString stringWithCString:[data bytes] encoding:NSUTF8StringEncoding];
              NSLog(@"responseString: %@", fetchedXML);
              
              self.httpResponseCode = operation.response.statusCode;
              self.httpResponseData = fetchedXML;
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %d, %@", (int) operation.response.statusCode, error);
              self.httpResponseCode = operation.response.statusCode;
              self.httpResponseData = nil;
          }];
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:NETWORK_TIMEOUT_IN_SECONDS];
    while(self.httpResponseCode == -100000)
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:loopUntil];
    }
    
    if(!self.httpResponseData)
    {
        NSLog(@"API network call timed out");
        return kErrorNetworkUnavailable;
    }
    
    if(self.httpResponseCode == 200 ||
       self.httpResponseCode == 201)
    {
        return kNetworkSuccess;
    }
    
    return kErrorNetworkUnavailable;
}

@end
