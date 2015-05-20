//
//  AppDelegate.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "Globals.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "Contact.h"
#import "DDTTYLogger.h"
#import "BSEngine.h"
#import "BSClient.h"
#import "Message.h"
#import "User.h"
#import "Notify.h"
#import "Room.h"
#import "ImageProgressQueue.h"
#import "JSON.h"
#import "KAlertView.h"
#import "KWAlertView.h"
#import "XMPPManager.h"
#import "BMapKit.h"
#import "BasicNavigationController.h"

static SystemSoundID soundDidRecMsg;
static SystemSoundID soundDidSendMsg;
static SystemSoundID soundDidRecNotify;

@interface AppDelegate() <BMKGeneralDelegate> {
    BMKMapManager   * _mapManager;
    NSMutableArray  * prepSendList;
    BSClient        * client;
}

@property (nonatomic, strong) ViewController * viewController;

@end

@implementation AppDelegate
@synthesize viewController;

+ (AppDelegate*)instance {
	return (AppDelegate*)[[UIApplication sharedApplication] delegate];
}

- (void)dealloc {
    Release(_mapManager);
    self.timerOnlineSetter = nil;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self initializeAudios];
    
    // Setup Baidu Map
    _mapManager = [[BMKMapManager alloc] init];
    BOOL ret = [_mapManager start:@"DHpAihyiy9OEfw8hR2i0mH22" generalDelegate:self];
    if (!ret) {
        DLog(@"manager start failed!");
    }
    
    prepSendList = [[NSMutableArray alloc] init];
    // init DBFile
    [Globals createTableIfNotExists];
    [Globals initializeGlobals];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[ViewController alloc] init];
    BasicNavigationController *subNav = [[BasicNavigationController alloc] initWithRootViewController:viewController];
    
    self.window.rootViewController = subNav;
    [self.window makeKeyAndVisible];
    if (Sys_Version >= 8) {
        UIUserNotificationType types = UIRemoteNotificationTypeBadge |UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert;
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        UIUserNotificationSettings * registerSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:registerSettings];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound];
    }

    application.applicationIconBadgeNumber = 0;
    
    dispatch_async(kQueueDEFAULT, ^{
        UILocalizedIndexedCollation * theCollation = [UILocalizedIndexedCollation currentCollation];
        [theCollation sectionForObject:self
               collationStringSelector:@selector(displayName)];
    });
    return YES;
}

- (NSString*)displayName {
    return AppDisplayName;
}

// 注册推送
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)pToken {
    
    NSString * uid = [NSString stringWithFormat:@"%@", pToken];
    uid = [uid stringByReplacingOccurrencesOfString:@"<" withString:@""];
    uid = [uid stringByReplacingOccurrencesOfString:@">" withString:@""];
    uid = [uid stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:uid forKey:@"APNSID"];
    [defaults synchronize];
    
    [BSEngine currentEngine].deviceIDAPNS = uid;
    DLog(@"Regist APNS successfully %@",uid);
}

-(void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler
{
    //在非本App界面时收到本地消息，下拉消息会有快捷回复的按钮，点击按钮后调用的方法，根据identifier来判断点击的哪个按钮，notification为消息内容
    DLog(@"%@----%@",identifier,notification);
    completionHandler();//处理完消息，最后一定要调用这个代码块
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    // 处理推送消息
     DLog(@"----%@",userInfo.description);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    DLog(@"Regist APNS fail%@",error);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if ([BSEngine currentEngine].isLoggedIn) {
        DLog(@"Chat System offline");
        [[XMPPManager shareManager] disconnect];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    if ([BSEngine currentEngine].isLoggedIn) {
        [[XMPPManager shareManager] connectAgain];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if ([[BSEngine currentEngine] isLoggedIn]) {
        User * user = [[BSEngine currentEngine] user];
        BOOL isNoticedNewFriend = [user readConfigWithKey:@"isNoticedNewFriend"].boolValue;
        if (isNoticedNewFriend) {
            NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
            if (time - viewController.timefromLastTime > 3600*24) {
                // 触发检测
                viewController.timefromLastTime = time;
                [viewController checkNow];
            }
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark -
#pragma mark - reset Badge Number
bool isNotificationSetBadge;
- (void)resetBadgeNumberOnProviderWithDeviceToken: (NSString *)deviceTokenString
{
	DLog(@"reset Provider DeviceToken %@", deviceTokenString);
}

- (void)signOut {
    //    [[LocalPassManager sharedManager] deleteData];
    [[XMPPManager shareManager] disconnect];
    DLog(@"Forced to leave the server");
    [self cancelAPNS];
    DLog(@"Chat System offline");
    [[XMPPManager shareManager] teardownStream];
    DLog(@"Exit system");
    [[BSEngine currentEngine] signOut];
    
    self.viewController = [[ViewController alloc] init];
    BasicNavigationController *subNav = [[BasicNavigationController alloc] initWithRootViewController:viewController];
    
    self.window.rootViewController = subNav;
    [self.window makeKeyAndVisible];
}

- (void)signOutWithConflict {
    [self signOut];
    dispatch_async(kQueueDEFAULT, ^{
        dispatch_async(kQueueMain, ^{
            [KAlertView showType:KAlertTypeNone text:@"您的账号已经在其他设备登录" for:1.45 animated:YES];
        });
    });
}

- (void)signIn {
    if (![[XMPPManager shareManager] exist]) {
        DLog(@"Successful login system");
#if ShouldLogXMPPDebugInfo
        // Configure logging framework
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
#endif
        // Setup the XMPP stream
        [[XMPPManager shareManager] setupStream];
        [[XMPPManager shareManager] connectWithId:[BSEngine currentUserId] password:[[BSEngine currentUser] password]];
    }
}

- (void)startSetOnline {
    [self setupAPNS];
}

#pragma mark - Message Get
- (void)receivedMessage:(Message*)msg {
    [viewController receivedMessage:msg];
}

- (void)requestDidFinish:(BSClient*)sender obj:(NSDictionary *)obj{
    if (sender.hasError) {
        [sender showAlert];
        sender = nil;
        return;
    }
    [[AppDelegate instance] audioPlaySendMsg];
    sender = nil;
}

#pragma mark do Contact

- (void)doRemoveContact:(User *)item {
    [item deleteFromDB];
    [self.viewController doRemoveContact:item];
}

- (void)doAddContact:(User *)item {
    [item insertDB];
    [self.viewController setNewNotifyCount];
    [self.viewController doAddContact:item];
}

- (void)setBadgeValueforPage:(int)page withContent:(NSString*)withContent {
    [viewController setBadgeValueforPage:page withContent:withContent];
}

#pragma mark - do Session
- (void)cleanMessageWithSession:(Session*)item {
    [self.viewController cleanMessageWithSession:item];
}

- (void)refreshNewChatMessage:(int)value {
    [self.viewController refreshNewChatMessage:value];
}

- (void)updateNewMeetMessage:(BOOL)hasNew {
    [viewController updateNewMeetMessage:hasNew];
}

- (void)reSetNewFriendAdd {
    [self.viewController reSetNewFriendAdd];
}

- (void)hasNewFriendAdd {
    [self.viewController hasNewFriendAdd];
}

- (void)pushViewController:(id)con fromIndex:(int)idx {
    [self.viewController pushViewController:con fromIndex:idx];
}

#pragma mark - Functions

- (void)setupAPNS {
    User *user = [[BSEngine currentEngine] user];
    BOOL canreceiveNewMessage = [user readConfigWithKey:@"canreceiveNewMessage"].boolValue;
    if (canreceiveNewMessage) {
        BSClient * clt = [[BSClient alloc] initWithDelegate:nil action:nil];
        [clt setupAPNSDevice];
    }
}

- (void)cancelAPNS {
    BSClient * clt = [[BSClient alloc] initWithDelegate:nil action:nil];
    [clt cancelAPNSDevice];
}

#pragma mark - didReceiveMessage
- (void)didReceiveMessage:(NSDictionary *)result from:(NSString *)from receiptMessageID:(NSString*)receiptMessageID {
    if ([from hasPrefix:@"beautyas"]) {
        Notify * ntf = [Notify objWithJsonDic:result];
        if(ntf.type != forNotifydeleted) {
            DLog(@"收到一条新的通知 : %@",ntf.content);

            if (ntf.type == forNotifyGroupInfoUpdate || ntf.type == forNotifyNameChange || ntf.type == forNotifyKickUser || ntf.type == forNotifyLeaveRoom || ntf.type == forNotifyDestroyRoom || ntf.type == forNotifyaddNewOne) {
                [ntf getRoomContent];
                // 群聊通知
                if (ntf.type == forNotifyKickUser) {
                    // 瓜娃子，被踢了塞
                    Room * room = [Room roomForUid:ntf.roomID];
                    [room deleteFromDB];
                } else if (ntf.type == forNotifyLeaveRoom) {
                    // 离开
                    [Room kickOrAddUser:ntf.user toRoom:ntf.roomID isAdd:NO];
                } else if (ntf.type == forNotifyDestroyRoom) {
                    // 销毁
                    Room * room = [Room roomForUid:ntf.roomID];;
                    [room deleteFromDB];
                } else if (ntf.type == forNotifyGroupInfoUpdate) {
                    // 管理员更改房间名
                    Room * room = [Room roomForUid:ntf.roomID];
                    if (room) {
                        [room updateVaule:ntf.roomName key:@"name"];
                    }
                } else if (ntf.type == forNotifyaddNewOne) {
                    // 有新成员进来 更新数据库
                    Room * room = [Room roomForUid:ntf.roomID];
                    if (room) {
                        [room addUser:ntf.user isAdd:YES];
                        [room updateUserList];
                    }
                } else if (ntf.type == forNotifyNameChange) {
                    // 群里有人改了他的群昵称
                    Room * room = [Room roomForUid:ntf.roomID];
                    if (room) {
                        [room userNickNameChanged:ntf.user.uid name:ntf.user.nickname];
                        [room updateUserList];
                        [Message updatePersonNameInRoomMessageWithID:ntf.user.uid withName:ntf.user.nickname roomId:ntf.roomID];
                    }
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"receivedNotifyGroupChat" object:ntf];
            } else if (ntf.type == forNotifyAdd || ntf.type == forNotifyAgreeAdd) {
                [self audioPlayRecNotify];
                [viewController setNewNotifyCount];
                if (ntf.type == forNotifyAdd) {
                    Contact * item = [Contact objWithJsonDic:[result objectForKey:@"user"]];
                    item.statustype = 3;
                    item.isfriend = 0;
                    item.sign = [result getStringValueForKey:@"content" defaultValue:@""];
                    item.isFromLocation = 1;
                    [item insertDB];
                } else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshList" object:nil];
                }
            } else if (ntf.type >= forNotifyZan) {
                if (ntf.type < forNotifyMeetAdd) {
                    if (![ntf.user.uid isEqualToString:[BSEngine currentUserId]]) {
                        if (ntf.type != forNotifyCancelZan) {
                            [ntf insertDB];
                        }
                    }
                    
                    User * user = [BSEngine currentUser];
                    int friendsCirclecount = [[user readValueWithKey:@"FriendsCircle"] intValue];
                    friendsCirclecount++;
                    [user saveConfigWhithKey:@"FriendsCircle" value:[NSString stringWithFormat:@"%d", friendsCirclecount]];
                    [viewController setBadgeValueforPage:1 withContent:@"-1"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"receivedFriendCircle" object:ntf];
                } else {
                    if (ntf.type == forNotifyMeetAdd) {
                        [self audioPlayRecNotify];
                        [viewController setBadgeValueforPage:1 withContent:@"-1"];
                        [viewController updateNewMeetMessage:YES];
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"receivedMeetNot" object:ntf];
//                    [ntf insertDB];
                }
            }
        }
    } else {
        Message * msg = [Message objWithJsonDic:result];
        if (msg) {
            [[XMPPManager shareManager] receiptMessageID:receiptMessageID];
            if (!msg.isSendByMe) {
                [self audioPlayRecMsg];
                msg.unRead = YES;
            } else if (msg.typechat != forChatTypeUser) {
                [self audioPlaySendMsg];
            }
            [self receivedMessage:msg];
        }
    }
}

#pragma mark - BMKGeneralDelegate
- (void)onGetNetworkState:(int)iError
{
    if (0 == iError) {
        DLog(@"[Baidu-Map] moulde:online");
    } else {
        DLog(@"[Baidu-Map] moulde:offline. Reason %d",iError);
    }
}

- (void)onGetPermissionState:(int)iError
{
    if (0 == iError) {
        DLog(@"[Baidu-Map] successfully authorized");
    } else {
        DLog(@"[Baidu-Map] moulde offline. Reason %d",iError);
    }
}

#pragma mark - Audios Play

- (void)initializeAudios {
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"audio_msg_rec" ofType:@"caf"]], &soundDidRecMsg);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"audio_msg_send" ofType:@"caf"]], &soundDidSendMsg);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"audio_notify_rec" ofType:@"wav"]], &soundDidRecNotify);
}

- (void)audioPlayRecMsg {
    User *user = [[BSEngine currentEngine] user];
    BOOL canreceiveNewMessage = [user readConfigWithKey:@"canreceiveNewMessage"].boolValue;
    if (canreceiveNewMessage) {
        BOOL canplayVoice= [user readConfigWithKey:@"canplayVoice"].boolValue;
        if (canplayVoice) {
            AudioServicesPlaySystemSound(soundDidRecMsg);
        }
        
        BOOL canplayShake = [user readConfigWithKey:@"canplayShake"].boolValue;
        if (canplayShake) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
    }
}

- (void)audioPlaySendMsg {
    User *user = [[BSEngine currentEngine] user];
    BOOL canreceiveNewMessage = [user readConfigWithKey:@"canreceiveNewMessage"].boolValue;
    if (canreceiveNewMessage) {
        BOOL canplayVoice= [user readConfigWithKey:@"canplayVoice"].boolValue;
        if (!canplayVoice) {
            return;
        }
        AudioServicesPlaySystemSound(soundDidSendMsg);
    }
}

- (void)audioPlayRecNotify {
    User *user = [[BSEngine currentEngine] user];
    BOOL canreceiveNewMessage = [user readConfigWithKey:@"canreceiveNewMessage"].boolValue;
    if (canreceiveNewMessage) {
        BOOL canplayVoice = [user readConfigWithKey:@"canplayVoice"].boolValue;
        if (canplayVoice) {
            AudioServicesPlaySystemSound(1007);
        }
        BOOL canplayShake = [user readConfigWithKey:@"canplayShake"].boolValue;
        if (canplayShake) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
    }
}


#pragma mark - doSendMessage

- (void)doSendMessage {
    if (client) {
        return;
    }
    
    if (prepSendList.count > 0) {
        BOOL isSuccess = NO;
        Message * msg = prepSendList[0];
        if (msg.typefile == forFileText || msg.typefile == forFileAddress || msg.typefile == forFileNameCard || msg.typefile == forFilefav) {
            isSuccess = YES;
        } else if (msg.typefile == forFileImage) {
            if ([msg.imgUrlL hasPrefix:@"http"] && [msg.imgUrlS hasPrefix:@"http"] && msg.imgWidth > 0 && msg.imgHeight > 0) {
                // 转发的图片消息 -- 不做处理
                isSuccess = YES;
            } else {
                ImageProgress* progress = [[ImageProgress alloc] initWithUrl:msg.imgUrlL delegate:nil];
                if (progress.loaded) {
                    isSuccess = YES;
                    msg.value = progress.image;
                }
            }
        } else if (msg.typefile == forFileVoice) {
            if ([msg.voiceUrl hasPrefix:@"http"]) {
                // 转发的音频消息
                isSuccess = YES;
            } else {
                NSData* data = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/Library/Cache/Audios/%@.mp3",NSHomeDirectory(),[msg.voiceUrl md5Hex]]];
                if (data) {
                    isSuccess = YES;
                    msg.value = data;
                }
            }
        }
        if (isSuccess) {
            client = [[BSClient alloc] initWithDelegate:self action:@selector(doSendMessage:obj:)];
            [client sendMessageWithObject:msg];
        } else {
            msg.state = forMessageStateError;
            [self receivedMessage:msg];
            [prepSendList removeObjectAtIndex:0];
            [self doSendMessage];
        }
    }
}

- (void)doSendMessage:(BSClient*)sender obj:(NSDictionary*)obj {
    client = nil;
    BOOL isSuccess = NO;
    Message* msg = [prepSendList objectAtIndex:0];
    
    if (sender.hasError) {
        // 发送失败，
        if (sender.errorCode == 4) {
            isSuccess = YES;
        }
        DLog(@"%@\t%@",sender.errorMessage,msg.content);
        msg.errorCode = sender.errorCode;
        msg.errorMessage = sender.errorMessage;
        if (sender.errorCode == 3) {
            //            msg.errorMessage = @"你都被踢出去了怎么还能在这里面说话呢?";
           
        }
        
    } else {
        if (obj == nil || ![obj isKindOfClass:[NSDictionary class]]) {
            // 发送失败
            DLog(@"上传失败，未知错误\t%@",msg.content);
        } else {
            obj = [obj objectForKey:@"data"];
            Message* itemM = [Message objWithJsonDic:obj];
            msg.uid = itemM.uid;
            msg.state = itemM.state;
            if (itemM && [itemM.tag isEqualToString:msg.tag]) {
                /*
                 这里需要把文件按url的MD5值 剪切 到相应的地址。
                 */
                NSFileManager* fm = [NSFileManager defaultManager];
                NSError* err = nil;
                
                NSString* sName = nil;  // 原文件名
                NSString* oName = nil;  // 目标文件名
//                
                if (msg.typefile == forFileVoice) {
                    if ([msg.voiceUrl hasPrefix:@"http"]) {
                        // 转发的音频消息
                    } else {
                        sName = [NSString stringWithFormat:@"%@/Library/Cache/Audios/%@.mp3",NSHomeDirectory(),[msg.voiceUrl md5Hex]];
                        oName = [NSString stringWithFormat:@"%@/Library/Cache/Audios/%@.mp3",NSHomeDirectory(),[itemM.voiceUrl md5Hex]];
                        [fm moveItemAtPath:sName toPath:oName error:&err];
                    }
                } else if (msg.typefile == forFileImage) {
                    if ([msg.imgUrlL hasPrefix:@"http"] && [msg.imgUrlS hasPrefix:@"http"] && msg.imgWidth > 0 && msg.imgHeight > 0) {
                        // 转发的图片消息 -- 不做处理
                    } else {
                        sName = [NSString stringWithFormat:@"%@/Library/Cache/Images/%@.dat",NSHomeDirectory(),[msg.imgUrlL md5Hex]];
                        oName = [NSString stringWithFormat:@"%@/Library/Cache/Images/%@.dat",NSHomeDirectory(),[itemM.imgUrlL md5Hex]];
                        [fm moveItemAtPath:sName toPath:oName error:&err];
                        if (err == nil) {
                            sName = [NSString stringWithFormat:@"%@/Library/Cache/Images/%@.dat",NSHomeDirectory(),[msg.imgUrlS md5Hex]];
                            oName = [NSString stringWithFormat:@"%@/Library/Cache/Images/%@.dat",NSHomeDirectory(),[itemM.imgUrlS md5Hex]];
                            [fm moveItemAtPath:sName toPath:oName error:&err];
                        }
                    }
                } else {
                    isSuccess = YES;
                }
                if (err == nil) {
                    // 文件移动成功
                    isSuccess = YES;
                    msg.voiceUrl = itemM.voiceUrl;
                    msg.imgUrlS = itemM.imgUrlS;
                    msg.imgUrlL = itemM.imgUrlL;
                    [msg updateId];
                    [self receivedMessage:msg];
                }
            }
        }
    }
    
    if (!isSuccess) {
        msg.state = forMessageStateError;
        [self receivedMessage:msg];
    }
    
    [prepSendList removeObject:msg];
    [self doSendMessage];
}

// 发送消息预处理
- (void)sendMessage:(Message*)msg {
    if (msg.typefile == forFileText || msg.typefile == forFileAddress || msg.typefile == forFileNameCard || msg.typefile == forFilefav) {
        if (![msg ifExistInDB]) {
            [msg insertDB];
        }
        [prepSendList addObject:msg];
        [self doSendMessage];
    } else {
        NSFileManager* fm = [NSFileManager defaultManager];
        NSError* err = nil;
        
        if (msg.typefile == forFileVoice) {
            if ([msg.voiceUrl hasPrefix:@"http"]) {
                // 转发的音频消息
            } else {
                NSString * path = [NSString stringWithFormat:@"%@/Library/Cache/Audios/%@.mp3",NSHomeDirectory(),[msg.voiceUrl md5Hex]];
                if (![fm fileExistsAtPath:path]) {
                    [fm moveItemAtPath:msg.voiceUrl toPath:path error:&err];
                }
            }
        } else if (msg.typefile == forFileImage) {
            if ([msg.imgUrlL hasPrefix:@"http"] && [msg.imgUrlS hasPrefix:@"http"] && msg.imgWidth > 0 && msg.imgHeight > 0) {
                // 转发的图片消息 -- 不做处理
            } else {
                NSString * pathL = [NSString stringWithFormat:@"%@/Library/Cache/Images/%@.dat",NSHomeDirectory(),[msg.imgUrlL md5Hex]];
                if (![fm fileExistsAtPath:pathL]) {
                    [fm moveItemAtPath:msg.imgUrlL toPath:pathL error:&err];
                    if (err == nil) {
                        NSString * pathS = [NSString stringWithFormat:@"%@/Library/Cache/Images/%@.dat",NSHomeDirectory(),[msg.imgUrlS md5Hex]];
                        if (![fm fileExistsAtPath:pathS]) {
                            [fm moveItemAtPath:msg.imgUrlS toPath:pathS error:&err];
                        }
                    }
                }
            }
        }
        
        if (err == nil) {
            // 文件移动成功
            [msg insertDB];
            [prepSendList addObject:msg];
            [self doSendMessage];
        } else {
            // 文件移动失败
            msg.state = forMessageStateError;
            [self receivedMessage:msg];
        }
    }
}

@end
