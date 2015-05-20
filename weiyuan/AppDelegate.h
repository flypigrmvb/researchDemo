//
//  AppDelegate.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ViewController;
@class Message, User;
@class Session;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) NSTimer * timerOnlineSetter;

+ (AppDelegate*)instance;

- (void)signIn;
- (void)signOut;

- (void)sendMessage:(Message*)msg;
- (void)refreshNewChatMessage:(int)value;
- (void)updateNewMeetMessage:(BOOL)hasNew;
- (void)reSetNewFriendAdd;
- (void)hasNewFriendAdd;

- (void)startSetOnline;
- (void)cancelAPNS;

- (void)receivedMessage:(Message*)msg;

/**xmpp接收到消息会返回此接口*/
- (void)didReceiveMessage:(NSDictionary *)result from:(NSString *)from receiptMessageID:(NSString*)receiptMessageID;

- (void)signOutWithConflict;
// user
- (void)doRemoveContact:(User*)item;
- (void)doAddContact:(User*)item;

- (void)setBadgeValueforPage:(int)page withContent:(NSString*)withContent;
- (void)cleanMessageWithSession:(Session*)item;

- (void)pushViewController:(id)con fromIndex:(int)idx;

- (void)audioPlayRecMsg;
- (void)audioPlaySendMsg;
- (void)audioPlayRecNotify;
@end
