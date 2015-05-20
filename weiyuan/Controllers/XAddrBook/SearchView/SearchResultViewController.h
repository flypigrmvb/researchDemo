//
//  searchResultViewController.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "BaseTableViewController.h"

@interface SearchResultViewController : BaseTableViewController
@property (nonatomic, assign) int showType; // 0 用户 1 群
@property (nonatomic, strong) NSString * keyword; // 0 用户 1 群
@end
