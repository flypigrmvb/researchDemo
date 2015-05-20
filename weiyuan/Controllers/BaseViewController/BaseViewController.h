//
//  BaseViewController.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSClient.h"
#import "BSEngine.h"
#import "ImageProgressQueue.h"
#import "ImageCaches.h"

#define DefaultKeyBoardHeight 216.f

@class ImageTouchView, KTextField;

@interface BaseViewController : UIViewController {
    BSClient    * client;
    CGFloat     keyboardHeight;
    id          currentView;
    UIView      * currentInputView;
    UINib       * nib;
    BOOL        isFirstAppear;
    int         currentPage;
    int         totalCount;
    int         pageCount;
    int         maxPage;
    int         maxID;
    int         sinceID;
    BOOL        needToLoad;
    UIView      * refreshControl;
    BOOL        isloadByslime;
    ImageCaches                 * baseImageCaches;
    ImageProgressQueue          * baseImageQueue;
    NSOperationQueue            * baseOperationQueue;
    NSString                    * searchContent;
    UILabel                     * titlelab;
}

@property (nonatomic, strong) id        value;
@property (nonatomic, assign) BOOL willShowBackButton;
@property (nonatomic, assign) BOOL loading;

@property (nonatomic, strong) KTextField * searchField;
@property (nonatomic, strong) UIView * searchView;

/**搜索按钮*/
@property (nonatomic, strong) ImageTouchView * searchButton;
/**添加按钮*/
@property (nonatomic, strong) ImageTouchView * addButton;
/**更多按钮*/
@property (nonatomic, strong) ImageTouchView * moreButton;
/**重写标题view 通常为了添加👉右边的按钮*/
@property (nonatomic, strong) UIView * titleView;

- (void)popViewController;
- (void)pushViewController:(id)con;

- (void)sendNotificationInfoUpdate:(id)obj;
- (void)showAlert:(id)text isNeedCancel:(BOOL)isNeedCancel;
- (void)showAlertWithTag:(id)text isNeedCancel:(BOOL)isNeedCancel tag:(NSInteger)tag;
- (void)showText:(id)text;

- (void)setLoading:(BOOL)bl content:(NSString*)con;
- (void)showBackButton;
/**如果未登录，则弹出登录框*/
- (BOOL)showLoginIfNeed;
- (void)presentModalController:(id)con animated:(BOOL)animated;
- (void)dismissModalController:(BOOL)animated;

/**
 *	Copyright © 2013 Xizue Inc. All rights reserved.
 *
 *	Set bar button items with image, do not worry about the width of the button either
 *
 *	@param 	image 	Image for button
 *	@param 	himage 	Highlighted Image for button
 *	@param 	rbtn 	title for button
 *	@param 	sel 	The selector which the button would trigger
 */
- (void)setRightBarButton:(NSString*)rbtn selector:(SEL)sel;
- (void)setLeftBarButton:(NSString*)rbtn selector:(SEL)sel;

- (void)setRightBarButtonImage:(UIImage*)img highlightedImage:(UIImage*)himg selector:(SEL)sel;
- (void)setLeftBarButtonImage:(UIImage*)img selector:(SEL)sel;
- (void)setLeftBarButton:(NSString*)title image:(UIImage*)img highlightedImage:(UIImage*)himg selector:(SEL)sel;

#pragma mark - Bar Style

- (UIButton*)buttonWithTitle:(NSString*)title image:(UIImage*)img selector:(SEL)sel;

#pragma mark - Request
/**
 *	Copyright © 2013 Xizue Inc. All rights reserved.
 *
 *	Start request when possible and - (void)prepareRequest should be called
 */
- (BOOL)startRequest;

/**
 *	Copyright © 2013 Xizue Inc. All rights reserved.
 *
 *	数据请求的回调。
 *
 *	@param 	sender 	BSClient 类
 *	@param 	obj 	数据请求成功，则为返回数据
 *
 *	@return 返回的数据可以解析时返回yes，反之为no
 */

- (BOOL)requestDidFinish:(id)sender obj:(NSDictionary*)obj;

/**
 *	Copyright © 2013 Xizue Inc. All rights reserved.
 *
 *	解析分页信息（如果存在）
 *
 *	@param 	obj 	BSClient object
 *
 */
- (void)updatePageInfo:(id)obj;

#pragma mark - Public Methods
/**
 *	Copyright © 2013 Xizue Inc. All rights reserved.
 *
 *	Start request when possible and - (void)prepareLoadMoreRequest should be called
 *
 *	@param 	reqID 	request identifier
 */
- (void)loadMoreRequest;
/**
 *	Copyright © 2013 Xizue Inc. All rights reserved.
 *
 *	Resign keyboard for all subviews and subview's subviews for a view
 *
 *	@param 	aView 	The view with Text Input Object that you want to resign
 */
- (void)resignAllKeyboard:(UIView*)aView;
/**
 *	Copyright © 2013 Xizue Inc. All rights reserved.
 *
 *	self.edgesForExtendedLayout = UIRectEdgeNone;
 *
 */
- (void)setEdgesNone;

/**
 *	Copyright © 2013 Xizue Inc. All rights reserved.
 *
 *	用户点击转发某条消息消息
 *
 */
- (void)forwordWithMsg:(Message*)msg;

/**
 *	Copyright © 2013 Xizue Inc. All rights reserved.
 *
 *	返回到首页并立即跳转
 *
 */
- (void)pushViewControllerAfterPop:(id)con;

/**
 *	Copyright © 2013 Xizue Inc. All rights reserved.
 *
 *	当启动自定义标题时，可以在这里配置 额外的属性 to be implemented in sub-classes
 *
 */
- (void)individuationTitleView;
@end
