//
//  BlackListViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "BlackListViewController.h"
#import "SessionCell.h"
#import "UIColor+FlatUI.h"
#import "UIImage+FlatUI.h"
#import "UIButton+NSIndexPath.h"
#import "UserInfoViewController.h"

@interface BlackListViewController ()
@end

@implementation BlackListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"黑名单";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDataList:) name:@"refreshList" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (isFirstAppear && [super startRequest]) {
        [client blackList];
    }
}

- (BOOL)requestDidFinish:(BSClient*)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        if ([sender.tag isEqualToString:@"cancel"]) {
            [contentArr removeObjectAtIndex:sender.indexPath.row];
            [tableView reloadData];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshList" object:nil];
        } else {
            NSArray *data = [obj getArrayForKey:@"data"];
            for (NSDictionary *dic in data) {
                User * item = [User objWithJsonDic:dic];
                [item insertDB];
                [contentArr addObject:item];
            }
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
    return YES;
}

- (void)refreshDataList:(NSNotification*)sender {
    // 有人被移除黑名单
    if (contentArr.count > 0) {
        User * user = sender.object;
        [contentArr removeObject:user];
        [tableView reloadData];
    }
}

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"SessionCell";
    BaseTableViewCell * cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
    UIButton *otherBtn = (UIButton *)[cell.contentView viewWithTag:98];
    if (!cell) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        otherBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [otherBtn infoStyle];
        [otherBtn setTitle:@"取消黑名单" forState:UIControlStateNormal];
        otherBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        otherBtn.frame = CGRectMake(cell.width - 100, 10, 80, 30);
        [cell.contentView addSubview:otherBtn];
        [otherBtn addTarget:self action:@selector(cancelblack:) forControlEvents:UIControlEventTouchUpInside];
    }
    otherBtn.indexPath = indexPath;
    User * itemS = [contentArr objectAtIndex:indexPath.row];
    cell.superTableView = sender;
    
    cell.textLabel.text = itemS.nickname;
    cell.detailTextLabel.text = itemS.sign;

    cell.backgroundColor = RGBACOLOR(255, 255, 251, 0.8);
    [cell update:^(NSString *name) {
        otherBtn.top = (cell.height - 30)/2;
        [cell autoAdjustText];
        cell.detailTextLabel.width = cell.width - cell.imageView.right - 100;
    }];
    return cell;
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    id item = [contentArr objectAtIndex:indexPath.row];
    UserInfoViewController * con = [[UserInfoViewController alloc] init];
    [con setUser:item];
    [self pushViewController:con];
}

- (NSString*)baseTableView:(UITableView *)sender imageURLAtIndexPath:(NSIndexPath *)indexPath {
    User * user = [contentArr objectAtIndex:indexPath.row];
    return user.headsmall;
}

- (void)cancelblack:(UIButton*)sender {
    [super startRequest];
    User * itemS = [contentArr objectAtIndex:sender.indexPath.row];
    client.indexPath = sender.indexPath;
    client.tag = @"cancel";
    [client black:itemS.uid];
}

@end
