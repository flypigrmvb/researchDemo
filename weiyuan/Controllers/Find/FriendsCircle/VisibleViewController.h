//
//  VisibleViewController.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "BaseTableViewController.h"

typedef void(^SelectedArray)(NSArray * array);
@interface VisibleViewController : BaseTableViewController
@property (nonatomic, strong) NSMutableArray        * selectedArray;
@property (nonatomic, strong) SelectedArray block;
@end
