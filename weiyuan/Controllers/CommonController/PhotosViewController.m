//
//  PhotosViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PhotosViewController.h"
#import "ScrollShowView.h"
#import "PhotoShowCell.h"
#import "KAlertView.h"
#import "UILabelAdditions.h"
#import "ImageProgressQueue.h"
#import "SharePicture.h"

@interface PhotosViewController () <UIActionSheetDelegate, ImageProgressQueueDelegate> {
    int currentIndex;
    int defaultIndex;
    IBOutlet ScrollShowView * scrollView;
    IBOutlet UIView *tarbarView;
    ImageProgressQueue * operationQueue;
    UIView * statusBar;
}


@property (nonatomic, strong) NSArray * contentArray;
@property (nonatomic, strong) UIImage * bkgImage;
@property (nonatomic, assign) BOOL loading;
@end

@implementation PhotosViewController
@synthesize delegate;
@synthesize loading;
@synthesize content;
@synthesize contentArray;

- (id)init {
    if (self = [super initWithNibName:@"PhotosViewController" bundle:nil]) {
        currentIndex = 0;
//        self.wantsFullScreenLayout = YES;
        operationQueue = [[ImageProgressQueue alloc] initWithDelegate:self];
    }
    return self;
}

- (id)initWithArray:(NSArray*)albs defaultIndex:(int)index {
    if (self = [self init]) {
        self.contentArray = albs;
        defaultIndex = index;
    }
    return self;
}

- (id)initWithFrameStart:(CGRect)fra supViewImage:(UIImage*)supv picArray:(NSArray*)albs defaultIndex:(int)index {
    if (self = [self init]) {
        self.contentArray = albs;
        defaultIndex = index;
        _bkgImage = supv;
    }
    return self;
}

- (void)dealloc {
    self.loading = NO;
    self.content = nil;
}

- (void)viewDidLoad {
    self.willShowBackButton = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    self.navigationItem.title = _tmpTitle;
    self.view.backgroundColor = [UIColor clearColor];
    if (content && content.length > 0) {
        UILabel *label = [UILabel defaultLabel:content font:[UIFont systemFontOfSize:14] maxWid:self.view.width];
        label.frame = CGRectMake(0, 0, label.width, label.height + 8);
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = RGBACOLOR(0, 0, 0, 0.5);
        label.origin = CGPointMake(0, self.view.bounds.size.height - label.height);
        label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
        [self.view addSubview:label];
    }
    if (_bkgImage) {
        UIImageView * bkgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        [self.view insertSubview:bkgView atIndex:0];
        bkgView.image = _bkgImage;
    }
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (isFirstAppear) {
        [scrollView updateWithIndex:defaultIndex];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)singleTap {
    [self popViewController];
}

- (NSInteger)scrollShowViewNumberOfIndexes {
    return contentArray.count;
}

- (ScrollShowViewCell*)scrollShowView:(ScrollShowView*)sender cellForIndex:(int)idx {
    PhotoShowCell * cell = (PhotoShowCell*)[sender cellForIndex:idx];
    if (!cell) {
        CGRect frame = self.view.bounds;
        cell = [[PhotoShowCell alloc] initWithIndex:idx frame:frame];
    }
    return cell;
}

- (void)scrollShowView:(ScrollShowView*)sender willDisplayCell:(PhotoShowCell*)cell forIndex:(int)idx {
    if (abs(currentIndex-idx) > 1) {
        currentIndex = -1;
    }
    if (contentArray.count > 0) {
        id obj = [contentArray objectAtIndex:idx];
        if ([obj isKindOfClass:[NSString class]]) {
            NSString *url = nil;
            url = obj;
            ImageProgress * progress = [[ImageProgress alloc] initWithUrl:url delegate:operationQueue];
            if (progress.loaded) {
                cell.image = progress.image;
            } else {
                progress.tag = idx;
                [operationQueue addOperation:progress];
            }
        } else if ([obj isKindOfClass:[SharePicture class]]) {
            NSString *url = nil;
            url = [(SharePicture*)obj originUrl];
            ImageProgress * progress = [[ImageProgress alloc] initWithUrl:url delegate:operationQueue];
            if (progress.loaded) {
                cell.image = progress.image;
            } else {
                progress.tag = idx;
                [operationQueue addOperation:progress];
            }
        }

    } else {
        self.loading = NO;
        [self setLoading:NO];
    }
}

- (void)scrollShowView:(ScrollShowView*)sender didShowCell:(ScrollShowViewCell*)cell forIndex:(int)idx {
    if (!self.navigationController.navigationBarHidden) {
        CGRect frame = tarbarView.frame;
        frame.origin.y = frame.origin.y * 2;
        [UIView animateWithDuration:0.3 animations:^{
            tarbarView.frame = frame;
        }];
        
    }
    if (currentIndex != idx) {
        currentIndex = idx;
    }
    PhotoShowCell * pcell = (PhotoShowCell*)[sender cellForIndex:idx-1];
    if (pcell) {
        [pcell.scrollView setZoomScale:1.0 animated:YES];
    }
    PhotoShowCell * ncell = (PhotoShowCell*)[sender cellForIndex:idx+1];
    if (ncell) {
        [ncell.scrollView setZoomScale:1.0 animated:YES];
    }
}

#pragma mark - imageProgress
- (void)imageProgressCompleted:(UIImage *)img indexPath:(NSIndexPath *)indexPath idx:(NSInteger)idx url:(NSString *)url tag:(NSInteger)tag
{
    PhotoShowCell *cell = (PhotoShowCell*)[scrollView cellForIndex:tag];
    cell.image = img;
}

@end
