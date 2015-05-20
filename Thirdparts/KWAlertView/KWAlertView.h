//
//  KWAlertView.h
//  huazhuangpin
//
//  Created by Kiwaro on 14-11-20.
//  Copyright (c) 2014年 Kiwaro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextInput.h"
#import <CoreLocation/CoreLocation.h>

typedef void(^KWAlertView_Block)(NSString * content);
@class KWAlertView, KTextField;

@protocol KWAlertViewDelegate <NSObject>

@optional
- (void)kwAlertView:(KWAlertView*)sender didDismissWithButtonIndex:(NSInteger)index;

@end



NS_CLASS_AVAILABLE_IOS(2_0) @interface KWAlertView : UIView

@property (nonatomic, strong) KTextField * field;
@property (nonatomic, assign) id <KWAlertViewDelegate> delegate;
@property (nonatomic, assign) int index;
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSIndexPath * indexPath;
@property (nonatomic, strong) UIButton * cancelButton;
@property (nonatomic, strong) UIButton * otherButton;

#pragma mark - Quick Methods

+ (void)showAlertFieldWithTitle:(NSString*)title delegate:(id)delegate tag:(int)tag;
+ (void)showAlert:(NSString*)msg;
- (id)initWithMsg:(NSString*)msg cancelButtonTitle:(NSString *)canBtn;
- (id)initAlertFieldWithTitle:(NSString*)title delegate:(id)_delegate tag:(int)_ctag;
- (void)dismissWithButtonIndex:(NSInteger)idx;
#pragma mark - Public Methods

- (id)initWithTitle:(NSString*)title
            message:(NSString*)message
           delegate:(id)_delegate
  cancelButtonTitle:(NSString*)cancelButtonTitle
   otherButtonTitle:(NSString*)otherButtonTitle;

- (void)show;

@end
