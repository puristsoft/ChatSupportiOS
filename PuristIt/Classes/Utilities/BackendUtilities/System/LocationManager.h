//
//  LocationManager.h
//  PuristIt
//
//  Created by Ramakrishnan Naidu on 22/02/15.
//  Copyright (c) 2015 PuristSoft Corp. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MKReverseGeocoder.h>

@interface LocationManager : NSObject <MKReverseGeocoderDelegate, CLLocationManagerDelegate>

+ (LocationManager *)shared;

- (NSString *) currentLocationCountryISOCode;
- (NSString *) currentLocationLongitude;
- (NSString *) currentLocationLatitude;
- (void) startLocationServices;

@end
