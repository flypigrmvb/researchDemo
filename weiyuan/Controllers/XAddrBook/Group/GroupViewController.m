//
//  GroupViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "GroupViewController.h"
#import "Room.h"
#import "UIButton+NSIndexPath.h"
#import "UserCell.h"
#import "UserInfoViewController.h"

@interface GroupViewController ()

@end

@implementation GroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString * str = nil;
    if (_isAdd) {
        str = @"邀请新成员";
    } else {
        str = @"成员列表";
    }
    self.navigationItem.title = str;
}

- (void)viewDidAppear:(BOOL)animated {
    if (isFirstAppear && _room) {
        [super startRequest];
        if (_isAdd) {
            [client inviteMember:_room.uid page:currentPage];
        } else {
            [client getGroupUserList:_room.uid];
        }
    }
}

- (void)prepareLoadMoreWithPage:(int)page sinceID:(int)sID {
    if (_isAdd) {
        [client inviteMember:_room.uid page:page];
    } else {
        [client getGroupUserList:_room.uid];
    }
}

- (BOOL)requestDidFinish:(id)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        NSArray* arr = [obj objectForKey:@"data"];
        for (NSDictionary* dic in arr) {
            User * itemU = [User objWithJsonDic:dic];
            if (itemU) {
                [itemU insertDB];
                [contentArr addObject:itemU];
                if (!_isAdd) {
                    
                }
            }
        }
        [tableView reloadData];
    }
    return YES;
}

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"UserCell";
    UserCell * cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
    UIButton * btn = nil;
    if (!_isAdd) {
        btn = VIEWWITHTAG(cell.contentView, 11);
    }
    if (!cell) {
        cell = [[UserCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        [cell setlabTimeHide:YES];
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn addTarget:self action:@selector(kickUser:) forControlEvents:UIControlEventTouchUpInside];
        btn.hidden = NO;
        btn.frame = CGRectMake(cell.width - 100, 20, 80, 28);
        [btn navBlackStyle];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        btn.tag = 11;
        [cell.contentView addSubview:btn];
    }
    btn.indexPath = indexPath;
    User * item = [contentArr objectAtIndex:indexPath.row];
    if (_isAdd) {
        [btn setTitle:@"邀请" forState:UIControlStateNormal];
    } else {
        [btn setTitle:@"踢出房间" forState:UIControlStateNormal];
        if (!_room.isOwer || (indexPath.row == 0 && _room.isOwer)) {
            btn.hidden = YES;
        }
    }
    
    cell.withFriendItem = item;
    if (self.tag == 3) {
        [cell update:^(NSString *name) {
            [cell autoAdjustText];
        }];
    }
    
    return cell;
}

- (int)baseTableView:(UITableView *)sender imageTagAtIndexPath:(NSIndexPath *)indexPath {
    return self.tag != 3?-1:-2;
}

- (NSString*)baseTableView:(UITableView *)sender imageURLAtIndexPath:(NSIndexPath*)indexPath {
    User * user = [contentArr objectAtIndex:indexPath.row];
    return user.headsmall;
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    id item = [contentArr objectAtIndex:indexPath.row];
    
    UserInfoViewController * con = [[UserInfoViewController alloc] init];
    [con setUser:item];
    [self pushViewController:con];
}

#pragma mark - Request

- (BOOL)kickUser:(UIButton*)sender {
    if (client) {
        return NO;
    }
    if (needToLoad) {
        self.loading = YES;
    }
    
    client = [[BSClient alloc] initWithDelegate:self action:@selector(requestkickUserDidFinish:obj:)];
    User * user = contentArr[sender.indexPath.row];
    client.indexPath = sender.indexPath;
    if (_isAdd) {
        [client inviteUser:_room.uid inviteduids:@[user]];
    } else {
        [client delUserFromGroup:_room.uid fuid:user.uid];
    }
    return YES;
}

- (BOOL)requestkickUserDidFinish:(BSClient *)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        if (obj != nil && [obj isKindOfClass:[NSDictionary class]]) {
            if (!_isAdd) {
                User * user = contentArr[sender.indexPath.row];
                [contentArr removeObject:user];
                [tableView deleteRowsAtIndexPaths:@[sender.indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            } else {
                [self showText:sender.errorMessage];
            }
        }
    }
    return YES;
}

@end
