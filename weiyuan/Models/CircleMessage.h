//
//  Message.h
//  BusinessMate
//
//  Created by keen on 13-6-8.
//  Copyright (c) 2013年 xizue. All rights reserved.
//

#import "NSBaseObject.h"
#import "Declare.h"
#import "Address.h"

@interface CircleComment : NSBaseObject

@property (nonatomic, strong) NSString* uid;        // 人id
@property (nonatomic, strong) NSString* nickname;   // 名字
@property (nonatomic, strong) NSString* headsmall;  // 头像
@property (nonatomic, strong) NSString* fid;        // 被评论人id
@property (nonatomic, strong) NSString* fnickname;  // 被评论人
@property (nonatomic, strong) NSString* content;    // 内容
@property (nonatomic, strong) NSString* createtime; // 时间
@property (nonatomic, strong) NSString* id;         // 记录id
@end

@interface CircleZan : NSBaseObject

@property (nonatomic, strong) NSString* uid;       // 人id
@property (nonatomic, strong) NSString* nickname;  // 名字
@property (nonatomic, strong) NSString* headsmall; // 头像
@end

@interface CircleMessage : NSBaseObject

@property (nonatomic, strong) NSString* fid;            // 记录id
@property (nonatomic, strong) NSString* uid;            // 发布人id
@property (nonatomic, strong) NSString* name;           // 发布人名字
@property (nonatomic, strong) NSString* content;        // 内容
@property (nonatomic, strong) NSString* imgHeadUrl;     // 头像
@property (nonatomic, strong) NSString* createtime;     // 格式化时间
@property (nonatomic, assign) NSTimeInterval time;      // 时间戳
@property (nonatomic, strong) Address * address;        // 地址分享的保存类
@property (nonatomic, assign) int replys;               // 回复数
@property (nonatomic, assign) int praises;              // 赞
@property (nonatomic, assign) BOOL ispraise;            // 是我赞的吗

@property (nonatomic, strong) NSMutableArray * praiselist;  // 赞列表
@property (nonatomic, strong) NSMutableArray * replylist;   // 回复列表
@property (nonatomic, strong) NSMutableArray * picsArray;   // 分享中的图片数据列表
@property (nonatomic, assign) CircleMessageType cmType;     // 分享类型

@end
