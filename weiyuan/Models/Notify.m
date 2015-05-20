//
//  Notify.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "Notify.h"
#import "User.h"
#import "DBConnection.h"
#import "BSEngine.h"
#import "Globals.h"
#import "JSON.h"
#import "EmotionInputView.h"
#import "CircleMessage.h"
#import "SharePicture.h"
#import "JSON.h"

@implementation Notify
@synthesize type, content, user, time;
@synthesize roomID, roomName, shareID;

- (void)updateWithJsonDic:(NSDictionary*)dic {
    isInitSuccuss = NO;
    if (dic != nil && [dic isKindOfClass:[NSDictionary class]]) {
        isInitSuccuss = YES;
    }
    if (isInitSuccuss) {
        self.type = [dic getIntValueForKey:@"type" defaultValue:0];
        NSDictionary * info = [dic objectForKey:@"user"];
        if ([info isKindOfClass:[NSDictionary class]] && [info objectForKey:@"uid"]) {
            self.user = [[User alloc] init];
            self.user.uid = [info getStringValueForKey:@"uid" defaultValue:nil];
            self.user.nickname = [info getStringValueForKey:@"name" defaultValue:nil];
            user.nickname = [EmotionInputView decodeMessageEmoji:user.nickname];
            NSString * url = [info getStringValueForKey:@"headsmall" defaultValue:nil];
            if (url) {
                self.user.headsmall = url;
            }
        }
        self.shareID = @"-1";
        self.content = [dic getStringValueForKey:@"content" defaultValue:nil];
        if (type < forNotifyMeetAdd) {
            if (type >= forNotifyZan) {
                NSMutableDictionary * shareObj = [NSMutableDictionary dictionaryWithDictionary:[[dic objectForKey:@"other"] getDictionaryForKey:@"share"]];
                NSString * pic = [shareObj getStringValueForKey:@"picture" defaultValue:nil];
                if (pic && pic.length > 0) {
                    [shareObj setObject:[JSON objectFromJSONString:pic] forKey:@"picture"];
                }
                CircleMessage * it = [CircleMessage objWithJsonDic:shareObj];
                self.shareID = it.fid;
                if (it.picsArray.count > 0) {
                    self.shareContent = [it.picsArray[0] smallUrl];
                } else {
                    self.shareContent = it.content;
                    self.shareContent = [EmotionInputView decodeMessageEmoji:_shareContent];
                }
            } else {
                NSDictionary * room = [dic objectForKey:@"other"];
                if (room && [room isKindOfClass:[NSDictionary class]] ) {
                    self.roomID = [room getStringValueForKey:@"id" defaultValue:nil];
                    self.roomName = [room getStringValueForKey:@"name" defaultValue:nil];
                    roomName = [EmotionInputView decodeMessageEmoji:roomName];
                }
            }
            self.isMeet = 0;
        } else {
            NSDictionary * meet = [dic objectForKey:@"other"];
            self.isMeet = 1;
            self.shareContent = [meet getStringValueForKey:@"content" defaultValue:@""];
            self.shareID = [meet getStringValueForKey:@"id" defaultValue:@""];
        }
        
        self.content = [dic getStringValueForKey:@"content" defaultValue:nil];
        content = [EmotionInputView decodeMessageEmoji:content];
        long long ctime = [dic getLongLongValueValueForKey:@"time" defaultValue:0];
        self.time = [NSString stringWithFormat:@"%lld", ctime/1000];
    }
}

- (void)getRoomContent {
    NSDictionary * info = [JSON mutableObjectFromJSONString:content];
    if (info && [info isKindOfClass:[NSDictionary class]]) {
        self.user = [[User alloc] init];
        
        NSDictionary * us = [info getDictionaryForKey:@"user"];
        self.user.uid = [us getStringValueForKey:@"uid" defaultValue:nil];
        self.user.nickname = [us getStringValueForKey:@"nickname" defaultValue:nil];
        self.user.headsmall = [us getStringValueForKey:@"head" defaultValue:nil];
        
        NSDictionary * group = [info getDictionaryForKey:@"group"];
        
        self.roomID = [group getStringValueForKey:@"groupid" defaultValue:nil];
        self.roomName = [group getStringValueForKey:@"groupname" defaultValue:nil];
        if (type == forNotifyKickUser) {
            self.user.headsmall = [group getStringValueForKey:@"head" defaultValue:nil];
        }
        _displayContent = [info getStringValueForKey:@"content" defaultValue:nil];
    }
}

- (NSString*)displayContent {
    if (self.type >= forNotifydeleted) {
        [self getRoomContent];
    } else {
        _displayContent = content;
    }
    return [EmotionInputView decodeMessageEmoji:_displayContent];
}

#pragma DB

+ (void)createTableIfNotExists
{
	Statement *stmt = [DBConnection statementWithQuery:"CREATE TABLE IF NOT EXISTS tb_Notify (type, content, userID, time, shareID, shareContent, ismeet, currentUser, primary key(userID, time, type, currentUser))"];
    int step = [stmt step];
	if (step != SQLITE_DONE) {
        [DBConnection alert];
    }
}

+ (NSArray*)getListFromDBSinceTime:(NSString*)time
{
    if (time == nil) {
        return [self getListFromDBSinceNow];
    }

    NSMutableArray* list = [NSMutableArray array];
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQuery:"SELECT * FROM tb_Notify WHERE currentUser = ? and time < ? order by time desc limit 0,?"];
    }
    
    int i = 1;
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
    [stmt bindString:time forIndex:i++];
    [stmt bindInt32:defaultSizeInt forIndex:i++];
    
    int ret = [stmt step];
    
    while (ret == SQLITE_ROW) {
        Notify* item = [[Notify alloc] initWithStatement:stmt];
        if (item) {
            [list addObject:item];
        }
        ret = [stmt step];
    }
    
    [stmt reset];
	return list;
}

+ (void)deleteFromDB {
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQuery:"delete from tb_Notify where currentUser = ?"];
    }
    int i = 1;
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
    
	int step = [stmt step];
    if (step != SQLITE_DONE) {
        [DBConnection alert];
    }
    [stmt reset];
}

+ (void)deleteFromDBWithShareID:(NSString*)sId {
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQuery:"delete from tb_Notify where shareID = ? and currentUser = ?"];
    }
    int i = 1;
    
    [stmt bindString:sId forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
    
	int step = [stmt step];
    if (step != SQLITE_DONE) {
        [DBConnection alert];
    }
    [stmt reset];
}

+ (NSArray*)getListFromDBSinceNowWithMeetId:(NSString*)mid {
    NSMutableArray* list = [NSMutableArray array];
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQuery:"SELECT * FROM tb_Notify WHERE shareID = ? and currentUser = ? and ismeet = 1 order by time desc limit 0,?"];
    }
    
    int i = 1;
    [stmt bindString:mid forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
    [stmt bindInt32:defaultSizeInt forIndex:i++];
    
    int ret = [stmt step];
    
    while (ret == SQLITE_ROW) {
        Notify* item = [[Notify alloc] initWithStatement:stmt];
        if (item) {
            [list addObject:item];
        }
        ret = [stmt step];
    }
    
    [stmt reset];
	return list;
}

+ (NSArray*)getListFromDBSinceNow
{
    NSMutableArray* list = [NSMutableArray array];
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQuery:"SELECT * FROM tb_Notify WHERE currentUser = ? and ismeet = 0 order by time desc limit 0,?"];
    }
    
    int i = 1;
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
    [stmt bindInt32:defaultSizeInt forIndex:i++];
    
    int ret = [stmt step];
    
    while (ret == SQLITE_ROW) {
        Notify* item = [[Notify alloc] initWithStatement:stmt];
        if (item) {
            [list addObject:item];
        }
        ret = [stmt step];
    }
    
    [stmt reset];
	return list;
}

- (id)initWithStatement:(Statement *)stmt {
	if (self = [super init]) {
        int i = 0;
        self.type = [stmt getInt32:i++];
        self.content = [stmt getString:i++];
        self.user = [User userWithID:[stmt getString:i++]];
        self.time = [stmt getString:i++];
        self.shareID = [stmt getString:i++];
        self.shareContent = [stmt getString:i++];
	}
	return self;
}

- (void)insertDB
{
//    DLog(@"insertDB for tb_Notify");
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQuery:"REPLACE INTO tb_Notify VALUES(?, ?, ?, ?, ?, ?, ?, ?)"];
    }
    int i = 1;
    [stmt bindInt32:self.type forIndex:i++];
    [stmt bindString:self.content forIndex:i++];
    [stmt bindString:self.user.uid forIndex:i++];
    [stmt bindString:self.time forIndex:i++];
    [stmt bindString:self.shareID forIndex:i++];
    [stmt bindString:self.shareContent forIndex:i++];
    [stmt bindInt32:self.isMeet forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];

    if (user && ![user.uid isEqualToString:[BSEngine currentUserId]]) {
        User * us = [User userWithID:user.uid];
        if (us) {
            [us insertDB];
        } else {
            [user insertDB];
        }
    }
    
	int step = [stmt step];
    if (step != SQLITE_DONE) {
        [DBConnection alert];
    }
    [stmt reset];
}

- (void)deleteFromDB {
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQuery:"delete from tb_Notify where time = ? and type = ? and ismeet = 0 and currentUser = ?"];
    }
    int i = 1;
    [stmt bindString:time forIndex:i++];
    [stmt bindInt32:self.type forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
    
	int step = [stmt step];
    if (step != SQLITE_DONE) {
        [DBConnection alert];
    }
    [stmt reset];
}

- (void)deleteIfExistsOld {
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQuery:"delete from tb_Notify where userID = ? and type = ? and currentUser = ?"];
    }
    int i = 1;
    [stmt bindString:user.uid forIndex:i++];
    [stmt bindInt32:type forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
    
	int step = [stmt step];
    if (step != SQLITE_DONE) {
        [DBConnection alert];
    }
    [stmt reset];
}

- (NSString*)timeString {
    NSTimeInterval tInterval = [time doubleValue];
    return [Globals timeStringForListWith:tInterval];
}

@end
