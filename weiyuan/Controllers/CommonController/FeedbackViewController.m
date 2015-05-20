//
//  FeedbackViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "FeedbackViewController.h"
#import "User.h"

@interface FeedbackViewController () <UITextViewDelegate> {
    User                 * user;
    IBOutlet UIImageView * bkgTextView;
    IBOutlet UITextView  * tvContent;
}

@end

@implementation FeedbackViewController

- (id)initWithUser:(id)u {
    self = [self init];
    if (self) {
        // Custom initialization
        user = u;
    }
    return self;
}

- (id)init {
    self = [super initWithNibName:@"FeedbackViewController" bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setRightBarButtonImage:LOADIMAGE(@"map_send") highlightedImage:nil selector:@selector(btnCommitPressed:)];

    self.navigationItem.title = NSLocalizedString(@"反馈意见", nil);

    [self setEdgesNone];
    UIImage * tfImg = [[UIImage imageNamed:@"bkg_bb_textField"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
    bkgTextView.image = tfImg;
    
    tvContent.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [tvContent becomeFirstResponder];
}

- (void)btnCommitPressed:(id)sender {
    [tvContent resignFirstResponder];
    [self sendRequest];
}

- (BOOL)sendRequest {
    if (!([tvContent.text isKindOfClass:[NSString class]] && tvContent.text.length > 0)) {
        [self showAlert:@"真的不想说点什么吗？" isNeedCancel:NO];
        return NO;
    }
    if ([super startRequest]) {
        [client feedback:tvContent.text];
    }
    return YES;
}


- (BOOL)requestDidFinish:(BSClient *)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        [self showText:sender.errorMessage];
        [self popViewController];
    }
    return YES;
}

@end
