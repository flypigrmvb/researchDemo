//
//  PhotoView.m
//  QiChuang
//
//  Created by keen on 14-2-13.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "PhotoView.h"
#import "ImageProgressQueue.h"
#import "Globals.h"

#define PhotoMaximumZoomScale 2.5

@interface PhotoView () <UIScrollViewDelegate> {
    UIActivityIndicatorView* actView;
    ImageProgress* progress;
}

@property (nonatomic, assign) id <PhotoViewDelegate> phDelegate;

@end

@implementation PhotoView

@synthesize imgUrl;
@synthesize phDelegate;
@synthesize imageView;

- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame delegate:nil];
}

- (id)initWithFrame:(CGRect)frame delegate:(id<PhotoViewDelegate>)del {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.phDelegate = del;
        self.delegate = self;
        [self initImageView];
    }
    return self;
}


- (void)setImgUrl:(NSString *)url {
    imageView.image = [Globals getImageGray];
    
    imgUrl = url;
    
    if (imgUrl.length > 10) {
        [progress cancelDownload];
        progress = nil;
        
        progress = [[ImageProgress alloc] initWithUrl:imgUrl delegate:self];
        if (progress.loaded) {
            [actView stopAnimating];
            imageView.image = progress.image;
        } else {
            [actView startAnimating];
            [progress startDownload];
        }
    }
}

- (void)imageProgress:(ImageProgress*)sender completed:(BOOL)bl {
    if (bl && sender.loaded) {
        [actView stopAnimating];
        imageView.image = sender.image;
    }
}

- (void)initImageView {
    self.imageView = [[UIImageView alloc]init];
    
    // The imageView can be zoomed largest size
    imageView.frame = CGRectMake(0, 0, self.width*PhotoMaximumZoomScale, self.height*PhotoMaximumZoomScale);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.userInteractionEnabled = YES;
    [self addSubview:imageView];
    
    actView = [[UIActivityIndicatorView alloc] init];
    actView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    actView.hidesWhenStopped = YES;
    actView.center = self.center;
    [self addSubview:actView];
    
    // Add gesture,double tap zoom imageView.
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(handleDoubleTap:)];
    [doubleTapGesture setNumberOfTapsRequired:2];
    [imageView addGestureRecognizer:doubleTapGesture];
    
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(handleSingleTap:)];
    [singleTapGesture setNumberOfTapsRequired:1];
    [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
    [imageView addGestureRecognizer:singleTapGesture];

    
    [self initializeScale];
}

- (void)initializeScale {
    float minimumScale = 1/PhotoMaximumZoomScale;
    [self setMinimumZoomScale:minimumScale];
    [self setZoomScale:minimumScale];
}

#pragma mark - Zoom methods

- (void)handleSingleTap:(UIGestureRecognizer *)gesture {
    if ([phDelegate respondsToSelector:@selector(photoViewDidPress:)]) {
        [phDelegate photoViewDidPress:self];
    }
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gesture {
    float newScale = self.zoomScale;
    if (self.zoomScale < 1) {
        newScale = 1;
    } else {
        newScale = 1/PhotoMaximumZoomScale;
    }
    
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gesture locationInView:gesture.view]];
    [self zoomToRect:zoomRect animated:YES];
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    CGRect zoomRect;
    zoomRect.size.height = self.frame.size.height / scale;
    zoomRect.size.width  = self.frame.size.width  / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}


#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)sender {
    return imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)sender withView:(UIView *)view atScale:(CGFloat)scale {
    [sender setZoomScale:scale animated:NO];
}

@end
