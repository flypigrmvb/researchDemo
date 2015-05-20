//
//  PhotoView.h
//  QiChuang
//
//  Created by keen on 14-2-13.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoViewDelegate <NSObject>

- (void)photoViewDidPress:(id)sender;

@end

@interface PhotoView : UIScrollView

- (void)initializeScale;

@property (nonatomic, strong) NSString* imgUrl;

@property (nonatomic, strong) UIImageView *imageView;
- (id)initWithFrame:(CGRect)frame delegate:(id<PhotoViewDelegate>)del;

@end
