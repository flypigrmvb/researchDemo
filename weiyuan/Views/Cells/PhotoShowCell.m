//
//  PhotoShowCell.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "PhotoShowCell.h"

@interface PhotoShowCell () {
    UIActivityIndicatorView * indicatorView;
}

@end

@implementation PhotoShowCell
@synthesize scrollView, image, imageView;

- (id)initWithIndex:(NSInteger)idx frame:(CGRect)frame {
    self = [super initWithIndex:idx frame:frame];
    if (self) {
        // Initialization code
        UIScrollView * scroller = [[UIScrollView alloc] initWithFrame:self.bounds];
        scroller.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        scroller.delegate = self;
        scroller.zoomScale = 1.0;
        scroller.minimumZoomScale = 1.0;
        [self addSubview:scroller];
        self.scrollView = scroller;
  
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
//        imgV.autoresizingMask = UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleHeight;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [scroller addSubview:imageView];

        screenFrame = [[UIScreen mainScreen] bounds];
        UITapGestureRecognizer * doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap)];
        doubleTapGesture.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTapGesture];

        UITapGestureRecognizer * singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap)];
        singleTapGesture.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTapGesture];

        
        indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        indicatorView.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        [self addSubview:indicatorView];
        [indicatorView startAnimating];
    }
    return self;
}

- (void)dealloc {
    self.scrollView = nil;
}

- (void)doubleTap{
    if (singleOnWait) {
        singleOnWait = NO;
        if (scrollView.zoomScale > 1.0) {
            [scrollView setZoomScale:1.0 animated:YES];
        } else {
            [scrollView setZoomScale:1.5 animated:YES];
        }
        [timer invalidate];
        timer = nil;
    }
}

- (void)singleTap {
    singleOnWait = YES;
    timer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(singleTapDid) userInfo:nil repeats:NO];
}

- (void)singleTapDid {
    if (singleOnWait) {
        singleOnWait = NO;
        ScrollShowView * supV = (ScrollShowView*)self.superview.superview;
        [supV.delegate performSelector:@selector(singleTap)];
    }
}

- (UIImage*)image {
    return imageView.image;
}

- (void)setImage:(UIImage*)img {
    [indicatorView stopAnimating];
    [indicatorView removeFromSuperview];
    indicatorView = nil;
    imageView.image = img;
    if (img) {
        imageSize = img.size;
        [self generate];
        CGFloat kw = screenFrame.size.width;
        CGFloat kh = screenFrame.size.height;
        CGFloat biggerTime = img.size.width/kw;
        if (imageSize.height/kh > biggerTime) {
            biggerTime = imageSize.height/kh;
        }
        biggerTime += 0.8;
        if (biggerTime < 1.5) {
            biggerTime = 1.5;
        }
        scrollView.maximumZoomScale = biggerTime;
    }
}

- (void)generate {
    [scrollView setZoomScale:1.0 animated:NO];
    screenFrame = self.frame;
    std_hw = screenFrame.size.height/screenFrame.size.width;
    CGFloat kw = screenFrame.size.width;
    CGFloat kh = screenFrame.size.height;
    hw = imageSize.height/imageSize.width;
    CGFloat contentWidth = kw;
    CGFloat contentHeight = kh;
    
    if (hw > std_hw) {
        contentWidth = contentHeight/hw;
        [imageView setFrame:CGRectMake((kw-contentWidth)/2, 0, contentWidth, contentHeight)];
    } else if (hw < std_hw) {
        contentHeight = contentWidth*hw;
        [imageView setFrame:CGRectMake(0, (kh-contentHeight)/2, contentWidth, contentHeight)];
    }
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView*)sender {
    return imageView;
}

- (void)scrollViewDidZoom:(UIScrollView*)sender {
    UIImageView * imgView = (UIImageView*)imageView;
    CGRect frame = imgView.frame;
    
    if (hw > std_hw) {
        frame.origin.x = (screenFrame.size.width-frame.size.width)/2;
        if (frame.origin.x<0) {
            frame.origin.x = 0;
        }
    } else if (hw < std_hw) {
        frame.origin.y = (screenFrame.size.height-frame.size.height)/2;
        if (frame.origin.y<0) {
            frame.origin.y = 0;
        }
    }
    
    [imgView setFrame:frame];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self generate];
}

@end
