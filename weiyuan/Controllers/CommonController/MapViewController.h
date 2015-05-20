//
//  MapViewController.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "BaseTableViewController.h"
#import "BMapKit.h"
#import "Declare.h"

@class MapViewController;

@protocol MapViewDelegate <NSObject>
@optional
- (void)mapViewControllerSetLocation:(Location)loc;
- (void)mapViewControllerSetLocation:(Location)loc content:(NSString*)con;
- (NSString*)getCurrentSetLocationString;
- (void)mapViewControllerSetPoiInfo:(BMKPoiInfo*)selectBMKPoiInfo;
@end

@interface MapViewController : BaseTableViewController

@property (nonatomic, strong) NSString                  * pointAnnotationTitle;
@property (nonatomic, assign) BOOL                      readOnly;
@property (nonatomic, assign) Location                  location;
@property (nonatomic, strong) BMKPointAnnotation        * pointAnnotation;
@property (nonatomic, strong) NSString                  * city;
@property (nonatomic, strong) BMKPoiInfo                * currectPoiInfo;
@property (nonatomic, assign) id <MapViewDelegate> delegate;

- (id)initWithDelegate:(id <MapViewDelegate>)del;
@end
