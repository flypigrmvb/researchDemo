//
//  NewMessageViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//
#import "PrivacyViewController.h"
#import "BaseTableViewCell.h"
#import "KLSwitch.h"
#import "Globals.h"

@interface PrivacyViewController () {
    /**是否推荐通讯录朋友*/
    BOOL isNoticedNewFriend;
    /**加我为朋友时是否需要验证*/
    BOOL isVerify;
}
@end

@implementation PrivacyViewController

- (id)init {
    self = [super init];
    if (self) {
        // Custom initialization
        
        User * user = [[BSEngine currentEngine] user];
        isNoticedNewFriend = [user readConfigWithKey:@"isNoticedNewFriend"].boolValue;
        isVerify = [user readConfigWithKey:@"isVerify"].boolValue;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"隐私设置";
    self.tableViewCellHeight = 43;
}


- (NSInteger)tableView:(UITableView *)sender numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)sender heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (UIView *)tableView:(UITableView *)sender viewForHeaderInSection:(NSInteger)section {
    UIImageView *clearView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, sender.width, 20)];
    clearView.backgroundColor = [UIColor clearColor];
    return clearView;
}

- (UITableViewCell *)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"UITableViewCell";
    BaseTableViewCell *cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    [cell addSwitch];
    cell.customSwitch.left = cell.width - 75;
    User * user = [[BSEngine currentEngine] user];
    cell.topLine = NO;
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                {
                    cell.textLabel.text = @"加我为朋友时需要验证";
                    [cell setSwitchON:isVerify];
                    [cell.customSwitch setDidChangeHandler:^(BOOL isOn) {
                        client = [[BSClient alloc] initWithDelegate:self action:@selector(requestDidFinish:obj:)];
                        [self setLoading:YES content:@"设置中"];
                        [client setVerify];
                    }];
                }
                    break;
                default:
                    break;
            }
            break;
        case 1: {
            cell.textLabel.text = @"向我推荐通讯录朋友";
            [cell setSwitchON:isNoticedNewFriend];
            [cell.customSwitch setDidChangeHandler:^(BOOL isOn) {
                isNoticedNewFriend = !isNoticedNewFriend;
                [user saveConfigWhithKey:@"isNoticedNewFriend" value:[NSString stringWithFormat:@"%d",isNoticedNewFriend]];
            }];
        }
           
            break;
        default:
            break;
    }
    [cell update:^(NSString *name) {
        cell.customSwitch.right = cell.width - 15;
        cell.backgroundColor =
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }];
    cell.imageView.hidden = YES;
    return cell;
}

- (void)tableView:(UITableView *)sender willDisplayCell:(BaseTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (BOOL)requestDidFinish:(BSClient *)sender obj:(NSDictionary *)obj
{
    BaseTableViewCell *cell = (BaseTableViewCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    User *user = [[BSEngine currentEngine] user];
    if ([super requestDidFinish:sender obj:obj]) {
        isVerify = !isVerify;
        [user saveConfigWhithKey:@"isVerify" value:[NSString stringWithFormat:@"%d",isVerify]];
    } else {
       [cell setSwitchON:isVerify];
    }
    
    return NO;
}
@end
