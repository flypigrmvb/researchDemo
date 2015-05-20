//
//  Meet.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "NSBaseObject.h"

@interface Meet : NSBaseObject
/** 聊吧id*/
@property (nonatomic, strong) NSString  * id;
/** 聊吧发起人的ID*/
@property (nonatomic, strong) NSString  * uid;
/** 聊吧名字*/
@property (nonatomic, strong) NSString  * name;
/** 小头像*/
@property (nonatomic, strong) NSString  * logo;
/** 大头像*/
@property (nonatomic, strong) NSString  * logolarge;
/** 是否加入*/
@property (nonatomic, assign) bool isjoin;
/** 聊吧人数*/
@property (nonatomic, assign) int memberCount;
/** 聊吧主题*/
@property (nonatomic, strong) NSString  * content;
/** 群创建时间*/
@property (nonatomic, assign) double createtime;
/** 主持人 */
@property (nonatomic, strong) NSString  * creator;
/** 开始时间 */
@property (nonatomic, strong) NSString  * start;
/** 开始时间 */
@property (nonatomic, strong) NSString  * end;
/** 聊吧成员id字符串*/
@property (nonatomic, strong) NSString  * idUserList;
/** 聊吧成员姓名字符串*/
@property (nonatomic, strong) NSString  * nameUserList;
/** 未读消息数量*/
@property (nonatomic, assign) int unreadCount;
/** 有新的申请*/
@property (nonatomic, assign) int applyCount;


/** 观察者是否是管理员*/
- (BOOL)isOwer;

/** 聊吧是否过期*/
- (BOOL)isInValid;
@end
