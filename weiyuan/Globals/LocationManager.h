//
//  LocationManager.h
//
//  AppDelegate.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#define LocationUpdateNotification @"LocationUpdateNotification"
#define GeoInitNotification @"GeoInitNotification"

#define CoordinateNotification @"CoordinateUpdateNotification"

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

typedef enum {
    forLocationError = 0,
    forLocationSuccess,
    forLocationFinished,
} LocationType;

typedef void(^LocationUpdate)(LocationType locationType);
@interface LocationManager : NSObject

@property (nonatomic, strong) CLLocationManager * locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign) BOOL located;
@property (nonatomic, assign) BOOL geocodeGot;
@property (nonatomic, strong) NSString * locationText;
@property (nonatomic, strong) LocationUpdate block;
@property (nonatomic, assign) BOOL alwaysUpdateLocation;

+ (LocationManager*)sharedManager;
+ (void)setDealloc;
+ (CLLocationCoordinate2D)getBaiduFromGPS:(CLLocationCoordinate2D )locationCoord;
- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;

@end
