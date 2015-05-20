//
//  InvitationViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "InvitationViewController.h"
#import "Contact.h"
#import "Globals.h"
#import <MessageUI/MessageUI.h>

@interface InvitationViewController ()<MFMessageComposeViewControllerDelegate> {
    IBOutlet UILabel * nameLabel;
    IBOutlet UILabel * phoneLabel;
    IBOutlet UILabel * nameLabel1;
    IBOutlet UIImageView * imageView;
    IBOutlet UIView * headView;
    IBOutlet UIButton * invButton;
}

@end

@implementation InvitationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"邀请";
    headView.layer.masksToBounds = YES;
    headView.layer.cornerRadius = 4;
    headView.layer.borderColor = RGBCOLOR(220, 220, 220).CGColor;
    headView.layer.borderWidth = 1;
    [invButton navStyle];
    nameLabel1.text = [NSString stringWithFormat:@"%@还未开通", _item.nickname];
    nameLabel.text = _item.nickname;
    phoneLabel.text = _item.phone;
    NSData * dat = [Contact getImageByID:_item.personId];
    if (dat) {
        imageView.image = [UIImage imageWithData:dat];
    }
    
    [self setEdgesNone];
}

- (IBAction)invitation:(id)sender
{
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController * MsgController = [[MFMessageComposeViewController alloc] init];
        MsgController.recipients = [NSArray arrayWithObject:_item.phone];
        MsgController.body = @"我正在使用《睿社区》这款应用,邀请你也来使用。详情请访问 http://www.xxx.com";
        MsgController.messageComposeDelegate = self;
        [self presentModalController:MsgController animated:YES];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissModalController:YES];
    if (result == MessageComposeResultCancelled)
        DLog(@"Message cancelled");
    else if (result == MessageComposeResultSent)
        DLog(@"Message sent");
    else
        DLog(@"Message failed");
}

@end
