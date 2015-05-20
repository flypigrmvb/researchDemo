//
//  SessionViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "SessionViewController.h"
#import "Session.h"
#import "Notify.h"
#import "Room.h"
#import "SessionNewController.h"
#import "TalkingViewController.h"
#import "SessionCell.h"
#import "Message.h"
#import "AppDelegate.h"
#import "UserInfoViewController.h"
#import "UIImage+FlatUI.h"
#import "UIImage+Resize.h"
#import "Globals.h"
#import "CameraActionSheet.h"
#import "JSON.h"

@interface SessionViewController ()<BSTableViewDataSource, CameraActionSheetDelegate>
@end

@implementation SessionViewController

- (id)init {
    if (self = [super init]) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    needToLoad = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self forwardMessageIfHas];
}

- (void)loginSuccess {
    self.navigationItem.title = @"消息";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedMessage:) name:@"receivedMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reSetConversation:) name:@"reSetConversation" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUIForMarkName:) name:@"updateUIForMarkName" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotifyGroupChat:) name:@"receivedNotifyGroupChat" object:nil];
    [contentArr addObjectsFromArray:[Session getListFromDBWithIsTop]];
    [self setbadgeValue:[self getUnreadCount]];
    [tableView reloadData];
}

- (int)getUnreadCount {
    int unreadCount = 0;
    for (Session * item in contentArr) {
        unreadCount += item.unreadCount;
    }
    return unreadCount;
}

/** 收到更新备注名的通知后重加载列表 */
- (void)updateUIForMarkName:(NSNotification*)sender {
    [contentArr removeAllObjects];
    [contentArr addObjectsFromArray:[Session getListFromDBWithIsTop]];
    [tableView reloadData];
}

/** 群消息通知的处理 */
- (void)receivedNotifyGroupChat:(NSNotification*)sender {
    Notify * ntf = sender.object;
    if (ntf.type == forNotifyDestroyRoom || ntf.type == forNotifyKickUser) {
        BOOL needDeleted = NO;
        if (ntf.type == forNotifyDestroyRoom) {
            needDeleted = YES;
        } else if (ntf.type == forNotifyKickUser && [ntf.user.uid isEqualToString:[BSEngine currentUserId]]) {
            needDeleted = YES;
        }
        if (needDeleted) {
            __block NSInteger find = -1;
            [contentArr enumerateObjectsUsingBlock:^(Session *obj, NSUInteger idx, BOOL *stop) {
                if ([obj.uid isEqualToString:ntf.roomID]) {
                    Room * room = [Room roomForUid:obj.uid];
                    if (room) {
                        [room deleteFromDB];
                    }
                    [obj deleteFromDB];
                    find = idx;
                    *stop = YES;
                }
            }];
            if (find >= 0) {
                [contentArr removeObjectAtIndex:find];
                [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:find inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
    } else if (ntf.type == forNotifyGroupInfoUpdate) {
        // 群昵称更改
        [contentArr enumerateObjectsUsingBlock:^(Session *obj, NSUInteger idx, BOOL *stop) {
            if ([obj.uid isEqualToString:ntf.roomID]) {
                obj.name =
                obj.message.toname = ntf.roomName;
                [obj.message updateVaule:ntf.roomName key:@"toname"];
                [obj updateVaule:obj.name key:@"name"];
                [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                *stop = YES;
            }
        }];
    }
}

/** 导航栏右键点击 */
- (void)barItemRightPressed:(id)sender {
    id con = [[SessionNewController alloc] init];
    [self pushViewController:con];
}

/** 重加载会话列表 */
- (void)cleanMessageWithSession:(Session*)item {
    [contentArr removeAllObjects];
    [contentArr addObjectsFromArray:[Session getListFromDBWithIsTop]];
    [tableView reloadData];
}

/** 废弃函数 现用于强制刷新列表*/
- (void)forwardMessageIfHas {
    if (isFirstAppear) {
        [tableView reloadData];
    }
}

#pragma mark -
#pragma mark - Messages

/** 单聊消息通知的处理 */
- (void)receivedMessage:(NSNotification*)sender {
    Message * msg = sender.object;
    if (msg.typechat == forChatTypeMeet) {
        return;
    }
    __block Session * itemS = nil;
    __block NSInteger index;
    [contentArr enumerateObjectsUsingBlock:^(Session * ssion, NSUInteger idx, BOOL *stop) {
        NSString * str = ssion.message.withID;
        if ([str isEqualToString:msg.withID]) {
            itemS = ssion;
            index = idx;
            *stop = YES;
        }
    }];
    
    if (itemS == nil) {
        //新会话
        itemS = [Session sessionWithMessage:msg];
        [itemS insertDB];
    } else {
        //更新原有会话
        [itemS updateWithMessage:msg];
    }
    
    // 重新分配 cell 的 indexpath
    [contentArr removeAllObjects];
    [contentArr addObjectsFromArray:[Session getListFromDBWithIsTop]];
    [tableView reloadData];
    [self setbadgeValue:[self getUnreadCount]];
}

/** 重置消息数量 */
- (void)reSetConversation:(NSNotification*)sender {
    NSString* withID = sender.object;
    //    DLog(@"%s:%@",__FUNCTION__,withID);
    if (withID) {
        for (int i = 0; i < contentArr.count; i++) {
            Session* cs = [contentArr objectAtIndex:i];
            if ([cs.uid isEqualToString:withID]) {
                if (cs.unreadCount > 0) {
                    [cs resetUnread];
                    [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
                break;
            }
        }
    }
    [self setbadgeValue:[self getUnreadCount]];
}

/** 设置程序app 的applicationIconBadgeNumber*/
- (void)setbadgeValue:(int)value {
    NSString *str = nil;
    if (value > 0) {
        str = [NSString stringWithFormat:@"%d", value];
    } else {
        str = nil;
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber = value;
    self.tabBarItem.badgeValue = str;
    [[AppDelegate instance] refreshNewChatMessage:value];
}

#pragma mark - UITableViewDelegate

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"SessionCell";
    SessionCell * cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
    if (inFilter) {
        if (!cell) {
            cell = [[SessionCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            [cell enableLongPress];
        }
    } else {
        if (!cell) {
            cell = [[SessionCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            [cell enableLongPress];
        }
    }
    cell.superTableView = sender;
    
    Session * itemS = [self.dataArray objectAtIndex:indexPath.row];
    cell.withItem = itemS;
    if (itemS.isRoom) {
        // 群聊的头像是用户头像拼出来的
        if (!itemS.value) {
            itemS.value = [itemS.headsmall componentsSeparatedByString:@","];
        }
        NSInteger number = [itemS.value count];
        if (number > 4) {
            number = 4;
        }
        [cell setNumberOfGroupHead:number];
    } else {
        [cell setNumberOfGroupHead:0];
    }
    [cell setBottomLine:NO];
    if (indexPath.row == contentArr.count - 1) {
        [cell setBottomLine:YES];
    }

    [cell update:^(NSString *name) {
        [cell autoAdjustText];
        cell.textLabel.width = cell.width - 50 - cell.labTime.width;
        if (itemS.istop) {
            cell.contentView.backgroundColor =
            cell.backgroundColor = RGBACOLOR(204, 204, 204, 0.6);
        } else {
            cell.contentView.backgroundColor =
            cell.backgroundColor = [UIColor whiteColor];
        }
    }];
    return cell;
}

- (void)tableView:(id)sender handleTableviewCellLongPressed:(NSIndexPath*)indexPath {
    Session * item = [contentArr objectAtIndex:indexPath.row];
    CameraActionSheet * sheet = [[CameraActionSheet alloc] initWithActionTitle:nil TextViews:nil CancelTitle:@"取消" withDelegate:self otherButtonTitles:item.istop?@"取消置顶":@"置顶聊天", @"删除聊天", nil];
    sheet.idx = [NSString stringWithFormat:@"%d", (int)indexPath.row];
    [sheet show];
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    Session * item = [contentArr objectAtIndex:indexPath.row];
    item.unreadCount = 0;
    [self setbadgeValue:[self getUnreadCount]];
    id con = [[TalkingViewController alloc] initWithSession:item];
    [self pushViewController:con];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)tableView:(id)sender didTapHeaderAtIndexPath:(NSIndexPath *)indexPath {
    Session* itemS = [self.dataArray objectAtIndex:indexPath.row];
    if (itemS.isRoom) {
        
    } else {
        [self getUserByName:itemS.uid];
    }
}

- (void)tableView:(UITableView *)sender willDisplayCell:(SessionCell*)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    Session* item = [self.dataArray objectAtIndex:indexPath.row];
    if (item.isRoom) {
        cell.imageView.image = [Globals getImageRoomHeadDefault];
    } else {
        cell.imageView.image = [Globals getImageUserHeadDefault];
    }
    NSInvocationOperation * opHeadItem = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadHeadImageWithIndexPath:) object:indexPath];
    [baseOperationQueue addOperation:opHeadItem];
}

- (NSString*)baseTableView:(UITableView *)sender imageURLAtIndexPath:(NSIndexPath *)indexPath {
    Session * item = [self.dataArray objectAtIndex:indexPath.row];
    if (item.isRoom) {
        return item.value;
    } else {
        return item.headsmall;
    }
}

- (int)baseTableView:(UITableView *)sender imageTagAtIndexPath:(NSIndexPath*)indexPath {
    Session * item = [self.dataArray objectAtIndex:indexPath.row];
    if (item.isRoom) {
        return -2;
    } else {
        return -1;
    }
}

- (void)baseTableView:(NSInteger)tag imageUpdateAtIndexPath:(NSIndexPath*)indexPath image:(UIImage *)image idx:(NSInteger)idx {
    if (tag == -1) {
        [self setHeadImage:image forIndex:indexPath];
    } else {
        [self setGroupHeadImage:image forIndex:indexPath forPos:idx];
    }
}

- (void)kwAlertView:(id)sender didDismissWithButtonIndex:(NSInteger)index {
    if (index == 0) {
        [[AppDelegate instance] signOut];
    }
}

#pragma mark - CameraActionSheetDelegate

- (void)cameraActionSheet:(CameraActionSheet *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 2) {
        return;
    }
    Session * session = contentArr[sender.idx.intValue];
    if (buttonIndex == 0) {
        // 更新置顶聊天状态
        if (session.istop > 0) {
            session.istop = 0;
        } else {
            session.istop = [Session getLastTopSession]+1;
        }
        [session updateVaule:[NSNumber numberWithInt:session.istop] key:@"istop"];
        [self cleanMessageWithSession:session];
    } else {
        // 删除某个会话， 更新数据库
        [session deleteFromDB];
        [contentArr removeObjectAtIndex:sender.idx.intValue];
        [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:sender.idx.intValue inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
        [self setbadgeValue:[self getUnreadCount]];
    }
}
@end
