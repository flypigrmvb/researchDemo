//
//  MeetingManagerController.m
//  ReSearch
//
//  Created by kiwi on 14-9-2.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "MeetingManagerController.h"
#import "MeetingActiveViewController.h"
#import "MeetingMessageListViewController.H"

@implementation MeetingManagerController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"会议管理";
    UIButton * inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    inviteButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
    inviteButton.frame = CGRectMake(20, 200, self.view.width - 40, 40);
    [inviteButton defaultStyle];
    inviteButton.tag = 1;
    [inviteButton addTarget:self action:@selector(itemPressed:) forControlEvents:UIControlEventTouchUpInside];
    [inviteButton setTitle:@"处理参会申请" forState:UIControlStateNormal];
    [self.view addSubview:inviteButton];
    
    UIButton * managerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    managerButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
    managerButton.frame = CGRectMake(20, inviteButton.bottom + 20, self.view.width - 40, 40);
    [managerButton navStyle];
    managerButton.tag = 2;
    [managerButton addTarget:self action:@selector(itemPressed:) forControlEvents:UIControlEventTouchUpInside];
    [managerButton setTitle:@"参会用户活跃度排行" forState:UIControlStateNormal];
    [self.view addSubview:managerButton];
}

- (void)itemPressed:(UIButton*)sender {
    if (sender.tag == 1) {
        MeetingMessageListViewController * con = [[MeetingMessageListViewController alloc] init];
        con.item = self.item;
        [self pushViewController:con];
    } else {
        MeetingActiveViewController * con = [[MeetingActiveViewController alloc] init];
        con.item = self.item;
        [self pushViewController:con];
    }
}

@end
