//
//  ViewController.m
//
//  AppDelegate.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "ViewController.h"
#import "BasicNavigationController.h"
#import "BSEngine.h"
#import "LoginController.h"
#import "AppDelegate.h"
#import "XAddrBookViewController.h"
#import "Session.h"
#import "UIImage+FlatUI.h"
#import "UIColor+FlatUI.h"
#import "SessionViewController.h"
#import "Globals.h"
#import "MenuView.h"
#import "SessionNewController.h"
#import "SupplementaryInformationViewController.h"
#import "FriendPhotosViewController.h"
#import "CameraActionSheet.h"
#import "PhotoSeeViewController.h"
#import "UIImage+Resize.h"
#import "Contact.h"
#import "SearchAllViewController.h"
#import "TalkingViewController.h"
#import "Message.h"
#import "XMPPManager.h"
#import "FindViewController.h"

@interface ViewController ()<UIGestureRecognizerDelegate, MenuViewDelegate , UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    UIView  * actionBar; //
}

@end

@implementation ViewController

- (id)init {
    if (self = [super init]) {
        // Custom initialization
        self.className = @[@"SessionViewController", @"FindViewController", @"XAddrBookViewController"];
        [self setNameArray:@[@"聊天", @"发现", @"通讯录"]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    // ACTIONBAR
    UIView * actionbar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
    self.navigationItem.titleView = actionbar;
    actionBar = actionbar;
    // left icon
    UIImageView * icon = [[UIImageView alloc] initWithImage:LOADIMAGE(@"actionbar_icon")];
    icon.frame = CGRectMake(8, 10, 24, 24);
    [actionbar addSubview:icon];
    
    UILabel * lab = [UILabel linesText:AppDisplayName font:[UIFont boldSystemFontOfSize:18] wid:100 lines:0 color:[UIColor whiteColor]];
    lab.origin = CGPointMake((actionbar.width - lab.width)/2 - 20, 10);
    [actionbar addSubview:lab];
    
    int i = 0;
    UIButton * btn = [self buttonInActionbar:i++ actionbar:actionbar];
    [btn setImage:LOADIMAGE(@"actionbar_search_icon") forState:UIControlStateNormal];

    btn = [self buttonInActionbar:i++ actionbar:actionbar];
    [btn setImage:LOADIMAGE(@"actionbar_add_icon") forState:UIControlStateNormal];
    
    btn = [self buttonInActionbar:i++ actionbar:actionbar];
    [btn setImage:LOADIMAGE(@"actionbar_more_icon") forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    /**标准情况下, 只要姓名存在即可以登录*/
    if ([[BSEngine currentUser] canLogin]) {
        // 登陆后 刷新 actionbar 各栏上的数量标记
        NSString * str = [[BSEngine currentUser] readConfigWithKey:@"newNotifyCount"];
        if (str.intValue > 0) {
            [self setBadgeValueforPage:2 withContent:@"-1"];
        }
        str = [[BSEngine currentUser] readConfigWithKey:@"FriendsCircle"];
        if (str.intValue > 0) {
            [self setBadgeValueforPage:1 withContent:@"-1"];
        }
        str = [[BSEngine currentUser] readConfigWithKey:@"NewMeetMessage"];
        if (str.intValue > 0) {
            [self setBadgeValueforPage:1 withContent:@"-1"];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self showLoginIfNeed]) {
        if (![[BSEngine currentUser] canLogin]) {
            // 完善基本信息
            SupplementaryInformationViewController * con = [[SupplementaryInformationViewController alloc] init];
            con.editType = forSupplementaryInfo;
            BasicNavigationController *subNav = [[BasicNavigationController alloc] initWithRootViewController:con];
            [self presentViewController:subNav animated:YES completion:nil];
        } else if (![[XMPPManager shareManager] exist]){
            // 登陆成功 启动通知监听 配置 声音震动
            User *user = [[BSEngine currentEngine] user];
            BOOL canplayVoice = [user readConfigWithKey:@"canplayVoice"].boolValue;
            BOOL canplayShake = [user readConfigWithKey:@"canplayShake"].boolValue;
            if (canplayVoice && canplayShake) {
                [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound| UIRemoteNotificationTypeAlert];
            } else if (canplayVoice && !canplayShake) {
                [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound];
            } else if (!canplayVoice && canplayShake) {
                [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert];
            } else if (canplayVoice) {
                [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound];
            } else {
                [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge];
            }
                // 加载会话列表
            SessionViewController * tmpCon = [self.viewControllers objectAtIndex:0];
            [tmpCon loginSuccess];
                // 登陆openfire
            [[AppDelegate instance] signIn];
            _timefromLastTime = [[NSDate date] timeIntervalSince1970];
            dispatch_async(kQueueDEFAULT, ^{
                [self checkNow];
            });
        } else {
            [[XMPPManager shareManager] connectAgain];
        }
    }
}

- (UIButton*)buttonInActionbar:(int)number actionbar:(UIView*)actionbar{
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = number;
    [btn setImage:LOADIMAGE(@"actionbar_add_icon") forState:UIControlStateNormal];
    btn.frame = CGRectMake(self.view.width - 44*(3-number), 6, 32, 32);
    [actionbar addSubview:btn];
    [btn addTarget:self action:@selector(btnItemPressed:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)btnItemPressed:(UIButton*)sender {
    MenuView * menuView;
    switch (sender.tag) {
        case 0:
            // 搜索
        {
            SearchAllViewController * con = [[SearchAllViewController alloc] init];
            [self pushViewController:con];
        }
            break;
        case 1:
            // 添加
            menuView = [[MenuView alloc] initWithButtonTitles:@[@"发起群聊",@"添加朋友",@"扫一扫",@"拍照分享"] withDelegate:self];
            menuView.tag = sender.tag;
            break;
        case 2:
            // 更多
            menuView = [[MenuView alloc] initWithButtonTitles:@[[BSEngine currentUser].nickname, @"我的相册",@"我的收藏", @"设置", @"意见反馈"] withDelegate:self];
            menuView.tag = -1;
            break;
        default:
            break;
    }
    if (menuView) {
        [menuView showInView:self.view origin:CGPointMake(tableView.width - 180, 0)];
    }
}

/**更新[新的朋友]的数量*/
- (void)setNewNotifyCount {
    NSString * str = [[BSEngine currentUser] readConfigWithKey:@"newNotifyCount"];
    if (!str) {
        str = @"1";
    } else {
        str = [NSString stringWithFormat:@"%d", str.intValue + 1];
    }
    [[[BSEngine currentEngine] user] saveConfigWhithKey:@"newNotifyCount" value:str];
    [self setBadgeValueforPage:2 withContent:@"-1"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateSectionZero" object:nil];
}

/**更新总的未读聊天消息数*/
- (void)refreshNewChatMessage:(int)value {
    NSString *str = nil;
    if (value > 0) {
        str = [NSString stringWithFormat:@"%d", value];
    } else {
        str = nil;
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber = value;
    [self setBadgeValueforPage:0 withContent:str];
    
    DLog(@"更新总的未读消息数 : %d", value);
}

/**更新总的未读聊吧消息数*/
- (void)updateNewMeetMessage:(BOOL)hasNew {
    NSString *str = nil;
    User * user = [BSEngine currentUser];
    if (hasNew) {
        str = @"-1";
    } else {
        str = nil;
    }
    [user saveConfigWhithKey:@"NewMeetMessage" value:[NSString stringWithFormat:@"%d", hasNew]];
    [self setBadgeValueforPage:1 withContent:str];
    FindViewController * con = (FindViewController*)[self.viewControllers objectAtIndex:1];
    [con receivedNewMeetMessage];
}

#pragma mark - Message Get
/**Message Get: xmpp收到的消息会转发到此函数里进行处理*/
- (void)receivedMessage:(Message*)msg {
    if (msg.isSendByMe && msg.state == forMessageStateError) {
        // 本地存在的消息更新数据
        [msg updateId];
    } else {
        // 不存在的插入数据
        [msg insertDB];
    }
    if (msg.typechat == forChatTypeMeet) {
        [self updateNewMeetMessage:YES];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"receivedMessage" object:msg];
}

#pragma mark - Message notify
/**重置新消息数量*/
- (void)reSetNewFriendAdd {
    [[[BSEngine currentEngine] user] saveConfigWhithKey:@"newNotifyCount" value:@"0"];
    [self setBadgeValueforPage:2 withContent:nil];
}

/**收到好友申请后，点亮相应的小红点*/
- (void)hasNewFriendAdd {
    [self setBadgeValueforPage:2 withContent:@"-1"];
}

#pragma mark - cleanMessageWithSession
/**执行清除不必要的会话*/
- (void)cleanMessageWithSession:(id)item {
    SessionViewController * tmpCon = [self.viewControllers objectAtIndex:0];
    [tmpCon cleanMessageWithSession:item];
}

#pragma mark do Contact
/**保留接口 可以使用来处理收到移除好友的消息*/
- (void)doRemoveContact:(User *)item {
    DLog(@"doRemoveContact");
}

/**保留接口 可以使用来处理收到添加好友的消息*/
- (void)doAddContact:(User *)item {
    DLog(@"doAddContact");
}

- (void)pushViewController:(id)con fromIndex:(int)idx {
    BaseViewController * tmpCon = [self.viewControllers objectAtIndex:idx];
    [tmpCon pushViewController:con];
}

#pragma mark - MenuViewDelegate
- (void)popoverView:(MenuView *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSString * str = nil;
    if (sender.tag == 1) {
        switch (buttonIndex) {
            case 0:
                // 发起群聊
                str = @"SessionNewController";
                break;
            case 1:
                // 添加朋友
                str = @"FriendsAddViewController";
                
                break;
            case 2:
                // 扫一扫
                str = @"QRcodeReaderViewController";
                
                break;
            case 3:
                // 拍照分享
            {
                CameraActionSheet *actionSheet = [[CameraActionSheet alloc] initWithActionTitle:nil TextViews:nil CancelTitle:@"取消" withDelegate:self otherButtonTitles:@"从相册选择",  @"拍一张", nil];
                actionSheet.tag = -1;
                [actionSheet show];
            }
                break;
                
            default:
                break;
        }
        
    } else {
        switch (buttonIndex) {
            case 0:
                // 个人信息
                str = @"SupplementaryInformationViewController";
                break;
            case 1:
                // 我的相册
            {
                User *user = [[BSEngine currentEngine] user];
                FriendPhotosViewController *con = [[FriendPhotosViewController alloc] initWithUser:user];
                [self pushViewController:con];
            }
                break;
            case 2:
                // 我的收藏
                str = @"CollectionViewController";
                break;
            case 3:
                // 设置
                str = @"SystemSettingViewController";
                break;
                
            case 4:
                // 意见反馈
                str = @"FeedbackViewController";
                break;
            default:
                break;
        }
    }
    
    if (str) {
        UIViewController * tmpCon = [[NSClassFromString(str) alloc] init];
        if ([str isEqualToString: @"SessionNewController"]) {
            [(SessionNewController*)tmpCon setIsGroup:YES];
            [(SessionNewController*)tmpCon setIsShowGroup:YES];
        }
        [self pushViewController:tmpCon];
    }
}

- (void)popoverViewCancel:(MenuView *)sender {
}

#pragma mark - CameraActionSheetDelegate

/**选择图片*/
- (void)cameraActionSheet:(CameraActionSheet *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 2) {
        return;
    }
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    if (buttonIndex == 0){
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    } else if (buttonIndex == 1) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        } else {
            [self showText:@"无法打开相机"];
        }
    }
    [self presentModalController:picker animated:YES];
}

#pragma mark - imagePicker

/**新建分享*/
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage * img = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        img = [img resizeImageGreaterThan:1024];
        PhotoSeeViewController * con = [[PhotoSeeViewController alloc] init];
        con.preImage = img;
        [self pushViewController:con];
    }];
}

/**检测新的朋友*/
- (void)checkNow {
    if ([Contact canAccessBook]) {
        NSArray * arr = [Contact readABAddressBook];
        NSMutableString * str = [NSMutableString string];
        NSMutableArray * uploadArr = [NSMutableArray array];
        NSMutableArray * uploadPersonId = [NSMutableArray array];
        for (Contact *item in arr) {
            // 电话号码对比本地存储的数据库，筛选可以被上传的号码
            if ([Contact isInlastContacts:item.phone]||[Contact contactWithPhone:item.phone]) {
                continue;
            }
            if (str.length > 0) {
                [str appendString:@","];
            }
            [str appendFormat:@"%@",item.phone];
            [uploadArr addObject:item.phone];
            [uploadPersonId addObject:[NSString stringWithFormat:@"%d", item.personId]];
        }
        if (str.length > 0 ) {
            // 可以被上传的号码添加进数据库
            [Contact putInlastContacts:uploadArr];
            dispatch_async(kQueueMain, ^{
                BSClient * clientContact = [[BSClient alloc] initWithDelegate:self action:@selector(requestCheckNowDidFinish:obj:)];
                clientContact.tag = (id)uploadArr;
                clientContact.indexPath = (id)uploadPersonId;
                [clientContact newFriends:str];
            });
        }
    }
}

#pragma mark - Rrequest

- (BOOL)requestCheckNowDidFinish:(BSClient *)sender obj:(NSDictionary *)obj {
    if (!sender.hasError) {
        NSArray * arr = [obj getArrayForKey:@"data"];
        NSMutableArray * uploadArr = (id)sender.tag;
        NSMutableArray * uploadPersonId = (id)sender.indexPath;
        [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Contact * item = [Contact objWithJsonDic:obj];
            item.nickname = [obj getStringValueForKey:@"name" defaultValue:@""];
            [uploadArr enumerateObjectsUsingBlock:^(NSString * phone, NSUInteger idx, BOOL *stop) {
                if ([phone isEqualToString:item.phone]) {
                    *stop = YES;
                    item.personId = ((NSString*)uploadPersonId[idx]).intValue;
                }
            }];
            [item insertDB];
        }];
        if (arr.count > 0) {
            // 通知更新数据库和界面显示
            [[[BSEngine currentEngine] user] saveConfigWhithKey:@"newNotifyCount" value:@"1"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshList" object:nil];
            [self setBadgeValueforPage:2 withContent:@"-1"];
        }
    }
    
    sender = nil;
    return YES;
}

/**页码发送改变后会调用这个函数*/
- (void)pageHasChanged {
    BaseTableViewController * tmpCon = [self.viewControllers objectAtIndex:self.getCurrentPageIndex];
    [tmpCon refreshDataListIfNeed];
}
@end