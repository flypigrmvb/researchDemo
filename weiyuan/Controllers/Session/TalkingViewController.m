//
//  TalkingViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "TalkingViewController.h"
#import "SessionActionBar.h"
#import "TalkingRecordView.h"
#import "MapViewController.h"
#import "AgreementViewController.h"
#import "SessionInfoController.h"
#import "AppDelegate.h"
#import "AudioMsgPlayer.h"
#import "ChatMessagesCell.h"
#import "UIImage+Resize.h"
#import "ImageViewController.h"
#import "UserInfoViewController.h"
#import "WebViewController.h"
#import "CameraActionSheet.h"
#import "ReportViewController.h"
#import "TextInput.h"
#import "KWAlertView.h"
#import "XMPPManager.h"
#import "BasicNavigationController.h"
#import "BaseNavigationBar.h"
#import "SessionInfoController.h"
#import "CollectionViewController.h"
#import "SessionNewController.h"
#import "Message.h"
#import "Session.h"
#import "Globals.h"
#import "JSON.h"
#import "Meet.h"
#import "Notify.h"
#import "Room.h"
#import "Address.h"

@interface TalkingViewController ()<UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, MapViewDelegate, SessionActionBarDelegate, UITextViewDelegate, CameraActionSheetDelegate> {
    SessionActionBar    * actionBar;
    TalkingRecordView   * recordView;
    BSClient            * qClient;
    BOOL                needShowNameInGroup;
}

@property (nonatomic, strong) NSIndexPath       *   actionIndex;
@property (nonatomic, strong) NSIndexPath       *   reSendIndex;
@property (nonatomic, strong) NSString          *   addressString;
@property (nonatomic, strong) Session           *   session;
@end

@implementation TalkingViewController
@synthesize session;
@synthesize actionIndex;
@synthesize addressString;
@synthesize reSendIndex;

- (id)initWithSession:(Session*)item {
    if ([super init]) {
        // Custom initialization
        self.session = item;
    }
    return self;
}

- (void)dealloc {
    // data
    if (qClient) {
        [qClient cancel];
    }
    [recordView recordCancel];
    self.actionIndex = nil;
    self.addressString = nil;
    self.reSendIndex = nil;
    self.session = nil;
    
    // view
    Release(actionBar);
    Release(recordView);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 重置会话未读数量
    [session resetUnread];
    
    // 群会话 是否需要显示 群成员名字
    needShowNameInGroup = session.isshownick;
    self.navigationItem.title = session.name;
    self.view.backgroundColor =
    tableView.backgroundColor = RGBCOLOR(247, 247, 247);
    
    // 加载列表
    [contentArr addObjectsFromArray:[Message getListFromDBWithID:session.uid sinceRowID:-1]];
    if (!_isSearchMode) {
        if (session.typechat == forChatTypeUser) {
            [self setRightBarButtonImage:LOADIMAGE(@"people_n") highlightedImage:LOADIMAGE(@"people_d") selector:@selector(lookInfo)];
        } else if (session.typechat == forChatTypeGroup){
            [self setRightBarButtonImage:LOADIMAGE(@"btn_info") highlightedImage:LOADIMAGE(@"btn_info_d") selector:@selector(lookInfo)];
        }
        recordView = [[TalkingRecordView alloc] initWithFrame:CGRectMake(80, (self.view.height-160)/2, self.view.width-160, 160) del:self];
        [self.view addSubview:recordView];
        recordView.hidden = YES;
        
        actionBar = [[SessionActionBar alloc] initWithOrigin:CGPointMake(0.0f, self.view.height - 44.0f)];
        [self.view addSubview:actionBar];
        actionBar.sessionDelegate = self;
        actionBar.textView.delegate = self;
        tableView.height -= actionBar.height;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUIForMarkName:) name:@"updateUIForMarkName" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotifyGroupChat:) name:@"receivedNotifyGroupChat" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedMessage:) name:@"receivedMessage" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needShowPerconName:) name:@"needShowPerconName" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedMeetNot:) name:@"receivedMeetNot" object:nil];
    }
    if (_sinceMsgID) {
        [contentArr enumerateObjectsUsingBlock:^(Message * obj, NSUInteger idx, BOOL *stop) {
            if (obj.rowID == _sinceMsgID) {
                actionIndex = [NSIndexPath indexPathForRow:0 inSection:idx];
                *stop = YES;
            }
        }];
    }
    if (contentArr.count > 0) {
        tableView.alpha = 0;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (!_isSearchMode) {
        [actionBar.textView resignFirstResponder];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reSetConversation" object:session.uid];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (!_isSearchMode) {
        actionBar.talkState = TalkStateNone;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (isFirstAppear) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reSetConversation" object:session.uid];
        if (contentArr.count > 0) {
            [UIView animateWithDuration:0.1 animations:^{
                if (actionIndex) {
                    [tableView scrollToRowAtIndexPath:actionIndex atScrollPosition:UITableViewScrollPositionNone animated:YES];
                    actionIndex = nil;
                } else {
                    [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:contentArr.count-1] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                }
            } completion:^(BOOL finished) {
                if (finished) {
                    [UIView animateWithDuration:0.15 animations:^{
                        tableView.alpha = 1;
                    }];
                }
            }];
            if (contentArr.count >= defaultSizeInt) {
                hasMore = YES;
            }
        }
        /**比如转发分享啊图片啊地址什么都是预先配置好消息再传进来，然后在这里解析然后发送*/
        Message * msg = [Globals preSendMsg];
        if (msg) {
            if (msg.typefile == forFileImage && !msg.imgUrlS) {
                UIImage * img = msg.value;
                img = [img resizeImageGreaterThan:1200];
                NSData * dat = UIImageJPEGRepresentation(img, 1.0);
                NSString * path = [NSString stringWithFormat:@"%@/tmp/IMG%.0f.jpg", NSHomeDirectory(), [NSDate timeIntervalSinceReferenceDate] * 1000];
                [dat writeToFile:path atomically:YES];
                DLog(@"image saved at %@", path);
                img = [img resizeImageGreaterThan:200];
                
                NSString * smallPath = [NSString stringWithFormat:@"%@/tmp/COPYIMG%.0f.jpg", NSHomeDirectory(), [NSDate timeIntervalSinceReferenceDate] * 1000];
                NSData *copy = UIImagePNGRepresentation(img);
                [copy writeToFile:smallPath atomically:YES];
                [self sendMessageWithPath:path type:forFileImage time:@"0" imgSize:img.size smallPath:smallPath];
            } else {
                [self updateTableViewWithMsg:msg];
            }
            // 重置预配置的消息
            [Globals setPreSendMsg:nil];
        }
    }
    [self setKeyboardTriggerEnabled:YES];
}

/**更新界面显示*/
- (void)updateTableViewWithMsg:(Message*)msg {
    [[AppDelegate instance] sendMessage:msg];
    [tableView beginUpdates];
    [tableView insertSections:[NSIndexSet indexSetWithIndex:contentArr.count] withRowAnimation:UITableViewRowAnimationFade];
    [contentArr addObject:msg];
    [tableView endUpdates];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:contentArr.count-1] withRowAnimation:UITableViewRowAnimationNone];
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:contentArr.count-1] atScrollPosition:UITableViewScrollPositionBottom animated:(msg.typefile == forFileText)];
    });
}

/**查看会话信息*/
- (void)lookInfo {
    SessionInfoController * con = [[SessionInfoController alloc] initWithSession:session delegate:self];
    [self pushViewController:con];
}

#pragma mark - eceivedNotifyGroup
/**接收群组信息*/
- (void)receivedNotifyGroupChat:(NSNotification*)sender {
    Notify* ntf = sender.object;
    if ([ntf.roomID isEqualToString:session.uid]) {
        if (ntf.type == forNotifyDestroyRoom || ntf.type == forNotifyKickUser) {
            BOOL needDeleted = NO;
            if (ntf.type == forNotifyDestroyRoom) {
                /**房间被销毁*/
                needDeleted = YES;
            } else if (ntf.type == forNotifyKickUser && [ntf.user.uid isEqualToString:[BSEngine currentUserId]]) {
                /**自己被踢了*/
                needDeleted = YES;
            }
            if (needDeleted) {
                if ([self.navigationController.viewControllers lastObject] == self) {
                    self.view.userInteractionEnabled = NO;
                    self.navigationItem.rightBarButtonItem = nil;
                    KWAlertView * k = [[KWAlertView alloc] initWithTitle:nil message:ntf.content delegate:self cancelButtonTitle:nil otherButtonTitle:@"确定"];
                    k.tag = 2;
                    [k show];
                }
                
            }
        } else if (ntf.type == forNotifyGroupInfoUpdate) {
            /**更新群名字*/
            session.message.toname = ntf.roomName;
            self.navigationItem.title = ntf.roomName;
        } else if (ntf.type == forNotifyNameChange) {
            /**更新群里某人的群昵称*/
            [contentArr enumerateObjectsUsingBlock:^(Message * obj, NSUInteger idx, BOOL *stop) {
                if ([obj.fromId isEqualToString:ntf.user.uid]) {
                    obj.displayName = ntf.user.nickname;
                }
            }];
            [tableView reloadData];
        }
    }
}

/** 收到更新备注名的通知 */
- (void)updateUIForMarkName:(NSNotification*)sender {
    Session * it = sender.object;
    self.navigationItem.title = it.name;
}

/** 键盘监控 可以拖动关闭键盘*/
- (void)setKeyboardTriggerEnabled:(BOOL)enabled {
    __block TalkingViewController*blockd = self;
    if (enabled) {
        [blockd.view addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView, BOOL opening, BOOL closing) {
            CGRect toolBarFrame = actionBar.frame;
            toolBarFrame.origin.y = keyboardFrameInView.origin.y - toolBarFrame.size.height;
            actionBar.frame = toolBarFrame;
            
            CGRect tableViewFrame = tableView.frame;
            tableViewFrame.size.height = toolBarFrame.origin.y;
            tableView.frame = tableViewFrame;
            if (opening) {
                tableView.userInteractionEnabled = NO;
            }
            if (closing) {
                tableView.userInteractionEnabled = YES;
            }
        }];
    } else {
        [self.view removeKeyboardControl];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [actionBar.textView resignFirstResponder];
}

/** 重新加载列表 */
- (void)cleanMessageWithSession:(Session*)item {
    [contentArr removeAllObjects];
    [tableView reloadData];
}

/** 右上角的按钮点击事件 */
- (void)btnRightPressed:(id)sender {
    if (session.isRoom) {
        /** 查看聊天信息 */
        SessionInfoController *con = [[SessionInfoController alloc] initWithSession:session delegate:self];
        [self pushViewController:con];
    } else {
        /** 是否清空消息 */
        [actionBar.textView resignFirstResponder];
        CameraActionSheet *actionSheet = [[CameraActionSheet alloc] initWithActionTitle:nil TextViews:nil CancelTitle:@"取消" withDelegate:self otherButtonTitles:@"清空", nil];
        [actionSheet show];
    }
}

#pragma mark - textView

- (BOOL)textView:(UITextView*)sender shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text {
    if ([sender.text isEqualToString:@"\n"]) {
        return NO;
    }
    if ([text hasPrefix:@"\n"]) {
        /** \n 回车 自动收起键盘 发送消息 */
        if (![self checkAndResetHeader]) {
            return YES;
        };
        if ([self sendMessage:sender.text type:forFileText]) {
            actionBar.textView.text = @"";
        }
        return NO;
    }
    return YES;
}

#pragma mark -
#pragma mark - Messages

/** 收到新的聊天信息 */
- (void)receivedMessage:(NSNotification*)sender {
    Message * msg = sender.object;
    [msg updateReadState:YES];
    if ([msg.withID isEqualToString:session.uid]) {
        if (msg.isSendByMe) {
            for (NSInteger i = contentArr.count - 1; i >= 0 ; i--) {
                Message* prepMsg = [contentArr objectAtIndex:i];
                if (prepMsg.isSendByMe && prepMsg.uid == msg.uid) {
                    [prepMsg updateId];
                    if (tableView) {
                        [tableView reloadSections:[NSIndexSet indexSetWithIndex:i] withRowAnimation:UITableViewRowAnimationNone];
                    }
                    return;
                }
            }
        }
        if (!msg.isSendByMe) {
            [tableView beginUpdates];
            [tableView insertSections:[NSIndexSet indexSetWithIndex:contentArr.count] withRowAnimation:UITableViewRowAnimationFade];
            [contentArr addObject:msg];
            [tableView endUpdates];
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:contentArr.count-1] withRowAnimation:UITableViewRowAnimationNone];
            [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:contentArr.count-1] atScrollPosition:UITableViewScrollPositionBottom animated:(msg.typefile == forFileText)];
        }
        if (contentArr.count > 0) {
            tableView.tableHeaderView = nil;
        }
    }
}

- (void)needShowPerconName:(NSNotification*)sender {
    // 更改群的是否显示昵称后， 更新 聊天列表
    NSString * show = sender.object;
    needShowNameInGroup = show.boolValue;
    [tableView reloadData];
}

- (void)loadMoreMessages {
    if (hasMore) {
        Message* tmpMsg = [contentArr objectAtIndex:0];
        NSArray* tmpArr = [Message getListFromDBWithID:session.uid sinceRowID:tmpMsg.rowID];
        hasMore = NO;
        if (tmpArr.count >= defaultSizeInt) {
            hasMore = YES;
        }
        if (tmpArr.count > 0) {
            NSRange range = NSMakeRange(0, tmpArr.count);
            NSIndexSet* indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
            [contentArr insertObjects:tmpArr atIndexes:indexSet];
            
            CGFloat marginBottom = tableView.contentSize.height - tableView.contentOffset.y;
            [tableView reloadData];
            [tableView setContentOffset:CGPointMake(0, tableView.contentSize.height - marginBottom) animated:NO];
        }
    }
}

#pragma mark -
#pragma mark - TalkingActionBarDelegate
/** actionBar 的协议*/
- (void)actionBarDidChangeState:(ActionBarState)sts {
    if (sts == ActionBarStateMap) {
        /** 地图*/
        id con = [[MapViewController alloc] initWithDelegate:self];
        [self pushViewController:con];
    } else if (sts == ActionBarStateNameCard){
        /** 名片*/
        SessionNewController * con = [[SessionNewController alloc] init];
        con.isShowGroup = NO;
        con.isGroup = NO;
        [con setUserBlack:^(User * user) {
            NSMutableDictionary * dic = [NSMutableDictionary dictionary];
            [dic setObject:user.uid forKey:@"uid"];
            [dic setObject:user.nickname forKey:@"nickname"];
            [dic setObject:user.headsmall forKey:@"headsmall"];
            [self sendMessage:[dic JSONString] type:forFileNameCard];
        }];
        [self pushViewController:con];
    } else if (sts == ActionBarStateMyFav){
        /** 收藏*/
        CollectionViewController * con = [[CollectionViewController alloc] init];
        [self pushViewController:con];
    } else if (sts >= ActionBarStateCamera){
        /** 图片*/
        UIImagePickerController * picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        if (sts == ActionBarStateCamera && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        } else {
            picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        }
        [self presentViewController:picker animated:YES completion:nil];
    }
}

/** 语音状态协议*/
- (void)actionBarTalkStateChanged:(TalkState)sts {
    if (sts == TalkStateTalking) {
        recordView.hidden = NO;
    } else if (sts == TalkStateCanceling) {
        recordView.hidden = NO;
    } else {
        recordView.hidden = YES;
    }
    recordView.state = sts;
}

/** 语音录制完成*/
- (void)actionBarTalkFinished {
    [recordView recordEnd];
}

/** 点击 发送 按钮*/
- (BOOL)actionBarSendMessage:(NSString*)msgStr {
    return [self sendMessage:msgStr type:forFileText];
}

- (void)animationEnd:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
    if ([animationID isEqualToString:@"SHOW"]) {
        CGPoint offset = CGPointMake(0, tableView.contentSize.height - tableView.height);
        if (offset.y > 0) {
            [tableView setContentOffset:offset animated:YES];
        }
    } else if ([animationID isEqualToString:@"HIDE"]) {
        
    }
}

- (BOOL)sendMessage:(NSString*)msgStr type:(FileType)fileType {
    if (![self checkAndResetHeader] || msgStr.length == 0) {
        return NO;
    };
    Message * msg = [[Message alloc] init];
    msg.content = msgStr;
    msg.typefile = fileType;
    msg.toId = session.uid;
    msg.typechat = session.typechat;
    [msg getToUserInfoWithSession:session];
    
    actionBar.textView.text = @"";
    
    [self updateTableViewWithMsg:msg];
    return YES;
}

/** 检测和聊天服务器的连接状态*/
- (BOOL)checkAndResetHeader {

    if (![XMPPManager shareManager].xmppStream.isAuthenticated) {
        [actionBar.textView resignFirstResponder];
        [[[KWAlertView alloc] initWithTitle:nil message:@"连接服务中，请稍候" delegate:self cancelButtonTitle:@"确定" otherButtonTitle:nil] show];
        [[XMPPManager shareManager] connectAgain];
        return NO;
    }
    return YES;
}

/** 发送媒体数据*/
- (void)sendMessageWithPath:(NSString*)path type:(FileType)type time:(NSString*)time imgSize:(CGSize)imgSize smallPath:(NSString*)smallPath {
    if (![self checkAndResetHeader]) {
        return;
    };
    Message * msg = [[Message alloc] init];
    if (type == forFileImage) {
        msg.imgUrlL = path;
        msg.imgUrlS = smallPath;
        msg.content = @"[图片]";
        msg.imageSize = imgSize;
    } else {
        msg.voiceUrl = path;
        msg.content = @"[声音]";
        msg.voiceTime = time;
    }
    msg.toId = session.uid;
    msg.typefile = type;
    msg.typechat = session.typechat;
    msg.state = forMessageStateHavent;
    [msg getToUserInfoWithSession:session];
    
    [self updateTableViewWithMsg:msg];
}

#pragma mark - TalkingRecordViewDelegate
/** 录制完成的协议*/
- (void)recordView:(TalkingRecordView*)sender didFinish:(NSString*)path duration:(NSTimeInterval)du {
    DLog(@"record did finish %@, duration: %.0f", path, du);
    if (du >= 1) {
         [self sendMessageWithPath:path type:forFileVoice time:[NSString stringWithFormat:@"%.0f", du] imgSize:CGSizeZero smallPath:nil];
    } else {
        [self showText:@"录音时间太短"];
    }
}

#pragma mark - TableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"MessageCell";
    ChatMessagesCell * cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ChatMessagesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.superTableView = sender;
    }
    [cell setTopLine:NO];
    cell.item = [contentArr objectAtIndex:indexPath.section];
    
    if (indexPath.section == 0) {
        cell.timeText = [Globals sendTimeString:cell.item.sendTime.doubleValue];
    } else {
        Message * msgLast = [contentArr objectAtIndex:indexPath.section - 1];
        NSString * tStr = nil;
        if (cell.item.sendTime.doubleValue / 1000 - msgLast.sendTime.doubleValue / 1000 > 180) {
            tStr = [Globals sendTimeString:cell.item.sendTime.doubleValue];
        }
        cell.timeText = tStr;
    }
    
    if ([cell.item.fromId isEqualToString:[BSEngine currentUserId]]) {
        cell.personName = nil;
    } else {
        cell.personName = needShowNameInGroup?cell.item.displayName:nil;
    }
    
    if (actionIndex && indexPath.section == actionIndex.section && indexPath.row == actionIndex.row) {
        cell.playing = YES;
    } else {
        cell.playing = NO;
    }
    if (cell.item.typefile == forFileImage) {
        UIImage * img = [baseImageCaches getImageCache:[cell.item.content md5Hex]];
        if (img == nil) {
            img = [Globals getImageGray];
        }
        cell.imageSize = cell.item.imageSize;
        cell.conImage = img;
    }
    return cell;
}

#pragma mark - TableViewDelegate
- (UIView *)tableView:(UITableView *)sender viewForHeaderInSection:(NSInteger)section {
    CGFloat height = 0;
    Message * msg = [contentArr objectAtIndex:section];
    if (section == 0) {
        height += 28;
    } else {
        Message * msgLast = [contentArr objectAtIndex:section - 1];
        if (msg.sendTime.doubleValue / 1000 - msgLast.sendTime.doubleValue / 1000 > 60) {
            height += 28;
        }
    }
    UIImageView * clearView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, sender.width, height)];
    clearView.backgroundColor = [UIColor clearColor];
    return clearView;
}

- (CGFloat)tableView:(UITableView *)sender heightForHeaderInSection:(NSInteger)section {
    
    // 是否留出显示时间的高度
    CGFloat height = 0;
    if (section == 0) {
        height += 28;
    } else {
        Message * msg = [contentArr objectAtIndex:section];
        Message * msgLast = [contentArr objectAtIndex:section - 1];
        if (msg.sendTime.doubleValue / 1000 - msgLast.sendTime.doubleValue / 1000 > 180) {
            height += 28;
        }
    }
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)sender {
    return contentArr.count;
}

- (NSInteger)tableView:(UITableView *)sender numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView*)sender heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    Message * msg = [contentArr objectAtIndex:indexPath.section];
    CGFloat height = [ChatMessagesCell heightForMessage:msg];
    if (needShowNameInGroup) {
        // 显示名字则需要多加18单位高度
        height += 18;
    }
    return height;
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)sender willDisplayCell:(ChatMessagesCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.imageView.image = [Globals getImageUserHeadDefault];
    NSInvocationOperation * opHeadItem = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadHeadImageWithIndexPath:) object:indexPath];
    [baseOperationQueue addOperation:opHeadItem];
    
    NSInvocationOperation * opItem = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadImageWithIndexPath:) object:indexPath];
    [baseOperationQueue addOperation:opItem];
}

- (void)loadImageWithIndexPath:(NSIndexPath *)indexPath {
    Message * msg = [contentArr objectAtIndex:indexPath.section];
    NSString * url = nil;
    if (msg.typefile == forFileAddress) {
        // 地址 从百度那儿获取地址
        url = [Globals getBaiduAdrPicForTalk:msg.address.lat lng:msg.address.lng];
    } else if (msg.typefile == forFileNameCard) {
        // 名片
        NSDictionary * dic = [JSON objectFromJSONString:msg.content];
        url = [dic getStringValueForKey:@"headsmall" defaultValue:nil];
    }else {
        // 图片
        url = msg.imgUrlS;
    }
    if (url) {
        UIImage * img = [baseImageCaches getImageCache:[url md5Hex]];
        if (!img) {
            ImageProgress * progress = [[ImageProgress alloc] initWithUrl:url delegate:baseImageQueue];
            progress.indexPath = indexPath;
            progress.tag = 0;
            [self performSelectorOnMainThread:@selector(startLoadingWithProgress:) withObject:progress waitUntilDone:YES];
        } else {
            dispatch_async(kQueueMain, ^{
                [self setConImage:img forIndex:indexPath];
            });
        }
    }
}

- (void)setConImage:(UIImage *)image forIndex:(NSIndexPath*)indexPath {
    ChatMessagesCell * cell = (ChatMessagesCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.conImage = image;
}

/**头像*/
- (NSString*)baseTableView:(UITableView *)sender imageURLAtIndexPath:(NSIndexPath*)indexPath {
    Message * msg = [contentArr objectAtIndex:indexPath.section];
    if (msg.isSendByMe) {
        return [[BSEngine currentUser] headsmall];
    }
    return msg.displayImgUrl;
}

- (int)baseTableView:(UITableView *)sender imageTagAtIndexPath:(NSIndexPath*)indexPath {
    return -1;
}

- (void)baseTableView:(NSInteger)tag imageUpdateAtIndexPath:(NSIndexPath*)indexPath image:(UIImage *)image idx:(NSInteger)idx {
    if (tag == -1) {
        [self setHeadImage:image forIndex:indexPath];
    } else {
        [self setConImage:image forIndex:indexPath];
    }
}

- (CGFloat)baseTableView:(UITableView *)sender imageSizeAtIndexPath:(NSIndexPath*)indexPath{
    return 0;
}

/**长按响应*/
- (void)tableView:(UITableView *)sender handleTableviewCellLongPressed:(NSIndexPath *)indexPath {
    Message * msg = [contentArr objectAtIndex:indexPath.section];
    CameraActionSheet * sheet = nil;
    if (msg.typefile == forFileText) {
        // 复制
        sheet = [[CameraActionSheet alloc] initWithActionTitle:nil TextViews:nil CancelTitle:@"取消" withDelegate:self otherButtonTitles:@"复制", @"转发", @"收藏", nil];
        sheet.mark = @"forFileText";
    } else {
        sheet = [[CameraActionSheet alloc] initWithActionTitle:nil TextViews:nil CancelTitle:@"取消" withDelegate:self otherButtonTitles:@"转发", @"收藏", nil];
        sheet.mark = @"forOther";
    }
    
    sheet.indexPath = indexPath;
    [sheet show];
    [actionBar.textView resignFirstResponder];
}

// 点击某个消息的协议响应
- (void)tableView:(UITableView *)sender accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    Message * msg = [contentArr objectAtIndex:indexPath.section];
    if (msg.state == forMessageStateHavent) {
        [self showText:@"发送中, 请稍候"];
    } else if (msg.state != forMessageStateNormal) {
        // 提示 重新发送
        self.reSendIndex = indexPath;
        [self showAlert:@"是否重新发送？" isNeedCancel:YES];
    } else {
        if (msg.typefile == forFileImage) {
            // 查看大图
            Message * msg = [contentArr objectAtIndex:indexPath.section];
            ChatMessagesCell * cell = (ChatMessagesCell*)[sender cellForRowAtIndexPath:indexPath];
            CGRect cellF = [cell convertRect:cell.imageFrame toView:self.navigationController.view];
            ImageViewController * con = [[ImageViewController alloc] initWithFrameStart:cellF supView:self.navigationController.view pic:msg.imgUrlL preview:msg.imgUrlS];
            con.value = msg;
            con.bkgImage = [self.view screenshot];
            [self.navigationController pushViewController:con animated:NO];
        } else if (msg.typefile == forFileVoice) {
            // 播放
            if (actionIndex) {
                [AudioMsgPlayer cancel];
                ChatMessagesCell * cell = (ChatMessagesCell*)[sender cellForRowAtIndexPath:actionIndex];
                cell.playing = NO;
                self.actionIndex = nil;
                return;
            }
            self.actionIndex = indexPath;
            ChatMessagesCell * cell = (ChatMessagesCell*)[sender cellForRowAtIndexPath:indexPath];
            cell.playing = YES;
            
            [AudioMsgPlayer playWithURL:msg.voiceUrl delegate:self];
        } else if (msg.typefile == forFileNameCard) {
            // 查看名片
            [self getUserByName:[msg.value getStringValueForKey:@"uid" defaultValue:@""]];
        } else if (msg.typefile == forFileAddress) {
            // 查看地图
            self.addressString = msg.address.address;
            MapViewController * con = [[MapViewController alloc] init];
            con.location = msg.address.location;
            con.readOnly = YES;
            con.pointAnnotationTitle = msg.address.address;
            con.value = msg;
            [self pushViewController:con];
        }
    }
}

/**点击头像 显示个人资料*/
- (void)tableView:(id)sender didTapHeaderAtIndexPath:(NSIndexPath *)indexPath {
    Message * msg = [contentArr objectAtIndex:indexPath.section];
    if (client) {
        return;
    }
    if (needToLoad) {
        self.loading = YES;
    }
    BSClient * sclient = [[BSClient alloc] initWithDelegate:self action:@selector(requestUserInfoDidFinish:obj:)];
    [sclient getUserInfoWithuid:msg.fromId];
}

/**播放结束时执行的动作*/
- (void)audioMsgPlayerDidFinishPlaying:(AudioMsgPlayer*)sender {
    DLog(@"audioMsgPlayerDidFinishPlaying");
    if (actionIndex) {
        ChatMessagesCell * cell = (ChatMessagesCell*)[tableView cellForRowAtIndexPath:actionIndex];
        cell.playing = NO;
        self.actionIndex = nil;
    }
}

#pragma mark - KWAlertViewDelegate
- (void)kwAlertView:(KWAlertView*)sender didDismissWithButtonIndex:(NSInteger)index {
    if (sender.tag == 2) {
        [self popViewController];
    } else if (self.reSendIndex && index == 1) {
        Message * msg = [contentArr objectAtIndex:self.reSendIndex.section];
        msg.state = forMessageStateHavent;
        ChatMessagesCell *cell = (ChatMessagesCell *)[tableView cellForRowAtIndexPath:self.reSendIndex];
        cell.loading = YES;
        [tableView reloadRowsAtIndexPaths:@[self.reSendIndex] withRowAnimation:UITableViewRowAnimationFade];
        [[AppDelegate instance] sendMessage:msg];
        self.reSendIndex = nil;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender {
    if (sender.contentOffset.y < 10) {
        [self loadMoreMessages];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)sender willDecelerate:(BOOL)decelerate {
    if (!decelerate && sender.contentOffset.y < 10) {
        [self loadMoreMessages];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        if (![self checkAndResetHeader]) {
            return;
        };
        UIImage * img = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        img = [img resizeImageGreaterThan:1200];
        NSData * dat = UIImageJPEGRepresentation(img, 1.0);
        NSString * path = [NSString stringWithFormat:@"%@/tmp/IMG%.0f.jpg", NSHomeDirectory(), [NSDate timeIntervalSinceReferenceDate] * 1000];
        [dat writeToFile:path atomically:YES];
        DLog(@"image saved at %@", path);
        img = [img resizeImageGreaterThan:200];
        
        NSString * smallPath = [NSString stringWithFormat:@"%@/tmp/COPYIMG%.0f.jpg", NSHomeDirectory(), [NSDate timeIntervalSinceReferenceDate] * 1000];
        NSData *copy = UIImagePNGRepresentation(img);
        [copy writeToFile:smallPath atomically:YES];
        
        [self sendMessageWithPath:path type:forFileImage time:@"0" imgSize:img.size smallPath:smallPath];
    }];
}

#pragma mark - MyLocationControllerDelegate
- (void)mapViewControllerSetPoiInfo:(BMKPoiInfo*)selectBMKPoiInfo {
    if (![self checkAndResetHeader]) {
        return;
    };
    Message * msg = [[Message alloc] init];
    
    msg.content = @"[位置]";
    msg.typefile = forFileAddress;
    msg.toId = session.uid;
    msg.typechat = session.typechat;
    [msg getToUserInfoWithSession:session];
    msg.address = [[Address alloc] init];
    msg.address.address = selectBMKPoiInfo.address;
    msg.address.location = kLocationMake(selectBMKPoiInfo.pt.latitude, selectBMKPoiInfo.pt.longitude);
    
    [self updateTableViewWithMsg:msg];
}

- (NSString*)getCurrentSetLocationString {
    return addressString;
}

#pragma mark - request

- (BOOL)requestUserInfoDidFinish:(id)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        User * item = [User objWithJsonDic:[obj getDictionaryForKey:@"data"]];
        UserInfoViewController * con = [[UserInfoViewController alloc] init];
        [con setUser:item];
        [item insertDB];
        [self pushViewController:con];
    }
    return YES;
}

/**收藏回调*/
- (BOOL)requestFavDidFinish:(BSClient*)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        [self showText:sender.errorMessage];
    }
    return YES;
}

#pragma mark - CameraActionSheetDelegate

- (void)cameraActionSheet:(CameraActionSheet *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex {
    Message * msg = [contentArr objectAtIndex:sender.indexPath.section];
    if ([sender.mark isEqualToString:@"forFileText"]) {
        if (buttonIndex == 0) {
            // 复制文字
            [[UIPasteboard generalPasteboard] setString:msg.content];
        } else if (buttonIndex == 1) {
            // 转发消息
            [self forwordWithMsg:msg];
        } else if (buttonIndex == 2) {
            // 收藏消息
            if (!client) {
                [self setLoading:YES content:@"收藏中"];
                client = [[BSClient alloc] initWithDelegate:self action:@selector(requestFavDidFinish:obj:)];
                
                NSMutableDictionary * dic = [NSMutableDictionary dictionary];
                [dic setObject:msg.content forKey:@"content"];
                [dic setObject:[NSString stringWithFormat:@"%d", forFileText]  forKey:@"typefile"];
                NSString *otherid = (msg.typechat != forChatTypeUser)?session.uid:nil;
                [client addfavorite:msg.fromId otherid:otherid content:[dic JSONString]];
            } else {
                [self showText:@"网络繁忙，请等等吧"];
            }
        }
    } else if ([sender.mark isEqualToString:@"forOther"]) {
        if (buttonIndex == 0) {
            // 转发消息
            [self forwordWithMsg:msg];
        } else if (buttonIndex == 1) {
            // 收藏消息
            if (msg.typefile == forFileNameCard) {
                [self showAlert:@"抱歉, 暂不支持的收藏类型！" isNeedCancel:NO];
                return;
            }
            if (client) {
                return ;
            }
            [self setLoading:YES content:@"收藏中"];
            client = [[BSClient alloc] initWithDelegate:self action:@selector(requestFavDidFinish:obj:)];

            Message * msg = [contentArr objectAtIndex:sender.indexPath.section];
            NSMutableDictionary * dic = [NSMutableDictionary dictionary];
            if (msg.typefile == forFileImage) {
                [dic setObject:msg.imgUrlL forKey:@"urllarge"];
            } else if (msg.typefile == forFileAddress) {
                [dic setObject:msg.address.address forKey:@"address"];
                [dic setObject:[NSString stringWithFormat:@"%f", msg.address.lat] forKey:@"lat"];
                [dic setObject:[NSString stringWithFormat:@"%f", msg.address.lng] forKey:@"lng"];
            } else if (msg.typefile == forFileVoice) {
                [dic setObject:msg.voiceUrl forKey:@"url"];
                [dic setObject:msg.voiceTime forKey:@"time"];
            }
            
            [dic setObject:[NSString stringWithFormat:@"%d", msg.typefile]  forKey:@"typefile"];
            NSString *otherid = (msg.typechat != forChatTypeUser)?session.uid:nil;
            [client addfavorite:msg.fromId otherid:otherid content:[dic JSONString]];
        }
    } else {
        if (buttonIndex == 0){
            [Message deleteWithID:session.uid];
            [contentArr removeAllObjects];
            [tableView reloadData];
        }
    }
}

/**用户协议*/
- (IBAction)AgreementView:(id)sender {
    AgreementViewController* controller = [[AgreementViewController alloc] init];
    [self pushViewController:controller];
}

#pragma mark - 聊吧相关通知
- (void)receivedMeetNot:(NSNotification*)sender {
    Notify * ntf = sender.object;
    if (ntf.type == forNotifyMeetKicked) {
        [self popViewController];
    }
    
}
@end;