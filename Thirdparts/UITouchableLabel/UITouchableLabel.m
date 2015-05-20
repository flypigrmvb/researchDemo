//
//  UITouchableLabel.m
//  UILabelTouch
//
//  Created by kiwaro Hood on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UITouchableLabel.h"

#define FONTSIZE 14

@implementation UITouchableLabel

@synthesize touchdelegate;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.layer.masksToBounds=YES;
        self.layer.borderWidth = 0;
        self.layer.cornerRadius = 3;
        [self setLineBreakMode:NSLineBreakByWordWrapping|NSLineBreakByTruncatingTail];
        [self setBackgroundColor:[UIColor clearColor]];
        [self setBackgroundColor:RGBCOLOR(207, 207, 207)];
        [self setUserInteractionEnabled:YES];
        [self setNumberOfLines:1];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setTextAlignment:NSTextAlignmentCenter];
        self.layer.masksToBounds=YES;
        self.layer.borderWidth = 0;
        self.layer.cornerRadius = 3;
        [self setLineBreakMode:NSLineBreakByWordWrapping|NSLineBreakByTruncatingTail];
        [self setFont:[UIFont systemFontOfSize:FONTSIZE]];
        [self setBackgroundColor:[UIColor clearColor]];
        [self setBackgroundColor:RGBCOLOR(207, 207, 207)];
        [self setUserInteractionEnabled:YES];
        [self setNumberOfLines:1];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self setBackgroundColor:RGBCOLOR(207, 207, 207)];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self setBackgroundColor:[UIColor clearColor]];
    UITouch * touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGSize size = self.bounds.size;
    if (point.x >= -10 && point.y >= -10 && point.x <= size.width + 10 && point.y <= size.height + 10) {
        [touchdelegate touchableLabelLabel:self touchesWtihTag:self.tag];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self setBackgroundColor:[UIColor clearColor]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGSize size = self.bounds.size;
    if (point.x < -10 || point.y < -10 || point.x > size.width + 10 || point.y > size.height + 10) {
        [self setBackgroundColor:[UIColor clearColor]];
    } else {
        [self setBackgroundColor:RGBCOLOR(207, 207, 207)];
    }
}

@end
