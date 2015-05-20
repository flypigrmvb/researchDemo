//
//  ImageViewController.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "Declare.h"

typedef void(^DeletedPicture)(BOOL del);
@interface ImageViewController : BaseViewController <UIAlertViewDelegate>{
    IBOutlet UIScrollView * scrollView;
    IBOutlet UIImageView * imageView;
    IBOutlet UIActivityIndicatorView * indicatorView;
}
@property (nonatomic, strong) UIImage * bkgImage;
@property (nonatomic, strong) DeletedPicture block;
@property (nonatomic, assign) LookPictureState lookPictureState;

+ (void)showWithFrameStart:(CGRect)fra supView:(UIView*)supv pic:(NSString*)pic preview:(NSString*)pre;
- (id)initWithFrameStart:(CGRect)fra supView:(UIView*)supv pic:(NSString*)pic preview:(NSString*)pre;

@end
