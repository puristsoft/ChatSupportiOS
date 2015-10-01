//
//  DeviceUtility.h
//  PuristIt
//
//  Created by Ramakrishnan Naidu on 22/02/15.
//  Copyright (c) 2015 PuristSoft Corp. All rights reserved.
//

@interface DeviceUtility: NSObject 
{
}

+ (NSString *) getOSVersion;
+ (NSString *) getDeviceModel;
+ (NSString *) getDeviceClass;
+ (NSString *) getLanguage;
+ (float) getScreenResolution;
+ (BOOL) doesHaveTransparentStatusBar;

@end
