//
//  ImageGridView.m
//  SpartaEducation
//
//  Created by kiwaro on 13-12-6.
//  Copyright (c) 2013年 xizue.com All rights reserved.
//

#import "ImageGridView.h"

@implementation ImageGridView
@synthesize delegate;
@synthesize numberOfItems;
@synthesize row;

+ (ImageGridView*)viewWithDel:(id)del numberOfItems:(NSInteger)num {
    return [[ImageGridView alloc] initWithDel:del numberOfItems:num];
}

- (id)initWithDel:(id)del numberOfItems:(NSInteger)num {
    // 缩略图60*80 会不会太小了呢 ）＊……＊）
    CGRect frame = CGRectMake(80, 0, 200, 80);
    if (self = [super initWithFrame:frame]) {
        // Initialization code
        delegate = del;
        numberOfItems = num;
        [self initDefault];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        // Initialization code
        self.numberOfItems = 1;
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
    SEL sel = @selector(tappedOnItems:);
    if (!items) {
        items = [[NSMutableArray alloc] init];
    } else {
        [items removeAllObjects];
    }
    if (numberOfItems > 1) {
        CGFloat wid = self.width / 3 - 2;
        CGFloat hei = self.height - 2;
        for (int i = 0; i < numberOfItems; i ++) {
            UIImageView * item = [[UIImageView alloc] initWithFrame:CGRectMake((wid + 4)*i, 1, wid, hei)];
            item.contentMode = UIViewContentModeScaleAspectFill;
            item.clipsToBounds = YES;
            item.tag = i;
            item.userInteractionEnabled = YES;
            UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:sel];
            tap.numberOfTapsRequired = 1;
            [item addGestureRecognizer:tap];
         
            [self addSubview:item];
            [items addObject:item];

        }
    } else {
        CGFloat hei = self.height - 2;
        UIImageView * item = [[UIImageView alloc] initWithFrame:CGRectMake(0, 1, (hei * 3) / 2, hei)];
        item.contentMode = UIViewContentModeScaleAspectFill;
        item.clipsToBounds = YES;
        item.tag = 0;
        item.userInteractionEnabled = YES;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:sel];
        tap.numberOfTapsRequired = 1;
        [item addGestureRecognizer:tap];

        [self addSubview:item];
        [items addObject:item];

    }
}

- (void)setNumberOfItems:(NSInteger)nI {
    numberOfItems = nI;
    if (items && items.count > 0) {
        for (UIImageView * item in items) {
            [item removeFromSuperview];
        }
    }
    [self initDefault];
}

- (void)dealloc {
    Release(items);
}

- (UIImageView*)itemForIndex:(NSInteger)index {
    return (UIImageView*)[items objectAtIndex:index];
}

- (void)setImage:(UIImage*)img forIndex:(NSInteger)index {
    [self itemForIndex:index].image = img;
}

- (void)setDefaultImage:(UIImage*)img {
    for (UIImageView * item in items) {
        item.image = img;
    }
}

- (void)setDelegate:(id<ImageGridViewDelegate>)del {
    delegate = del;
}

- (void)tappedOnItems:(UITapGestureRecognizer*)recognizer {
    UIImageView * item = (UIImageView*)recognizer.view;
    [delegate gridView:self itemTappedAtIndex:item.tag];
}

@end
