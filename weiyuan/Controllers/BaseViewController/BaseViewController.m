//
//  BaseViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "BaseViewController.h"
#import "BSEngine.h"
#import "BSClient.h"
#import "KLoadingView.h"
#import "KAlertView.h"
#import "TextInput.h"
#import "KWAlertView.h"
#import "BasicNavigationController.h"
#import "LoginController.h"
#import "SessionNewController.h"
#import "AppDelegate.h"
#import "Globals.h"
#import "ImageTouchView.h"

@interface BaseViewController () <KWAlertViewDelegate, UIGestureRecognizerDelegate, ImageTouchViewDelegate, UITextFieldDelegate> {
    KLoadingView   * loadingView;
}
@end

@implementation BaseViewController
@synthesize willShowBackButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self initDefault];
    }
    return self;
}

- (id)init {
    if (self = [super init]) {
        [self initDefault];
    }
    return self;
}

- (void)initDefault {
    needToLoad = YES;
    baseImageQueue = [[ImageProgressQueue alloc] initWithDelegate:self];
    baseImageCaches = [[ImageCaches alloc] initWithMaxCount:250];
    baseOperationQueue = [[NSOperationQueue alloc] init];
    baseOperationQueue.maxConcurrentOperationCount = 1;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationInfoUpdate:) name:NtfInfoUpdate object:nil];
}

- (void)dealloc {
    [client cancel];
    Release(client);
    Release(baseImageCaches);
    
    [baseImageQueue cancelOperations];
    Release(baseImageQueue);
    
    [baseOperationQueue cancelAllOperations];
    Release(baseOperationQueue);
    
    self.loading = NO;
    Release(loadingView);
    Release(currentInputView);
    Release(nib);
    
    Release(refreshControl);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
//    self.extendedLayoutIncludesOpaqueBars = YES;
    self.view.backgroundColor = RGBCOLOR(247, 247, 247);
    isFirstAppear = YES;
    if (willShowBackButton) {
        UIImage * bkgN = [[UIImage imageNamed:@"btn_back_n"] stretchableImageWithLeftCapWidth:19 topCapHeight:0];
        UIImage * bkgD = [[UIImage imageNamed:@"btn_back_d"] stretchableImageWithLeftCapWidth:19 topCapHeight:0];
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectZero;
        btn.size = bkgN.size;
        [btn setBackgroundImage:bkgN forState:UIControlStateNormal];
        [btn setBackgroundImage:bkgD forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem * itemLeft = [[UIBarButtonItem alloc] initWithCustomView:btn];
        self.navigationItem.leftBarButtonItem = itemLeft;
    }
    if (Sys_Version >= 7) {
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    needToLoad = YES;
    keyboardHeight = DefaultKeyBoardHeight;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (loadingView) [loadingView show];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _moreButton.delegate = self;
    _addButton.delegate = self;
    _searchButton.delegate = self;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (loadingView) [loadingView hide];
    isFirstAppear = NO;
    [self.view removeKeyboardControl];
    [currentInputView resignFirstResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:currentInputView];
    _moreButton.delegate = nil;
    _addButton.delegate = nil;
    _searchButton.delegate = nil;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)sender {
    currentInputView = sender;
    return YES;
}

- (void)showBackButton {
    willShowBackButton = YES;
}

- (BOOL)showLoginIfNeed {
    if (![[BSEngine currentEngine] isLoggedIn]) {
        BasicNavigationController *subNav = [[BasicNavigationController alloc] initWithRootViewController:[[LoginController alloc] init]];
        [self presentViewController:subNav animated:YES completion:nil];
        return NO;
    }
    return YES;
}

- (void)setEdgesNone {
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

#pragma mark -
#pragma mark - Loading State

- (void)showText:(id)text {
    [KAlertView showType:KAlertTypeNone text:text for:1.45 animated:YES];
}

- (void)showAlertWithTag:(id)text isNeedCancel:(BOOL)isNeedCancel tag:(NSInteger)tag {
    KWAlertView *k = [[KWAlertView alloc] initWithTitle:nil message:text delegate:self cancelButtonTitle:isNeedCancel?@"取消":nil otherButtonTitle:@"确定"];
    k.tag = tag;
    [k show];
}

- (void)showAlert:(id)text isNeedCancel:(BOOL)isNeedCancel {
    [[[KWAlertView alloc] initWithTitle:nil message:text delegate:self cancelButtonTitle:isNeedCancel?@"取消":nil otherButtonTitle:@"确定"] show];
}

- (void)kwAlertView:(KWAlertView*)sender didDismissWithButtonIndex:(NSInteger)index {
    
}


- (void)setLoading:(BOOL)bl {
    [self setLoading:bl content:String(@"稍等一下")];
}

- (void)setLoading:(BOOL)bl content:(NSString*)con {
    if (bl) {
        self.view.userInteractionEnabled = NO;
        if (loadingView == nil) {
            loadingView = [[KLoadingView alloc] initWithText:con animated:NO];
        }
        [loadingView show];
    } else if (loadingView) {
        self.view.userInteractionEnabled = YES;
        [loadingView hide];
        loadingView = nil;
    }
}

/**返回到上一个页面*/
- (void)popViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)pushViewController:(id)con {
    ((BaseViewController*)con).hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:con animated:YES];
}

- (void)sendNotificationInfoUpdate:(id)obj {
    [[NSNotificationCenter defaultCenter] postNotificationName:NtfInfoUpdate object:obj];
}

- (void)notificationInfoUpdate:(NSNotification*)notification {
    //to be implemented in sub-classes
}

#pragma mark -
#pragma mark - Modal View Controller
- (void)presentModalController:(id)con animated:(BOOL)animated {
    [self presentViewController:con animated:animated completion:nil];
}

- (void)dismissModalController:(BOOL)animated {
    [self dismissViewControllerAnimated:animated completion:nil];
}

- (void)resignAllKeyboard:(UIView*)aView
{
    if([aView isKindOfClass:[UITextField class]] ||
       [aView isKindOfClass:[UITextView class]])
    {
        UITextField* tf = (UITextField*)aView;
        if([tf canResignFirstResponder])
            [tf resignFirstResponder];
    }
    
    for (UIView* pView in aView.subviews) {
        [self resignAllKeyboard:pView];
    }
}

+ (void)resignAllKeyboard:(UIView*)aView
{
    if([aView isKindOfClass:[UITextField class]] ||
       [aView isKindOfClass:[UITextView class]])
    {
        UITextField* tf = (UITextField*)aView;
        if([tf canResignFirstResponder])
            [tf resignFirstResponder];
    }
    
    for (UIView* pView in aView.subviews) {
        [self resignAllKeyboard:pView];
    }
}

#pragma mark -
#pragma mark - Bar Style
- (UIButton*)buttonWithTitle:(NSString*)title image:(UIImage*)img selector:(SEL)sel {
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (title) {
        UIFont * font = [UIFont boldSystemFontOfSize:15];
        CGSize size = CGSizeMake(150, 18);
        size = [title sizeWithFont:font constrainedToSize:size];
        btn.frame = CGRectMake(0, 0, size.width + 6, 31);
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitle:title forState:UIControlStateHighlighted];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        btn.titleLabel.font = font;
        if (img) {
            btn.frame = CGRectMake(0, 0, img.size.width, img.size.height);
            [btn setBackgroundImage:img forState:UIControlStateNormal];
        }
    } else if (img) {
        btn.frame = CGRectMake(0, 0, img.size.width, img.size.height);
        [btn setImage:img forState:UIControlStateNormal];
    }
    if (sel != nil) {
        [btn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    }
    return btn;
}

- (void)setRightBarButton:(NSString*)title selector:(SEL)sel {
    UIButton * btn = [self buttonWithTitle:title image:nil selector:sel];
    UIBarButtonItem * itemRight = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = itemRight;
}

- (void)setLeftBarButton:(NSString*)title selector:(SEL)sel {
    UIButton * btn = [self buttonWithTitle:title image:nil selector:sel];
    UIBarButtonItem * itemLeft = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = itemLeft;
}

- (void)setLeftBarButton:(NSString*)title image:(UIImage*)img highlightedImage:(UIImage*)himg selector:(SEL)sel {
    UIButton * btn = [self buttonWithTitle:title image:img selector:sel];
    if (himg) {
        [btn setBackgroundImage:himg forState:UIControlStateHighlighted];
    }
    UIBarButtonItem * itemLeft = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = itemLeft;
}

- (void)setRightBarButtonImage:(UIImage*)img highlightedImage:(UIImage*)himg selector:(SEL)sel {
    UIButton * btn = [self buttonWithTitle:nil image:img selector:sel];
    if (himg) {
        [btn setImage:himg forState:UIControlStateHighlighted];
    }
    UIBarButtonItem * itemRight = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = itemRight;
}

- (void)setLeftBarButtonImage:(UIImage*)img selector:(SEL)sel {
    UIButton * btn = [self buttonWithTitle:nil image:img selector:sel];
    UIBarButtonItem * itemLeft = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = itemLeft;
}

//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    [self resignAllKeyboard:self.view];
//}

- (void)loginControllerDidLoginSuccess:(id)sender
{
    DLog(@"loginControllerDidLoginSuccess");
}

#pragma mark - Requests
- (BOOL)startRequest {
    if (client) {
        return NO;
    }
    if (needToLoad) {
        self.loading = YES;
    }
    client = [[BSClient alloc] initWithDelegate:self action:@selector(requestDidFinish:obj:)];
    return YES;
}

- (BOOL)requestDidFinish:(BSClient*)sender obj:(NSDictionary*)obj {
    client = nil;
    self.loading = NO;
    [refreshControl performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.8];
    if (sender.hasError) {
        [sender showAlert];
        return NO;
    }
    return YES;
}

- (void)loadMoreRequest {
    if (client) return;
    self.loading = YES;
    client = [[BSClient alloc] initWithDelegate:self action:@selector(requestDidFinish:obj:)];
    [self prepareLoadMoreWithPage:currentPage + 1 sinceID:sinceID];
}

- (void)prepareLoadMoreWithPage:(int)page sinceID:(int)sID {
    //to be implemented in sub-classes
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
    //to be implemented in sub-classes
}


#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)sender {
    currentInputView = sender;
}

- (void)textViewDidBeginEditing:(UITextView *)sender {
    currentInputView = sender;
}

- (BOOL)textFieldShouldReturn:(UITextField *)sender{
    [sender resignFirstResponder];
    currentInputView = nil;
    return YES;
}

- (BOOL)textField:(UITextField *)sender shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}
- (BOOL)textView:(UITextView*)sender shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text {
    if ([text hasPrefix:@"\n"]) {
        [sender resignFirstResponder];
        return NO;
    }
    return YES;
}
/**
 *	Copyright © 2013 Xizue Inc. All rights reserved.
 *
 *	用户点击转发某个内容
 *
 */
- (void)forwordWithMsg:(Message*)msg {
    SessionNewController * con = [[SessionNewController alloc] init];
    con.value = msg;
    con.isForword =
    con.isShowGroup = YES;
    [[AppDelegate instance] pushViewController:con fromIndex:0];
}

/**
 *	Copyright © 2013 Xizue Inc. All rights reserved.
 *
 *	返回到首页并立即跳转
 *
 */
- (void)pushViewControllerAfterPop:(id)con {
    [UIView animateWithDuration:0.15 animations:^{
        [self.navigationController popToRootViewControllerAnimated:NO];
        [[AppDelegate instance] pushViewController:con fromIndex:0];
    }];
}

- (UIView*)titleView {
    if (!_titleView) {
        _titleView = [[UIView alloc] initWithFrame:CGRectMake(17, 0, self.view.width - 17, 44)];
        _titleView.backgroundColor = [UIColor clearColor];
        
        titlelab = [[UILabel alloc] initWithFrame:CGRectMake(-34, 0, self.view.width, 44)];
        titlelab.font = [UIFont boldSystemFontOfSize:20];
        titlelab.backgroundColor = [UIColor clearColor];
        titlelab.textColor = [UIColor whiteColor];
        titlelab.text = self.navigationItem.title;
        titlelab.textAlignment = NSTextAlignmentCenter;
        [_titleView addSubview:titlelab];
        
        [_titleView addSubview:[self searchView]];
        [_titleView addSubview:[self addButton]];
        [_titleView addSubview:[self searchButton]];
        _titleView.backgroundColor = [UIColor clearColor];
        [self individuationTitleView];
    }
    return _titleView;
}

/**
 *	Copyright © 2013 Xizue Inc. All rights reserved.
 *
 *	当启动自定义标题时，可以在这里配置 额外的属性 to be implemented in sub-classes
 *
 */
- (void)individuationTitleView {
    //to be implemented in sub-classes
}

- (ImageTouchView*)addButton {
    if (!_addButton) {
        _addButton = [[ImageTouchView alloc] initWithFrame:CGRectMake(self.searchView.right - 35, 0, 30, 44) delegate:self];
        _addButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        _addButton.tag = @"normalList";
        _addButton.image = LOADIMAGE(@"icon_favorite_list");
        _addButton.alpha = 0;
    }
    return _addButton;
}

- (ImageTouchView*)searchButton {
    if (!_searchButton) {
        _searchButton = [[ImageTouchView alloc] initWithFrame:CGRectMake(self.titleView.width - 75, 0, 30, 44) delegate:self];
        _searchButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        _searchButton.tag = @"none";
        _searchButton.image = LOADIMAGE(@"btn_search_d");
        _searchButton.highlightedImage = LOADIMAGE(@"btn_search");
        _searchButton.alpha = 0;
    }
    return _searchButton;
}

- (ImageTouchView*)moreButton {
    if (!_moreButton) {
        _moreButton = [[ImageTouchView alloc] initWithFrame:CGRectMake(self.titleView.width - 35, 0, 30, 44) delegate:self];
        _moreButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        _moreButton.tag = @"more";
        _moreButton.image = LOADIMAGE(@"btn_more");
    }
    return _moreButton;
}

- (UIView *)searchView {
    if (!_searchView) {
        _searchView = [[UIView alloc] initWithFrame:CGRectMake(30, 5, self.view.width - 65, 34)];
        _searchView.layer.masksToBounds = YES;
        _searchView.layer.cornerRadius = 4;
        _searchView.backgroundColor = [UIColor whiteColor];
        _searchView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        //        _searchView.userInteractionEnabled = YES;
        [_searchView addSubview:self.searchField];
    }
    return _searchView;
}

- (UITextField*)searchField {
    if (!_searchField) {
        _searchField = [[KTextField alloc] initWithFrame:CGRectMake(30, 0, _searchView.width - 30, 34)];
        _searchField.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        [_searchField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        _searchField.textColor = [UIColor blackColor];
        _searchField.placeholder = @"请输入";
        _searchField.returnKeyType = UIReturnKeyDone;
        _searchField.backgroundColor = [UIColor clearColor];
        _searchField.delegate = self;
    }
    return _searchField;
}

- (void)imageTouchViewDidSelected:(id)sender {
    //to be implemented in sub-classes
}
@end
