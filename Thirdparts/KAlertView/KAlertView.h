//
//  KAlertView.h
//  微慧Sam团队
//
//  Created by 微慧Sam团队 on 3/4/13.
//  Copyright (c) 2013 Kiwaro.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum KAlertType {
    KAlertTypeNone = 0,
    KAlertTypeStar = 1,
    KAlertTypeCheck = 2,
    KAlertTypeError = 3,
}KAlertType;

@interface KAlertView : UIView {
    KAlertType type;
    NSTimeInterval life;
    BOOL animated;
}
@property (nonatomic, strong) NSString * text;
@property (nonatomic, strong) UIImage * image;

+ (void)showType:(KAlertType)ty text:(NSString*)txt for:(NSTimeInterval)tm animated:(BOOL)ani;

@end
