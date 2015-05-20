//
//  searchResultViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "SearchResultViewController.h"
#import "UserInfoViewController.h"
#import "UserCell.h"
#import "Room.h"
#import "TalkingViewController.h"
#import "SessionInfoController.h"
#import "Session.h"

@interface SearchResultViewController ()

@end

@implementation SearchResultViewController
@synthesize showType;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"搜索结果";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (isFirstAppear) {
        [super startRequest];
        if (showType == 0) {
            [client getUserInfoWithKeyword:_keyword page:currentPage];
        }
    }
}

- (void)prepareLoadMoreWithPage:(int)page sinceID:(int)sinceID {
    if (showType == 0) {
        [client getUserInfoWithKeyword:_keyword page:page];
    }
}

- (BOOL)requestDidFinish:(id)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        NSArray * arr = [obj objectForKey:@"data"];
        if (arr && arr.count > 0) {
            if (showType == 0) {
                [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    User * item = [User objWithJsonDic:obj];
                    [contentArr addObject:item];
                }];
            }
            
            [tableView reloadData];
        } else {
            [self showText:@"不存在这样的账号哦，亲!"];
            [self popViewController];
        }
    }
    return NO;
}

#pragma mark - UITableViewDelegate

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"UserCell";
    UserCell * cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UserCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        [cell setlabTimeHide:YES];
    }
    User * user = [contentArr objectAtIndex:indexPath.row];
    cell.withFriendItem = user;
    [cell update:^(NSString *name) {
        [cell autoAdjustText];
    }];
    
    return cell;
}

- (int)baseTableView:(UITableView *)sender imageTagAtIndexPath:(NSIndexPath *)indexPath {
    return showType == 0?-1:-2;
}

- (NSString*)baseTableView:(UITableView *)sender imageURLAtIndexPath:(NSIndexPath*)indexPath {
    User *user = [contentArr objectAtIndex:indexPath.row];
    return user.headsmall;
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    id item = [contentArr objectAtIndex:indexPath.row];
    id con = nil;
    if (showType == 1) {
        Room * it = item;
        Session * session = [Session sessionWithRoom:item];
        if (it.isjoin) {
            con = [[TalkingViewController alloc] initWithSession:session];
        } else {
            con = [[SessionInfoController alloc] initWithSession:session delegate:nil];
        }
    } else {
        con = [[UserInfoViewController alloc] init];
        [(UserInfoViewController * )con setUser:item];
    }
    if (con) {
        [self pushViewController:con];
    }

}

@end
