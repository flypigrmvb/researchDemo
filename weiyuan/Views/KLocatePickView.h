//
//  KLocatePickView.h
//  SpartaEducation
//
//  Created by kiwaro on 14-3-5.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KLocation;

@interface KLocatePickView : UIActionSheet

@property (nonatomic, strong) KLocation *locate;
+ (NSString *)convertProvincesCode:(int)code;
+ (NSString *)convertCitiesCode:(int)code;

- (id)initWithTitle:(NSString *)title delegate:(id)delegate;
- (void)showInView:(UIView *)view;

@end
