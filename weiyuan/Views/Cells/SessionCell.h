//
//  SessionCell.h
//
//  AppDelegate.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "BaseTableViewCell.h"

@protocol SessionCellDelegate <NSObject>
@optional
- (void)tableView:(id)sender didTapOtherBtnAtIndexPath:(NSIndexPath*)indexPath;
@end
@interface SessionCell : BaseTableViewCell

@property (nonatomic, strong) UILabel * labTime;
@property (nonatomic, assign) id withItem;
@property (nonatomic, strong) IBOutlet UIButton * otherBtn;

- (void)setTime:(NSString*)time;

@end

