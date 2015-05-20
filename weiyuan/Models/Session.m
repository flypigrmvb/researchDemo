//
//  Session.m
//
//  AppDelegate.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "Session.h"
#import "DBConnection.h"
#import "User.h"
#import "Message.h"
#import "Room.h"
#import "Globals.h"
#import "BSEngine.h"
#import "UserMsg.h"
#import "Meet.h"

@implementation Session

@synthesize uid, name, headsmall;
@synthesize content;
@synthesize unreadCount;
@synthesize istop;
@synthesize isshownick;
@synthesize typechat;
@synthesize message;

+ (Session*)sessionWithMessage:(Message *)msg {
    return [[Session alloc] initWithMessage:msg];
}

+ (Session*)sessionWithUser:(User *)item {
    return [[Session alloc] initWithUser:item];
}

+ (Session*)sessionWithRoom:(id)room {
    return [[Session alloc] initWithRoom:room];
}

+ (Session*)sessionWithMeet:(Meet*)meet {
    return [[Session alloc] initWithMeet:meet];
}

- (id)initWithMessage:(Message*)msg {
    if (self = [super init]) {
        self.message = msg;
        self.unreadCount = 0;
        self.typechat = msg.typechat;
        self.uid = msg.withID;
        self.name = self.title;
        self.headsmall = msg.displayImgUrl;
        if (!msg.isSendByMe) {
            self.unreadCount++;
        }
        self.istop = 0;
        if (typechat == forChatTypeUser) {
            UserMsg * um = [[UserMsg alloc] init];
            um.uid = uid;
            um.getmsg = @"1";
            [um insertDB];
        }
    }
    return self;
}

- (id)initWithUser:(User*)item {
    if (self = [super init]) {
        self.typechat = forChatTypeUser;
        self.uid = item.uid;
        self.unreadCount = 0;
        if (!message) {
            message = [[Message alloc] init];
            message.sendTime = [Globals timeString];
            message.displayImgUrl = item.headsmall;
            message.displayName = item.displayName;
            message.toId = item.uid;
        }
        
        self.name = self.title;
        self.headsmall = message.displayImgUrl;
        self.istop = 0;
        if (typechat == forChatTypeUser) {
            UserMsg * um = [[UserMsg alloc] init];
            um.uid = uid;
            um.getmsg = [NSString stringWithFormat:@"%d", item.getmsg];
            [um insertDB];
        }
    }
    return self;
}

- (id)initWithRoom:(Room*)room {
    if (self = [super init]) {
        uid = room.uid;
        self.typechat = forChatTypeGroup;
        self.unreadCount = 0;
        self.message = [Message getLatestMessageWithID:uid];
        if (!message) {
            message = [[Message alloc] init];
            message.sendTime = [Globals timeString];
            message.tohead = room.head;
            message.toname = room.name;
            message.toId = room.uid;
        }
        self.name = self.title;
        self.headsmall = message.tohead;
        self.istop = 0;
    }
    return self;
}

- (id)initWithMeet:(Meet*)meet {
    if (self = [super init]) {
        uid = meet.id;
        self.typechat = forChatTypeMeet;
        self.unreadCount = 0;
        self.message = [Message getLatestMessageWithID:uid];
        if (!message) {
            message = [[Message alloc] init];
            message.sendTime = [Globals timeString];
            message.tohead = meet.logo;
            message.toname = meet.name;
            message.toId = meet.uid;
        }
        self.name = self.title;
        self.headsmall = message.tohead;
        self.istop = 0;
    }
    return self;
}

- (void)dealloc {
    self.uid = nil;
    self.content = nil;
    self.message = nil;
}

- (NSString*)title {
    if (typechat == forChatTypeUser) {
        return message.displayName;
    } else {
        return message.toname;
    }
}

- (void)setMessage:(Message *)item {
    if (message) {
        message = nil;
    }
    message = item;
    self.content = message.content;
}

- (void)updateWithMessage:(Message*)msg {
    self.message = msg;
    if (!msg.isSendByMe) {
        self.unreadCount ++;
    }
    if (msg.displayName && ![msg.displayName isEqualToString:self.name]) {
        self.name = msg.displayName;
        [self updateVaule:self.name key:@"name"];
    }
    [self updateSessioninfo];
}

- (NSString*)time {
    return message.sendTime;
}

- (BOOL)isRoom {
    return (typechat == forChatTypeGroup);
}

+ (void)createTableIfNotExists {
	Statement *stmt = [DBConnection statementWithQueryString:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (uid, name, content, headsmall, typechat, sendTime, unreadCount, istop, isshownick, currentUser, primary key(uid, currentUser))", [self tableName]]];
    int step = [stmt step];
	if (step != SQLITE_DONE) {
        [DBConnection alert];
    }
}

+ (id)getSessionWithID:(NSString*)sid {
    static Statement *stmt = nil;
    if (!stmt) {
        stmt = [DBConnection statementWithQueryString:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE uid = ? AND currentUser = ?", [self tableName]]];
    }
    
    int i = 1;
    [stmt bindString:sid forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
    
    int ret = [stmt step];
    Session * item = nil;
    if (ret == SQLITE_ROW) {
        item = [[Session alloc] initWithStatement:stmt];
    }
    [stmt reset];
	return item;
}

+ (NSArray*)getListFromDBWithIsTop {
    NSMutableArray * listSession = [NSMutableArray array];
    Statement * stmt = [DBConnection statementWithQueryString:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE currentUser = ? order by istop desc, sendTime desc", [self tableName]]];
    [stmt bindString:[BSEngine currentUserId] forIndex:1];
    int ret = [stmt step];
    
    while (ret == SQLITE_ROW) {
        Session * item = [[Session alloc] initWithStatement:stmt];
        if (item) {
            if (item) {
                [listSession addObject:item];
            }
        }
        ret = [stmt step];
    }
	return listSession;
}

+ (int)getLastTopSession {
    Statement * stmt = [DBConnection statementWithQueryString:[NSString stringWithFormat:@"SELECT max(istop) FROM %@ WHERE currentUser = ?", [self tableName]]];
    int i = 1;
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
    int step = [stmt step];
    int istop = 0;
    if (step == SQLITE_ROW) {
        int i = 0;
        istop = [stmt getInt32:i++];
    }
    return istop;
}

- (void)updateSessioninfo {
    static Statement *stmt = nil;
    if (!stmt) {
        stmt = [DBConnection statementWithQueryString:[NSString stringWithFormat:@"update %@ set unreadCount = ?, sendTime = ?, istop = ? WHERE uid = ? and currentUser = ?", [[self class] tableName]]];
    }

    int i = 1;
    [stmt bindInt32:self.unreadCount forIndex:i++];
    [stmt bindString:self.time forIndex:i++];
    [stmt bindInt32:(istop>0?(istop+1):0) forIndex:i++];
    [stmt bindString:self.uid forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
	int step = [stmt step];
    if (step != SQLITE_DONE) {
        [DBConnection alert];
    }
    [stmt reset];
}

- (id)initWithStatement:(Statement *)stmt {
	if (self = [super init]) {
        int i = 0;
        self.uid = [stmt getString:i++];
        self.name = [stmt getString:i++];
        self.content = [stmt getString:i++];
        self.headsmall = [stmt getString:i++];
        self.typechat = [stmt getInt32:i++];
        i++;//      sendtime
        self.unreadCount = [stmt getInt32:i++];
        self.istop = [stmt getInt32:i++];
        self.isshownick = [stmt getInt32:i++];
        self.message = [Message getLatestMessageWithID:uid];
	}
	return self;
}

- (void)resetUnread {
    self.unreadCount = 0;
    Statement *stmt = [DBConnection statementWithQueryString:[NSString stringWithFormat:@"UPDATE %@ SET unreadCount = 0 where uid = ? and currentUser = ?", [[self class] tableName]]];
    int i = 1;
    [stmt bindString:uid forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
    
	int step = [stmt step];
    if (step != SQLITE_DONE) {
        [DBConnection alert];
    }
    [Message resetAllUnReadWithID:self.uid];
}

- (void)insertDB {
    Statement *stmt = [DBConnection statementWithQueryString:[NSString stringWithFormat:@"REPLACE INTO %@ VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", [[self class] tableName]]];
    int i = 1;
    [stmt bindString:uid forIndex:i++];
    [stmt bindString:name forIndex:i++];
    [stmt bindString:content forIndex:i++];
    [stmt bindString:headsmall forIndex:i++];
    [stmt bindInt32:typechat forIndex:i++];
    [stmt bindString:self.time forIndex:i++];
    [stmt bindInt32:unreadCount	forIndex:i++];
    [stmt bindInt32:(istop>0?(istop+1):0)	forIndex:i++];
    [stmt bindInt32:isshownick?1:0	forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
    
	int step = [stmt step];
    if (step != SQLITE_DONE) {
        [DBConnection alert];
    }
}

- (void)deleteFromDB {
    [Message deleteWithID:uid];
    
    Statement * stmt = [DBConnection statementWithQueryString:[NSString stringWithFormat:@"delete from %@ where uid = ? and currentUser = ?",[[self class] tableName]]];
    int i = 1;
    [stmt bindString:uid forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
    
	int step = [stmt step];
    if (step != SQLITE_DONE) {
        [DBConnection alert];
    }
}

- (void)cleanMessage {
    self.content = @"";
    [self updateVaule:content key:@"content"];
    [Message deleteWithID:uid];
}

@end
