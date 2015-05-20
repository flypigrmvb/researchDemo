//
//  ImageGridView.h
//  SpartaEducation
//
//  Created by kiwaro on 13-12-6.
//  Copyright (c) 2013年 Kiwaro. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImageGridViewDelegate <NSObject>
@optional
- (void)gridView:(id)sender itemTappedAtIndex:(NSInteger)index;
@end

@interface ImageGridView : UIView {
    NSMutableArray * items;
}
@property (nonatomic, assign) id <ImageGridViewDelegate> delegate;
@property (nonatomic, assign) NSInteger numberOfItems;
@property (nonatomic, assign) int row;

+ (ImageGridView*)viewWithDel:(id)del numberOfItems:(NSInteger)num;
- (id)initWithDel:(id)del numberOfItems:(NSInteger)num;

- (UIImageView*)itemForIndex:(NSInteger)index;
- (void)setImage:(UIImage*)img forIndex:(NSInteger)index;

- (void)setDefaultImage:(UIImage*)img;

@end
