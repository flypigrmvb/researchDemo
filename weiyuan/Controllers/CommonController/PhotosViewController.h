//
//  PhotosViewController.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@class ScrollShowView;

@protocol PhotosViewControllerDelegate <NSObject>
- (void)photosViewControllerDeletePhoto:(int)currentIndex;
@end

@interface PhotosViewController : BaseViewController
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *tmpTitle;
@property (nonatomic, assign) id <PhotosViewControllerDelegate> delegate;

- (id)initWithArray:(NSArray*)albs defaultIndex:(int)index;
- (id)initWithFrameStart:(CGRect)fra supViewImage:(UIImage*)supv picArray:(NSArray*)albs defaultIndex:(int)index;

@end
