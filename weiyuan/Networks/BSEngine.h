//
//  BSEngine.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

#define KBSLoginUserName    [NSString stringWithFormat:@"%@LoginUserName",AppDisplayName]
#define KBSLoginPassWord    [NSString stringWithFormat:@"%@LoginPassWord",AppDisplayName]
#define KBSCurrentUserInfo  [NSString stringWithFormat:@"%@UserInfo",AppDisplayName]
#define KBSCurrentPassword  [NSString stringWithFormat:@"%@PassWord",AppDisplayName]

@interface BSEngine : NSObject {
    
}

@property (nonatomic, strong) User     * user;
@property (nonatomic, strong) NSString * passWord;
@property (nonatomic, strong) NSString * deviceIDAPNS;

/**返回当前登录用户的引擎数据对象*/
+ (BSEngine *) currentEngine;
/**返回当前登录用户对象*/
+ (User *) currentUser;
/**返回当前登录用户的uid*/
+ (NSString *) currentUserId;

/**覆盖当前引擎数据对象的用户对象，并写入档案*/
- (void)setCurrentUser:(User*)item password:(NSString*)pwd;
/**读取数据到引擎*/
- (void)readAuthorizeData;

/**注销：删除对应账号的信息*/
- (void)signOut;
/**判断是否登录*/
- (BOOL)isLoggedIn;

@end
