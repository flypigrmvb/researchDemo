//
//  SessionInfoController.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "BaseTableViewController.h"
@class Session;

@interface SessionInfoController : BaseTableViewController

- (id)initWithSession:(Session*)item delegate:(id)del;

/** 当从我的群聊列表查看群聊信息时 onlylook 代表只看群成员 和 进入聊天*/
@property (nonatomic, assign) BOOL onlylook;
@end
