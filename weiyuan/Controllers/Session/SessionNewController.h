//
//  SessionNewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "BaseTableViewController.h"

@class Session, User, Room;

typedef void(^NSMutableSeletedPerson)(NSMutableArray * array);
typedef void(^SeletedPerson)(User * it);
typedef void(^Invite)(NSArray * it);
typedef enum {
    forSessionNewRequestFriendList = 0,
    forSessionNewRequestInviteUser = 1,
    forSessionNewRequestCreateRoom = 2,
}SessionNewRequestType;

@interface SessionNewController : BaseTableViewController

/** 标题切换, 只有发起 群聊 时为 yes*/
@property (nonatomic, assign) BOOL isGroup;

/** 是否显示选择群*/
@property (nonatomic, assign) BOOL isShowGroup;

/** 是否是为转发选择好友*/
@property (nonatomic, assign) BOOL isForword;

/** 是否是单聊转群聊*/
@property (nonatomic, assign) BOOL isSign;

@property (nonatomic, strong) NSMutableArray  * sourceArr;
/** 多选回调*/
@property (nonatomic, strong) NSMutableSeletedPerson mbsUserBlack;
/** 单选回调*/
@property (nonatomic, strong) SeletedPerson userBlack;
@property (nonatomic, strong) Invite inviteBlack;
- (void)setInviteBlack:(Invite)inviteBlack currectRoom:(Room*)currectRoom;
- (id)initWithSession:(Session*)item;

@end
