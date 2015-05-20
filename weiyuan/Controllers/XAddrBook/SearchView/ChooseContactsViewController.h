//
//  ChooseContactsViewController.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//
#import "BaseTableViewController.h"
typedef void(^ResetNewFriends)(NSString*name);
@interface ChooseContactsViewController : BaseTableViewController
@property (nonatomic, assign) BOOL findNewFriend;
@property (nonatomic, strong) ResetNewFriends resetBlock;
@end
