//
//  User.h
//
//  AppDelegate.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "NSBaseObject.h"

@interface User : NSBaseObject

@property (nonatomic, strong) NSString  * uid;
@property (nonatomic, strong) NSString  * phone;      // 电话(帐号)
@property (nonatomic, strong) NSString  * password;   // openfire 密码
@property (nonatomic, strong) NSString  * nickname;   // 姓名 必填
@property (nonatomic, strong) NSString  * remark;     // 备注名
@property (nonatomic, strong) NSString  * headsmall;  // 小头像 必填
@property (nonatomic, strong) NSString  * headlarge;  // 大头像
@property (nonatomic, strong) NSString  * sign;       // 个性签名
@property (nonatomic, strong) NSString  * gender;     // 性别 0-男 1-女 2-未填写
@property (nonatomic, strong) NSString  * province;   // 省
@property (nonatomic, strong) NSString  * city;       // 市
@property (nonatomic, assign) BOOL        getmsg;     // 是否接受用户的新消息
@property (nonatomic, assign) BOOL        isstar;     // 是否星标朋友
@property (nonatomic, assign) BOOL        isfriend;   // 0 没关系 1 好友
@property (nonatomic, assign) BOOL        verify;     // 0-不验证 1-验证 （加好友）
@property (nonatomic, strong) NSString  * sort;       // 排序位置
@property (nonatomic, assign) BOOL        isblack;    // 是否在黑名单
@property (nonatomic, assign) BOOL        waitforadd; // 存在好友申请
@property (nonatomic, assign) int         type;       // type 0-等待自己同意 1-等待验证 2-已添加
/** 0-看 1-不看 当前用户是否看另个用户的朋友圈 */
@property (nonatomic, assign) int         fauth1;
/** 0-看 1-不看 当前用户不让另个用户查看我的朋友圈 */
@property (nonatomic, assign) int         fauth2;
@property (nonatomic, strong) NSString  * cover;      // 朋友圈相册封面
@property (nonatomic, strong) NSString  * picture1;   // 最新照片
@property (nonatomic, strong) NSString  * picture2;   // 最新照片
@property (nonatomic, strong) NSString  * picture3;   // 最新照片

+ (void)initUserStorage;

/**标准情况下， 头像和姓名均存在才可以登录*/
- (BOOL)canLogin;

/**新的朋友：状态 0 未添加 1*/
- (void)contactType;

/**显示的名字，有备注名优先显示备注名*/
- (NSString*)displayName;
/**
 *	Copyright © 2013 Xizue Inc. All rights reserved.
 *
[""] *	为索引排序
[""] *
[""] *	@param 	tempArray 	需要排序的数组
[""] *	@param 	hasHeader 	是否有置顶的组
[""] *
[""] *	@return
[""] */
+ (NSMutableArray *)sortData:(NSArray*)tempArray hasHeader:(NSArray*)hasHeader;

- (NSMutableDictionary*)descriptionDictionary;

//DB
+ (User*)userWithID:(NSString*)uid;
+ (User*)userWithPhone:(NSString *)phone;
+ (id)valueWaitForAddlistFromeDB;

// user config
+ (id)friendlistFromeDB;
- (void)saveConfigWhithKey:(NSString*)key value:(id)value;
- (NSString*)readConfigWithKey:(NSString*)key;
- (id)readValueWithKey:(NSString*)key;
- (void)checkConfig;
@end
