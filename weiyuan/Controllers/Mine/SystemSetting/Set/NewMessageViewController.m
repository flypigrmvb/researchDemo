//
//  NewMessageViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "NewMessageViewController.h"
#import "BaseTableViewCell.h"
#import "KLSwitch.h"
#import "Globals.h"

#define kBColor RGBCOLOR(50, 154, 233)

@interface NewMessageViewController () {
    IBOutlet KLSwitch * customSwitch0;
    IBOutlet KLSwitch * customSwitch1;
    IBOutlet KLSwitch * customSwitch2;
}

@property (nonatomic, strong) IBOutlet UIView   * sectionViewTwo;
@property (nonatomic, assign) BOOL canplayVoice;
@property (nonatomic, assign) BOOL canplayShake;
@property (nonatomic, assign) BOOL canreceiveNewMessage;
@end

@implementation NewMessageViewController
@synthesize canreceiveNewMessage, canplayVoice, canplayShake;

- (id)init
{
    self = [super initWithNibName:@"NewMessageViewController" bundle:NULL];
    if (self) {
        // Custom initialization
        [KLSwitch class];
        User *user = [[BSEngine currentEngine] user];
        canplayVoice = [user readConfigWithKey:@"canplayVoice"].boolValue;
        canplayShake = [user readConfigWithKey:@"canplayShake"].boolValue;
        canreceiveNewMessage = [user readConfigWithKey:@"canreceiveNewMessage"].boolValue;
    }
    
    return self;
}

- (void)setCanreceiveNewMessage:(BOOL)can {
    if ([super startRequest]) {
        [client setNoticeForIphone:can];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"新消息通知";

    if (!canreceiveNewMessage) {
        [self.sectionViewTwo setHeight:0];
    }
    self.sectionViewTwo.clipsToBounds = YES;
    
    [customSwitch0 setOn:canreceiveNewMessage animated:YES];
    __block NewMessageViewController *blockSelf = self;
    User *user = [[BSEngine currentEngine] user];
    [customSwitch0 setDidChangeHandler:^(BOOL isOn) {
        blockSelf.canreceiveNewMessage = isOn;
    }];
    
    [customSwitch1 setOn:canplayVoice animated:YES];
    [customSwitch1 setDidChangeHandler:^(BOOL isOn) {
        blockSelf.canplayVoice = isOn;
        [user saveConfigWhithKey:@"canplayVoice" value:[NSString stringWithFormat:@"%d",isOn]];
    }];
    
    [customSwitch2 setOn:canplayShake animated:YES];
    [customSwitch2 setDidChangeHandler:^(BOOL isOn) {
        blockSelf.canplayShake = isOn;
        [user saveConfigWhithKey:@"canplayShake" value:[NSString stringWithFormat:@"%d",isOn]];
    }];
    [customSwitch0 setOnTintColor: kBColor];
    [customSwitch1 setOnTintColor: kBColor];
    [customSwitch2 setOnTintColor: kBColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (canreceiveNewMessage) {
        User *user = [[BSEngine currentEngine] user];
        canplayVoice = [user readConfigWithKey:@"canplayVoice"].boolValue;
        canplayShake = [user readConfigWithKey:@"canplayShake"].boolValue;
        if (canplayVoice && canplayShake) {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge |UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];
        } else if (canplayVoice && !canplayShake) {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge |UIRemoteNotificationTypeSound];
        } else if (!canplayVoice && canplayShake) {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge |UIRemoteNotificationTypeAlert];
        } else {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge];
        }
    }
}

- (BOOL)requestDidFinish:(id)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        User *user = [[BSEngine currentEngine] user];
        canreceiveNewMessage = !canreceiveNewMessage;
        [user saveConfigWhithKey:@"canreceiveNewMessage" value:[NSString stringWithFormat:@"%d",canreceiveNewMessage]];
        if (!canreceiveNewMessage) {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge];
        }
    } else {
        [customSwitch0 setOn:canreceiveNewMessage animated:YES];
    }
    if (canreceiveNewMessage) {
        [self.sectionViewTwo setHeight:78];
    } else {
        [self.sectionViewTwo setHeight:0];
    }
    return NO;
}

@end
