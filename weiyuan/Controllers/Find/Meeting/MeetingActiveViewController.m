//
//  MeetingActiveViewController.m
//  ReSearch
//
//  Created by kiwi on 14-9-2.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "MeetingActiveViewController.h"
#import "BaseTableViewCell.h"
#import "Meet.h"
#import "UserInfoViewController.h"
#import "UIButton+NSIndexPath.h"

@interface MeetingActiveViewController ()

@end

@implementation MeetingActiveViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"活跃度排行";
    tableView.allowsSelection = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (isFirstAppear) {
        [super startRequest];
        [client getMeetingActiveWithMid:_item.id];
        client.tag = @"get";
    }
}

- (BOOL)requestDidFinish:(BSClient*)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        if ([sender.tag isEqualToString:@"get"]) {
            NSArray * data = [obj getArrayForKey:@"data"];
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                User * it = [User objWithJsonDic:obj];
                [contentArr addObject:it];
            }];
            [tableView reloadData];
        } else {
            [contentArr removeObjectAtIndex:sender.indexPath.row];
            [UIView animateWithDuration:0.25 animations:^{
                [tableView deleteRowsAtIndexPaths:@[sender.indexPath] withRowAnimation:UITableViewRowAnimationRight];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMeetList" object:nil];
            } completion:^(BOOL finished) {
                if (finished) {
                    [tableView reloadData];
                }
            }];
           
        }
        
    }
    return YES;
}

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"tableCell";
    BaseTableViewCell* cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
    UIButton * btn = VIEWWITHTAG(cell.contentView, 992);
    if (cell == nil) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.superTableView = sender;
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = 992;
        [btn navStyle];
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        [btn setTitle:@"移除" forState:UIControlStateNormal];
        btn.frame = CGRectMake(tableView.width - 100, (self.tableViewCellHeight- 30)/2, 80, 30);
        [cell.contentView addSubview:btn];
    }
    
    [btn addTarget:self action:@selector(removeFromMeet:) forControlEvents:UIControlEventTouchUpInside];
    btn.indexPath = indexPath;
    [cell setBottomLine:NO];
    User * user = [contentArr objectAtIndex:indexPath.row];
    cell.textLabel.text = user.nickname;
    cell.backgroundColor =
    cell.contentView.backgroundColor = [UIColor whiteColor];
    [cell update:^(NSString *name) {
        [cell autoAdjustText];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
        cell.textLabel.top = 0;
        cell.textLabel.height = cell.height;
    }];
    return cell;
}

- (NSString*)baseTableView:(UITableView *)sender imageURLAtIndexPath:(NSIndexPath*)indexPath {
    User * user = [contentArr objectAtIndex:indexPath.row];
    return user.headsmall;
}

- (void)tableView:(id)sender didTapHeaderAtIndexPath:(NSIndexPath *)indexPath {
    User * user = [contentArr objectAtIndex:indexPath.row];
    [self getUserByName:user.uid];
}

- (void)removeFromMeet:(UIButton*)sender {
    if (client) {
        return;
    }
    User * user = [contentArr objectAtIndex:sender.indexPath.row];
    [super startRequest];
    [client removefromMeeting:_item.id fuid:user.uid];
    client.tag = @"remove";
    client.indexPath = sender.indexPath;
}
@end
