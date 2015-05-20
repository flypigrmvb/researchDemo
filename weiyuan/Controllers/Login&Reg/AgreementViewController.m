//
//  AgreementViewController.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "AgreementViewController.h"
#import "Notify.h"

@interface AgreementViewController () <UIWebViewDelegate>{
    IBOutlet UITextView     * textView;
    UIWebView               * webView;
    UIActivityIndicatorView * activityIndicator;
}
@end

@implementation AgreementViewController
@synthesize notice, arType;

- (id)init {
    if (self = [super initWithNibName:@"AgreementViewController" bundle:nil]) {
        // Custom initialization
        arType = 0;
    }
    return self;
}

- (void)dealloc {
    self.notice = nil;
    [activityIndicator stopAnimating];
    Release(activityIndicator);
    Release(webView);
    Release(textView);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (notice) {
        self.navigationItem.title = @"系统通知";
        textView.text = notice;
    } else {
        textView.hidden = YES;
        webView = [[UIWebView alloc] initWithFrame:self.view.frame];
        webView.delegate = self;
        webView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:webView];
        if (arType == 1) {
            self.navigationItem.title = @"注册协议";
        } else {
            self.navigationItem.title = @"用户协议";
        }
    }
    UIView *view = [[UIView alloc] initWithFrame:webView.frame];
    [view setBackgroundColor:[UIColor clearColor]];
    view.tag = 999;
    [view setAlpha:0.8];
    [self.view addSubview:view];
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
    [activityIndicator setCenter:view.center];
    activityIndicator.color = kbColor;
    [view addSubview:activityIndicator];
    [self setEdgesNone];
    needToLoad = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    if (isFirstAppear && !notice && [super startRequest]) {
        client.tag = @"notice";
        [client userAgreement:arType];
    }
}

- (BOOL)requestDidFinish:(BSClient*)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        NSDictionary *dic = [obj getDictionaryForKey:@"data"];
        if ([sender.tag isEqualToString:@"notice"]) {
            NSString *url = [dic getStringValueForKey:@"propvalue" defaultValue:@""];
            NSURL *nsurl =[NSURL URLWithString:url];
            NSURLRequest *request =[NSURLRequest requestWithURL:nsurl];
            [webView loadRequest:request];
        }
        
    }
    return YES;
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
}

@end
