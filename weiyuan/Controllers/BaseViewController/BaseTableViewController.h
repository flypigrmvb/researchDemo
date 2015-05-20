//
//  SessionNewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "BaseViewController.h"
#import "BaseTableView.h"

typedef enum {
    forBaseListRequestDataList,
    forBaseListRequestOther,
}BaseListRequestType;

@interface SearchDisplayController : UISearchDisplayController

@end
@class KTextField;

@interface BaseTableViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    IBOutlet BaseTableView      * tableView;
    
    UITableView                 * filterTableView;
    
    NSMutableArray              * contentArr;
    NSMutableArray              * filterArr;
    
    UINib                       * fileNib;
    UINib                       * fileNibFilter;
    int                         count;
    BOOL                        hasMore;
    int                         page_count;
    BOOL                        isNeedMore;
    
    BaseListRequestType         baseRequestType;
    
    BOOL                        needRadius;
    CGFloat                     headImageViewSize;
    BOOL                        inFilter;       // 是否处于过滤模式
    BOOL                        needLoadMore;
    BOOL                        enablefilter;
}

@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, assign) CGFloat   tableViewCellHeight;
@property (nonatomic, assign) NSArray   * dataArray; // 得到当前正确的数据源
@property (nonatomic, assign) BaseTableView   * currectTableView; // 得到当前正确的数据源
@property (nonatomic, strong) SearchDisplayController * mySearchDisplayController;
@property (nonatomic, strong) IBOutlet UISearchBar * searchBar;

- (void)enableUpdateName;
/**
 *	Copyright © 2013 Xizue Inc. All rights reserved.
 *
 *	开启下拉刷新
 *
 */
- (void)enableSlimeRefresh;

/**
 *	Copyright © 2013 Xizue Inc. All rights reserved.
 *
 *	下拉刷新的代理协议
 *
 */
- (void)slimeRefreshStartRefresh:(id)refreshView;

/**
 *	Copyright © 2013 Xizue Inc. All rights reserved.
 *
 *	需要加载更多的时候会调用这个函数，子类实现
 *
 */
- (void)prepareLoadMoreWithPage:(int)page sinceID:(int)sinceID;

- (void)startLoadingWithProgress:(ImageProgress*)progress;

/**
 *	Copyright © 2013 Xizue Inc. All rights reserved.
 *
 *	下载每个cell的图片，子类实现
 *
 */
- (void)loadImageWithIndexPath:(NSIndexPath *)indexPath;

/**
 *	Copyright © 2013 Xizue Inc. All rights reserved.
 *
 *	根据@selector(baseTableView:imageURLAtIndexPath:)返回的url下载头像（数组）
 *
 */
- (void)loadHeadImageWithIndexPath:(NSIndexPath *)indexPath;

/**
 *	Copyright © 2013 Xizue Inc. All rights reserved.
 *
 *	设置BaseTableViewCell的imageView的图像
 *
 */
- (void)setHeadImage:(UIImage*)image forIndex:(NSIndexPath*)indexPath;

/**
 *	Copyright © 2013 Xizue Inc. All rights reserved.
 *
 *	设置BaseTableViewCell的群组头像
 *
 */
- (void)setGroupHeadImage:(UIImage*)image forIndex:(NSIndexPath*)indexPath forPos:(NSInteger)pos;

- (void)refreshDataList:(NSNotification*)sender;
- (void)refreshDataList;
- (void)refreshDataListIfNeed;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	根据name搜索详细资料
 *
 */
- (void)getUserByName:(NSString *)name;

/**
 *	Copyright © 2013 Xizue Inc. All rights reserved.
 *
 *	设置imageView头像的tag，将影响默认图像 默认-1 [-1 个人默认头像 -2 群组默认头像]
 *
 */
- (int)baseTableView:(UITableView *)sender imageTagAtIndexPath:(NSIndexPath*)indexPath;
/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	返回对应index即将加载的图像，默认为头像cell.imageView
 *
 */
- (NSString*)baseTableView:(UITableView *)sender imageURLAtIndexPath:(NSIndexPath*)indexPath;
/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	返回对应index即将加载的图像的缩略尺寸，默认50*50
 *
 */
- (CGFloat)baseTableView:(UITableView *)sender imageSizeAtIndexPath:(NSIndexPath*)indexPath;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	图片已经下载好了，这里可以根据tag/idx 定位图片在哪个cell
 *
 */
- (void)baseTableView:(NSInteger)tag imageUpdateAtIndexPath:(NSIndexPath*)indexPath image:(UIImage *)image idx:(NSInteger)idx;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	搜索时根据输入的字符过滤tableview
 *
 */
- (void)textFieldDidChange:(id)sender;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	show tip text from top or bottom
 *
 *	@param 	text 	tip text
 *	@param 	top 	YES for top, NO for bottom
 */
- (void)showTipText:(NSString*)text top:(BOOL)top;
@end
