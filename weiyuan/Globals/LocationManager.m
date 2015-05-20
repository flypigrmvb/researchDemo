//
//  LocationManager.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#define SetDefaultLocation [self setLocation:30.679943 lng:104.067923]

#import "LocationManager.h"
#import "BMapKit.h"
#import "GTMBase64.h"

static LocationManager * sharedLocationManager = nil;

@interface LocationManager () <CLLocationManagerDelegate>
@property (nonatomic, retain) CLGeocoder * geocoder;
@end

@implementation LocationManager
@synthesize locationManager, coordinate, located, geocodeGot, locationText, alwaysUpdateLocation;
@synthesize geocoder;
@synthesize block;

+ (LocationManager*)sharedManager {
    if (sharedLocationManager == nil) {
        sharedLocationManager = [[LocationManager alloc] init];
    }
    return sharedLocationManager;
}

+ (void)setDealloc {
    [sharedLocationManager setBlock:nil];
    [sharedLocationManager stopUpdatingLocation];
    sharedLocationManager = nil;
}

- (id)init {
    if (self = [super init]) {
        self.locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = 10.0f;
        located = NO;
    }
    return self;
}

- (void)dealloc {
    [locationManager stopUpdatingLocation];
    self.locationManager = nil;
    self.locationText = nil;
    self.geocoder = nil;
}

#pragma mark - Setters
- (void)setLocationText:(NSString *)text {
    Release(locationText);
    locationText = text;
    [[NSNotificationCenter defaultCenter] postNotificationName:LocationUpdateNotification object:self];
}

#pragma mark - Public
- (void)startUpdatingLocation {
    if ([CLLocationManager locationServicesEnabled]) {
        [locationManager startUpdatingLocation];
    } else {
        alwaysUpdateLocation = NO;
        if (coordinate.latitude == 0 && coordinate.longitude == 0) {
            SetDefaultLocation;
        }
        [self showAlertMessage:@"无法定位，请在设置中为APP开启定位权限。"];
    }
}

- (void)stopUpdatingLocation {
    alwaysUpdateLocation = NO;
    [locationManager stopUpdatingLocation];
    [geocoder cancelGeocode];
}

- (void)showAlertMessage:(NSString*)msg {
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:String(@"ok") otherButtonTitles:nil, nil];
    [alertView show];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self locationManagerUpdateLocation:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation * newLocation = [locations lastObject];
    [self locationManagerUpdateLocation:newLocation];
}

- (void)locationManagerUpdateLocation:(CLLocation*)newLocation {
    NSDate * newLocDate = newLocation.timestamp;
    NSTimeInterval interval = [newLocDate timeIntervalSinceNow];
    if (abs(interval) < 5) {
        CLLocationCoordinate2D coord = newLocation.coordinate;
        if (coord.latitude == 0 && coord.longitude == 0) {
            SetDefaultLocation;
            goto out;
        }
        //should get location string
        located = YES;
        [self setLocation:coord.latitude
                      lng:coord.longitude];
        if (block) {
            block(forLocationFinished);
        }
        if (alwaysUpdateLocation) {
            [[NSNotificationCenter defaultCenter] postNotificationName:LocationUpdateNotification object:self];
            return;
        }
        out:
        [locationManager stopUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    SetDefaultLocation;
    if (block) {
        block(forLocationError);
    }
}

#pragma mark - Private
+ (CLLocationCoordinate2D)getBaiduFromGPS:(CLLocationCoordinate2D )locationCoord {
    NSDictionary * baidudict = BMKConvertBaiduCoorFrom(CLLocationCoordinate2DMake(locationCoord.latitude, locationCoord.longitude), BMK_COORDTYPE_GPS);
    NSString * xbase64 =[baidudict objectForKey:@"x"];
    NSString * ybase64 = [baidudict objectForKey:@"y"];
    NSData * xdata = [GTMBase64 decodeString:xbase64];
    NSData * ydata = [GTMBase64 decodeString:ybase64];
    NSString * xstr = [[NSString alloc] initWithData:xdata encoding:NSUTF8StringEncoding];
    NSString * ystr = [[NSString alloc] initWithData:ydata encoding:NSUTF8StringEncoding];
    CLLocationCoordinate2D result;
    result.latitude = [ystr floatValue];
    result.longitude = [xstr floatValue];
    return result;
}

- (void)setLocation:(double)lat lng:(double)lng {
    self.coordinate = [LocationManager getBaiduFromGPS:CLLocationCoordinate2DMake(lat, lng)];
    CLLocation * loc = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
    self.geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:loc completionHandler:^(NSArray * placemarks, NSError * error) {
        geocodeGot = YES;
        if (!self.locationText.hasValue) {
            if (error != nil) {
                [LocationManager sharedManager].locationText = @"未知位置";
                DLog(@"reverse Geocode error: %@", [error localizedDescription]);
            }
            if (placemarks.count > 0) {
                CLPlacemark * place = [placemarks lastObject];
                NSMutableString * str = [NSMutableString stringWithFormat:@"%@", place.locality];
                if (place.thoroughfare.hasValue) [str appendFormat:@" %@", place.thoroughfare];
                if (place.name.hasValue) [str appendFormat:@" %@", place.name];
                self.locationText = place.locality;
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:GeoInitNotification object:nil];
    }];
}

@end
