//
//  Session.h
//
//  AppDelegate.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "NSBaseObject.h"
#import "Declare.h"

@class User;
@class Message;
@class Statement;
@class Room;
@class Meet;
@class Subscription;

@interface Session : NSBaseObject
@property (nonatomic, strong) NSString * uid;        // 如果是单聊,则为对方 UserID 如果是群聊,则为 RoomID
@property (nonatomic, strong) NSString * name;       // 名字
@property (nonatomic, strong) NSString * content;    // 内容
@property (nonatomic, strong) NSString * headsmall;  // 头像
@property (nonatomic, strong) Message  * message;    // 最新的一条消息
@property (nonatomic, assign) Typechat   typechat;   // 是否群聊
@property (nonatomic, assign) int        unreadCount;// 未读数
@property (nonatomic, assign) int        istop;      // 是否置顶 有值表示置顶
@property (nonatomic, assign) BOOL       isshownick; // 是否显示群成员昵称

+ (Session*)sessionWithMessage:(Message*)msg;
+ (Session*)sessionWithUser:(User*)item;
+ (Session*)sessionWithRoom:(Room*)room;
+ (Session*)sessionWithMeet:(Meet*)meet;

- (BOOL)isRoom;
- (void)updateWithMessage:(Message*)msg;
- (id)initWithRoom:(Room*)_room;
- (NSString*)time;           // 最新一条消息的时间

#pragma DB

- (void)resetUnread;
+ (int)getLastTopSession;
+ (NSArray*)getListFromDBWithIsTop;
+ (id)getSessionWithID:(NSString*)sid;
- (void)cleanMessage;
- (void)deleteFromDB;

@end
