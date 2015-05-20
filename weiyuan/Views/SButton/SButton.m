//
//  SButton.m
//
//  AppDelegate.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "SButton.h"
#import "Globals.h"
#import <QuartzCore/QuartzCore.h>
@implementation SButton

@synthesize indexPath;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        [self setImage:[Globals getImageUserHeadDefault] forState:UIControlStateNormal];
    }
    return self;
}

- (void)dealloc {
    self.indexPath = nil;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (CGRect)contentRectForBounds:(CGRect)bounds {
    CGSize size = bounds.size;
    CGRect inset;
    CGFloat offSet = 5.0;
    inset = CGRectMake(offSet, offSet , size.width - offSet*2, size.height - offSet*2);
    return inset;
}

@end
