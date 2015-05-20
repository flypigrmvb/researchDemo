//
//  BaseListPageViewController.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "BaseTableViewController.h"
#import "ScrollViewHeaderView.h"

@interface BaseListPageViewController : BaseTableViewController
/**
 *  分页视图数组
 *
 */
@property (nonatomic, strong) NSMutableArray        * viewControllers;
/**
 *  每一页视图的名称
 *
 */
@property (nonatomic, strong) NSArray               * nameArray;

/**
 *  视图的类名称，由它来生成需要管理的视图类
 *
 */
@property (nonatomic, strong) NSArray              * className;
/**
 *  名称滑动交互层，传递用户在名称层的交互
 *
 */
@property (nonatomic, strong) ScrollViewHeaderView  * scrollheaderView;
/**
 *  分页滑动交互层，传递用户在每一页层的交互
 *
 */
@property (nonatomic, strong) UIScrollView          * paggingScrollView;
/**
 *  当前的中心视图页
 *
 */
@property (nonatomic, strong) UIView                * centerView;

/**
 *  获取当前页码
 *
 *  @return 返回当前页码
 */
- (NSInteger)getCurrentPageIndex;

/**
 *  为指定页码更新消息数
 *
 */
- (void)setBadgeValueforPage:(int)page withContent:(NSString*)withContent;

/**
 *  当前页码已经改变
 *
 *
 */
- (void)pageHasChanged;

@end
