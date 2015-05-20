//
//  Room.h
//
//  AppDelegate.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "NSBaseObject.h"

@class User;

@interface Room : NSBaseObject
/** 群id*/
@property (nonatomic, strong) NSString  * uid;
/** 群名字*/
@property (nonatomic, strong) NSString  * name;
/** 群头像*/
@property (nonatomic, strong) NSString  * head;
/** 查询用户是否在群里*/
@property (nonatomic, assign) BOOL      isjoin;
/** 群成员数量*/
@property (nonatomic, assign) int       usercount;
/** 群主uid和自己得uid比较得出*/
@property (nonatomic, strong) NSString  * creator;
/** 群创建时间*/
@property (nonatomic, strong) NSString  * createtime;
/** 群规则 */
@property (nonatomic, strong) NSString  * role;
/** 观察者在群里的昵称 */
@property (nonatomic, strong) NSString  * mynickname;
/** 是否接收群消息: 这里的是否接收是指，收到了 是否在列表显示, 消息数量无论怎么都要显示*/
@property (nonatomic, assign) BOOL      getmsg;
/** 是否是管理员*/
@property (nonatomic, assign) BOOL      isOwer;
/** 群成员id字符串*/
@property (nonatomic, strong) NSString * idUserList;
/** 群成员姓名字符串*/
@property (nonatomic, strong) NSString * nameUserList;

+ (Room*)roomForUid:(NSString*)rid;
+ (void)kickOrAddUser:(User*)user toRoom:(NSString*)rid isAdd:(BOOL)isAdd;

- (void)addUser:(User*)user isAdd:(BOOL)isAdd;
- (void)updateUserList;
- (NSInteger)userNickNameChanged:(NSString*)uid name:(NSString*)name;
- (NSInteger)userIndex:(NSString*)uid;
@end
