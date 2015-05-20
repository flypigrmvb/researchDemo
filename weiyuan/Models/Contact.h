//
//  Contact.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSBaseObject.h"

/** 新的朋友包含来自对方的好友申请和本地的手机联系人数据*/
@interface Contact : NSBaseObject
/**联系人在手机里通讯录数据库的id*/
@property (nonatomic, assign) int       personId;
/**id*/
@property (nonatomic, strong) NSString  * uid;
/**名字*/
@property (nonatomic, strong) NSString  * nickname;
/**电话*/
@property (nonatomic, strong) NSString  * phone;
/**头像*/
@property (nonatomic, strong) NSString  * headsmall;
/**表示有帐号的用户所设置的好友验证*/
@property (nonatomic, assign) BOOL      verify;
/** [isFromLocation = 0]0-表示没有帐号 1-表示有帐号*/
@property (nonatomic, assign) int       type;
/** 好友申请需要有申请理由*/
@property (nonatomic, strong) NSString  * sign;
/** 0 本地的联系人检索的数据 1 表示这条数据来自对方的好友请求*/
@property (nonatomic, assign) int       isFromLocation;
/** 0 未添加 1 等待验证 2 已经添加 3 同意添加*/
@property (nonatomic, assign) int       statustype;
/** 手机联系人批量检索返回对方是否是你的好友*/
@property (nonatomic, assign) int       isfriend;
/** 联系人在手机里的名字*/
@property (nonatomic, assign, readonly) NSString * personName;
+ (NSMutableArray *)readABAddressBook;
+ (NSData*)getImageByID:(int)personid;
+ (NSString*)getNameByID:(int)personid;
+ (BOOL)canAccessBook;

+ (Contact*)contactWithPhone:(NSString *)phone;
+ (BOOL)isInlastContacts:(NSString *)contactPhone;
+ (void)putInlastContacts:(NSArray *)array;

@end
