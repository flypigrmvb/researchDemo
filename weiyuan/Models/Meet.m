//
//  Meet.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "Meet.h"
#import "BSEngine.h"
#import "Globals.h"
#import "Message.h"

@implementation Meet

- (void)updateWithJsonDic:(NSDictionary *)dic {
    [super updateWithJsonDic:dic];
    self.start = [Globals convertDateFromString:_start timeType:0];
    self.end = [Globals convertDateFromString:_end timeType:0];
    self.unreadCount = [Message getUnreadMessageCountWithID:self.id];
}

/** 观察者是否是管理员*/
- (BOOL)isOwer {
    return [_uid isEqualToString:[BSEngine currentUserId]];
}

/** 聊吧是否过期*/
- (BOOL)isInValid {
    NSDate * dat = [Globals convertStringtoDate:_end timeType:0];
    return (dat.timeIntervalSince1970 > [NSDate date].timeIntervalSince1970);
}

@end
