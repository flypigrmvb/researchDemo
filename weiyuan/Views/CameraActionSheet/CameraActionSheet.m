//
//  CmeraActionSheetController.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "CameraActionSheet.h"
#import "UIColor+FlatUI.h"
#import "UIImage+FlatUI.h"
#import <CoreGraphics/CoreGraphics.h>

@interface CameraActionSheet ()
@property (nonatomic, strong) UIView        * bkgView;
@property (nonatomic, strong) UIView        * frameView;
@property (nonatomic, strong) UIView        * buttonView;
@property (nonatomic, assign) CGFloat       minimumButtonHeight;
@property (nonatomic, assign) CGFloat       maximumButtonWidth;
@property (nonatomic, assign) BOOL          hasCancel;
@property (nonatomic, strong) NSString      * actionTitle;
@property (nonatomic, strong) NSString      * textViews;
@end

@implementation CameraActionSheet
@synthesize buttonTitles, frameView, actionTitle, textViews;
@synthesize destructiveButtonIndex;
@synthesize delegate;

- (id)initWithActionTitle:(NSString*)title TextViews:(NSString*)tViews CancelTitle:(NSString*)cancelTitle withDelegate:(id)del otherButtonTitles:(NSString *)otherButtonTitles, ... {
    if (self = [self initWithFrame:[[[UIApplication sharedApplication] keyWindow] frame]]) {
        // Cancel Button Index
        _cancelButtonIndex = -1;
        //  Minimum Button Height
        _minimumButtonHeight = 38;
        //  Maximum button width
        _maximumButtonWidth = self.width - 40;
        _hasCancel = cancelTitle?YES:NO;
        destructiveButtonIndex = -1;
        //        self.actionTitle = title;
        self.textViews = tViews;
        self.delegate = del;
        self.buttonTitles = nil;
        if ([otherButtonTitles isKindOfClass:[NSString class]] && otherButtonTitles.length > 0) {
            self.buttonTitles = [NSMutableArray array];
            va_list args;
            va_start(args, otherButtonTitles); // scan for arguments after firstObject.
            // get rest of the objects until nil is found
            for (NSString * str = otherButtonTitles; str != nil; str = va_arg(args,NSString*)) {
                if ([str isKindOfClass:[NSString class]] && str.length > 0) {
                    [buttonTitles addObject:str];
                }
            }
            va_end(args);
        }
        
        if (cancelTitle) {
            destructiveButtonIndex =
            _cancelButtonIndex = buttonTitles.count;
            [buttonTitles addObject:cancelTitle];
        }
        // 1. Add a modal wrapper one third of the screen
        [self addSubview:self.frameView];
        
        // 2. Render the buttons
        [self renderButtons];
        self.numberOfButtons = buttonTitles.count;
    }
    return self;
}

- (void)dealloc {
    self.actionTitle = nil;
    self.textViews = nil;
    self.delegate = nil;
    self.frameView = nil;
    self.buttonTitles = nil;
    self.buttonView = nil;
}

- (UIView*)bkgView {
    if (!_bkgView) {
        _bkgView = [[UIView alloc] initWithFrame:frameView.bounds];
        [_bkgView setBackgroundColor:[RGBCOLOR(100, 100, 100) colorWithAlphaComponent:0.6]];
    }
    return _bkgView;
}

- (UIView*)frameView {
    if (!frameView) {
        frameView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, KeyWindow_Height)];
        [frameView setAutoresizingMask:(UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth)];
        //
        [frameView addSubview:self.bkgView];
        CGSize size = CGSizeZero;
        CGFloat height = 5;
        
        // 1. Add actionTitle
        UILabel * label = nil;
        if (actionTitle) {
            UIFont * font = [UIFont systemFontOfSize:14];
            label = [UILabel linesText:actionTitle font:font wid:self.width-20 lines:0];
            label.origin = CGPointMake(10, height);
            label.width = self.width-20;
            label.adjustsFontSizeToFitWidth = YES;
            label.textAlignment = NSTextAlignmentCenter;
            [frameView addSubview:label];
            height += label.bottom + 5;
        }
        
        // 2. Add contentLabel
        if (textViews && textViews.length > 0) {
            UIFont * font = [UIFont systemFontOfSize:13];
            size = [textViews sizeWithFont:font maxWidth:self.width - 80 maxNumberLines:0];
            label = [UILabel multLinesText:textViews font:font wid:self.width - 80 color:[UIColor blackColor]];
            label.origin = CGPointMake(40, height);
            [frameView addSubview:label];
            height += label.bottom + 5;
        }
        // 3. Add buttonView
        [frameView addSubview:[self buttonView]];
        _buttonView.frame = CGRectMake(0, KeyWindow_Height, self.width, buttonTitles.count*_minimumButtonHeight+(_hasCancel?self.verticalSpacingBetweenButtons:0));
        _buttonView.height += self.verticalSpacingBetweenButtons;
        
    }
    return frameView;
}

- (UIView *)buttonView {
    if (!_buttonView) {
        _buttonView = [[UIView alloc] init];
        _buttonView.autoresizingMask  = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        _buttonView.backgroundColor = [UIColor clearColor];
    }
    return _buttonView;
}

#pragma mark - Overridden Setters

- (void)setDestructiveButtonIndex:(NSInteger)_destructiveButtonIndex
{
    destructiveButtonIndex = _destructiveButtonIndex;
    [self renderButtons];
}

#pragma mark - Render Buttons

- (void)renderButtons {
    //  remove
    [_buttonView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    //  Render new buttons
    NSInteger count = _hasCancel?(self.buttonTitles.count - 1):self.buttonTitles.count;
    [self.buttonTitles enumerateObjectsUsingBlock:^(NSString * title, NSUInteger idx, BOOL *stop) {
        UIButton * button = [self buttonWithTitle:title forIndex:idx];
        [_buttonView addSubview:button];
        
    }];
    [_buttonView.subviews enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        if (idx != count-1 && idx != destructiveButtonIndex) {
            // 其他按钮组之间存在分割线
            UIImageView *bottomLineView = [[UIImageView alloc] initWithFrame:CGRectMake(button.left, button.bottom, button.width, 0.5)];
            bottomLineView.backgroundColor = RGBCOLOR(238, 238, 238);
            [_buttonView addSubview:bottomLineView];
        }
    }];
}

#pragma mark - Button Metrics

//
//  Returns a button for a given title and index
//

- (UIButton *) buttonWithTitle:(NSString *)title forIndex:(NSUInteger)index {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitleColor:RGBCOLOR(0, 117, 251) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    button.backgroundColor = [UIColor whiteColor];
    //  Apply autoresizing masks
    [button setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin)];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    button.tag = index;
    //
    //  Resize the button
    //
    CGFloat offset = 1;
    if (index == destructiveButtonIndex) {
        offset = 8;
    }
    CGRect buttonFrame = CGRectMake((self.width - _maximumButtonWidth)/2, index*(_minimumButtonHeight)+offset, _maximumButtonWidth, _minimumButtonHeight);
    [button setFrame:buttonFrame];
    if (index == destructiveButtonIndex) {
        [button setTitleColor:RGBCOLOR(210, 0, 0) forState:UIControlStateNormal];
    } else {
    }
    BOOL needAllRadius = NO;
    if (self.buttonTitles.count == 2 && _hasCancel) {
        // 取消和其他按钮分别：有且只有一个
        needAllRadius = YES;
        button.layer.cornerRadius = 4;
    } else {
        BOOL    topLeft     = NO;
        BOOL    topRight    = NO;
        BOOL    bottomLeft  = NO;
        BOOL    bottomRight = NO;
        if (index == 0||index == self.destructiveButtonIndex) {
            topLeft     = YES;
            topRight    = YES;
        }
        if (index == self.buttonTitles.count - 1 || index == self.destructiveButtonIndex - 1) {
            bottomLeft  = YES;
            bottomRight = YES;
        }
        button = [button roundCornersOnTopLeft:topLeft topRight:topRight bottomLeft:bottomLeft bottomRight:bottomRight radius:5.0];
    }
    //  Apply the title
    [button setTitle:title forState:UIControlStateNormal];
    //  Handle touches in the app
    [button addTarget:self action:@selector(hide:) forControlEvents:UIControlEventTouchUpInside];
    return button;
    
}

//  Returns the space between the buttons
- (CGFloat)verticalSpacingBetweenButtons {
    return 5;
}

#pragma mark - Presentation

//- (void)showInView:(UIView*)view {
- (void)show {
    //  1. Add the modal view
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
    _bkgView.alpha = 0;
    [UIView
     animateWithDuration:0.25
     animations:^{
         _bkgView.alpha = 1;
         //  2. Animate everything into place
         // Transform:slowly in iphone4
         [_buttonView setTransform:CGAffineTransformMakeTranslation(0,  -_buttonView.height-20)];
     } completion:^(BOOL finished) {
         [UIView
          animateWithDuration:0.15
          animations:^{
              [_buttonView setTransform:CGAffineTransformTranslate(_buttonView.transform, 0, 10)];
          }];
     }];
}

- (void)hide:(UIButton*)sender {
    // Animate everything out of place
    
    [UIView
     animateWithDuration:0.15
     animations:^{
         //  hide the main view down
         [_buttonView setTransform:CGAffineTransformTranslate(_buttonView.transform, 0, -10)];
     }
     completion:^(BOOL finished) {
         if (finished) {
             [UIView
              animateWithDuration:0.25
              animations:^{
                  _bkgView.alpha = 0;
                  [_buttonView setTransform:CGAffineTransformIdentity];
              } completion:^(BOOL finished) {
                  [self removeFromSuperview];
                  if([delegate respondsToSelector:@selector(cameraActionSheet:didDismissWithButtonIndex:)]){
                      [delegate cameraActionSheet:self didDismissWithButtonIndex:sender.tag];
                  }
              }];
             
         }
     }];
    
}

@end

