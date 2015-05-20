//
//  KWAlertView.m
//  huazhuangpin
//
//  Created by Kiwaro on 14-11-20.
//  Copyright (c) 2014年 Kiwaro. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "KWAlertView.h"
#import "TextInput.h"
#import "UIImage+FlatUI.h"
#import "Globals.h"
#import "UIColor+FlatUI.h"

#define KWAlertTag 1818
#define KWAlertTWidth window.frame.size.width - 100
#define KWAlertButtonWidth (window.frame.size.width - 80)/2
#define KWAlertBoldFont [UIFont systemFontOfSize:16]
#define KWAlertSFont [UIFont systemFontOfSize:14]
#define KWAlertSFontB [UIFont systemFontOfSize:13]

@interface KWAlertView ()<UITextFieldDelegate> {
    UIImageView * blackView;
}
@end

@implementation KWAlertView
@synthesize delegate, index, tag;

+ (void)showAlert:(NSString*)msg {
    KWAlertView * alert = [[KWAlertView alloc] initWithMsg:msg cancelButtonTitle:@"确定"];
    [alert show];
}

+ (void)showAlertFieldWithTitle:(NSString*)title delegate:(id)delegate tag:(int)tag {
    KWAlertView * alert = [[KWAlertView alloc] initAlertFieldWithTitle:title delegate:delegate tag:tag];
    [alert show];
}

- (id)initWithMsg:(NSString*)msg cancelButtonTitle:(NSString *)canBtn {
    NSString * deftit = nil;
    return [self initWithTitle:deftit
                       message:msg
                      delegate:nil
             cancelButtonTitle:canBtn
              otherButtonTitle:nil];
}

- (id)initAlertFieldWithTitle:(NSString*)title delegate:(id)_delegate tag:(int)_ctag {
    if (self = [super init]) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 2;
        self.backgroundColor = [UIColor blackColor];
        
        NSMutableArray * subs = [NSMutableArray array];
        UIWindow * window = [UIApplication sharedApplication].keyWindow;
        CGSize size; CGRect frame; CGFloat poY=0;
        UILabel * lab;
        self.delegate = _delegate;
        self.tag = _ctag;
        if (title && [title isKindOfClass:[NSString class]] && title.length > 0) {
            size = [title sizeWithFont:KWAlertSFont maxWidth:KWAlertTWidth maxNumberLines:0];
            frame = CGRectMake(0, poY, KWAlertTWidth + 20, size.height + 15);
            lab = [[UILabel alloc] initWithFrame:frame];
            lab.backgroundColor = [UIColor clearColor];
            lab.font = KWAlertSFont;
            lab.textColor = [UIColor blackColor];
            lab.numberOfLines = 0;
            
            lab.textAlignment = NSTextAlignmentCenter;
            lab.text = title;
            
            UIImageView *bkg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bkg_blue"]];
            bkg.frame = frame;
            [subs addObject:bkg];
            [subs addObject:lab];
            poY += size.height + 15;
        }
        
        
        self.field = [[KTextField alloc] initWithFrame:CGRectMake(10, poY, KWAlertButtonWidth*2 - 20, 30)];
        _field.textColor = [UIColor blackColor];
        _field.delegate = self;
        _field.placeholder = @"请输入验证信息";
        _field.returnKeyType = UIReturnKeyDone;
        _field.backgroundColor = [UIColor cloudsColor];
        [self addSubview:[self field]];
        
        poY += 40;
        // 确定+取消
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"取消" forState:UIControlStateNormal];
        btn.frame = CGRectMake(0, poY, KWAlertButtonWidth, 40);
        [btn blackStyle];
        
        _cancelButton = btn;
        [btn addTarget:self action:@selector(didDismissWithButtonIndex:) forControlEvents:UIControlEventTouchUpInside];
        [subs addObject:btn];
        btn.tag = 0;
        
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"确定" forState:UIControlStateNormal];
        btn.frame = CGRectMake(KWAlertButtonWidth, poY, KWAlertButtonWidth, 40);
        [btn blackStyle];
        
        _otherButton = btn;
        [btn addTarget:self action:@selector(didDismissWithButtonIndex:) forControlEvents:UIControlEventTouchUpInside];
        [subs addObject:btn];
        btn.tag = 1;
        poY += 40;
        
        frame = CGRectMake(40, (window.frame.size.height-poY)/2 - 40, KWAlertButtonWidth*2, poY);
        self.frame = frame;
        for (UIView * sub in subs) {
            [self addSubview:sub];
        }
    }
    return self;
}

- (id)initWithTitle:(NSString*)title
            message:(NSString*)message
           delegate:(id)_delegate
  cancelButtonTitle:(NSString*)cancelButtonTitle
   otherButtonTitle:(NSString*)otherButtonTitle {
    if (self = [super init]) {
        NSMutableArray * subs = [NSMutableArray array];
        UIWindow * window = [UIApplication sharedApplication].keyWindow;
        CGSize size; CGRect frame; CGFloat poY=0;
        UILabel * lab;
        
        BOOL hasTitle = NO;
        if (title && [title isKindOfClass:[NSString class]] && title.length > 0) {
            
            size = [title sizeWithFont:KWAlertBoldFont maxWidth:KWAlertTWidth maxNumberLines:0];
            frame = CGRectMake(5, poY, KWAlertTWidth + 10, size.height + 15);
            lab = [[UILabel alloc] initWithFrame:frame];
            lab.backgroundColor = [UIColor clearColor];
            lab.font = KWAlertBoldFont;
            lab.textColor = [UIColor blackColor];
            lab.numberOfLines = 0;
            
            lab.textAlignment = NSTextAlignmentCenter;
            lab.text = title;
            
            [subs addObject:lab];
            poY += size.height + 20;
            hasTitle = YES;
        }
        
        if (message && [message isKindOfClass:[NSString class]] && message.length > 0) {
            UIFont * font;
            if (hasTitle) {
                font = KWAlertSFontB;
            } else {
                poY = 10;
                font = KWAlertSFont;
            }
            size = [message sizeWithFont:font maxWidth:KWAlertTWidth maxNumberLines:0];
            frame = CGRectMake(5, poY, KWAlertTWidth, size.height);
            lab = [[UILabel alloc] initWithFrame:frame];
            lab.backgroundColor = [UIColor clearColor];
            lab.font = font;
            lab.textColor = [UIColor blackColor];
            lab.numberOfLines = 0;
            lab.textAlignment = NSTextAlignmentLeft;
            lab.text = message;
            [subs addObject:lab];
            poY += size.height + 5;
        }
        
        int hasBtn = otherButtonTitle?1:0;
        if ([cancelButtonTitle isKindOfClass:[NSString class]] && cancelButtonTitle.length > 0) {
            hasBtn ++;
        }
        
        poY += 35;
        UIView * lineH = [[UIView alloc] initWithFrame:CGRectMake(0, poY-1, KWAlertButtonWidth*2, 0.5)];
        lineH.backgroundColor = RGBCOLOR(216, 220, 220);
        [subs addObject:lineH];
        if (hasBtn == 1) {
            UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitle:otherButtonTitle?otherButtonTitle:cancelButtonTitle forState:UIControlStateNormal];
            btn.frame = CGRectMake(0, poY, KWAlertButtonWidth*2, 40);
            [btn blackStyle];
            _cancelButton = btn;
            [btn setTitleColor:kbColor forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(didDismissWithButtonIndex:) forControlEvents:UIControlEventTouchUpInside];
            [subs addObject:btn];
            btn.tag = 1;
            
        } else if (hasBtn == 2) {
            // 确定+取消
            UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitle:cancelButtonTitle forState:UIControlStateNormal];
            btn.frame = CGRectMake(0, poY, KWAlertButtonWidth-0.25, 40);
            [btn blackStyle];
            _cancelButton = btn;
            
            UIView * lineV = [[UIView alloc] initWithFrame:CGRectMake(KWAlertButtonWidth, poY-0.25, 0.5, 40)];
            lineV.backgroundColor = RGBCOLOR(216, 220, 220);
            [subs addObject:lineV];
            
            [btn addTarget:self action:@selector(didDismissWithButtonIndex:) forControlEvents:UIControlEventTouchUpInside];
            [subs addObject:btn];
            btn.tag = 0;
            
            btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitle:otherButtonTitle forState:UIControlStateNormal];
            btn.frame = CGRectMake(KWAlertButtonWidth+0.25, poY, KWAlertButtonWidth-0.25, 40);
            [btn blackStyle];
            _otherButton = btn;
            
            //        btn.layer.cornerRadius = 5;
            [btn addTarget:self action:@selector(didDismissWithButtonIndex:) forControlEvents:UIControlEventTouchUpInside];
            [subs addObject:btn];
            btn.tag = 1;
            self.layer.masksToBounds = YES;
            self.clipsToBounds = YES;
        }
        poY += 40;
        
        frame = CGRectMake(40, (window.frame.size.height-poY)/2, KWAlertButtonWidth*2, poY);
        self.frame = frame;
        self.delegate = _delegate;
        self.tag = KWAlertTag;
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 5;
        self.backgroundColor = [UIColor cloudsColor];
        for (UIView * sub in subs) {
            [self addSubview:sub];
        }
    }
    
    return self;
}

- (void)dealloc {
    Release(blackView);
}

- (void)show {
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    if (blackView == nil) {
        blackView = [[UIImageView alloc] initWithFrame:window.bounds];
        blackView.backgroundColor = [UIColor clearColor];
        blackView.alpha = 0;
        blackView.backgroundColor = [RGBCOLOR(10, 10, 10) colorWithAlphaComponent:0.6];
        blackView.userInteractionEnabled = YES;
        [window addSubview:blackView];
    }
    [window addSubview:self];
    self.alpha = 0;
    self.transform = CGAffineTransformMakeScale(0.6, 0.6);
    [UIView animateWithDuration:0.35 animations:^{
        blackView.alpha = 1;
        self.alpha = 1;
        self.transform = CGAffineTransformIdentity;
    }];
}

- (void)dismissWithButtonIndex:(NSInteger)idx {
    if (idx == 0) {
        [self didDismissWithButtonIndex:self.cancelButton];
    } else {
        [self didDismissWithButtonIndex:self.otherButton];
    }
}

- (void)didDismissWithButtonIndex:(UIButton*)sender {
    [UIView animateWithDuration:0.25 animations:^{
        blackView.alpha = 0;
        self.transform = CGAffineTransformMakeScale(0.7, 0.7);
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            if ([delegate respondsToSelector:@selector(kwAlertView:didDismissWithButtonIndex:)]) {
                [delegate kwAlertView:self didDismissWithButtonIndex:sender.tag];
            }
        }
        [blackView removeFromSuperview];
        [self removeFromSuperview];
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)sender {
    [sender resignFirstResponder];
    return YES;
}

@end
