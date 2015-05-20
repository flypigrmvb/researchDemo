//
//  Notify.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "NSBaseObject.h"
#import "Declare.h"

@class User;

@interface Notify : NSBaseObject
/**通知类型 @see also NotifyType*/
@property (nonatomic, assign) NotifyType    type;
/**通知内容*/
@property (nonatomic, strong) NSString      * content;
/**通知附带的用户*/
@property (nonatomic, strong) User          * user;
/**通知时间*/
@property (nonatomic, strong) NSString      * time;
/**群id*/
@property (nonatomic, strong) NSString      * roomID;
/**群名字*/
@property (nonatomic, strong) NSString      * roomName;
/**将要显示的通知内容*/
@property (nonatomic, strong) NSString      * displayContent;
/**评论或者赞的通知时，分享的id*/
@property (nonatomic, strong) NSString      * shareID;
/**评论或者赞的通知时，原文的内容 / 申请聊吧得理由*/
@property (nonatomic, strong) NSString      * shareContent;
/**是否是回忆的通知*/
@property (nonatomic, assign) BOOL          isMeet;

#pragma DB
+ (void)deleteFromDB;
+ (void)deleteFromDBWithShareID:(NSString*)sId;
+ (NSArray*)getListFromDBSinceNow;
+ (NSArray*)getListFromDBSinceTime:(NSString*)time;
+ (NSArray*)getListFromDBSinceNowWithMeetId:(NSString*)mid;
- (void)deleteFromDB;
- (void)getRoomContent;
@end
