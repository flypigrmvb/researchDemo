//
//  BaseListPageViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//


#import "BaseListPageViewController.h"
#import "BaseTableViewController.h"
#import "ScrollViewHeaderView.h"
#import "BaseTableViewCell.h"
#import "UserCell.h"
#import "UserInfoViewController.h"
#import "FriendsAddViewController.h"

@interface BaseListPageViewController ()<UIScrollViewDelegate>

/**
 *  滑动比例
 *
 */
@property (nonatomic, assign, readonly) CGFloat     displacementRatio;
/**
 *  ［名称滑动层］可视宽度内最大容纳名称数量
 *
 */
@property (nonatomic, assign, readonly) int         numberOfPackets;

/**
 *  标识当前页码
 */
@property (nonatomic, assign) NSInteger selectedPage;
@end

@implementation BaseListPageViewController
@synthesize viewControllers, nameArray, className, scrollheaderView;
@dynamic displacementRatio, numberOfPackets;

- (id)init {
    if (self = [super init]) {
        // Custom initialization
        self.viewControllers = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setEdgesNone];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (isFirstAppear) {
        [self.view addSubview:self.centerView];
        [self reloadData];
    }
    __block BaseListPageViewController * blockView = self;
    self.scrollheaderView.selecdBlock = ^(NSInteger selected) {
        [blockView setSelectedPage:selected];
        [UIView animateWithDuration:0.3 animations:^{
            blockView.paggingScrollView.contentOffset = CGPointMake(selected*blockView.paggingScrollView.width, blockView.paggingScrollView.contentOffset.y);
        }];
    };

}

- (void)viewDidDisappear:(BOOL)animated {
    self.scrollheaderView.selecdBlock = nil;
    self.loading = NO;
}

- (ScrollViewHeaderView*)scrollheaderView {
    if (!scrollheaderView) {
        scrollheaderView = [[ScrollViewHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 38)];
        [self.view addSubview:scrollheaderView];
    }
    return scrollheaderView;
}

- (void)setNameArray:(NSArray *)arr {
    nameArray = arr;
    [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Class class = NSClassFromString(className[idx]);
        BaseTableViewController * tmpCon = [[class alloc] init];
        tmpCon.tag = idx;
        [self.viewControllers addObject:tmpCon];
    }];
    self.scrollheaderView.nameArray = arr;
}

- (UIScrollView *)paggingScrollView {
    if (!_paggingScrollView) {
        _paggingScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, _centerView.height)];
        _paggingScrollView.bounces = NO;
        _paggingScrollView.pagingEnabled = YES;
        [_paggingScrollView setScrollsToTop:NO];
        _paggingScrollView.delegate = self;
        _paggingScrollView.showsVerticalScrollIndicator = NO;
        _paggingScrollView.showsHorizontalScrollIndicator = NO;
        [_paggingScrollView.panGestureRecognizer addTarget:self action:@selector(panGestureRecognizerHandle:)];
    }
    return _paggingScrollView;
}

- (UIView *)centerView {
    if (!_centerView) {
        _centerView = [[UIView alloc] initWithFrame:CGRectMake(0, 38, self.view.width, self.view.height - scrollheaderView.height)];
        _centerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _centerView.backgroundColor = [UIColor whiteColor];
        [_centerView addSubview:self.paggingScrollView];
    }
    return _centerView;
}

- (void)reloadData {
    [_paggingScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.viewControllers enumerateObjectsUsingBlock:^(BaseTableViewController *viewController, NSUInteger idx, BOOL *stop) {
        CGRect contentViewFrame = viewController.view.bounds;
        contentViewFrame.origin.x = idx * _paggingScrollView.width;
        contentViewFrame.size.height = _paggingScrollView.height;
        viewController.view.frame = contentViewFrame;
        [_paggingScrollView addSubview:viewController.view];
        [self addChildViewController:viewController];
    }];
    [_paggingScrollView setContentSize:CGSizeMake(CGRectGetWidth(self.view.bounds) * self.viewControllers.count, 0)];
}

#pragma mark - DataSource

- (NSInteger)getCurrentPageIndex {
    return self.selectedPage;
}

/**
 *  为指定页码更新消息数
 *
 */
- (void)setBadgeValueforPage:(int)page withContent:(NSString*)withContent {
    [scrollheaderView setBadgeValueAtIndex:page withContent:withContent];
}

- (void)addNewFriend {
    FriendsAddViewController * con = [[FriendsAddViewController alloc] init];
    [self pushViewController:con];
}

#pragma mark - PanGesture Handle Method

- (void)panGestureRecognizerHandle:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint contentOffset = self.paggingScrollView.contentOffset;
    CGSize contentSize = self.paggingScrollView.contentSize;
    CGFloat baseWidth = CGRectGetWidth(self.paggingScrollView.bounds);
    if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        if (contentOffset.x <= 0) {
            // 滑动到最左边
            [panGestureRecognizer setTranslation:CGPointZero inView:panGestureRecognizer.view];
        } else if (contentOffset.x >= contentSize.width - baseWidth) {
            // 滑动到最右边
            [panGestureRecognizer setTranslation:CGPointZero inView:panGestureRecognizer.view];
        }
    }
}

- (void)setupScrollToTop {
    for (int i = 0; i < self.viewControllers.count; i ++) {
        UITableView *_tableView = (UITableView *)[self subviewWithClass:[UITableView class] onView:[self getPageViewControllerAtIndex:i].view];
        if (_tableView) {
            if (self.selectedPage == i) {
                [_tableView setScrollsToTop:YES];
            } else {
                [_tableView setScrollsToTop:NO];
            }
        }
    }
}

- (UIViewController *)getPageViewControllerAtIndex:(NSInteger)index {
    if (index < self.viewControllers.count) {
        return self.viewControllers[index];
    } else {
        return nil;
    }
}

- (void)setSelectedPage:(NSInteger)selectedPage {
    self.scrollheaderView.selectedBtn = selectedPage;
    if (_selectedPage == selectedPage)
        return;
    _selectedPage = selectedPage;
    [self setupScrollToTop];
    [self pageHasChanged];
}

- (void)pageHasChanged {
    //to be impletemented in sub-class
}

#pragma mark - View Helper Method
- (UIView *)subviewWithClass:(Class)cuurentClass onView:(UIView *)view {
    for (UIView *subView in view.subviews) {
        if ([subView isKindOfClass:cuurentClass]) {
            return subView;
        }
    }
    return nil;
}

- (int)numberOfPackets {
    return self.centerView.width/self.scrollheaderView.maxButtonWidth;
}

- (CGFloat)displacementRatio {
    return self.scrollheaderView.maxButtonWidth/self.centerView.width;
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    self.scrollheaderView.selecedBlackgroundView.left = sender.contentOffset.x * self.displacementRatio;
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender {
    // 得到每页宽度
    CGFloat pageWidth = sender.width;
    // 根据当前的x坐标和页宽度计算出当前页数
    self.selectedPage = floor((sender.contentOffset.x - pageWidth/2) / pageWidth)+ 1;
    if (nameArray.count > 4) {
        [UIView animateWithDuration:0.3 animations:^{
            if (_selectedPage == nameArray.count - 1) {
                self.scrollheaderView.contentOffset = CGPointMake(self.scrollheaderView.maxButtonWidth * (_selectedPage-2), self.scrollheaderView.contentOffset.y);
            } else {
                self.scrollheaderView.contentOffset = CGPointMake((_selectedPage/self.numberOfPackets)*self.centerView.width/2, self.scrollheaderView.contentOffset.y);
            }
        }];
    }
}

@end