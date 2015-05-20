//
//  ImageTouchView.m
//
//  AppDelegate.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "ImageTouchView.h"

@interface ImageTouchView () {
    BOOL onAction;
}

@end

@implementation ImageTouchView
@synthesize delegate, tag;

- (id)initWithFrame:(CGRect)frame delegate:(id <ImageTouchViewDelegate>)del {
    if (self = [super initWithFrame:frame]) {
        [self inSetup];
        self.delegate = del;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self inSetup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self inSetup];
    }
    return self;
}

- (id)init {
    if (self = [super init]) {
        [self inSetup];
    }
    return self;
}

- (void)inSetup {
    self.clipsToBounds = NO;
    self.contentMode = UIViewContentModeScaleAspectFit;
    self.userInteractionEnabled = YES;
}

- (void)dealloc {
    Release(delegate);
    Release(tag);
}

- (void)setEdgingImage:(UIImage *)eImage {
    if (!_edgingImageView) {
        _edgingImageView = [[UIImageView alloc] init];
        _edgingImageView.contentMode = UIViewContentModeScaleToFill;
        [self insertSubview:_edgingImageView atIndex:0];
    }
    _edgingImageView.frame = self.bounds;
    _edgingImageView.image = eImage;
}

- (void)setSize:(CGSize)size {
    [super setSize:size];
    if (_edgingImageView) {
        _edgingImageView.size = size;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    onAction = YES;
    if (self.highlightedImage) {
        [self setHighlighted:onAction];
    }
    [UIView beginAnimations:@"DOWN" context:NULL];
    [UIView setAnimationDelegate:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:nil cache:YES];
    self.alpha = 0.5;
    [UIView commitAnimations];
    if ([delegate respondsToSelector:@selector(imageTouchViewDidBegin:)]) {
        [delegate imageTouchViewDidBegin:self];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (onAction) {
        UITouch * touch = [[event allTouches] anyObject];
        CGPoint touchLocation = [touch locationInView:self];
        if (!CGRectContainsPoint(self.bounds, touchLocation)) {
            [self touchesCancelled:touches withEvent:event];
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (onAction) {
        onAction = NO;
        if (self.highlightedImage) {
            [self setHighlighted:onAction];
        }
        [UIView beginAnimations:@"NOR" context:NULL];
        [UIView setAnimationDelegate:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:nil cache:YES];
        self.alpha = 1.0;
        [UIView commitAnimations];
        if ([delegate respondsToSelector:@selector(imageTouchViewDidCancel:)]) {
            [delegate imageTouchViewDidCancel:self];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (onAction) {
        [self touchesCancelled:touches withEvent:event];
        if ([delegate respondsToSelector:@selector(imageTouchViewDidSelected:)]) {
            [delegate imageTouchViewDidSelected:self];
        }
    }
}

@end
