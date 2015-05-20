//
//  UserCell.h
//
//  AppDelegate.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "BaseTableViewCell.h"

typedef enum {
    forUserSelectCellNone,    // 正常状态,可被选中
    forUserSelectCellNormal,    // 正常状态,可被选中
    forUserSelectCellSelected,  // 选中状态,可被取消选择
    forUserSelectCellSource,    // 原始被选择状态,无法更改状态
}UserSelectCellType;

@interface UserCell : BaseTableViewCell

@property (nonatomic, assign) id            withFriendItem;
@property (nonatomic, assign) id            withItem;
@property (nonatomic, assign) UserSelectCellType  selected;   // 选中
@property (nonatomic, assign) BOOL  isAdded;    // 已添加
@property (nonatomic, strong) NSString      * time;
- (void)setlabTimeHide:(BOOL)hide;
@end
