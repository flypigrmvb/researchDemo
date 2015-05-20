//
//  FriendCircleAuthViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "FriendCircleAuthViewController.h"
#import "BaseTableViewCell.h"

@interface FriendCircleAuthViewController ()

@end

@implementation FriendCircleAuthViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"设置朋友圈权限";
    [contentArr addObjectsFromArray:@[@"不让他(她)看我的朋友圈", @"不看他(她)的朋友圈"]];
    [filterArr addObjectsFromArray:@[@"打开后，你在朋友圈发的内容，对方将无法看到", @"打开后，对方在朋友圈发的内容将不会出现在你的朋友圈里"]];
    tableView.allowsSelection = NO;
    self.tableViewCellHeight = 100;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)sender heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0) {
        return self.tableViewCellHeight - 18;
    }
    return self.tableViewCellHeight;
}

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"BaseHeadCell";
    BaseTableViewCell* cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.textLabel.textColor = [UIColor blackColor];
        
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
        cell.detailTextLabel.textColor = RGBCOLOR(130, 130, 130);
    }
    cell.imageView.hidden = YES;
    [cell addSwitch];
    cell.customSwitch.top = 15;
    cell.customSwitch.right = cell.right - 10;
    cell.textLabel.text = [contentArr objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [filterArr objectAtIndex:indexPath.row];
    cell.bottomLine = NO;
    if (indexPath.row == 0) {
        [cell.customSwitch setOn:self.user.fauth2];
        [cell.customSwitch setDidChangeHandler:^(BOOL isOn) {
            client = [[BSClient alloc] initWithDelegate:self action:@selector(requestDidFinish:obj:)];
            [self setLoading:YES content:@"设置中"];
            client.indexPath = indexPath;
            [client setFriendCircleAuth:_user.uid type:2];
        }];
    } else {
        [cell.customSwitch setOn:self.user.fauth1];
        [cell.customSwitch setDidChangeHandler:^(BOOL isOn) {
            client = [[BSClient alloc] initWithDelegate:self action:@selector(requestDidFinish:obj:)];
            [self setLoading:YES content:@"设置中"];
            client.indexPath = indexPath;
            [client setFriendCircleAuth:_user.uid type:1];
        }];
        cell.bottomLine = YES;
    }
    [cell update:^(NSString *name) {
        cell.detailTextLabel.top = 50;
        cell.textLabel.top = 20;
        if (indexPath.row == 0) {
            cell.detailTextLabel.height = 18;
        } else {
            cell.detailTextLabel.height = 36;
        }
        cell.textLabel.height = 20;
    }];
    return cell;
}

- (BOOL)requestDidFinish:(BSClient*)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        if (sender.indexPath.row == 0) {
            self.user.fauth2 = !self.user.fauth2;
            [self.user updateVaule:[NSNumber numberWithInt:self.user.fauth2] key:@"fauth2"];
        } else {
            self.user.fauth1 = !self.user.fauth1;
            [self.user updateVaule:[NSNumber numberWithInt:self.user.fauth1] key:@"fauth1"];
        }
    }
    [tableView reloadRowsAtIndexPaths:@[sender.indexPath] withRowAnimation:UITableViewRowAnimationNone];
    return YES;
}
@end
