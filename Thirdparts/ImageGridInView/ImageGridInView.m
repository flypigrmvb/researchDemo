//
//  ImageGridView.m
//  SpartaEducation
//
//  Created by kiwaro on 13-12-6.
//  Copyright (c) 2013年 xizue.com All rights reserved.
//

#import "ImageGridInView.h"

@implementation ImageGridInView
@synthesize numberOfItems;
@synthesize isHead;

+ (ImageGridInView*)viewWithNum:(NSInteger)num {
    return [[ImageGridInView alloc] initWithNum:num];
}

+ (ImageGridInView*)viewWithNum:(NSInteger)num isHead:(BOOL)isHead {
    return [[ImageGridInView alloc] initWithNum:num isHead:isHead];
}

- (id)initWithNum:(NSInteger)num isHead:(BOOL)isH {
    CGRect frame = CGRectMake(2.5, 2, 35, 36);
    if (self = [super initWithFrame:frame]) {
        // Initialization code
        self.isHead = isH;
        numberOfItems = num;
        [self initDefault];
    }
    return self;
}

- (id)initWithNum:(NSInteger)num{
    CGRect frame = CGRectMake(2, 2, 35, 36);
    if (self = [super initWithFrame:frame]) {
        // Initialization code
        numberOfItems = num;
        [self initDefault];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
        numberOfItems = 1;
        [self initDefault];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        // Initialization code
        numberOfItems = 1;
        [self initDefault];
    }
    return self;
}

- (void)initDefault {
    [items removeAllObjects];
    self.clipsToBounds = NO;
    if (numberOfItems == 0) {
        return;
    }
    NSMutableArray * arr = [NSMutableArray arrayWithCapacity:numberOfItems];
    if (numberOfItems == 1) {
        CGFloat hei = self.height - 2;
        CALayer * layer = [CALayer layer];
        layer.frame = CGRectMake(1, 1, self.width - 2, hei);
        [[self layer] addSublayer:layer];
        [arr addObject:layer];
    } else if (numberOfItems == 2) {
        CGFloat wid = self.width / 2 - 1;
        CGFloat hei = self.height - 2;
        
        CGFloat originY = 1;
        if (isHead) {
            hei = wid;
            originY = (self.height - 2 - wid)/2;
        }
        for (int i = 0; i < numberOfItems; i ++) {
            CALayer * layer = [CALayer layer];
            layer.frame = CGRectMake((wid + 1)*i, originY, wid, hei);
            [[self layer] addSublayer:layer];
            [arr addObject:layer];
        }
    } else if (numberOfItems >= 3) {
        CGFloat wid = self.width / 2 - 1;
        CGFloat hei = self.height/ 2 - 1;
        if (isHead) {
            hei = wid;
        }
        for (int i = 0; i < numberOfItems; i ++) {
            if (i == 2 && numberOfItems == 3) {
                wid = self.width - 1;
                CALayer * layer = [CALayer layer];
                layer.frame = CGRectMake(0, self.height/ 2 + 1, wid, hei);
                [[self layer] addSublayer:layer];
                [arr addObject:layer];
            } else if (i > 1 && numberOfItems == 4 && isHead) {
                int originX = (wid + 1)*i;
                if (i > 1) {
                    originX = (wid + 1)*(i-2);
                }
                CALayer * layer = [CALayer layer];
                layer.frame = CGRectMake(originX, (i>1?2+wid:1), wid, hei);
                [[self layer] addSublayer:layer];
                [arr addObject:layer];
            } else {
                CALayer * layer = [CALayer layer];
                layer.frame = CGRectMake((wid + 1)*i, 1, wid, hei);
                [[self layer] addSublayer:layer];
                [arr addObject:layer];
            }

        }
    }
    if (!items) {
        items = [[NSMutableArray alloc] initWithArray:arr];
    } else {
        [items addObjectsFromArray:arr];
    }
}

- (void)setNumberOfItems:(NSInteger)nI {
    if (numberOfItems != nI) {
        numberOfItems = nI;
        [items makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
        [self initDefault];
    }
}

- (void)dealloc {
    Release(items);
}

- (UIImageView*)bkgImageView {
    if (!_bkgImageView) {
        _bkgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-1, -1, self.width+2, self.height+2)];
        [self insertSubview:_bkgImageView atIndex:0];
    }
    return _bkgImageView;
}

- (CALayer*)itemForIndex:(NSInteger)index {
    if (index == items.count || items.count == 0) {
        DLog(@"@error when set image in ImageGridInView");
        return nil;
    } else {
        return (CALayer*)[items objectAtIndex:index];
    }
}

- (void)setImage:(UIImage*)img forIndex:(NSInteger)index {
    [self itemForIndex:index].contents = (id)img.CGImage;
}

- (void)setDefaultImage:(UIImage*)img {
    for (CALayer * item in items) {
        item.contents = (id)img.CGImage;
    }
}

@end
