//
//  DeviceUtility.m
//  PuristIt
//
//  Created by Ramakrishnan Naidu on 22/02/15.
//  Copyright (c) 2015 PuristSoft Corp. All rights reserved.
//

#import "DeviceUtility.h"
#import <sys/utsname.h>

@implementation DeviceUtility

+ (NSString *) getOSVersion
{
	return [UIDevice currentDevice].systemVersion;
}

+ (NSString *) getDeviceModel
{
	struct utsname systemInfo;
	uname(&systemInfo);
		
	return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

+ (NSString *) getDeviceClass
{
	NSString *deviceClass = [UIDevice currentDevice].model;
	if(deviceClass == nil)
		deviceClass = @"";
	
	return deviceClass;
}

+ (NSString *) getLanguage
{
	//NSString *lang = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode]; //this give's the region's language
	NSString *lang = [[NSLocale preferredLanguages] objectAtIndex:0]; // this correctly give's the device's current language
	
	if(![lang length])
		lang = @"en";
	
	return lang;
}

+ (float) getScreenResolution
{
    float screenResolution = [[UIScreen mainScreen] respondsToSelector:@selector(scale)] ? 2.0f : 1.0f;
	return screenResolution;
}

+ (BOOL) doesHaveTransparentStatusBar
{
    if([[DeviceUtility getOSVersion] floatValue] < 7.0)
		return FALSE;
	
	return TRUE;
}

@end