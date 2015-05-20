//
//  Favorite.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//
#import "Declare.h"
#import "NSBaseObject.h"
@class Address;

@interface Favorite : NSBaseObject
/** 收藏记录的id */
@property (nonatomic, strong) NSString * fid;
/** 收藏内容 */
@property (nonatomic, strong) NSString * content;
/** 收藏时间 */
@property (nonatomic, strong) NSString * createtime;
/** 被收藏的记录的用户 */
@property (nonatomic, strong) NSString * uid;
/** 头像 */
@property (nonatomic, strong) NSString * headsmall;
/** 名字 */
@property (nonatomic, strong) NSString * nickname;
/** 区别群和单聊 的消息id */
@property (nonatomic, strong) NSString * otherid;
/** 文件类型 @see FileType */
@property (nonatomic, assign) FileType   typefile;
/** 图地址 */
@property (nonatomic, strong) NSString * imgUrl;
/** 音频地址 */
@property (nonatomic, strong) NSString * voiceUrl;
/** 音频时长 */
@property (nonatomic, strong) NSString * voiceTime;
/** 地址 @see Address */
@property (nonatomic, strong) Address  * address;

+ (CGFloat)HeightOfFavorite:(Favorite*)item;
@end
