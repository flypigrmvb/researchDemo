//
//  KAlertView.m
//  微慧Sam团队
//
//  Created by 微慧Sam团队 on 3/4/13.
//  Copyright (c) 2013 Kiwaro.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "KAlertView.h"

#define KAlertTWidth 100
#define KAlertTag 6363

@implementation KAlertView
@synthesize text, image;

+ (void)showType:(KAlertType)ty text:(NSString*)txt for:(NSTimeInterval)tm animated:(BOOL)ani {
    [[[KAlertView alloc] initWithType:ty text:txt for:tm animated:ani] show];
}

- (id)initWithType:(KAlertType)ty text:(NSString*)txt for:(NSTimeInterval)tm animated:(BOOL)ani {
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    UIFont * font = [UIFont systemFontOfSize:16];
    CGSize size = [txt sizeWithFont:font maxWidth:KAlertTWidth maxNumberLines:0];
    CGFloat height = size.height;
    UIImage * img;
    switch (ty) {
        case KAlertTypeStar:
            height += 67;
            img = [UIImage imageNamed:@"KAlertStar"];
            break;
        case KAlertTypeCheck:
            height += 67;
            img = [UIImage imageNamed:@"KAlertCheck"];
            break;
        case KAlertTypeError:
            height += 67;
            img = [UIImage imageNamed:@"KAlertError"];
            break;
        default:
            height += 40;
            img = nil;
            break;
    }
    CGRect frame = CGRectMake((window.width - KAlertTWidth-40)/2, (window.height-height)/2, KAlertTWidth+40, height);
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        type = ty;
        self.image = img;
        self.text = txt;
        life = tm;
        animated = ani;
        self.backgroundColor = [RGBCOLOR(10, 10, 10) colorWithAlphaComponent:0.8];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 10;
    }
    return self;
}

- (void)dealloc {
    self.text = nil;
    self.image = nil;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGFloat pointY;
    switch (type) {
        case KAlertTypeStar:
            pointY = 15;
            break;
        case KAlertTypeCheck:
            pointY = 15;
            break;
        case KAlertTypeError:
            pointY = 15;
            break;
        default:
            pointY = 20;
            break;
    }
    if (image) {
        [image drawInRect:CGRectMake((self.width-32)/2, pointY, 32, 32)];
        pointY += 37;//32+5
    }
    [[UIColor whiteColor] setFill];
    UIFont * font = [UIFont systemFontOfSize:16];
    CGSize size = [text sizeWithFont:font maxWidth:KAlertTWidth maxNumberLines:0];
    CGRect txtRect = CGRectMake((self.width-size.width)/2, pointY, size.width, size.height);
    [text drawInRect:txtRect withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
}

- (void)show {
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    for (KAlertView * sub in window.subviews) {
        if ([sub isKindOfClass:[KAlertView class]] && sub.tag == KAlertTag) {
            [sub hide];
        }
    }
    self.tag = KAlertTag;
    self.alpha = 0;
    [window addSubview:self];
    if (animated) {
        [UIView beginAnimations:@"SHOW" context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationEnd:finished:context:)];
        [UIView setAnimationDuration:0.1];
        [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:nil cache:YES];
    }
    self.alpha = 1;
    if (animated) {
        [UIView commitAnimations];
    } else {
        [self performSelector:@selector(hide) withObject:nil afterDelay:life];
    }
}

- (void)hide {
    if (animated) {
        [UIView beginAnimations:@"HIDE" context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationEnd:finished:context:)];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:nil cache:YES];
    }
    self.alpha = 0;
    if (animated) {
        [UIView commitAnimations];
    } else {
        [self removeFromSuperview];
    }
}

- (void)animationEnd:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
    if ([animationID isEqualToString:@"SHOW"]) {
        [self performSelector:@selector(hide) withObject:nil afterDelay:life];
    } else if ([animationID isEqualToString:@"HIDE"]) {
        [self removeFromSuperview];
    }
}

@end
