//
//  BSClient.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "BSClient.h"
#import "BSEngine.h"
#import "StRequest.h"
#import "Message.h"
#import "KAlertView.h"
#import "Room.h"

@interface BSClient () <StRequestDelegate> {
    BOOL    needUID;
    BOOL    cancelled;
}

@property (nonatomic, assign) id          delegate;
@property (nonatomic, assign) SEL         action;
@property (nonatomic, strong) StRequest * bsRequest;
@property (nonatomic, weak)   BSEngine  * engine;

@end

@implementation BSClient
@synthesize action;
@synthesize bsRequest;
@synthesize engine;
@synthesize errorMessage;
@synthesize errorCode;
@synthesize hasError;
@synthesize indexPath;
@synthesize tag;
@synthesize delegate;

- (id)initWithDelegate:(id)del action:(SEL)act {
    self = [super init];
    if (self) {
        self.delegate = del;
        self.action = act;
        
        needUID = YES;
        self.hasError = YES;
        self.engine = [BSEngine currentEngine];
    }
    return self;
}

- (void)dealloc {
    Release(tag);
    Release(indexPath);
    Release(errorMessage);
    Release(action);
    Release(bsRequest);
    Release(engine);
    self.delegate = nil;
}

- (void)cancel {
    if (!cancelled) {
        [bsRequest disconnect];
        self.bsRequest = nil;
        cancelled = YES;
        self.action = nil;
        self.delegate = nil;
    }
}

- (void)showAlert {
    NSString* alertMsg = nil;
    if ([errorMessage isKindOfClass:[NSString class]] && errorMessage.length > 0) {
        alertMsg = errorMessage;
    } else {
        alertMsg = @"服务器出去晃悠了，等它一下吧！";
    }
    [KAlertView showType:KAlertTypeError text:alertMsg for:0.8 animated:YES];
}

- (void)loadRequestWithDoMain:(BOOL)isDoMain
                   methodName:(NSString *)methodName
                       params:(NSMutableDictionary *)params
                 postDataType:(StRequestPostDataType)postDataType {
    [bsRequest disconnect];
    
    NSMutableDictionary* mutParams = [NSMutableDictionary dictionaryWithDictionary:params];
//    [mutParams setObject:APPKEY forKey:@"appkey"];
    if (needUID && [engine isLoggedIn]) {
        [mutParams setObject:engine.user.uid forKey:@"uid"];
    }
    
    self.bsRequest = [StRequest requestWithURL:[NSString stringWithFormat:@"%@%@", KBSSDKAPIDomain, methodName]
                                  httpMethod:@"POST"
                                      params:mutParams
                                postDataType:postDataType
                            httpHeaderFields:nil
                                    delegate:self];
    
	[bsRequest connect];
}

#pragma mark - StRequestDelegate Methods

- (void)request:(StRequest*)sender didFailWithError:(NSError *)error {
    if (cancelled) {
        return;
    }
    
    NSString * errorStr = [[error userInfo] objectForKey:@"error"];
    if (errorStr == nil || errorStr.length <= 0) {
        errorStr = [NSString stringWithFormat:@"%@", [error localizedDescription]];
    } else {
        errorStr = [NSString stringWithFormat:@"%@", [[error userInfo] objectForKey:@"error"]];
    }
    if ([errorStr hasPrefix:@"The operation couldn’t"]) {
        errorStr = @"服务器换班去啦，客官就请歇息下吧!";
    }
    self.errorMessage = errorStr;
    
    if ([delegate respondsToSelector:action]) {
        IMP imp = [delegate methodForSelector:action];
        void (*func)(id, SEL, id, id) = (void *)imp;
        func(delegate, action, self, error);
    }
    
    self.bsRequest = nil;
}

- (void)request:(StRequest*)sender didFinishLoadingWithResult:(NSDictionary*)result {
    if (cancelled) {
        return;
    }
    
    int stateCode = -1;
    if (result != nil && [result isKindOfClass:[NSDictionary class]]) {
        NSDictionary* state = [result objectForKey:@"state"];
        if (state != nil && [state isKindOfClass:[NSDictionary class]]) {
            stateCode = [state getIntValueForKey:@"code" defaultValue:stateCode];
            self.errorCode = stateCode;
            self.hasError = (stateCode != 0);
            self.errorMessage = [state getStringValueForKey:@"msg" defaultValue:nil];
        }
    }
    
    if (stateCode != 0 && self.errorMessage == nil) {
        self.errorMessage = @"让网络飞一会再说吧..";
    }
    
    self.bsRequest = nil;
    if (cancelled) {
        return;
    }
    if ([delegate respondsToSelector:action]) {
        IMP imp = [delegate methodForSelector:action];
        void (*func)(id, SEL, id, id) = (void *)imp;
        func(delegate, action, self, result);
    }
}

#pragma mark - Method

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	登陆
 *
 *	@param 	Phone 	手机号
 *	@param 	pwd 	密码
 */
- (void)loginWithUserPhone:(NSString *)phone
                  password:(NSString *)pwd
{
    needUID = NO;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:phone forKey:@"phone"];
    [params setObject:pwd forKey:@"password"];
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/login"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

// ======== 获取验证码 =========
- (void)getPhoneCode:(NSString*)phone {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:phone forKey:@"phone"];
    [self loadRequestWithDoMain:YES
                     methodName:@"user/apiother/getCode"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

- (void)regWithPhone:(NSString *)phone
            password:(NSString *)password
                code:(NSString *)code
{
    needUID = NO;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:phone forKey:@"phone"];
    [params setObject:password forKey:@"password"];
    if (code && code.length > 0) {
        [params setObject:code forKey:@"code"];
    }
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/regist"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	根据uid获取详细资料
 *
 *	@param 	fuid 	fuid
 */

- (void)getUserInfoWithuid:(NSString*)uid {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:uid forKey:@"fuid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/detail"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	根据Keyword获取资料
 *
 *	@param 	Keyword 	昵称/电话
 */

- (void)getUserInfoWithKeyword:(NSString*)keyword page:(int)page {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:keyword forKey:@"search"];
    if (page>0) {
        [params setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    }
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/search"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

- (void)setMarkName:(NSString*)name fuid:(NSString*)fuid {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:name forKey:@"remark"];
    [params setObject:fuid forKey:@"fuid"];
    
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/remark"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

// ========= editInfo =========
// 编辑资料
- (void)editUserInfo:(UIImage*)headImg user:(NSMutableDictionary *)user {
    StRequestPostDataType dataType = KSTRequestPostDataTypeNormal;
    if (headImg) {
        [user setObject:headImg forKey:@"picture"];
        dataType= KSTRequestPostDataTypeMultipart;
    }
    
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/edit"
                         params:user
                   postDataType:dataType];
}

// ========= Friend =========

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	添加好友
 *
 *	@param 	fuid 	uid
 *	@param 	content 	理由
 */
- (void)to_friend:(NSString*)fuid content:(NSString*)content {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:fuid forKey:@"fuid"];
    if (content&&content.length>0) {
        [params setObject:content forKey:@"content"];
    }
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/applyAddFriend"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	 删除好友
 *
 *	@param 	fuid 	uid
 */
- (void)del_friend:(NSString*)fuid {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:fuid forKey:@"fuid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/deleteFriend"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	同意申请加好友
 *
 *	@param 	fuid 	uid
 */
- (void)agreeAddFriend:(NSString*)fuid {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:fuid forKey:@"fuid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/agreeAddFriend"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	好友列表
 *
 */
- (void)friendList;
 {
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/friendList"
                         params:nil
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	通讯录添加好友
 *  @param phones 上传格式：电话1,电话2,电话3,电话4
 *  @return type  	0-不是系统用户，可邀请的用户 1-系统用户
            isfriend  0-不是好友 可以添加 1-是好友
 */
- (void)telephone:(NSString*)phones {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:phones forKey:@"phone"];
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/importContact"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	新的朋友
 *  @param phones 上传格式：电话1,电话2,电话3,电话4
 */
- (void)newFriends:(NSString*)phones {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:phones forKey:@"phone"];
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/newFriend"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}
/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *  个人相册
 *  @param fuid 不传刚获取自己的，传刚获取别人的
 */
- (void)userAlbum:(NSString*)fuid page:(int)page {
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:1];
    if (page > 1) {
        [params setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    }
    
    [params setObject:fuid forKey:@"fuid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"friend/api/userAlbum"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
    
}
// ========= 黑名单 =========
/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	添加到黑名单
 *
 *	@param 	fuid 	uid
 */
- (void)black:(NSString*)fuid {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:fuid forKey:@"fuid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/black"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	黑名单列表
 *
 */
- (void)blackList {
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/blackList"
                         params:nil
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 * 收藏列表
 *
 */
- (void)favoriteList {
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/favoriteList"
                         params:nil
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 * 删除收藏
 *
 */
- (void)deleteFavorite:(NSString*)fid {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:fid forKey:@"favoriteid"];
    
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/deleteFavorite"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 * 增加收藏
 *
 *	@param fuid 被收藏人的uid
 *	@param otherid 如果是收藏的群组的消息，就传入此id
 *	@param content 收藏的内容
 */
- (void)addfavorite:(NSString*)fuid otherid:(NSString*)otherid content:(NSString*)content {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:fuid forKey:@"fuid"];
    if (otherid) {
        [params setObject:otherid forKey:@"otherid"];
    }
    [params setObject:content forKey:@"content"];
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/favorite"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

// ========= 聊天消息 =========

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	发送消息
 *
 *	@param msg 消息对象
 *
 */
- (void)sendMessageWithObject:(Message*)msg {
    [self sendMessageToid:msg.toId toname:msg.toname tourl:msg.tohead file:msg.value typefile:msg.typefile typechat:[NSString stringWithFormat:@"%d", msg.typechat] voicetime:msg.voiceTime lat:[NSString stringWithFormat:@"%f", msg.address.lat] lng:[NSString stringWithFormat:@"%f", msg.address.lng] address:msg.address.address content:msg.content tag:msg.tag time:msg.sendTime];
}
/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	发送消息
 *
 *	@param fromid false 发送者id
 *	@param fromname true 发送者name
 *	@param fromurl true 发送者头像
 *	@param toid true 接收者，可以是某人，也可以是某个群id
 *	@param toname true 接收者name
 *	@param file false 上传图片/声音
 *	@param voicetime false 声音时间长度
 *	@param address false 地址
 *	@param content false 消息的文字内容
 *	@param typechat false 100-单聊 200-群聊 300-临时会话 默认为100
 *	@param typefile false 1-文字 2-图片 3-声音 4-位置 默认为1
 *	@param tag true 标识符
 *	@param time true 发送消息的时间,毫秒（服务器生成）
 *
 */
- (void)sendMessageToid:(NSString*)toid
                 toname:(NSString*)toname
                  tourl:(NSString*)tourl
                   file:(id)file
               typefile:(int)typefile
               typechat:(NSString*)typechat
              voicetime:(NSString*)voicetime
                    lat:(NSString*)lat
                    lng:(NSString*)lng
                address:(NSString*)address
                content:(NSString*)content
                    tag:(NSString*)_tag
                   time:(NSString*)time {
    
    StRequestPostDataType dType = KSTRequestPostDataTypeNormal;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:[BSEngine currentUserId] forKey:@"fromid"];
    if (typechat.intValue == 300) {
        Room * room = [Room roomForUid:toid];
        if (room) {
            [params setObject:room.mynickname forKey:@"fromname"];
        } else {
            [params setObject:[[BSEngine currentUser] nickname] forKey:@"fromname"];
        }
    } else {
        [params setObject:[[BSEngine currentUser] nickname] forKey:@"fromname"];
    }
    
    [params setObject:[[BSEngine currentUser] headsmall] forKey:@"fromurl"];
    [params setObject:toid forKey:@"toid"];
    [params setObject:toname forKey:@"toname"];
    if (tourl) {
        [params setObject:tourl forKey:@"tourl"];
    }
    if (file) {
        if (![file isKindOfClass:[NSString class]]) {
            // 只有非转发的消息才会上传媒体数据
            dType = KSTRequestPostDataTypeMultipart;
        }
        [params setObject:file forKey:@"image"];
    }
    if (voicetime) {
        [params setObject:voicetime forKey:@"voicetime"];
    }
    if (lat) {
        [params setObject:lat forKey:@"lat"];
    }
    if (lng) {
        [params setObject:lng forKey:@"lng"];
    }
    if (address) {
        [params setObject:address forKey:@"address"];
    }
    if (typechat) {
        [params setObject:typechat forKey:@"typechat"];
    }
    if (typefile) {
        [params setObject:[NSString stringWithFormat:@"%d", typefile] forKey:@"typefile"];
    }
    if (content) {
        [params setObject:content forKey:@"content"];
    }
    [params setObject:_tag forKey:@"tag"];
    [params setObject:time forKey:@"time"];
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/sendMessage"
                         params:params
                   postDataType:dType];
    
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	设置是否接收另一用户的消息
 *
 *	@param fuid 用户id
 *
 */
- (void)setGetmsg:(NSString*)fuid {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:fuid forKey:@"fuid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/setGetmsg"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	设置星标朋友
 *
 *	@param fuid 用户id
 *
 */
- (void)setStar:(NSString*)fuid {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:fuid forKey:@"fuid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/setStar"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

// ========= 群聊 =========
// /api/group/
/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	创建群组
 *
 *	@param 	inviteduids 	参数格式: uid1,uid2,uid3
 *	@param 	groupname 	聊天群的名称
 */
- (void)createGroupAndInviteUsers:(NSArray*)inviteduids groupname:(NSString*)groupname
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    NSMutableArray * idArr = [NSMutableArray array];
    if (!groupname) {
        NSMutableArray* nameArr = [NSMutableArray array];
        [nameArr addObject:[BSEngine currentUser].nickname];
        for (User * user in inviteduids) {
            if (nameArr.count < 4) {
                [nameArr addObject:user.nickname];
            }
            
            [idArr addObject:user.uid];
        }
        groupname = [nameArr componentsJoinedByString:@","];
    }
    [params setObject: [idArr componentsJoinedByString:@","] forKey:@"uids"];
    [params setObject:groupname forKey:@"name"];
    [self loadRequestWithDoMain:YES
                     methodName:@"session/api/add"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	删除群组
 *
 *	@param 	groupid 	群组id
 */
- (void)delGroup:(NSString*)groupid {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:groupid forKey:@"sessionid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"session/api/delete"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	查找群
 *
 *	@param 	keyword 	可以是群昵称或群id
 */
- (void)groupSearch:(NSString*)keyword page:(int)page {
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:1];
    if (page > 1) {
        [params setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    }
    [params setObject:keyword forKey:@"keyword"];
    [self loadRequestWithDoMain:YES
                     methodName:@"session/api/search"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	根据群id获取群信息
 *
 *	@param 	groupid 	群组id
 */
- (void)groupDetail:(NSString*)groupid {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:groupid forKey:@"sessionid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"session/api/detail"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	根据群id加入群
 *
 *	@param 	groupid 	群组id
 */
- (void)addtogroup:(NSString*)groupid {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:groupid forKey:@"sessionid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"session/api/join"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	添加用户到群组
 *
 *	@param 	groupid 	群组id
 *	@param 	inviteduids 	参数格式: uid1,uid2,uid3
 */
- (void)inviteUser:(NSString*)groupid inviteduids:(NSArray*)inviteduids {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:groupid forKey:@"sessionid"];
    [params setObject:[inviteduids componentsJoinedByString:@","] forKey:@"uids"];
    [self loadRequestWithDoMain:YES
                     methodName:@"session/api/addUserToSession"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	获取可邀请的成员
 *
 *	@param 	groupid 	群组id
 */
- (void)inviteMember:(NSString*)groupid page:(int)page {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:groupid forKey:@"sessionid"];
    if (page>0) {
        [params setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    }
    [self loadRequestWithDoMain:YES
                     methodName:@"session/api/contactList"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	把用户从某个群踢出
 *
 *	@param 	groupid 	群组id
 *	@param 	fuid 	被踢者
 */
- (void)delUserFromGroup:(NSString*)groupid fuid:(NSString*)fuid {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:groupid forKey:@"sessionid"];
    [params setObject:fuid forKey:@"fuid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"session/api/remove"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	获取群详细
 *
 *	@param 	groupid 	群组id
 */
- (void)getGroupdetail:(NSString*)groupid {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:groupid forKey:@"sessionid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"session/api/detail"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	获取群用户列表
 *
 *	@param 	groupid 	群组id 
 */
- (void)getGroupUserList:(NSString*)groupid {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:groupid forKey:@"sessionid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"Group/getGroupUserList"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	获取自己所在的群
 *
 */
- (void)getMyGroupWithPage:(int)page {
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    [params setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    [self loadRequestWithDoMain:YES
                     methodName:@"session/api/userSessionList"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	退出群
 *
 *	@param 	groupid 	群组id
 */
- (void)exitGroup:(NSString*)groupid {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:groupid forKey:@"sessionid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"session/api/quit"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	设置是否接受群消息
 *
 *	@param 	groupid 	群组id
 *	@param 	getmsg      是否接受
 */
- (void)groupMsgSetting:(NSString*)groupid getmsg:(BOOL)getmsg {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:groupid forKey:@"sessionid"];
    [params setObject:[NSString stringWithFormat:@"%d", getmsg] forKey:@"getmsg"];
    [self loadRequestWithDoMain:YES
                     methodName:@"session/api/getmsg"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
    
}
/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	设置是否接受群消息
 *
 *	@param 	groupid 	群组id
 *	@param 	name      会话名称
 */
- (void)editGroupname:(NSString*)groupid name:(NSString*)name{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:groupid forKey:@"sessionid"];
    [params setObject:name forKey:@"name"];
    [self loadRequestWithDoMain:YES
                     methodName:@"session/api/edit"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	修改我的群昵称
 *
 *	@param 	groupid 	群组id
 *	@param 	name      会话名称
 */
- (void)setNickname:(NSString*)groupid name:(NSString*)name {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:groupid forKey:@"sessionid"];
    [params setObject:name forKey:@"mynickname"];
    [self loadRequestWithDoMain:YES
                     methodName:@"session/api/setNickname"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}
/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	设置APNS
 */
- (void)setupAPNSDevice {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if ([[BSEngine currentEngine] deviceIDAPNS]) {
        [params setObject:[[BSEngine currentEngine] deviceIDAPNS] forKey:@"udid"];
    }
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/addNoticeHostForIphone"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	取消APNS
 */
- (void)cancelAPNSDevice {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if ([[BSEngine currentEngine] deviceIDAPNS]) {
        [params setObject:[[BSEngine currentEngine] deviceIDAPNS] forKey:@"udid"];
    }
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/removeNoticeHostForIphone"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	设置用户设备是否通知
 */
- (void)setNoticeForIphone:(BOOL)isNotice {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[NSString stringWithFormat:@"%d", isNotice] forKey:@"neednotice"];
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/removeNoticeHostForIphone"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

// ========= 聊吧 meeting =========
// meeting/api
/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	创建聊吧 - add
 *
 *	@param 	picture 上传头像
 *	@param 	name 聊吧标题
 *	@param 	content 聊吧主题
 *	@param  start 开始时间戳
 *	@param  end 结束时间戳
 */
- (void)addMeetingWithName:(NSString*)name content:(NSString*)content start:(NSString*)start end:(NSString*)end picture:(UIImage*)picture {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (name) [params setObject:name forKey:@"name"];
    if (content) [params setObject:content forKey:@"content"];
    if (start) [params setObject:start forKey:@"start"];
    if (end) [params setObject:end forKey:@"end"];
    StRequestPostDataType ty = KSTRequestPostDataTypeNormal;
    if (picture) {
        [params setObject:picture forKey:@"picture"];
        ty = KSTRequestPostDataTypeMultipart;
    }
    [self loadRequestWithDoMain:YES
                     methodName:@"meeting/api/add"
                         params:params
                   postDataType:ty];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	聊吧详细 - detail
 *
 *	@param 	meetingid 	聊吧id
 */
- (void)getMeetingWithMid:(NSString*)mid {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:mid forKey:@"meetingid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"meeting/api/detail"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	用户活跃度排行 - huoyue
 *
 *	@param 	meetingid 	聊吧id
 */
- (void)getMeetingActiveWithMid:(NSString*)mid {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:mid forKey:@"meetingid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"meeting/api/huoyue"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	移除用户 - remove
 *
 *	@param 	fuid 	要移除的用户
 *	@param 	meetingid 	聊吧id
 */
- (void)removefromMeeting:(NSString*)mid fuid:(NSString*)fuid {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:mid forKey:@"meetingid"];
    [params setObject:fuid forKey:@"fuid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"meeting/api/remove"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
    
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	聊吧列表 - meetingList
 *
 *	@param 	type 1-正在进行中 2-往期 3-我的
 */
- (void)meetingListWithType:(int)mType page:(int)page {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[NSString stringWithFormat:@"%d", mType] forKey:@"type"];
    if (page > 1) {
        [params setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    }
    [self loadRequestWithDoMain:YES
                     methodName:@"meeting/api/meetingList"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
    
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	申请加入聊吧 - apply
 *
 *	@param 	meetingid 	聊吧id
 */
- (void)applyMeeting:(NSString*)mid content:(NSString*)content {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:mid forKey:@"meetingid"];
    [params setObject:content forKey:@"content"];
    [self loadRequestWithDoMain:YES
                     methodName:@"meeting/api/apply"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
    
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	聊吧的用户申请列表 - meetingApplyList
 *
 *	@param 	meetingid 	聊吧id
 */
- (void)getMeetingApplyList:(NSString*)mid {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:mid forKey:@"meetingid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"meeting/api/meetingApplyList"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	同意申请加入聊吧 - agreeApply
 *
 *	@param 	fuid 	申请用户id
 *	@param 	meetingid 	聊吧id
 */
- (void)agreeApplyMeeting:(NSString*)mid fuid:(NSString*)fuid {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:mid forKey:@"meetingid"];
    [params setObject:fuid forKey:@"fuid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"meeting/api/agreeApply"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	不同意申请加入聊吧 - disagreeApply
 *
 *	@param 	fuid 	申请用户id
 *	@param 	meetingid 	聊吧id
 */
- (void)disagreeApplyMeeting:(NSString*)mid fuid:(NSString*)fuid {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:mid forKey:@"meetingid"];
    [params setObject:fuid forKey:@"fuid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"meeting/api/disagreeApply"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	邀请加入聊吧 - invite
 *
 *	@param 	fuid 	被邀请用户id
 *	@param 	meetingid 	聊吧id
 */
- (void)inviteMeeting:(NSString*)mid uids:(NSString*)uids {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:mid forKey:@"meetingid"];
    [params setObject:uids forKey:@"uids"];
    [self loadRequestWithDoMain:YES
                     methodName:@"meeting/api/invite"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	同意邀请加入聊吧 - agreeInvite
 *
 *	@param 	fuid 	申请用户id
 *	@param 	meetingid 	聊吧id
 */
- (void)agreeInviteMeeting:(NSString*)mid fuid:(NSString*)fuid {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:mid forKey:@"meetingid"];
    [params setObject:fuid forKey:@"fuid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"meeting/api/agreeInvite"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	不同意邀请加入聊吧 - disagreeInvite
 *
 *	@param 	fuid 	申请用户id
 *	@param 	meetingid 	聊吧id
 */
- (void)disagreeInviteMeeting:(NSString*)mid fuid:(NSString*)fuid {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:mid forKey:@"meetingid"];
    [params setObject:fuid forKey:@"fuid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"meeting/api/disagreeInviteMeeting"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

// ========= setting =========
// 设置密码
/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	设置密码
 *
 *	@param 	oldpass 	旧密码
 *	@param 	newpass 	新密码
 */
- (void)changePassword:(NSString*)oldpass new:(NSString*)newpass
 {
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    [params setObject:oldpass forKey:@"oldpassword"];
    [params setObject:newpass forKey:@"newpassword"];
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/editPassword"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	找回密码
 *
 *	@param 	phone 	电话
 */

- (void)findPassword:(NSString*)phone {
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    [params setObject:phone forKey:@"phone"];
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/findPass"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}
/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	设置加我为好友是否需要验证
 *
 */
- (void)setVerify {
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/setVerify"
                         params:nil
                   postDataType:KSTRequestPostDataTypeNormal];
}

// ========= 意见与反馈 =========
/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	反馈
 *
 *	@param 	content 	内容
 */
- (void)feedback:(NSString*)content {
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    if (content) {
        [params setObject:content forKey:@"content"];
    }
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/feedback"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	协议
 *
 *	@param 	aType 	0 userprotocol 用户协议 1 registprotocol 注册协议
 */
- (void)userAgreement:(int)aType
{
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    if (aType == 0) {
        [params setObject:@"userprotocol" forKey:@"propkey"];
    } else {
        [params setObject:@"registprotocol" forKey:@"propkey"];
    }
    
    [self loadRequestWithDoMain:YES
                     methodName:@"User/keyvalue"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	举报
 *
 *	@param 	content 	内容
 *	@param 	fuid        uid
 */
- (void)jubao:(NSString*)content fuid:(NSString*)fuid
 {
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    [params setObject:content forKey:@"content"];
    [params setObject:fuid forKey:@"fuid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"User/jubao"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

// ========= 朋友圈 =========
/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	朋友圈列表
 *
 */
- (void)shareList:(int)page {
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    [params setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    [self loadRequestWithDoMain:YES
                     methodName:@"friend/api/shareList"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	朋友圈 根据id获取分享详情
 *
 *	@param 	sid        分享id
 */
- (void)getShareDetail:(NSString*)sid {
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    [params setObject:sid forKey:@"fsid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"friend/api/detail"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
    
}
/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	朋友圈 赞
 *
 *	@param 	sid        分享id
 */
- (void)addZan:(NSString*)sid {
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    [params setObject:sid forKey:@"fsid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"friend/api/sharePraise"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	朋友圈 删除自己的分享
 *
 *	@param 	sid        分享id
 */
- (void)deleteShare:(NSString*)sid {
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    [params setObject:sid forKey:@"fsid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"friend/api/delete"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	朋友圈 回复
 *
 *	@param 	sid         分享id
 *	@param 	fuid        回复哪个人
 *	@param 	content     内容
 */
- (void)shareReply:(NSString*)sid fuid:(NSString*)fuid content:(NSString*)content {
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    [params setObject:sid forKey:@"fsid"];
    [params setObject:fuid forKey:@"fuid"];
    [params setObject:content forKey:@"content"];
    [self loadRequestWithDoMain:YES
                     methodName:@"friend/api/shareReply"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
    
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	朋友圈 删除回复
 *
 *	@param 	sid        分享id
 */
- (void)deleteReply:(NSString*)sid {
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    [params setObject:sid forKey:@"fsid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"friend/api/deleteReply"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	朋友圈 删除回复
 *
 *	@param 	fuid uid
 *	@param 	type 1. 不看他（她）的朋友圈 2.不让他（她）看我的朋友圈
 */
- (void)setFriendCircleAuth:(NSString*)fuid type:(int)type {
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    [params setObject:fuid forKey:@"fuid"];
    [params setObject:[NSString stringWithFormat:@"%d", type] forKey:@"type"];
    [self loadRequestWithDoMain:YES
                     methodName:@"friend/api/setFriendCircleAuth"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
    
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	朋友圈 设置相册封面
 *
 *	@param 	image 封面
 */
- (void)setCover:(UIImage*)image {
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    [params setObject:image forKey:@"picture"];
    [self loadRequestWithDoMain:YES
                     methodName:@"friend/api/setCover"
                         params:params
                   postDataType:KSTRequestPostDataTypeMultipart];
    
}
/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	发布分享
 *
 *	@param 	picdata     最多上传6张,命名picture1,picture2,..
 *	@param 	content     分享文字内容
 *	@param 	lng         经度
 *	@param 	lat         纬度
 *	@param 	address     经纬度所在的地址
 *	@param 	visible     不传表示是公开的，传入格式：id1,id2,id3
 */
- (void)addNewshare:(NSArray*)picdata content:(NSString*)content lng:(double)lng lat:(double)lat address:(NSString*)address visible:(NSArray*)visible {
    
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    StRequestPostDataType StRequestPostDataType;
    if (picdata && picdata.count > 0) {
        StRequestPostDataType = KSTRequestPostDataTypeMultipart;
        [picdata enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [params setObject:obj forKey:[NSString stringWithFormat:@"picture%d", (int)idx + 1]];
        }];
    } else {
        StRequestPostDataType = KSTRequestPostDataTypeNormal;
    }
    if (content) {
        [params setObject:content forKey:@"content"];
    }
    if (address) {
        [params setObject:[NSString stringWithFormat:@"%f", lng] forKey:@"lng"];
        [params setObject:[NSString stringWithFormat:@"%f", lat] forKey:@"lat"];
        [params setObject:address forKey:@"address"];
    }
    if (visible && visible.count > 0) {
        [params setObject:[visible componentsJoinedByString:@","] forKey:@"visible"];
    }
    [self loadRequestWithDoMain:YES
                     methodName:@"friend/api/add"
                         params:params
                   postDataType:StRequestPostDataType];
}
@end
