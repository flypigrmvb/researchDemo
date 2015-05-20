//
//  Message.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "NSBaseObject.h"
#import "Declare.h"
#import "Address.h"

@class Statement, Session;
@interface Message : NSBaseObject

/** 服务器指定的全球唯一id */
@property (nonatomic, strong) NSString *    uid;
/** 发送方id */
@property (nonatomic, strong) NSString *    fromId;
/** 接受方id */
@property (nonatomic, strong) NSString *    toId;
/** 是否自己发送的 */
@property (nonatomic, assign) BOOL          isSendByMe;
/** 消息内容 */
@property (nonatomic, strong) NSString *    content;
/** 接收者显示姓名 */
@property (nonatomic, strong) NSString *    toname;
/** 接收者显示头像 */
@property (nonatomic, strong) NSString *    tohead;
/** 显示姓名 */
@property (nonatomic, strong) NSString *    displayName;
/** 显示头像 */
@property (nonatomic, strong) NSString *    displayImgUrl;

/** 文件类型 @see FileType */
@property (nonatomic, assign) FileType      typefile;
/** 消息类型 @see typechat */
@property (nonatomic, assign) Typechat      typechat;

/** 地址 @see Address */
@property (nonatomic, strong) Address  *    address;
/** 小图地址 */
@property (nonatomic, strong) NSString *    imgUrlS;
/** 大图地址 */
@property (nonatomic, strong) NSString *    imgUrlL;
/** 小图宽度 */
@property (nonatomic, assign) CGFloat       imgWidth;
/** 小图高度 */
@property (nonatomic, assign) CGFloat       imgHeight;
/** 音频地址 */
@property (nonatomic, strong) NSString *    voiceUrl;
/** 音频时长 */
@property (nonatomic, strong) NSString *    voiceTime;
/** 发送时间 */
@property (nonatomic, strong) NSString *    sendTime;
/** 未读消息数 */
@property (nonatomic, assign) BOOL          unRead;
/** 标志(唯一)  客户端指定 */
@property (nonatomic, strong) NSString *    tag;
/** 错误code 1 显示errorMessage 3 被移除了某个群还在群里说话 */
/** 错误信息 4 对方拒绝接收消息*/
@property (nonatomic, assign) int           errorCode;  
@property (nonatomic, strong) NSString *    errorMessage;
/** 消息状态 @see MessageState */
@property (nonatomic, assign) MessageState  state;

//+ (id)preMessageWithData;
- (void)getToUserInfoWithSession:(Session*)obj;
- (id)initWithStatement:(Statement *)stmt;

- (NSString*)contentDisplay;

- (id)ifExistInDB;
/** 对方的 UserID*/
- (NSString*)withID;
- (NSInteger)rowID;
- (void)setRowID:(NSInteger)rid;
- (CGSize)imageSize;
- (void)setImageSize:(CGSize)size;

#pragma DB

+ (void)updatePersonNameInRoomMessageWithID:(NSString*)withID withName:(NSString*)name roomId:(NSString*)rid;
+ (int)getUnreadMessageCountWithID:(NSString*)wID;
+ (void)resetAllUnReadWithID:(NSString*)wID;
+ (NSArray*)getListFromDBWithID:(NSString*)toUid sinceRowID:(NSInteger)rID;
+ (Message*)getLatestMessageWithID:(NSString*)wID;

+ (void)deleteWithSendTime:(NSString *)sendTime;
+ (void)deleteWithID:(NSString*)wID;


- (void)updateId;
- (void)updateReadState:(BOOL)isread;

@end
