//
//  KLoadingView.h
//  iMRadioII
//
//  Created by 微慧Sam团队 on 4/19/13.
//  Copyright (c) 2013 Kiwaro.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KLoadingView : UIView {
    BOOL animated;
    UIActivityIndicatorView * indicatorView;
}
@property (nonatomic, strong) NSString * text;

+ (KLoadingView*)showText:(NSString*)txt animated:(BOOL)ani;
- (id)initWithText:(NSString*)txt animated:(BOOL)ani;
- (void)show;
- (void)hide;

@end
