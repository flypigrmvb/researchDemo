//
//  SupplementaryInformationViewController.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//
#import "BaseTableViewController.h"

typedef enum {
    forSupplementaryInfo,       // 完善信息
    forEditInfo,                // 编辑信息
} EditInfo;

@interface SupplementaryInformationViewController : BaseTableViewController

@property (nonatomic, strong) User *user;
@property (nonatomic, assign) EditInfo editType;
@end
