//
//  Address.h
//
//  AppDelegate.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "NSBaseObject.h"
#import "Declare.h"
@interface Address : NSBaseObject

@property (nonatomic, strong) NSString  * address;  // 地址
@property (nonatomic, assign) double    lat;        // 纬度
@property (nonatomic, assign) double    lng;        // 经度

- (NSString*)description;

#pragma DB

+ (Address*)AddressWithUUID:(int)uuid;
+ (void)deleteWithUID:(NSString*)uid;
- (void)insertDBWithUUID:(int)uuid withID:(NSString*)withID;

- (Location)location;
- (void)setLocation:(Location)loc;
@end
