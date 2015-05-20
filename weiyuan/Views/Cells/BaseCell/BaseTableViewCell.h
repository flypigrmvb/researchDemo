//
//  BaseTableViewCell.h
//
//  AppDelegate.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KLSwitch.h"

@class KBadgeView, ImageGridInView;

typedef void(^layoutCellView)(NSString*name);
@protocol BaseCellDelegate <NSObject>
- (void)tableView:(id)sender didTapHeaderAtIndexPath:(NSIndexPath*)indexPath;
@optional
- (void)tableView:(id)sender handleTableviewCellLongPressed:(NSIndexPath*)indexPath;
- (void)tableViewDidLongPressedImageAtIndexPath:(NSIndexPath*)indexPath tag:(NSString*)tag;
- (void)tableViewDidTapImageAtIndexPath:(NSIndexPath*)indexPath tag:(NSString*)tag;
- (void)tableView:(id)sender didTapButtonAtIndexPath:(NSIndexPath*)indexPath;
- (void)didMapAtIndexPath:(NSIndexPath*)indexPath;
/**分享的详情变色文字点击*/
- (void)statusDetailViewAction:(NSString *)str;
@end

@interface BaseTableViewCell : UITableViewCell
@property (nonatomic, strong) UIImageView   * bottomLineView;
@property (nonatomic, strong) UIImageView   * topLineView;
@property (nonatomic, strong) NSString      * className;
@property (nonatomic, strong) UITableView   * superTableView;
@property (nonatomic, assign, readonly) NSIndexPath   * indexPath;;
@property (nonatomic, assign) NSInteger     cornerRadius;
@property (nonatomic, assign) BOOL          newBadge;
@property (nonatomic, assign) BOOL          switchON;
@property (nonatomic, copy) layoutCellView  layoutBlock;
@property (nonatomic, strong) KLSwitch      * customSwitch;
@property (nonatomic, assign) BOOL          bottomLine;
@property (nonatomic, assign) BOOL          topLine;
@property (nonatomic, assign) BOOL          hasUpdate;
@property (nonatomic, strong) CALayer       * arrowlayer;
@property (nonatomic, assign) int           badgeValue;
@property (nonatomic, strong) KBadgeView   * badgeView;
@property (nonatomic, strong) UIImageView   * newbadgeView;
@property (nonatomic, strong) ImageGridInView * groupHeadView;
@property (nonatomic, assign) NSInteger     numberOfGroupHead;
@property (nonatomic, strong) UILabel       * labOther; // 第三个label
- (void)addArrowRight;
- (void)initialiseCell;
- (void)setNewBadge:(BOOL)isNew;
- (void)update:(layoutCellView)block;
- (void)addSwitch;
- (void)autoAdjustText;
- (void)enableLongPress;
- (void)longPressed:(UIGestureRecognizer *)sender;
- (void)setImage:(UIImage *)image AtPosition:(NSInteger)pos;
@end
