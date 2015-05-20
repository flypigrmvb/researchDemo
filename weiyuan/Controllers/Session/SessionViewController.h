//
//  SessionViewController.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "BaseTableViewController.h"
@class Session;

@interface SessionViewController : BaseTableViewController
/** 未读的消息数量 */
- (int)getUnreadCount;
/** 重加载会话列表 */
- (void)cleanMessageWithSession:(Session*)item;
/** 登录成功调用，作用为开启通知协议 */
- (void)loginSuccess;

@end
