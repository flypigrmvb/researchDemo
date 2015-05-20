//
//  VPImageCropperViewController.h
//  VPolor
//
//  Created by Vinson.D.Warm on 12/30/13.
//  Copyright (c) 2013 Huang Vinson. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^ImageCompletedBlock)(BOOL didFinished, UIImage * editedImage);

@interface VPImageCropperViewController : BaseViewController
@property (nonatomic, assign) CGRect cropFrame;

- (void)setCompletionBlock:(ImageCompletedBlock)completionBlock;
- (id)initWithImage:(UIImage *)originalImage cropFrame:(CGRect)cropFrame limitScaleRatio:(NSInteger)limitRatio title:(NSString*)title;

@end
