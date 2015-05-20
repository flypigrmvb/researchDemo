//
//  WebViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "WebViewController.h"
#import "CameraActionSheet.h"
#import "Globals.h"
#import "Message.h"

@interface WebViewController ()<CameraActionSheetDelegate> {
    IBOutlet UIWebView *webView;
    UIActivityIndicatorView *activityIndicator;
}
@end

@implementation WebViewController
@synthesize url, title, nid;

- (id)init
{
    self = [super initWithNibName:@"WebViewController" bundle:NULL];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    self.item = nil;
    self.url = nil;
    self.nid = nil;
    [activityIndicator stopAnimating];
    Release(activityIndicator);
    Release(webView);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIScrollView  *scroller = [webView.subviews objectAtIndex:0];
    if (scroller) {
        for (UIView *v in [scroller subviews]) {
            if ([v isKindOfClass:[UIImageView class]]) {
                [v removeFromSuperview];
            }
        }
    }
    self.navigationItem.title = title;
    [self setRightBarButtonImage:[UIImage imageNamed:@"more" isCache:YES] highlightedImage:nil selector:@selector(btnRightPressed:)];

    UIView *view = [[UIView alloc] initWithFrame:webView.frame];
    [view setBackgroundColor:[UIColor clearColor]];
    view.tag = 999;
    [view setAlpha:0.8];
    [self.view addSubview:view];
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
    [activityIndicator setCenter:view.center];
    activityIndicator.color = kbColor;
    [view addSubview:activityIndicator];
    // Do any additional setup after loading the view from its nib.
    NSURL *nsurl =[NSURL URLWithString:self.url];
    NSURLRequest *request =[NSURLRequest requestWithURL:nsurl];
    [webView loadRequest:request];
    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
}

//开始加载数据
- (void)webViewDidStartLoad:(UIWebView *)sender {
    [activityIndicator startAnimating];
}

//数据加载完
- (void)webViewDidFinishLoad:(UIWebView *)sender {
    [activityIndicator stopAnimating];
    UIView *view = (UIView *)[self.view viewWithTag:999];
    [view removeFromSuperview];
    if (!title) {
       self.navigationItem.title = [sender stringByEvaluatingJavaScriptFromString:@"document.title"];
    }
}

- (void)btnRightPressed:(id)sender {
    [[[CameraActionSheet alloc] initWithActionTitle:nil TextViews:nil CancelTitle:@"取消" withDelegate:self otherButtonTitles:@"发送给朋友", @"分享.正能量", @"收藏", nil] show];
}

- (void)cameraActionSheet:(CameraActionSheet *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 3) {
		return;
	}
}

- (BOOL)requestDidFinish:(BSClient *)sender obj:(NSDictionary *)obj
{
    if ([super requestDidFinish:sender obj:obj]) {
    
    }
    return NO;
}

@end
