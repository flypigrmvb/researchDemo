//
//  ViewController.h
//
//  AppDelegate.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseListPageViewController.h"

@class Session, User;

@interface ViewController : BaseListPageViewController

@property (nonatomic, assign) NSTimeInterval timefromLastTime; // 新的朋友 检测，距离上次唤醒24小时后执行
/**更新总的未读聊天消息数*/
- (void)refreshNewChatMessage:(int)value;
/**更新总的未读聊吧消息数*/
- (void)updateNewMeetMessage:(BOOL)hasNew;
/**更新[新的朋友]的数量*/
- (void)setNewNotifyCount;
/**Message Get: xmpp收到的消息会转发到此函数里进行处理*/
- (void)receivedMessage:(Message*)msg;
/**重置新消息数量*/
- (void)reSetNewFriendAdd;
// 收到好友申请后，点亮相应的小红点
- (void)hasNewFriendAdd;
/**执行清除不必要的会话*/
- (void)cleanMessageWithSession:(Session*)item;

/**保留接口 可以使用来处理收到移除好友的消息*/
- (void)doRemoveContact:(User *)item;
/**保留接口 可以使用来处理收到添加好友的消息*/
- (void)doAddContact:(User *)item;

/**检测新的朋友*/
- (void)checkNow;

- (void)pushViewController:(id)con fromIndex:(int)idx;

@end
