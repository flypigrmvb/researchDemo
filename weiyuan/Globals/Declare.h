//
//  Declare.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

// 全局需要的一些枚举类型数据声明在这里

typedef enum {
    forSendComment,         // 发表评论
    forGetCommentList,      // 获取评论列表
    forSendZan,
    forSenddonation,
    forSetCover,            //  设置相册封面
    forAddFav,            //  收藏
}CommentType;
// 消息状态
typedef enum {
    /** 查看和分享收藏*/
    forLookPictureStateMore = 0,
    /** 仅查看*/
    forLookPictureStateNormal,
    /** 查看和删除*/
    forLookPictureStateDelete,
}LookPictureState;

// 消息状态
typedef enum {
    /** 收到的消息，发送成功的消息*/
    forMessageStateNormal = 0,  //
    /** 发送失败的消息*/
    forMessageStateError,   //
    /** 未发送/发送中的消息*/
    forMessageStateHavent,  //
}MessageState;
// 0－男 1－女
typedef enum {
    Male = 0,
    Female = 1,
}Gender;

// 消息类型
typedef enum {
    forChatTypeUser = 100,
    forChatTypeMeet = 500,
    forChatTypeGroup = 300,
}Typechat;   //单聊100/群聊300/聊吧500

// 文件类型
typedef enum {
    forFileText = 1,    // 文字
    forFileImage ,      // 图片
    forFileVoice ,      // 声音
    forFileAddress ,    // 地址
    forFileNameCard,    // 名片
    forFilefav,         // 收藏
}FileType;

// 聊吧期限类型
typedef enum {
    forMeetLoading = 1,    // 正在进行中
    forMeetInvalid ,      // 往期
    forMeetmMine ,      // 我的
}MeetType;

typedef struct {
    double lat;
    double lng;
} Location;

typedef enum {
    forNotifySystem = 1,                    // 系统
    forNotifyAdd = 101,                     // 申请加好友
    forNotifyAgreeAdd = 102,                // 同意加好友
    forNotifyCancelAdd = 103,               // 不同意加好友
    forNotifydeleted = 104,                 // 删除好友
    forNotifyKickUser = 301,                // 踢用户出房间
    forNotifyLeaveRoom = 300,               // 用户离开房间
    forNotifyGroupInfoUpdate = 302,         // 管理员编辑会话名称
    forNotifyDestroyRoom = 303,             // 管理员删除会话
    forNotifyNameChange = 304,              // 群成员的昵称发生变化
    forNotifyaddNewOne = 305,               // 有新成员进来
    forNotifyZan = 400,                     // 收到赞的通知
    forNotifyCancelZan = 401,               // 收到取消赞的通知
    forNotifyComment = 402,                 // 收到评论的通知500
    forNotifyMeetAdd = 500,                 // 申请入会
    forNotifyMeetAgreeAdd = 501,            // 同意申请入会
    forNotifyMeetDisAgreeAdd = 502,         // 不同意申请入会
    forNotifyMeetInvite = 503,              // 邀请入会
    forNotifyMeetAgreeInvite = 504,         // 同意邀请
    forNotifyMeetDisInvite = 505,           // 不同意邀请
    forNotifyMeetKicked = 506,              // 你被踢出聊吧
    forNotifyMeetLookKick = 507,            // 所有用户收到你被踢的通知
} NotifyType;

typedef enum {
    forMessageType1 = 1, // 文字
    forMessageType2 = 2, // 图片
    forMessageType3 = 3, // 图片加文字
    forMessageType4 = 4,
}CircleMessageType;

extern Location kLocationMake(double la, double ln);