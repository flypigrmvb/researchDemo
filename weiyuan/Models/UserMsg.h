//
//  UserMsg.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NSBaseObject.h"

@interface UserMsg : NSBaseObject
/** id*/
@property (nonatomic, strong) NSString * uid;
/** 是否接收消息*/
@property (nonatomic, strong) NSString * getmsg;

@end
