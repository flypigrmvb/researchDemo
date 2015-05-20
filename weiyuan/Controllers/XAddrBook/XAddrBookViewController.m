//
//  NearByViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "XAddrBookViewController.h"
#import "BaseTableViewCell.h"
#import "UserCell.h"
#import "Room.h"
#import "UserInfoViewController.h"
#import "TalkingViewController.h"
#import "Session.h"

/**@"新的朋友", @"群聊"*/
static NSMutableArray * arrayHeader;

@implementation XAddrBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"联系人";
    [self enableSlimeRefresh];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        arrayHeader = [NSMutableArray array];
        [@[@"新的朋友", @"群聊"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            User * user = [[User alloc] init];
            user.nickname = obj;
            [arrayHeader addObject:user];
        }];
    });
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDataList) name:@"refreshList" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSectionZero) name:@"updateSectionZero" object:nil];
}

/**更新好友名字*/
- (void)updateName:(NSNotification*)sender {
    User * user = sender.object;
    [contentArr enumerateObjectsUsingBlock:^(NSArray * arr, NSUInteger section, BOOL *stop) {
        [arr enumerateObjectsUsingBlock:^(User * obj, NSUInteger row, BOOL *stop) {
            if ([obj.uid isEqualToString:user.uid]) {
                NSIndexPath * index = [NSIndexPath indexPathForRow:row inSection:section];
                [tableView reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
            }
        }];
    }];
}

#pragma mark - Request
- (BOOL)startRequest {
    if ([super startRequest]) {
        [self prepareLoadMoreWithPage:currentPage sinceID:sinceID];
        return YES;
    }
    return NO;
}

- (BOOL)requestDidFinish:(id)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        NSArray *data = [obj getArrayForKey:@"data"];
        for (NSDictionary *dic in data) {
            User * item = [User objWithJsonDic:dic];
            [item insertDB];
            [contentArr addObject:item];
        }
        // 索引排序
        contentArr = [User sortData:contentArr hasHeader:arrayHeader];
        [tableView reloadData];
    }
    return YES;
}

- (void)prepareLoadMoreWithPage:(int)page sinceID:(int)sID {
    [client friendList];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)sender {
    if (sender == tableView) {
        return contentArr.count;
    }
    return 1;
}

#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)sender heightForHeaderInSection:(NSInteger)section {
    if ([[contentArr objectAtIndex:section] count] > 0 && section != 0) {
        return 20;
    }
    return 0;
}

- (UIView*)tableView:(UITableView *)sender viewForHeaderInSection:(NSInteger)section {
    if ([[contentArr objectAtIndex:section] count] > 0 && section != 0) {
        UIImageView *bkgImageView = [[UIImageView alloc] init];
        bkgImageView.backgroundColor = [UIColor whiteColor];
        UILabel *tLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 2, 120, 14)];
        tLabel.textColor=[UIColor blackColor];
        tLabel.backgroundColor = [UIColor clearColor];
        tLabel.font = [UIFont systemFontOfSize:14];
        if (section == 1) {
            tLabel.text = @"星标朋友";
        } else {
            tLabel.text = [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section-2];
        }
        [bkgImageView addSubview:tLabel];
        return bkgImageView;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)sender numberOfRowsInSection:(NSInteger)section {
    return [[contentArr objectAtIndex:section] count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)sender {
    NSMutableArray *arr = [NSMutableArray arrayWithArray:[[UILocalizedIndexedCollation currentCollation] sectionIndexTitles]];
    return arr;
}

- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)section {
    if (contentArr.count > 0 && section != 0) {
        return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section-2];
    } else {
        return nil;
    }
}

/**更新[新的朋友]的数量 如果这个视图被加载出来了*/
- (void) updateSectionZero {
    if (contentArr.count > 0) {
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"UserCell";
    UserCell * cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UserCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        [cell setlabTimeHide:YES];
    }
    User * user = [[contentArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.withFriendItem = user;
    [cell update:^(NSString *name) {
        // 调整位置
        [cell autoAdjustText];
        if (indexPath.section == 0) {
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
            cell.textLabel.top = 0;
            cell.textLabel.height = cell.height;
        }
    }];
    
    cell.bottomLine = NO;
    if (indexPath.row == [contentArr[indexPath.section] count] - 1) {
        cell.bottomLine = YES;
    }
    
    cell.newBadge = NO;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            NSString * str = [[BSEngine currentUser] readConfigWithKey:@"newNotifyCount"];
            [cell setNewBadge:(str&&str.intValue > 0)];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)sender willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        cell.imageView.image = LOADIMAGE(cell.textLabel.text);
    } else {
        [super tableView:sender willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
}

- (int)baseTableView:(UITableView *)sender imageTagAtIndexPath:(NSIndexPath *)indexPath {
    return -1;
}

// 头像
- (NSString*)baseTableView:(UITableView *)sender imageURLAtIndexPath:(NSIndexPath*)indexPath {
    User * user = [[contentArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    return user.headsmall;
}

// 点击好友 查看好友信息/点击 系统图标跳到下一级目录
- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        NSString * str = nil;
        if (indexPath.row == 0) {
            str = @"ChooseContactsViewController";
        } else {
            str = @"GroupListViewController";
        }
        
        UIViewController * tmpCon = [[NSClassFromString(str) alloc] init];
        [self pushViewController:tmpCon];
    } else {
        User * user = [[contentArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        UserInfoViewController * con = [[UserInfoViewController alloc] init];
        [con setUser:user];
        [self pushViewController:con];
    }
}

@end
