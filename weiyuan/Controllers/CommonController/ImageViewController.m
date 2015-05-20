//
//  ImageViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "ImageViewController.h"
#import "ImageProgressQueue.h"
#import "KAlertView.h"
#import "Globals.h"
#import "CameraActionSheet.h"
#import "SessionNewController.h"
#import "Session.h"
#import "TalkingViewController.h"
#import "JSON.h"
#import "Message.h"

static ImageViewController * imageViewController = nil;

@interface ImageViewController ()<UIGestureRecognizerDelegate> {
    CGRect screenFrame;
    CGFloat hw;
    CGFloat std_hw;
    
    CGRect startFrame;
    NSString * imageURL;
    
    NSString * preURL;
    
    UIView * superView;
    CGRect contentFrame;
    BOOL shouldforwordMsg;
}
@property (nonatomic, retain) ImageProgress * progress;
@property (nonatomic, assign) CGRect startFrame;

@end

@implementation ImageViewController
@synthesize progress, startFrame;

+ (void)showWithFrameStart:(CGRect)fra supView:(UIView*)supv pic:(NSString*)pic preview:(NSString*)pre {
    Release(imageViewController);
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    window.userInteractionEnabled = NO;
    imageViewController = [[ImageViewController alloc] initWithFrameStart:fra supView:supv pic:pic preview:pre];
    [window addSubview:imageViewController.view];
    [imageViewController viewDidAppear:YES];
}

- (id)initWithFrameStart:(CGRect)fra supView:(UIView*)supv pic:(NSString*)pic preview:(NSString*)pre {
    if (self = [super initWithNibName:@"ImageViewController" bundle:nil]) {
        // Custom initialization
        superView = supv;
        startFrame = fra;
        imageURL = pic;
        preURL = pre;
//        self.wantsFullScreenLayout = YES;
        shouldforwordMsg = NO;
    }
    return self;
}

- (void)dealloc {
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
#if __IPHONE_7_0
    if ([UIDevice currentDevice].systemVersion.intValue < 7) {
#endif
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
#if __IPHONE_7_0
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }
#endif
    self.view.backgroundColor = [UIColor clearColor];
    scrollView.backgroundColor = [UIColor blackColor];
    
    scrollView.hidden = NO;
    UIImageView * imgV = (UIImageView*)[scrollView viewWithTag:63];
    imgV.height = self.view.height;
    imgV.centerY = scrollView.height/2;
    
    if ([preURL isKindOfClass:[NSString class]] && preURL.length > 0) {
        ImageProgress * pro = [[ImageProgress alloc] initWithUrl:preURL delegate:nil];
        if (pro.loaded) {
            imgV.image = pro.image;
        }
    } else {
        UIImage * img = (id)preURL;
        if ([img isKindOfClass:[UIImage class]]) {
            imgV.image = img;
        }
    }
    if (_bkgImage) {
        UIImageView * bkgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        [self.view insertSubview:bkgView atIndex:0];
        imageView.image = _bkgImage;
    }
    self.view.hidden = YES;
    self.navigationItem.title = @"查看大图";
    
    if (_lookPictureState == forLookPictureStateMore) {
        [self setRightBarButtonImage:LOADIMAGE(@"btn_more") highlightedImage:LOADIMAGE(@"btn_more_d") selector:@selector(morePressed)];
    } else if (_lookPictureState == forLookPictureStateDelete) {
        [self setRightBarButton:@"删除" selector:@selector(morePressed)];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (isFirstAppear) {
        self.view.hidden = NO;
        scrollView.userInteractionEnabled = NO;
        scrollView.frame = self.startFrame;
        [UIView beginAnimations:@"SHOW" context:nil];
        [UIView setAnimationDuration:0.35];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationEnd:finished:context:)];
        scrollView.frame = self.view.frame;
        [UIView commitAnimations];
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

- (void)morePressed {
    if (_lookPictureState == forLookPictureStateMore) {
        [[[CameraActionSheet alloc] initWithActionTitle:nil TextViews:nil CancelTitle:@"取消" withDelegate:self otherButtonTitles:@"发送给朋友", @"收藏", @"保存到手机", nil] show];
    } else if (_lookPictureState == forLookPictureStateDelete) {
        [self showAlert:@"真的要删除这张图片吗？" isNeedCancel:YES];
    }
}

- (void)kwAlertView:(id)sender didDismissWithButtonIndex:(NSInteger)index {
    if (index == 1) {
        [self back];
        if (_block) {
            _block(YES);
        }
    }
}

- (void)back {
    if (progress) {
        [progress cancelDownload];
        Release(progress);
    }
#if __IPHONE_7_0
    if ([UIDevice currentDevice].systemVersion.intValue < 7) {
#endif
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
#if __IPHONE_7_0
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }
#endif
    
    if (scrollView.zoomScale > 1.0) {
        [scrollView setZoomScale:1.0 animated:YES];
        [self performSelector:@selector(backAnimation) withObject:nil afterDelay:0.3];
    } else {
        [self performSelector:@selector(backAnimation)];
    }
}

- (void)doubleTap{
    if (scrollView.zoomScale > 1.0) {
        [scrollView setZoomScale:1.0 animated:YES];
    } else {
        [scrollView setZoomScale:scrollView.maximumZoomScale animated:YES];
    }
}

- (void)popViewController {
    [self back];
}

- (void)singleTap {
    if (self.navigationController) {
        [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
    } else {
        [self back];
    }
    
}

- (void)backAnimation {
    UIImageView * imgV = (UIImageView*)[scrollView viewWithTag:63];
    imgV.frame = self.view.bounds;
    [UIView beginAnimations:@"HIDE" context:nil];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationEnd:finished:context:)];
    scrollView.frame = self.startFrame;
    [UIView commitAnimations];
}

- (void)animationEnd:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
    if ([animationID isEqualToString:@"SHOW"]) {
        UIWindow * window = [UIApplication sharedApplication].keyWindow;
        window.userInteractionEnabled = YES;
#if __IPHONE_7_0
        if ([UIDevice currentDevice].systemVersion.intValue < 7) {
#endif
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
#if __IPHONE_7_0
        } else {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        }
#endif
        UITapGestureRecognizer * doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap)];
        doubleTapGesture.numberOfTapsRequired = 2;
        [scrollView addGestureRecognizer:doubleTapGesture];
        
        UITapGestureRecognizer * singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap)];
        singleTapGesture.numberOfTapsRequired = 1;
        [scrollView addGestureRecognizer:singleTapGesture];
        
        [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
        scrollView.userInteractionEnabled = YES;
        [NSThread detachNewThreadSelector:@selector(imageLoadThread) toTarget:self withObject:nil];
    } else if ([animationID isEqualToString:@"HIDE"]) {
        //        [self.view removeFromSuperview];
        if (self.navigationController) {
            [self.navigationController setNavigationBarHidden:NO animated:YES];
            [self.navigationController popViewControllerAnimated:NO];
        } else {
            [self dismissModalController:NO];
        }
        Release(imageViewController);
    }
}

#pragma mark -
#pragma mark - ImageProgress

- (void)imageLoadThread {
    if (imageURL.length > 0) {
        progress = [[ImageProgress alloc] initWithUrl:imageURL delegate:self];
        [self performSelectorOnMainThread:@selector(imageLoadOnMain:) withObject:progress waitUntilDone:YES];
    } else {
        UIImage * img = (id)preURL;
        if ([img isKindOfClass:[UIImage class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateImage:img];
            });
        }
    }
}

- (void)imageLoadOnMain:(ImageProgress*)pro {
    self.view.userInteractionEnabled = YES;
    if (pro.loaded) {
        UIImage * img = pro.image;
        [self updateImage:img];
    } else {
//        UIImageView * imgV = (UIImageView*)[scrollView viewWithTag:63];
//        imgV.alpha = 0.3;
        [indicatorView startAnimating];
        self.progress = pro;
        [pro startDownload];
    }
}

#pragma mark -
#pragma mark - ImageProgressDelegate

- (void)imageProgress:(ImageProgress*)sender completed:(BOOL)bl {
    if (bl) {
        UIImage * img = sender.image;
        [self updateImage:img];
    }
    [indicatorView stopAnimating];
    self.progress = nil;
}

#pragma mark -
#pragma mark - Scroll View Zoom

- (void)updateImage:(UIImage*)img {
    if (img) {
        screenFrame = self.view.bounds;
        UIImageView * imgV = (UIImageView*)[scrollView viewWithTag:63];
        imgV.image = img;
        imgV.alpha = 1;
        std_hw = screenFrame.size.height/screenFrame.size.width;
        CGFloat kw = screenFrame.size.width;
        CGFloat kh = screenFrame.size.height;
        hw = img.size.height/img.size.width;
        CGFloat contentWidth = kw;
        CGFloat contentHeight = kh;
        
        if (hw > std_hw) {
            contentWidth = contentHeight/hw;
            [imgV setFrame:CGRectMake((kw-contentWidth)/2, 0, contentWidth, contentHeight)];
        } else if (hw < std_hw) {
            contentHeight = contentWidth*hw;
            [imgV setFrame:CGRectMake(0, (kh-contentHeight)/2, contentWidth, contentHeight)];
        }
        
        CGFloat biggerTime = img.size.width/kw;
        if (img.size.height/kh > biggerTime) {
            biggerTime = img.size.height/kh;
        }
        biggerTime += 0.8;
        if (biggerTime < 1.5) {
            biggerTime = 1.5;
        }
        scrollView.maximumZoomScale = biggerTime;
        scrollView.userInteractionEnabled = YES;
    } else {
        [self back];
    }
}

#pragma mark -
#pragma mark - UIScrollViewDelegate

- (UIView*)viewForZoomingInScrollView:(UIScrollView*)sender {
    return [scrollView viewWithTag:63];
}

- (void)scrollViewDidZoom:(UIScrollView*)sender {
    if (sender.zoomScale > 1) {
        if (![UIApplication sharedApplication].statusBarHidden) {
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        }
    } else {
        if ([UIApplication sharedApplication].statusBarHidden) {
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        }
    }
    
    UIImageView * imgView = (UIImageView*)[scrollView viewWithTag:63];
    CGRect frame = imgView.frame;
    
    if (hw > std_hw) {
        frame.origin.x = (screenFrame.size.width-frame.size.width)/2;
        if (frame.origin.x < 0) {
            frame.origin.x = 0;
        }
    } else if (hw < std_hw) {
        frame.origin.y = (screenFrame.size.height-frame.size.height)/2;
        if (frame.origin.y < 0) {
            frame.origin.y = 0;
        }
    }
    
    [imgView setFrame:frame];
}

#pragma - mark CameraActionSheetDelegate
- (void)cameraActionSheet:(CameraActionSheet *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        shouldforwordMsg = YES;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        Release(imageViewController);
        [self forwordWithMsg:self.value];
    } else if (buttonIndex == 1) {
        Message * it = self.value;
        if (it && [it isKindOfClass:[Message class]]) {
            NSMutableDictionary * dic = [NSMutableDictionary dictionary];
            [dic setObject:it.imgUrlL forKey:@"urllarge"];
            [dic setObject:it.imgUrlS forKey:@"urlsmall"];
            [dic setObject:[NSString stringWithFormat:@"%f", it.imgWidth]  forKey:@"width"];
            [dic setObject:[NSString stringWithFormat:@"%f", it.imgHeight]  forKey:@"height"];
            [dic setObject:[NSString stringWithFormat:@"%d", forFileImage]  forKey:@"typefile"];
            NSString *otherid = (it.typechat != forChatTypeUser)?it.toId:nil;
            [super startRequest];
            [client addfavorite:it.fromId otherid:otherid content:[dic JSONString]];
        }
        
    } else if (buttonIndex == 2) {
        UIImageView * imgV = (UIImageView*)[scrollView viewWithTag:63];
        UIImageWriteToSavedPhotosAlbum(imgV.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)image:(UIImage*)img didFinishSavingWithError:(NSError*)error contextInfo:(void*)context {
    NSString * msg;
    KAlertType ty;
    if (error == nil) {
        msg = @"保存成功";
        ty = KAlertTypeCheck;
    } else {
        msg = [error localizedFailureReason];
        ty = KAlertTypeError;
    }
    [KAlertView showType:ty text:msg for:1.0 animated:YES];
}

#pragma mark - requset

- (BOOL)requestDidFinish:(BSClient*)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        [self showText:sender.errorMessage];
    }
    return YES;
}
@end
