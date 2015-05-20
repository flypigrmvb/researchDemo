//
//  PhotoShowCell.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "ScrollShowView.h"

@interface PhotoShowCell : ScrollShowViewCell <UIScrollViewDelegate> {
    BOOL singleOnWait;
    NSTimer * timer;
    CGRect screenFrame;
    CGFloat hw;
    CGFloat std_hw;
    CGSize imageSize;
}

@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) UIScrollView * scrollView;
@property (nonatomic, assign) UIImage * image;

@end
