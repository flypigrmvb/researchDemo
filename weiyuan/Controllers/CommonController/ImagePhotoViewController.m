//
//  ImagePhotoViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "ImagePhotoViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "KAlertView.h"
#import "ImageProgressQueue.h"
#import "SharePicture.h"
#import "ImgScrollView.h"
#import "ImageTouchView.h"
#import "CircleMessageCell.h"

@interface ImagePhotoViewController () <UIActionSheetDelegate, ImageProgressQueueDelegate, ImgScrollViewDelegate, UIScrollViewDelegate> {
    NSInteger     currentIndex;
    ImgScrollView * lastImgScrollView;
    UIScrollView  * imageScrollView;
    UIView        * bkgView;
}

@property (nonatomic, strong) NSArray * contentArray;

@end
@implementation ImagePhotoViewController

- (id)initWithPicArray:(NSArray*)albs defaultIndex:(int)index {
    if (self = [self init]) {
        self.contentArray = albs;
        currentIndex = index;
    }
    return self;
}

- (void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    bkgView = [[UIView alloc] initWithFrame:self.view.frame];
    bkgView.alpha = 0;
    bkgView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:bkgView];
    
    imageScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    imageScrollView.backgroundColor = [UIColor clearColor];
    imageScrollView.userInteractionEnabled = YES;
    [self.view addSubview:imageScrollView];
    imageScrollView.pagingEnabled = YES;
    imageScrollView.delegate = self;
}

- (void)showFromView:(UIView*)fromView {
    [imageScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGSize contentSize = imageScrollView.contentSize;
    contentSize.height = self.view.height;
    contentSize.width = self.view.width * self.contentArray.count;
    imageScrollView.contentSize = contentSize;
    
    CGPoint contentOffset = imageScrollView.contentOffset;
    contentOffset.x = (currentIndex)*self.view.width;
    imageScrollView.contentOffset = contentOffset;
    [self.contentArray enumerateObjectsUsingBlock:^(NSString * url, NSUInteger idx, BOOL *stop) {
        ImageTouchView *tmpView = (id)fromView;
        ImageProgress * progress = [[ImageProgress alloc] initWithUrl:url delegate:nil];
        
        CGRect tmpconvertRect = [self.view convertRect:tmpView.frame toView:self.navigationController.view];
        ImgScrollView *tmpImgScrollView = [[ImgScrollView alloc] initWithFrame:(CGRect){imageScrollView.contentOffset,imageScrollView.bounds.size}];
        tmpImgScrollView.tag = 10;
        [tmpImgScrollView setContentWithFrame:tmpconvertRect];
        [tmpImgScrollView setImage:progress.image];
        tmpImgScrollView.i_delegate = self;
        [imageScrollView addSubview:tmpImgScrollView];
        
        lastImgScrollView = tmpImgScrollView;
        
        UIWindow * window = [UIApplication sharedApplication].keyWindow;
        
        [window addSubview:self.view];
        [self viewDidAppear:YES];
        bkgView.alpha = 0.0;
        [UIView animateWithDuration:0.35 animations:^{
            [tmpImgScrollView setAnimationRect];
            bkgView.alpha = 1.0;
        } completion:^(BOOL finished) {
            NSInvocationOperation * opHeadItem = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadHeadImageWithIndexPath:) object:[NSNumber numberWithInteger:tmpImgScrollView.tag]];
            [baseOperationQueue addOperation:opHeadItem];
        }];
    }];

}

- (void)showInCell:(CircleMessageCell*)cell {
    [imageScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGSize contentSize = imageScrollView.contentSize;
    contentSize.height = self.view.height;
    contentSize.width = self.view.width * self.contentArray.count;
    imageScrollView.contentSize = contentSize;
    
    CGPoint contentOffset = imageScrollView.contentOffset;
    contentOffset.x = (currentIndex)*self.view.width;
    imageScrollView.contentOffset = contentOffset;
    [self.contentArray enumerateObjectsUsingBlock:^(SharePicture * obj, NSUInteger idx, BOOL *stop) {
        if (idx != currentIndex) {
            ImageTouchView *tmpView = (id)[cell viewWithTag:idx+1];
            //转换后的rect
            CGRect tmpconvertRect = [cell convertRect:[cell imageFrameAtIndex:idx] toView:self.navigationController.view];
            ImgScrollView *tmpImgScrollView = [[ImgScrollView alloc] initWithFrame:(CGRect){idx*imageScrollView.width,0,imageScrollView.bounds.size}];
            tmpImgScrollView.backgroundColor = [UIColor clearColor];
            [tmpImgScrollView setContentWithFrame:tmpconvertRect];
            [tmpImgScrollView setImage:tmpView.image];
            tmpImgScrollView.tag = idx + 10;
            [imageScrollView addSubview:tmpImgScrollView];
            [tmpImgScrollView setAnimationRect];
        } else {
            CGRect convertRect = [cell convertRect:[cell imageFrameAtIndex:currentIndex] toView:self.navigationController.view];
            SharePicture * sitem = _contentArray[currentIndex];
            ImageProgress * progress = [[ImageProgress alloc] initWithUrl:sitem.smallUrl delegate:nil];
            
            ImgScrollView *tmpImgScrollView = [[ImgScrollView alloc] initWithFrame:(CGRect){imageScrollView.contentOffset,imageScrollView.bounds.size}];
            tmpImgScrollView.backgroundColor = [UIColor clearColor];
            tmpImgScrollView.tag = currentIndex + 10;
            [tmpImgScrollView setContentWithFrame:convertRect];
            [tmpImgScrollView setImage:progress.image];
            tmpImgScrollView.i_delegate = self;
            [imageScrollView addSubview:tmpImgScrollView];
            lastImgScrollView = tmpImgScrollView;
            UIWindow * window = [UIApplication sharedApplication].keyWindow;
            [window addSubview:self.view];
            [self viewDidAppear:YES];
            
            bkgView.alpha = 0.;
            [UIView animateWithDuration:0.35 animations:^{
                [tmpImgScrollView setAnimationRect];
                bkgView.alpha = 1.;
//                bkgView.alpha = 1.0;
            } completion:^(BOOL finished) {
                NSInvocationOperation * opHeadItem = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadHeadImageWithIndexPath:) object:[NSNumber numberWithInteger:tmpImgScrollView.tag]];
                [baseOperationQueue addOperation:opHeadItem];
            }];
            
        }
    }];
}

- (void)loadHeadImageWithIndexPath:(NSNumber *)number {
    SharePicture * sitem = _contentArray[number.intValue-10];
    NSString * url = nil;
    if ([sitem isKindOfClass:[SharePicture class]]) {
        url = sitem.originUrl;
    } else if ([sitem isKindOfClass:[NSString class]]) {
        url = (NSString*)sitem;
    }
    ImgScrollView * tmpImgScrollView = VIEWWITHTAG(imageScrollView, number.intValue);
    ImageProgress * progress = [[ImageProgress alloc] initWithUrl:url delegate:baseImageQueue];
    if (progress.loaded) {
        [baseImageCaches insertImageCache:progress.image withKey:[progress.imageURLString md5Hex]];
        [tmpImgScrollView performSelectorOnMainThread:@selector(setImage:) withObject:progress.image waitUntilDone:YES];
    } else {
        dispatch_async(kQueueMain, ^{
            [tmpImgScrollView setLoading:YES];
            [baseImageQueue addOperation:progress];
            progress.tag = number.intValue;
        });
    }
}

- (void) tapImageViewTappedWithObject:(ImgScrollView *)sender {
    [UIView animateWithDuration:0.35 animations:^{
        [sender rechangeInitRdct];
        bkgView.alpha = 0.0;
    } completion:^(BOOL finished) {
        sender.i_delegate = nil;
        lastImgScrollView.i_delegate = nil;
        [self.view removeFromSuperview];
        [self dismissModalController:NO];
    }];
}

#pragma mark -
#pragma mark - scroll delegate
- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    currentIndex = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    ImgScrollView * tmpImgScrollView = VIEWWITHTAG(imageScrollView, currentIndex+10);

    if (lastImgScrollView && lastImgScrollView != tmpImgScrollView) {
        tmpImgScrollView.i_delegate = self;
        lastImgScrollView.i_delegate = nil;
        lastImgScrollView = tmpImgScrollView;
        NSInvocationOperation * opHeadItem = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadHeadImageWithIndexPath:) object:[NSNumber numberWithInteger:tmpImgScrollView.tag]];
        [baseOperationQueue addOperation:opHeadItem];
    }
    

}

#pragma mark - imageProgress

- (void)imageProgressCompleted:(UIImage*)img indexPath:(NSIndexPath*)indexPath idx:(NSInteger)_idx url:(NSString *)url tag:(NSInteger)_tag{
    [baseImageCaches insertImageCache:img withKey:[url md5Hex]];
    ImgScrollView * tmpImgScrollView = VIEWWITHTAG(imageScrollView, _tag);
    [tmpImgScrollView setLoading:NO];
    [tmpImgScrollView setImage:img];
}

@end
