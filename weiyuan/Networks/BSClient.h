//
//  BSClient.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Declare.h"
@class Message;

@interface BSClient : NSObject

@property (nonatomic, strong) NSString      * errorMessage;
@property (nonatomic, strong) NSIndexPath   * indexPath;
@property (nonatomic, strong) NSString      * tag;
@property (nonatomic, assign) BOOL          hasError;
@property (nonatomic, assign) int           errorCode;

#pragma mark - Init
- (id)initWithDelegate:(id)del action:(SEL)act;

- (void)showAlert;

- (void)cancel;

#pragma mark - Request

// ========= Login&Reg =========
/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	账号登录
 *
 *	@param 	phone 	电话
 *	@param 	pwd 	密码
 */
- (void)loginWithUserPhone:(NSString *)phone
                  password:(NSString *)pwd;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	账号注册
 *
 *	@param 	phone 	电话
 *	@param 	pwd 	密码
 *	@param 	code 	验证码
 */
- (void)regWithPhone:(NSString *)phone
            password:(NSString *)password
                code:(NSString *)code;

// ======== 获取验证码 =========
/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	获取验证码
 *
 *	@param 	phone 	电话
 */
- (void)getPhoneCode:(NSString*)phone;

// ========= UserInfo =========
/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	根据uid获取详细资料
 *
 *	@param 	uid 	uid
 */

- (void)getUserInfoWithuid:(NSString*)uid;
/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	根据Keyword获取资料
 *
 *	@param 	Keyword 	昵称/电话
 *  @return 返回为用户数组
 */
- (void)getUserInfoWithKeyword:(NSString*)keyword page:(int)page;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	设置好友的备注名
 *
 *	@param 	name 	备注名
 *	@param 	fuid 	uid
 */
- (void)setMarkName:(NSString*)name fuid:(NSString*)fuid
;

// ========= editInfo =========
/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	编辑资料
 *
 *	@param 	headImg 	新的头像
 *	@param 	user        用户对象
 */
- (void)editUserInfo:(UIImage*)headImg user:(id)user;

// ========= Friend =========

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	添加好友
 *
 *	@param 	fuid 	uid
 *	@param 	content 	理由
 */
- (void)to_friend:(NSString*)fuid content:(NSString*)content;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	删除好友
 *
 *	@param 	fuid 	uid
 */
- (void)del_friend:(NSString*)fuid;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	同意申请加好友
 *
 *	@param 	fuid 	uid
 */
- (void)agreeAddFriend:(NSString*)fuid;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	好友列表
 *
 */
- (void)friendList;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	通讯录添加好友
 *  @param phones 上传格式：电话1,电话2,电话3,电话4
 *  @return type  	0-不是系统用户，可邀请的用户 1-系统用户
 isfriend  0-不是好友 可以添加 1-是好友
 */
- (void)telephone:(NSString*)phones;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	通讯录添加好友
 *  @param phones 上传格式：电话1,电话2,电话3,电话4
 */
- (void)newFriends:(NSString*)phones;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *  个人相册
 *  @param fuid 不传刚获取自己的，传刚获取别人的
 */
- (void)userAlbum:(NSString*)fuid page:(int)page;

// ========= 黑名单 =========

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	添加到黑名单
 *
 *	@param 	fuid 	uid
 */
- (void)black:(NSString*)fuid;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	黑名单列表
 *
 */
- (void)blackList;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *  收藏列表
 *
 */
- (void)favoriteList;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *  删除收藏
 *
 */
- (void)deleteFavorite:(NSString*)fid;
/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *  增加收藏
 *
 *	@param fuid 被收藏人的uid
 *	@param otherid 如果是收藏的群组的消息，就传入此id
 *	@param content 收藏的内容
 */
- (void)addfavorite:(NSString*)fuid otherid:(NSString*)otherid content:(NSString*)content;

// ========= 单聊 =========

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	发送消息
 *
 *	@param msg 消息对象
 *
 */
- (void)sendMessageWithObject:(Message*)msg;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	@param fromid false 发送者id
 *	@param fromname true 发送者name
 *	@param fromurl true 发送者头像
 *	@param toid true 接收者，可以是某人，也可以是某个群id
 *	@param toname true 接收者name
 *	@param tourl true 接收者头像
 *	@param file false 上传图片/声音
 *	@param voicetime false 声音时间长度
 *	@param lat false 纬度
 *	@param lng false 经度
 *	@param address 地址 false
 *	@param content 消息的文字内容
 *	@param typechat 100-单聊 200-群聊 300-临时会话 默认为100
 *	@param typefile 1-文字 2-图片 3-声音 4-位置
 *	@param tag 标识符
 *	@param time 发送消息的时间,毫秒（服务器生成）
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
                    tag:(NSString*)tag
                   time:(NSString*)time;
/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	设置是否接收另一用户的消息
 *
 *	@param fuid 用户id
 *
 */
- (void)setGetmsg:(NSString*)fuid;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	设置星标朋友
 *
 *	@param fuid 用户id
 *
 */
- (void)setStar:(NSString*)fuid;
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

- (void)createGroupAndInviteUsers:(NSArray*)inviteduids groupname:(NSString*)groupname;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	删除群组
 *
 *	@param 	groupid 	群组id 
 */
- (void)delGroup:(NSString*)groupid;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	查找群
 *
 *	@param 	keyword 	可以是群昵称或群id
 */
- (void)groupSearch:(NSString*)keyword page:(int)page;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	根据群id获取群信息
 *
 *	@param 	groupid 	群组id 
 */
- (void)groupDetail:(NSString*)groupid;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	根据群id加入群
 *
 *	@param 	groupid 	群组id
 */
- (void)addtogroup:(NSString*)groupid;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	添加用户到群组
 *
 *	@param 	groupid 	群组id 
 *	@param 	inviteduids 	参数格式: uid1,uid2,uid3
 */
- (void)inviteUser:(NSString*)groupid inviteduids:(NSArray*)inviteduids;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	获取可邀请的成员
 *
 *	@param 	groupid 	群组id 
 */
- (void)inviteMember:(NSString*)groupid page:(int)page;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	把用户从某个群踢出
 *
 *	@param 	groupid 	群组id 
 *	@param 	fuid 	被踢者
 */
- (void)delUserFromGroup:(NSString*)groupid fuid:(NSString*)fuid;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	获取群详细
 *
 *	@param 	groupid 	群组id
 */
- (void)getGroupdetail:(NSString*)groupid;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	获取群用户列表
 *
 *	@param 	groupid 	群组id 
 */

- (void)getGroupUserList:(NSString*)groupid;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	获取自己所在的群
 *	@param 	page 	页码
 *
 */
- (void)getMyGroupWithPage:(int)page;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	退出群
 *
 *	@param 	groupid 	群组id
 */
- (void)exitGroup:(NSString*)groupid;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	设置是否接受群消息
 *
 *	@param 	groupid 	群组id
 *	@param 	getmsg      是否接受
 */
- (void)groupMsgSetting:(NSString*)groupid getmsg:(BOOL)getmsg;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	设置是否接受群消息
 *
 *	@param 	groupid 	群组id
 *	@param 	name      会话名称
 */
- (void)editGroupname:(NSString*)groupid name:(NSString*)name;
/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	修改我的群昵称
 *
 *	@param 	groupid 	群组id
 *	@param 	name      会话名称
 */
- (void)setNickname:(NSString*)groupid name:(NSString*)name;
// ========= APNS =========
// 添加APNS
- (void)setupAPNSDevice;
// 取消APNS
- (void)cancelAPNSDevice;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	设置用户设备是否通知
 */
- (void)setNoticeForIphone:(BOOL)isNotice;

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
- (void)addMeetingWithName:(NSString*)name content:(NSString*)content start:(NSString*)start end:(NSString*)end picture:(UIImage*)picture;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	聊吧详细 - detail
 *
 *	@param 	meetingid 	聊吧id
 */
- (void)getMeetingWithMid:(NSString*)mid;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	用户活跃度排行 - huoyue
 *
 *	@param 	meetingid 	聊吧id
 */
- (void)getMeetingActiveWithMid:(NSString*)mid;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	移除用户 - remove
 *
 *	@param 	fuid 	要移除的用户
 *	@param 	meetingid 	聊吧id
 */
- (void)removefromMeeting:(NSString*)mid fuid:(NSString*)fuid;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	聊吧列表 - meetingList
  *
 *	@param 	type 0-正在进行中 1-往期 2-我的
 */

- (void)meetingListWithType:(int)mType page:(int)page;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	申请加入聊吧 - apply
 *
 *	@param 	meetingid 	聊吧id
 */
- (void)applyMeeting:(NSString*)mid content:(NSString*)content;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	聊吧的用户申请列表 - meetingApplyList
 *
 *	@param 	meetingid 	聊吧id
 */
- (void)getMeetingApplyList:(NSString*)mid;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	同意申请加入聊吧 - agreeApply
 *
 *	@param 	fuid 	申请用户id
 *	@param 	meetingid 	聊吧id
 */
- (void)agreeApplyMeeting:(NSString*)mid fuid:(NSString*)fuid;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	不同意申请加入聊吧 - disagreeApply
 *
 *	@param 	fuid 	申请用户id
 *	@param 	meetingid 	聊吧id
 */
- (void)disagreeApplyMeeting:(NSString*)mid fuid:(NSString*)fuid;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	邀请加入聊吧 - invite
 *
 *	@param 	uids        用户id 格式 id1,id2,id3
 *	@param 	meetingid 	聊吧id
 */
- (void)inviteMeeting:(NSString*)mid uids:(NSString*)uids;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	同意邀请加入聊吧 - agreeInvite
 *
 *	@param 	fuid        申请用户id
 *	@param 	meetingid 	聊吧id
 */
- (void)agreeInviteMeeting:(NSString*)mid fuid:(NSString*)fuid;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	不同意邀请加入聊吧 - disagreeInvite
 *
 *	@param 	fuid 	申请用户id
 *	@param 	meetingid 	聊吧id
 */
- (void)disagreeInviteMeeting:(NSString*)mid fuid:(NSString*)fuid;

// ========= setting =========
/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	设置密码
 *
 *	@param 	oldpass 	旧密码
 *	@param 	newpass 	新密码
 */
- (void)changePassword:(NSString*)oldpass new:(NSString*)newpass;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	找回密码
 *
 *	@param 	phone 	电话
 */

- (void)findPassword:(NSString*)phone;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	设置加我为好友是否需要验证
 *
 */
- (void)setVerify;


// ========= 意见与反馈 =========
/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	反馈
 *
 *	@param 	content 	内容
 */
- (void)feedback:(NSString*)content;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	协议
 *
 *	@param 	aType 	0 userprotocol 用户协议 1 registprotocol 注册协议
 */
- (void)userAgreement:(int)aType;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	举报
 *
 *	@param 	content 	内容
 *	@param 	fuid        uid
 */
- (void)jubao:(NSString*)content fuid:(NSString*)fuid;

// ========= 朋友圈 =========

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	朋友圈列表
 *
 */
- (void)shareList:(int)page;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	朋友圈 根据id获取分享详情
 *
 *	@param 	sid        分享id
 */
- (void)getShareDetail:(NSString*)sid;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	朋友圈 赞
 *
 *	@param 	sid        分享id
 */
- (void)addZan:(NSString*)sid;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	朋友圈 删除自己的分享
 *
 *	@param 	sid        分享id
 */
- (void)deleteShare:(NSString*)sid;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	朋友圈 回复
 *
 *	@param 	sid         分享id
 *	@param 	fuid        回复哪个人
 *	@param 	content     内容
 */
- (void)shareReply:(NSString*)sid fuid:(NSString*)fuid content:(NSString*)content;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	朋友圈 删除回复
 *
 *	@param 	sid        分享id
 */
- (void)deleteReply:(NSString*)sid;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	朋友圈 删除回复
 *
 *	@param 	fuid uid
 *	@param 	type 1. 不看他（她）的朋友圈 2.不让他（她）看我的朋友圈
 */
- (void)setFriendCircleAuth:(NSString*)fuid type:(int)type;
/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	朋友圈 设置相册封面
 *
 *	@param 	image 封面
 */
- (void)setCover:(UIImage*)image;
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
- (void)addNewshare:(NSArray*)picdata content:(NSString*)content lng:(double)lng lat:(double)lat address:(NSString*)address visible:(NSArray*)visible;
@end
