//
//  UIButton+Bootstrap.m
//  UIButton+Bootstrap
//
//  Created by Oskur on 2013-09-29.
//  Copyright (c) 2013 Oskar Groth. All rights reserved.
//
#import "UIButton+Bootstrap.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+FlatUI.h"

@implementation UIButton (Bootstrap)

-(void)bootstrapStyle{
    self.layer.cornerRadius = 3.0;
    self.layer.masksToBounds = YES;
    [self setAdjustsImageWhenHighlighted:NO];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [self.titleLabel setFont:[UIFont fontWithName:@"FontAwesome" size:self.titleLabel.font.pointSize]];
    [self setBackgroundImage:[self buttonImageFromColor:[UIColor grayColor]] forState:UIControlStateDisabled];
}

-(void)defaultStyle{
    [self bootstrapStyle];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    self.backgroundColor = RGBCOLOR(242, 242, 242);
    self.layer.borderWidth = 1;
    self.layer.borderColor = RGBCOLOR(218, 217, 217).CGColor;
    [self setBackgroundImage:[self buttonImageFromColor:[UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1]] forState:UIControlStateHighlighted];
}

-(void)cancelStyle{
    
    [self setTitleColor:RGBCOLOR(0, 117, 251) forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    self.backgroundColor = [UIColor whiteColor];
    [self setBackgroundImage:[self buttonImageFromColor:RGBCOLOR(243, 243, 243)] forState:UIControlStateHighlighted];
}

-(void)primaryStyle{
    [self bootstrapStyle];
    self.backgroundColor = [UIColor colorWithRed:66/255.0 green:139/255.0 blue:202/255.0 alpha:1];
    self.layer.borderColor = [[UIColor colorWithRed:53/255.0 green:126/255.0 blue:189/255.0 alpha:1] CGColor];
    [self setBackgroundImage:[self buttonImageFromColor:[UIColor colorWithRed:51/255.0 green:119/255.0 blue:172/255.0 alpha:1]] forState:UIControlStateHighlighted];
}

-(void)successStyle{
    [self bootstrapStyle];
    self.backgroundColor = [UIColor colorWithRed:92/255.0 green:184/255.0 blue:92/255.0 alpha:1];
    [self setBackgroundImage:[self buttonImageFromColor:[UIColor colorWithRed:69/255.0 green:164/255.0 blue:84/255.0 alpha:1]] forState:UIControlStateHighlighted];
}

-(void)infoStyle{
    [self bootstrapStyle];
    self.backgroundColor = RGBCOLOR(58, 181, 233);
    self.layer.borderColor = RGBCOLOR(0, 177, 233).CGColor;
    [self setBackgroundImage:[self buttonImageFromColor:RGBCOLOR(126, 196, 236)] forState:UIControlStateHighlighted];
}

-(void)navStyle{
    [self bootstrapStyle];
    self.backgroundColor = kbColor;
    [self setBackgroundImage:[self buttonImageFromColor:RGBCOLOR(83, 167, 40)] forState:UIControlStateHighlighted];
}

-(void)blackStyle {
    self.titleLabel.font = [UIFont systemFontOfSize:14];
//    self.layer.borderWidth = 1;
//    self.layer.borderColor = RGBCOLOR(39, 39, 39).CGColor;
    [self setBackgroundImage:[UIImage imageWithColor:RGBCOLOR(100, 100, 100) cornerRadius:0] forState:UIControlStateHighlighted];
}

-(void)navBlackStyle{
    self.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    self.backgroundColor = RGBCOLOR(47, 97, 230);
    self.layer.masksToBounds = YES;
    self.layer.borderColor = RGBCOLOR(0, 84, 230).CGColor;
    self.layer.cornerRadius = 2;
    [self setBackgroundImage:[UIImage imageWithColor:RGBCOLOR(100, 100, 100) cornerRadius:0] forState:UIControlStateHighlighted];
}

-(void)warningStyle{
    [self bootstrapStyle];
    self.backgroundColor = RGBCOLOR(255, 184, 35);
    self.layer.borderColor = self.backgroundColor.CGColor;
    [self setBackgroundImage:[self buttonImageFromColor:[UIColor colorWithRed:237/255.0 green:155/255.0 blue:67/255.0 alpha:1]] forState:UIControlStateHighlighted];
}

- (void)commonStyle {
    self.layer.cornerRadius = 4;
    self.backgroundColor = RGBCOLOR(0, 200, 247);;
    [self setBackgroundImage:[self buttonImageFromColor:kbColor] forState:UIControlStateHighlighted];
}

-(void)dangerStyle{
    [self bootstrapStyle];
    self.backgroundColor = RGBCOLOR(197, 1, 44);
    self.layer.borderColor = [RGBCOLOR(198, 36, 59) CGColor];
    [self setBackgroundImage:[self buttonImageFromColor:kbColor] forState:UIControlStateHighlighted];
}

- (UIImage *) buttonImageFromColor:(UIColor *)color {
    return [UIImage imageWithColor:color cornerRadius:self.layer.cornerRadius];
}

@end
