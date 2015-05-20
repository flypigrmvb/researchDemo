//
//  TalkingViewController.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

@class Session;

#import "BaseTableViewController.h"

@interface TalkingViewController : BaseTableViewController

- (id)initWithSession:(Session*)item;

/**寻找聊天记录模式*/
@property (atomic, assign) BOOL isSearchMode;

@property (atomic, assign) NSInteger sinceMsgID;
@end
