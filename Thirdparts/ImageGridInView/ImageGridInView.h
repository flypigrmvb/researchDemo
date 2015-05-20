//
//  ImageGridView.h
//  SpartaEducation
//
//  Created by kiwaro on 13-12-6.
//  Copyright (c) 2013年 Kiwaro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageGridInView : UIView {
    NSMutableArray * items;
}

@property (nonatomic, strong) UIImageView *bkgImageView;
@property (nonatomic, assign) BOOL isHead;
@property (nonatomic, assign) NSInteger numberOfItems;


+ (ImageGridInView*)viewWithNum:(NSInteger)num;
+ (ImageGridInView*)viewWithNum:(NSInteger)num isHead:(BOOL)isHead;
- (id)initWithNum:(NSInteger)num;
- (void)initDefault;
- (void)setImage:(UIImage*)img forIndex:(NSInteger)index;

- (void)setDefaultImage:(UIImage*)img;

@end
