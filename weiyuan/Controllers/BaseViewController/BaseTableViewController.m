//  BaseTableViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "BaseTableViewController.h"
#import "BaseTableViewCell.h"
#import "Globals.h"
#import "SRRefreshView.h"
#import "UIImage+Resize.h"
#import "BaseTableView.h"
#import "UserInfoViewController.h"
#import "WebViewController.h"
#import "CircleMessage.h"
#import "MapViewController.h"
#import "TextInput.h"
#import "Message.h"

@implementation SearchDisplayController

- (void)setActive:(BOOL)visible animated:(BOOL)animated {
    [super setActive:visible animated:animated];
    [self.searchContentsController.navigationController setNavigationBarHidden: NO animated: NO];
}

@end

@interface BaseTableViewController ()<ImageProgressQueueDelegate, SRRefreshDelegate, UISearchBarDelegate, UISearchDisplayDelegate> {
    UIImageView * wordView;
    UILabel     * titleLabel;
}
@end

@implementation BaseTableViewController
@synthesize tableViewCellHeight, tag;
@dynamic dataArray, currectTableView;
@synthesize mySearchDisplayController, searchBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        contentArr = [[NSMutableArray alloc] init];
        needRadius = NO;
        sinceID = -1;
        needLoadMore = YES;
    }
    return self;
}

- (void)dealloc {
    [refreshControl removeFromSuperview];
    tableView.dataSource = nil;
    tableView.delegate = nil;
    if ([tableView isKindOfClass:[BaseTableView class]]) {
        tableView.baseDataSource = nil;
    }
    Release(tableView);
    Release(mySearchDisplayController);
    Release(searchBar);
    Release(contentArr);
    Release(filterArr);
    
    fileNib = nil;
    fileNibFilter = nil;

    Release(wordView);
    Release(titleLabel);
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if (!tableView) {
        tableView = [[BaseTableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
        tableView.top = 0;
        tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:tableView];
        if (enablefilter) {
            [self setEdgesNone];
            [self.view addKeyboardPanningWithActionHandler:nil];
            filterTableView = [[BaseTableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
            filterTableView.top = 0;
            filterTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            filterTableView.delegate = self;
            filterTableView.dataSource = self;
            filterTableView.showsVerticalScrollIndicator = NO;
            filterTableView.hidden = YES;
            [self.view addSubview:filterTableView];
        }

    }
    [self setupTableView];
    [self configureTableViewSection];
    currentPage = 1;
    headImageViewSize = 50;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (client == nil) {
        [refreshControl performSelector:@selector(endRefreshing) withObject:nil afterDelay:0];
    }
}

- (void)enableUpdateName {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateName:) name:@"updatename" object:nil];
}

- (UISearchBar*)searchBar {
    if (!searchBar) {
        searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 44)];
        searchBar.placeholder = @"搜索";
        searchBar.delegate = self;
        [searchBar setSearchBarBackgroundColor:kbColor];
    }
    return searchBar;
}

- (UISearchDisplayController*)mySearchDisplayController {
    if (!mySearchDisplayController) {
        [self.view addSubview:self.searchBar];
        mySearchDisplayController =[[SearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
        mySearchDisplayController.searchResultsDelegate = self;
        mySearchDisplayController.searchResultsDataSource = self;
        mySearchDisplayController.delegate = self;
        mySearchDisplayController.searchResultsTableView.backgroundView = nil;
        //Set the background color
        mySearchDisplayController.searchResultsTableView.backgroundColor =
        tableView.backgroundColor;
        mySearchDisplayController.searchResultsTableView.separatorStyle =
        UITableViewCellSeparatorStyleNone;
        
        tableView.top += 44;
        tableView.height -= 44;
    }
    return mySearchDisplayController;
}

- (void)setupTableView {
    if (filterTableView) {
        filterTableView.backgroundColor = self.view.backgroundColor;
        filterTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    self.tableViewCellHeight = 60;
    filterArr = [[NSMutableArray alloc] init];
    tableView.backgroundColor = self.view.backgroundColor;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)settableViewCellHeight:(CGFloat)hei {
    tableViewCellHeight = hei;
    tableView.tableViewCellHeight = hei;
}

- (void)configureTableViewSection {
    //改变索引选中的背景颜色
    if (Sys_Version >= 6.0) {
        //改变索引的颜色
        tableView.sectionIndexColor = RGBCOLOR(123, 122, 121);
        tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
        if (Sys_Version >= 7.0) {
            tableView.sectionIndexBackgroundColor = [UIColor clearColor];
            tableView.clipsToBounds = NO;
        }
        if (filterTableView) {
            filterTableView.sectionIndexColor = RGBCOLOR(123, 122, 121);
            filterTableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
            if (Sys_Version >= 7.0) {
                filterTableView.sectionIndexBackgroundColor = [UIColor clearColor];
                filterTableView.clipsToBounds = NO;
            }
        }
    }
    int width = tableView.width/2;
    int height = tableView.height/2;
    wordView = [[UIImageView alloc] initWithFrame:CGRectMake(width/2+50, height/2+50, 100, 100)];
    wordView.backgroundColor = [UIColor clearColor];
    wordView.image = [UIImage imageNamed:@"bg_scroll_index"];
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 100, 100)];
    titleLabel.font = [UIFont boldSystemFontOfSize:24];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    [wordView addSubview:titleLabel];
    [self.view addSubview:wordView];
    wordView.center = self.view.center;
    wordView.alpha = 0;
}

- (NSArray*)dataArray {
    return inFilter?filterArr:contentArr;
}

- (UITableView*)currectTableView {
    return inFilter?mySearchDisplayController?mySearchDisplayController.searchResultsTableView:filterTableView:tableView;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    titleLabel.text = title;
    [UIView animateWithDuration:0.3 animations:^{
        [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:nil cache:YES];
        wordView.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:nil cache:YES];
            wordView.alpha = 0;
        }];
    }];
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //to be impletemented in sub-class
    return 1;
}

- (NSInteger)tableView:(UITableView *)sender numberOfRowsInSection:(NSInteger)section
{
    //to be impletemented in sub-class
    NSInteger rowsNumber = 0;
    if (sender == tableView) {
        rowsNumber = contentArr.count;
    } else {
        rowsNumber = filterArr.count;
    }
    return rowsNumber;
}

- (BaseTableViewCell *)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //to be impletemented in sub-class
    static NSString * CellIdentifier = @"BaseTableViewCell";
    BaseTableViewCell * cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
    if (inFilter) {
        if (!cell) {
            cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
    } else {
        if (!cell) {
            cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)sender heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //to be impletemented in sub-class
    return self.tableViewCellHeight;
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //to be impletemented in sub-class
    [sender deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)sender willDisplayCell:(BaseTableViewCell*)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //to be impletemented in sub-class
    cell.imageView.image = [Globals getImageUserHeadDefault];
    if (needRadius) {
        BOOL    topLeft     = NO;
        BOOL    topRight    = NO;
        BOOL    bottomLeft  = NO;
        BOOL    bottomRight = NO;
        cell.backgroundView.top = 0.f;
        if (indexPath.row == 0) {
            topLeft     = YES;
            topRight    = YES;
            cell.backgroundView.top = 1.0;
        }
        if (indexPath.row == [self tableView:sender numberOfRowsInSection:indexPath.section] - 1) {
            bottomLeft  = YES;
            bottomRight = YES;
        }
        cell.selectedBackgroundView = [cell.selectedBackgroundView roundCornersOnTopLeft:topLeft topRight:topRight bottomLeft:bottomLeft bottomRight:bottomRight radius:kCornerRadiusNormal];
        cell.backgroundView = [cell.backgroundView roundCornersOnTopLeft:topLeft topRight:topRight bottomLeft:bottomLeft bottomRight:bottomRight radius:kCornerRadiusNormal];
    }
    NSInvocationOperation * opHeadItem = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadHeadImageWithIndexPath:) object:indexPath];
    [baseOperationQueue addOperation:opHeadItem];
}

/**
 *	Copyright © 2013 Xizue Inc. All rights reserved.
 *
 *	下载每个cell的图片，子类实现
 *
 */
- (void)loadImageWithIndexPath:(NSIndexPath *)indexPath {
    //to be impletemented in sub-class
}

/**
 *	Copyright © 2013 Xizue Inc. All rights reserved.
 *
 *	根据@selector(baseTableView:imageURLAtIndexPath:)返回的url下载头像（数组）
 *
 */
- (void)loadHeadImageWithIndexPath:(NSIndexPath *)indexPath {
    NSString * url = [self baseTableView:self.currectTableView imageURLAtIndexPath:indexPath];
    if (url) {
        if ([url isKindOfClass:[NSString class]]) {
            UIImage * img = [baseImageCaches getImageCache:[url md5Hex]];
            if (!img) {
                ImageProgress * progress = [[ImageProgress alloc] initWithUrl:url delegate:baseImageQueue];
                progress.indexPath = indexPath;
                progress.tag = [self baseTableView:tableView imageTagAtIndexPath:indexPath];
                [self performSelectorOnMainThread:@selector(startLoadingWithProgress:) withObject:progress waitUntilDone:YES];
            } else {
                dispatch_async(kQueueMain, ^{
                    [self setHeadImage:img forIndex:indexPath];
                });
            }
        } else if ([url isKindOfClass:[NSArray class]]) {
            NSArray * array = (NSArray*)url;
            [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                UIImage * img = [baseImageCaches getImageCache:[obj md5Hex]];
                if (!img) {
                    ImageProgress * progress = [[ImageProgress alloc] initWithUrl:obj delegate:baseImageQueue];
                    progress.indexPath = indexPath;
                    progress.tag = [self baseTableView:tableView imageTagAtIndexPath:indexPath];
                    progress.idx = idx;
                    [self performSelectorOnMainThread:@selector(startLoadingWithProgress:) withObject:progress waitUntilDone:YES];
                } else {
                    dispatch_async(kQueueMain, ^{
                        [self setGroupHeadImage:img forIndex:indexPath forPos:idx];
                    });
                }
                if (idx == 4) {
                    *stop = YES;
                }
            }];
        }
    }
}

/**
 *	Copyright © 2013 Xizue Inc. All rights reserved.
 *
 *	设置BaseTableViewCell的imageView的图像
 *
 */
- (void)setHeadImage:(UIImage*)image forIndex:(NSIndexPath*)indexPath {
    BaseTableViewCell * cell = (BaseTableViewCell*)[self.currectTableView cellForRowAtIndexPath:indexPath];
    cell.imageView.image = image;
}

/**
 *	Copyright © 2013 Xizue Inc. All rights reserved.
 *
 *	设置BaseTableViewCell的群组头像
 *
 */
- (void)setGroupHeadImage:(UIImage*)image forIndex:(NSIndexPath*)indexPath forPos:(NSInteger)pos {
    BaseTableViewCell * cell = (BaseTableViewCell*)[self.currectTableView cellForRowAtIndexPath:indexPath];
    [cell setImage:image AtPosition:pos];
}

- (void)startLoadingWithProgress:(ImageProgress*)sender {
    UIImage * ima = nil;
    if (sender.loaded) {
        ima = [sender.image resizeImageGreaterThan:(sender.tag == -1)?headImageViewSize:[self baseTableView:tableView imageSizeAtIndexPath:sender.indexPath]];
        [baseImageCaches insertImageCache:ima withKey:[sender.imageURLString md5Hex]];
    } else {
        [baseImageQueue addOperation:sender];
    }
    
    if (!ima) {
        if (sender.tag == -1) {
            ima = [Globals getImageUserHeadDefault];
        } else if (sender.tag == -2) {
            ima = [Globals getImageRoomHeadDefault];
        } else {
            ima = [Globals getImageDefault];
        }
    }
    [self baseTableView:sender.tag imageUpdateAtIndexPath:sender.indexPath image:ima idx:sender.idx];
}

/**
 *	Copyright © 2013 Xizue Inc. All rights reserved.
 *
 *	设置imageView头像的tag，将影响默认图像 默认-1 [-1 个人默认头像 -2 群组默认头像]
 *
 */
- (int)baseTableView:(UITableView *)sender imageTagAtIndexPath:(NSIndexPath*)indexPath {
    return -1;
}

- (NSString*)baseTableView:(UITableView *)sender imageURLAtIndexPath:(NSIndexPath*)indexPath {
    return nil;
}

- (CGFloat)baseTableView:(UITableView *)sender imageSizeAtIndexPath:(NSIndexPath*)indexPath {
    return headImageViewSize;
}

- (void)baseTableView:(NSInteger)tag imageUpdateAtIndexPath:(NSIndexPath*)indexPath image:(UIImage *)image idx:(NSInteger)idx {
    [self setHeadImage:image forIndex:indexPath];
}

#pragma mark - imageProgress

- (void)imageProgressCompleted:(UIImage*)img indexPath:(NSIndexPath*)indexPath idx:(NSInteger)_idx url:(NSString *)url tag:(NSInteger)_tag{
    //to be impletemented in sub-class
    img = [img resizeImageGreaterThan:(_tag == -1)?headImageViewSize:[self baseTableView:tableView imageSizeAtIndexPath:indexPath]];
    [baseImageCaches insertImageCache:img withKey:[url md5Hex]];
    [self baseTableView:_tag imageUpdateAtIndexPath:indexPath image:img idx:_idx];
}

#pragma mark - UIScrollView
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    if (needLoadMore && sender == tableView && sender.contentSize.height + 30 > sender.height) {
        if (sender.contentOffset.y + 44 < (sender.contentSize.height - sender.height)) {
            
        } else if (sender.contentOffset.y + 5 >= (sender.contentSize.height - sender.height)) {
            if (contentArr.count < totalCount) {
                [self loadMoreRequest];
            }
        }
    }
    if ([refreshControl isKindOfClass:[SRRefreshView class]]) [(SRRefreshView*)refreshControl scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([refreshControl isKindOfClass:[SRRefreshView class]]) [(SRRefreshView*)refreshControl scrollViewDidEndDraging];
}

- (void)refreshDataList:(NSNotification*)sender {
}

- (void)updateName:(NSNotification*)sender {
    User * user = sender.object;
    [contentArr enumerateObjectsUsingBlock:^(User * obj, NSUInteger row, BOOL *stop) {
        if ([obj.uid isEqualToString:user.uid]) {
            NSIndexPath * index = [NSIndexPath indexPathForRow:row inSection:0];
            [[self currectTableView] reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
        }
    }];
}

- (void)refreshDataList {
    if (client) {
        return;
    }
    isloadByslime = YES;
    hasMore = NO;
    isNeedMore = NO;
    currentPage = 1;
    baseRequestType = forBaseListRequestDataList;
    [self startRequest];
}

- (void)refreshDataListIfNeed {
    if (contentArr.count == 0) {
        [self refreshDataList];
    }
}

#pragma mark - Requests
- (void)prepareRequest:(int)reqID {
    //to be implemented in sub-classes
}

- (BOOL)requestDidFinish:(BSClient*)sender obj:(NSDictionary*)obj {
    if (isloadByslime) {
        [contentArr removeAllObjects];
    }
    isloadByslime = NO;
    BOOL res = [super requestDidFinish:sender obj:obj];
    if (res) {
        [self updatePageInfo:obj];
    }
    return res;
}

/**
 *	Copyright © 2013 Xizue Inc. All rights reserved.
 *
 *	解析分页信息（如果存在）
 *
 *	@param 	obj 	BSClient object
 *
 */
- (void)updatePageInfo:(id)obj {
    isloadByslime = NO;
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary * pageInfo = [obj getDictionaryForKey:@"pageInfo"];
        if (pageInfo) {
            sinceID = [obj getIntValueForKey:@"id" defaultValue:0];
            totalCount = [pageInfo getIntValueForKey:@"total" defaultValue:0];
            currentPage = [pageInfo getIntValueForKey:@"page" defaultValue:0];
            pageCount = [pageInfo getIntValueForKey:@"pageCount" defaultValue:0];
            if (currentPage < pageCount) {
                hasMore = YES;
            } else {
                hasMore = NO;
            }
        }
    }
}

#pragma mark -
#pragma mark - defaultRefresh
/**
 *	Copyright © 2013 Xizue Inc. All rights reserved.
 *
 *	开启下拉刷新
 *
 */
- (void)enableSlimeRefresh {
    SRRefreshView * refC = [[SRRefreshView alloc] init];
    refC.delegate = self;
    refC.upInset = 0;
    refC.slimeMissWhenGoingBack = YES;
    refC.slime.bodyColor = kbColor;
    refC.slime.skinColor = RGBCOLOR(195, 195, 195);
    refC.slime.lineWith = 2;
    refC.slime.shadowBlur = 2;
    refC.slime.shadowColor = RGBCOLOR(50, 50, 50);
    refC.backgroundColor = [UIColor clearColor];
    [tableView addSubview:refC];
    refreshControl = refC;
    tableView.clipsToBounds = YES;
}

#pragma mark - SRRefreshDelegate
/**
 *	Copyright © 2013 Xizue Inc. All rights reserved.
 *
 *	下拉刷新的代理协议
 *
 */
- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView {
    //to be implemented in sub-classes
    isloadByslime = YES;
    needToLoad = NO;
    currentPage = 1;
    if ([super startRequest]) {
        [self prepareLoadMoreWithPage:currentPage sinceID:-1];
    }
}

/**
 *	Copyright © 2013 Xizue Inc. All rights reserved.
 *
 *	需要加载更多的时候会调用这个函数，子类实现
 *
 */
- (void)prepareLoadMoreWithPage:(int)page sinceID:(int)sinceID {
    //to be implemented in sub-classes
}

#pragma filter

- (void)filterContentForSearchText:(NSString*)searchText
                             scope:(NSString*)scope {
    
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@",searchText];
    [filterArr addObjectsFromArray:[contentArr filteredArrayUsingPredicate:resultPredicate]];
}

#pragma mark - UISearchDisplayController delegate methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller  shouldReloadTableForSearchString:(NSString *)searchString {
    [filterArr removeAllObjects];
    inFilter = (searchString.length > 0);
    searchContent = searchString;
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller  shouldReloadTableForSearchScope:(NSInteger)searchOption {
    searchContent = [self.searchDisplayController.searchBar text];
    [self filterContentForSearchText:searchContent
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:searchOption]];
    return YES;
}

- (void)findButton:(UIView*)subviews {
    for(UIButton *subView in subviews.subviews) {
        if([subView isKindOfClass:NSClassFromString(@"UINavigationButton")]) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn commonStyle];
            btn.titleLabel.font = [UIFont systemFontOfSize:12];
            btn.frame = CGRectMake(0, 0, subView.width, subView.height);
            [btn addTarget:self action:@selector(cancelSearch) forControlEvents:UIControlEventTouchUpInside];
            [btn setTitle:@"取消" forState:UIControlStateNormal];
            [subView addSubview:btn];
            break;
        } else {
            [self findButton:subView];
        }
    }
}

- (void)cancelSearch {
    [self.searchDisplayController setActive:NO animated:YES];
}

- (BOOL)requestUserByNameDidFinish:(id)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        NSDictionary *dic = [obj getDictionaryForKey:@"data"];
        if (dic.count > 0) {
            User *user = [User objWithJsonDic:dic];
            [user insertDB];
            UserInfoViewController *con = [[UserInfoViewController alloc] init];
            [con setUser:user];
            [self pushViewController:con];
        }
    }
    return YES;
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	根据name搜索详细资料
 *
 */
- (void)getUserByName:(NSString *)name {
    if (client) {
        return;
    }
    if (needToLoad) {
        self.loading = YES;
    }
    client = [[BSClient alloc] initWithDelegate:self action:@selector(requestUserByNameDidFinish:obj:)];
    [client getUserInfoWithuid:name];
}

#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)sender {
//    [UIView animateWithDuration:0.35 animations:^{
//        sender.width -= 40;
//    }];
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)sender {
//    [UIView animateWithDuration:0.35 animations:^{
//        sender.width += 40;
//    }];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)sender {
    if (sender.text.length == 0) {
        [filterArr removeAllObjects];
        [filterTableView reloadData];
        [tableView reloadData];
        inFilter = NO;
    }
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)sender {
    [filterArr removeAllObjects];
    [filterTableView reloadData];
    [tableView reloadData];
    inFilter = NO;
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	搜索时根据输入的字符过滤tableview
 *
 */
- (void)textFieldDidChange:(UITextField*)sender {
    if (sender.markedTextRange != nil) {
        return;
    }
    [filterArr removeAllObjects];
    UITextField *_field = (UITextField *)sender;
    NSString * str = _field.text;
    if (str.length == 0) {
        [filterTableView reloadData];
        [UIView animateWithDuration:0.25 animations:^{
            filterTableView.alpha = 0;
            tableView.alpha = 1;
        } completion:^(BOOL finished) {
            if (finished) {
                inFilter = NO;
                filterTableView.hidden = YES;
            }
        }];
    } else {
        [self filterContentForSearchText:_field.text scope:nil];
        if (!inFilter) {
            filterTableView.alpha = 0;
            filterTableView.hidden = NO;
            inFilter = YES;
            [UIView animateWithDuration:0.25 animations:^{
                tableView.alpha = 0;
                filterTableView.alpha = 1;
            } completion:^(BOOL finished) {
                if (finished) {
                    [filterTableView reloadData];
                }
            }];
        } else {
            [filterTableView reloadData];
        }

    }
    
}

- (void)statusDetailViewAction:(NSString *)str {
    if ([str hasPrefix:@"@"]) {
        str = [str substringFromIndex:1];
        DLog(@"%@", str);
        [self getUserByName:str];
    } else if ([str hasPrefix:@"http://"]) {
        WebViewController *con = [[WebViewController alloc] init];
        con.url = str;
        con.navigationItem.title = [NSString stringWithFormat:@"微分享"];
        [self pushViewController:con];
    } else if ([str hasPrefix:@"img"]) {
    } else if ([str hasPrefix:@"#"]) {
    } else if ([str hasPrefix:@"cmt:"]) {
        if ([str isEqualToString:@"cmt:ret"]) {
        } else if ([str isEqualToString:@"cmt:com"]) {
        } else if ([str isEqualToString:@"cmt:reret"]) {
        } else if ([str isEqualToString:@"cmt:recom"]) {
        }
    } else {
        [self getUserByName:str];
    }
}

- (void)didMapAtIndexPath:(NSIndexPath *)indexPath {
    CircleMessage * item = [contentArr objectAtIndex:indexPath.row];
    // 查看地图
    MapViewController* con = [[MapViewController alloc] init];
    con.location = kLocationMake(item.address.lat, item.address.lng);
    con.readOnly = YES;
    Message * it = [[Message alloc] init];
    it.typefile = forFileAddress;
    it.address = [[Address alloc] init];
    it.address = item.address;
    con.value = it;
    con.pointAnnotationTitle = item.address.address;
    [self pushViewController:con];
}

- (void)showTipText:(NSString*)text top:(BOOL)top {
    UILabel * lab = [UILabel singleLineText:text font:[UIFont systemFontOfSize:14] wid:320 color:RGBCOLOR(255, 255, 255)];
    lab.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
    lab.textAlignment = NSTextAlignmentCenter;
    lab.backgroundColor = kbColor;
    lab.alpha = 0;
    
    CGRect frame = CGRectMake(0, -25, self.view.width, 25);

    if (!top) {
        frame.origin.y = self.view.height;
        if (Sys_Version >= 7) frame.origin.y -= 49;
    }
    
    lab.frame = frame;
    [self.view addSubview:lab];
    
    [UIView animateWithDuration:0.55 animations:^{
        lab.alpha = 1;
        if (top) {
            
            if (Sys_Version >= 7 && self.edgesForExtendedLayout != UIRectEdgeNone) {
                lab.top = 64;
            } else {
                lab.top = 0;
            }
        } else {
            CGFloat bottom = self.view.height;
            if (Sys_Version >= 7 && !self.hidesBottomBarWhenPushed) {
                bottom -= 49;
            }
            lab.bottom = bottom;
        }
    } completion:^(BOOL finished) {
        [self performSelector:@selector(hideTipText:) withObject:lab afterDelay:1.0];
    }];
}

- (void)hideTipText:(UILabel*)lab {
    [UIView animateWithDuration:0.45 animations:^{
        if (Sys_Version >= 7 && self.edgesForExtendedLayout != UIRectEdgeNone) {
            lab.top = 0;
        } else {
            lab.top = -25;
        }
        lab.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [lab removeFromSuperview];
        }
    }];
}

@end
