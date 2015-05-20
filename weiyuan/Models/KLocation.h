//
//  KLocation.h
//  SpartaEducation
//
//  Created by kiwaro on 14-3-5.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KLocation : NSObject

@property (assign, nonatomic) NSString *state;
@property (assign, nonatomic) NSString *city;
@property (nonatomic) int stateCode;
@property (nonatomic) int cityCode;
@end
