//
//  LocationManager.m
//  PuristIt
//
//  Created by Ramakrishnan Naidu on 22/02/15.
//  Copyright (c) 2015 PuristSoft Corp. All rights reserved.
//

#import "LocationManager.h"
#import <MapKit/MKPlacemark.h>
#import "SynthesizeSingleton.h"
#import "DeviceUtility.h"

@interface LocationManager ()
{
	MKReverseGeocoder *myReverseGeocoder_;
	CLLocationManager *myLocationManager_;
	int locationServicesStarted_;
}

@property (nonatomic, retain) MKReverseGeocoder *myReverseGeocoder;
@property (nonatomic, retain) CLLocationManager *myLocationManager;
@property (nonatomic) int locationServicesStarted;

- (CLLocation *) getCurrentLocation;
- (void) setCurrentLocation:(double)longitude latitude:(double)latitude;
- (void) setCurrentLocationCountryISO:(NSString *)countryISO;

@end

@implementation LocationManager

SYNTHESIZE_SINGLETON_FOR_CLASS(LocationManager);

@synthesize myReverseGeocoder = myReverseGeocoder_;
@synthesize myLocationManager = myLocationManager_;
@synthesize locationServicesStarted = locationServicesStarted_;

- (void)cleanupMyReverseGeocoder
{
    PU_METHOD_LOG
    self.myReverseGeocoder.delegate = nil;
    self.myReverseGeocoder = nil;
}

- (void)cleanupMyLocationManager
{
    PU_METHOD_LOG
    self.myLocationManager.delegate = nil;
	self.myLocationManager = nil;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	PU_METHOD_LOG
	if(self.locationServicesStarted == 1)
	{
		self.locationServicesStarted = 2;
		[manager stopUpdatingLocation];
		//[self cleanupMyLocationManager];
		
		if(newLocation != nil)
		{
			double longitude = newLocation.coordinate.longitude;
			double latitude = newLocation.coordinate.latitude;
			
            [self setCurrentLocation:longitude latitude:latitude];
		}
        else
        {
            PU_LOG(@"Location Services couldnt get a GPS read");
        }
		
		[self cleanupMyReverseGeocoder];
		myReverseGeocoder_ = [[MKReverseGeocoder alloc] initWithCoordinate:newLocation.coordinate];
		self.myReverseGeocoder.delegate = self;
		[self.myReverseGeocoder start];
	}
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    PU_METHOD_LOG
    
    PU_LOG(@"CLLocationManager failed: %@"
                 , error.localizedFailureReason);
    
    if (error.code == kCLErrorDenied)
    {
        // User has denied us permission to access location service (probably via Settings while we were backgrounded).
        [manager stopUpdatingLocation];
        [self cleanupMyLocationManager];
    }
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error {
	PU_METHOD_LOG
	
	//[self cleanupMyReverseGeocoder];	
    PU_LOG(@"Geocode failed: %@", error.localizedFailureReason);
    
    self.locationServicesStarted = 0;
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark {
	
	PU_METHOD_LOG
	PU_LOG(@"Geocode win with result: %@, %@",placemark.country, placemark.countryCode);
    
	NSString *countryString = placemark.countryCode;
	if(countryString == nil)
		countryString = @"";
	
	if([countryString length] > 0)
	{
        [self setCurrentLocationCountryISO:countryString];
	}
    else
    {
        PU_LOG(@"Geocode Failed.");
    }
	
	[self cleanupMyReverseGeocoder];
    
    self.locationServicesStarted = 0;
}

- (void)startLocationServices
{
	PU_METHOD_LOG
	
	if(self.locationServicesStarted == 0)
	{
		self.locationServicesStarted = 1;
		
		[self cleanupMyLocationManager];
		myLocationManager_ = [[CLLocationManager alloc] init];
		
		if ([CLLocationManager locationServicesEnabled] != NO) //dont use this - it crashes on iOS3
        //if (self.myLocationManager.locationServicesEnabled != NO)
        {
			self.myLocationManager.delegate = self;
			self.myLocationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
			
			[self.myLocationManager startUpdatingLocation];
		} 
		else 
		{
			PU_LOG(@"Location Services not allowed, so we can't do anything.");
        }
	}
}

#define kGPSLongitude @"kGPSLongitude"
#define kGPSLatitude @"kGPSLatitude"
#define kGPSCountryISO @"kGPSCountryISO"

- (CLLocation *) getCurrentLocation
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSString *longitude = [[NSUserDefaults standardUserDefaults] objectForKey:kGPSLongitude];
    NSString *latitude = [[NSUserDefaults standardUserDefaults] objectForKey:kGPSLatitude];
    
    if([longitude length] > 0 && [latitude length] > 0)
    {
        //PU_LOG([NSString stringWithFormat:@"%@: getCurrentLocation: %@, %@", self, longitude, latitude]);
        return [[[CLLocation alloc] initWithLatitude:(CLLocationDegrees)[latitude doubleValue] longitude:(CLLocationDegrees)[longitude doubleValue]] autorelease];
    }
    
    return nil;
}

- (void) setCurrentLocation:(double)longitude latitude:(double)latitude
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f", longitude] forKey:kGPSLongitude];
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f", latitude] forKey:kGPSLatitude];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *) currentLocationLongitude
{
    PU_METHOD_LOG
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSString *longitude = [[NSUserDefaults standardUserDefaults] objectForKey:kGPSLongitude];
    
    if([longitude length])
        return longitude;
    
    return @"0.0000";
}

- (NSString *) currentLocationLatitude
{
    PU_METHOD_LOG
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSString *latitude = [[NSUserDefaults standardUserDefaults] objectForKey:kGPSLatitude];
    
    if([latitude length])
        return latitude;
    
    return @"0.0000";
}

- (NSString *) currentLocationCountryISO
{
    PU_METHOD_LOG
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSString *gpsCountryISOCode = [[NSUserDefaults standardUserDefaults] stringForKey:kGPSCountryISO];
    
    if(gpsCountryISOCode != nil)
        return gpsCountryISOCode;
    
    return @"";
}
           
- (void) setCurrentLocationCountryISO:(NSString *)countryISO
{
    [[NSUserDefaults standardUserDefaults] setObject:countryISO forKey:kGPSCountryISO];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end