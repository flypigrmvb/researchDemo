//
//  FindViewController.m
//  ReSearch
//
//  Created by kiwi on 14-8-13.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "FindViewController.h"
#import "BaseTableViewCell.h"
#import "AppDelegate.h"

@interface FindViewController ()

@end

@implementation FindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedFriendCircle:) name:@"receivedFriendCircle" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetFriendCircle:) name:@"resetFriendCircle" object:nil];
}

- (NSInteger)tableView:(UITableView *)sender numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"tableCell";
    BaseTableViewCell* cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    [cell setBottomLine:NO];
    User * user = [BSEngine currentUser];
    if (indexPath.row == 0) {
        cell.className = @"FriendsCircleViewController";
        cell.textLabel.text = @"朋友圈";
        [cell setBadgeValue:[[user readValueWithKey:@"FriendsCircle"] intValue]];
    } else {
        cell.className = @"MeetingViewController";
        cell.textLabel.text = @"会议";
        NSString * str = [user readValueWithKey:@"NewMeetMessage"];
        [cell setNewBadge:(str&&str.intValue > 0)];
    }
    return cell;
}

- (void)tableView:(UITableView *)sender willDisplayCell:(BaseTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.imageView.image = LOADIMAGE(cell.textLabel.text);
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    BaseTableViewCell *cell = (BaseTableViewCell*)[sender cellForRowAtIndexPath:indexPath];
    Class class = NSClassFromString(cell.className);
    if ([cell.className isEqualToString:@"FriendsCircleViewController"]) {
        [self resetFriendCircle:nil];
    } else {
        [self resetNewMeetMessage];
    }
    id tmpCon = [[class alloc] init];
    if ([tmpCon isKindOfClass:[UIViewController class]]) {
        UIViewController* con = (UIViewController*)tmpCon;
        [self pushViewController:con];
    }
}

#pragma mark - Requests
- (BOOL)startRequest {
    return NO;
}

/**重置朋友圈消息数（小红点）*/
- (void)resetFriendCircle:(NSNotification*)sender {
    User * user = [BSEngine currentUser];
    [user saveConfigWhithKey:@"FriendsCircle" value:[NSString stringWithFormat:@"%d", 0]];
    [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [[AppDelegate instance] setBadgeValueforPage:1 withContent:@"0"];
}

/**重置会议消息数（小红点）*/
- (void)resetNewMeetMessage {
    User * user = [BSEngine currentUser];
    [user saveConfigWhithKey:@"NewMeetMessage" value:[NSString stringWithFormat:@"%d", 0]];
    [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [[AppDelegate instance] setBadgeValueforPage:1 withContent:@"0"];
}

#pragma mark - 赞或评论的通知
- (void)receivedFriendCircle:(NSNotification*)sender {
    [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - 会议消息的通知
- (void)receivedNewMeetMessage {
    [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}
@end
