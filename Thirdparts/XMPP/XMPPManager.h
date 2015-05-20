//
//  XMPPManager.h
//  SpartaEducation
//
//  Created by kiwi on 14-7-21.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"

@interface XMPPManager : NSObject

@property (nonatomic, strong, readonly) XMPPStream      * xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect   * xmppReconnect;
@property (nonatomic, strong) NSMutableDictionary       *  roomsDic;
@property (nonatomic, strong) NSString                  *  userId;
@property (nonatomic, strong) NSString                  *  password;

+ (XMPPManager*)shareManager;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	启动服务
 */
- (void)setupStream;
/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	关闭服务
 */
- (void)teardownStream;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	下线
 */
- (void)goOffline;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	连接服务器
 *	@param 	name 	openfire ID
 *	@param 	pass 	openfire 密码
 */
- (BOOL)connectWithId:(NSString*)name password:(NSString*)pass;
/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	再次连接服务器
 */
- (BOOL)connectAgain;
/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	断开连接服务器
 */
- (void)disconnect;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	将消息id回执到服务器
 *
 *	@param 	mid 	消息id
 */
- (void)receiptMessageID:(NSString*)mid;

- (BOOL)exist;

@end

