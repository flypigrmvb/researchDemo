//
//  Message.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "Message.h"
#import "DBConnection.h"
#import "BSEngine.h"
#import "Globals.h"
#import "JSON.h"
#import "EmotionInputView.h"
#import "Room.h"
#import "Session.h"
#import "Address.h"
#import "Meet.h"

@interface Message () {
    
    /** sqlite 自增 ID,只用作数据库查询 */
    NSInteger     rowID;
}

@end
@implementation Message

- (id)init {
    if (self = [super init]) {
        self.fromId = [[BSEngine currentUser] uid];
        self.sendTime = [Globals timeString];
        self.address = [[Address alloc] init];
        self.state = forMessageStateHavent;
        self.isSendByMe = YES;
        rowID = -1;
        self.imageSize = CGSizeZero;
        self.tag = [NSString GUIDString];
        _unRead = 0;
    }
    return self;
}

- (id)copy {
    Message * msg = [[Message alloc] init];
    msg.uid = 0;
    msg.fromId = [BSEngine currentUserId];
    msg.isSendByMe = YES;
    msg.state = forMessageStateHavent;
    msg.content = self.content;
    
    msg.typefile = self.typefile;
    msg.address = self.address;
    msg.imgUrlS = self.imgUrlS;
    msg.imgUrlL = self.imgUrlL;
    msg.imgWidth = self.imgWidth;
    msg.imgHeight = self.imgHeight;
    
    msg.voiceUrl = self.voiceUrl;
    msg.voiceTime = self.voiceTime;
    msg.tag = [NSString GUIDString];
    msg.sendTime = [Globals timeString];
    
    if (msg.typefile == forFileImage) {
        if (msg.imgUrlS) {
            NSMutableDictionary * dic = [NSMutableDictionary dictionary];
            [dic setObject:msg.imgUrlL forKey:@"urllarge"];
            [dic setObject:msg.imgUrlS forKey:@"urlsmall"];
            [dic setObject:[NSString stringWithFormat:@"%f", msg.imgWidth] forKey:@"width"];
            [dic setObject:[NSString stringWithFormat:@"%f", msg.imgHeight] forKey:@"height"];
            msg.value = [dic JSONString];
        } else {
            msg.value = self.value;
        }
        
    } else if (msg.typefile == forFileVoice) {
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        [dic setObject:msg.voiceUrl forKey:@"url"];
        [dic setObject:msg.voiceTime forKey:@"time"];
        msg.value = [dic JSONString];
    }
    return msg;
}

- (NSString*)contentDisplay {
    NSString * str = nil;
    if (_typefile == forFileImage) {
        str = @"[图片]";
    } else if (_typefile == forFileVoice) {
        str = @"[语音]";
    } else if (_typefile == forFileImage) {
        str = @"[位置]";
    } else if (_typefile == forFilefav) {
        str = @"[收藏]";
    } else if (_typefile == forFileNameCard) {
        str = @"[名片]";
    } else {
        str = _content;
    }
    return str;
}

- (NSString*)withID {
    NSString * withID = nil;
    if (self.typechat != forChatTypeUser) {
        withID = _toId;
    } else {
        if ([_fromId isEqualToString:[BSEngine currentUserId]]) {
            withID = _toId;
        } else {
            withID = _fromId;
        }
    }
    return withID;
}

- (NSInteger)rowID {
    return rowID;
}

- (void)setRowID:(NSInteger)rid {
    rowID = rid;
}

- (CGSize)imageSize {
    return CGSizeMake(_imgWidth, _imgHeight);
}

- (void)setImageSize:(CGSize)size {
    _imgHeight = size.height;
    _imgWidth = size.width;
}

- (void)updateWithJsonDic:(NSDictionary*)dic {
    isInitSuccuss = NO;
    if (dic != nil && [dic isKindOfClass:[NSDictionary class]]) {
        isInitSuccuss = YES;
    }
    if (isInitSuccuss) {
        self.tag = [dic getStringValueForKey:@"tag" defaultValue:@""];
        self.uid = [dic getStringValueForKey:@"id" defaultValue:@""];
        NSDictionary * from = [dic getDictionaryForKey:@"from"];
        self.fromId = [from getStringValueForKey:@"id" defaultValue:@""];
        self.displayName = [from getStringValueForKey:@"name" defaultValue:@""];
        self.displayName = [EmotionInputView decodeMessageEmoji:_displayName];
        self.displayImgUrl = [from getStringValueForKey:@"url" defaultValue:@""];
        
        NSDictionary * to = [dic getDictionaryForKey:@"to"];
        self.toId = [to getStringValueForKey:@"id" defaultValue:@""];
        self.toname = [to getStringValueForKey:@"name" defaultValue:@""];
        self.toname = [EmotionInputView decodeMessageEmoji:_toname];
        self.tohead = [to getStringValueForKey:@"url" defaultValue:@""];
        self.typefile = [dic getIntValueForKey:@"typefile" defaultValue:0];
        
        self.typechat = [dic getIntValueForKey:@"typechat" defaultValue:0];


        self.sendTime = [dic getStringValueForKey:@"time" defaultValue:@""];
        self.voiceTime = [dic getStringValueForKey:@"voiceTime" defaultValue:@""];
        self.content = [dic getStringValueForKey:@"content" defaultValue:@""];
        
        self.state = forMessageStateNormal;
        if (self.typefile == forFileAddress) {
            NSDictionary * loc = [dic getDictionaryForKey:@"location"];
            self.address = [Address objWithJsonDic:loc];
        } else if (self.typefile == forFileImage) {
            NSDictionary * uD = [dic getDictionaryForKey:@"image"];
            self.imgUrlS = [uD getStringValueForKey:@"urlsmall" defaultValue:@""];
            self.imgUrlL = [uD getStringValueForKey:@"urllarge" defaultValue:@""];
            self.imageSize = CGSizeMake([uD getDoubleValueForKey:@"width" defaultValue:0], [uD getDoubleValueForKey:@"height" defaultValue:0]);
        } else {
            NSDictionary * uD = [dic getDictionaryForKey:@"voice"];
            if (!uD || uD.count == 0) {
                uD = [dic getDictionaryForKey:@"image"];
            }
            self.voiceUrl = [uD getStringValueForKey:@"url" defaultValue:@""];
            self.voiceTime = [uD getStringValueForKey:@"time" defaultValue:@""];
        }
        if ([_fromId isEqualToString:[BSEngine currentUserId]]) {
            self.isSendByMe = YES;
        }
        self.content = [EmotionInputView decodeMessageEmoji:_content];
        self.unRead = NO;
    }
}

- (void)getToUserInfoWithSession:(Session*)obj {
    self.displayName = _toname = obj.name;
    self.displayImgUrl = _tohead = obj.headsmall;
}

#pragma DB

+ (void)createTableIfNotExists {
    Statement *stmt = [DBConnection statementWithQueryString:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (uid, fromId, withID, isSendByMe, state, content, toname, tohead, displayName, displayImgUrl, typefile, typechat, imgUrlS, imgUrlL, imgWidth, imgHeight, voiceUrl, voiceTime, sendTime, tag, errorCode, errorMessage, unread, currentUser, primary key(uid, fromId, currentUser))", [self tableName]]];
    int step = [stmt step];
	if (step != SQLITE_DONE) {
        [DBConnection alert];
    }
}

+ (void)updatePersonNameInRoomMessageWithID:(NSString*)withID withName:(NSString*)name roomId:(NSString*)rid {
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQueryString:[NSString stringWithFormat:@"UPDATE %@ SET displayName = ? WHERE fromId = ? AND withID = ? AND currentUser = ?", [[self class] tableName]]];
    }
    int i = 1;
    [stmt bindString:name forIndex:i++];
    [stmt bindString:withID forIndex:i++];
    [stmt bindString:rid forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
	int step = [stmt step];
    if (step != SQLITE_DONE) {
        [DBConnection alert];
    }
    [stmt reset];
}

+ (int)getUnreadMessageCountWithID:(NSString*)wID {
    int unread = 0;
    Statement * stmt = [DBConnection statementWithQueryString:[NSString stringWithFormat:@"SELECT count(unread) FROM %@ WHERE withID = ? AND currentUser = ? AND unread = 1", [[self class] tableName]]];
    int i = 1;
    [stmt bindString:wID forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
    
	int step = [stmt step];
    if (step == SQLITE_ROW) {
        unread = [stmt getInt32:0];
    }
    return unread;
}

+ (void)resetAllUnReadWithID:(NSString*)wID {
    Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQueryString:[NSString stringWithFormat:@"UPDATE %@ SET unread = 0 WHERE withID = ? AND currentUser = ?", [[self class] tableName]]];
    }
    int i = 1;
    [stmt bindString:wID forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
    
	int step = [stmt step];
    if (step != SQLITE_DONE) {
        [DBConnection alert];
    }
    [stmt reset];
}

- (void)updateId {
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQueryString:[NSString stringWithFormat:@"UPDATE %@ SET uid = ?, state = ?, imgUrlS = ?, imgUrlL = ? WHERE rowid = ? AND currentUser = ?", [[self class] tableName]]];
    }
    int i = 1;
    [stmt bindString:_uid forIndex:i++];
    [stmt bindInt32:_state forIndex:i++];
    [stmt bindString:_imgUrlS forIndex:i++];
    [stmt bindString:_imgUrlL forIndex:i++];
    [stmt bindInt32:(int)rowID forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
    if (_typefile == forFileAddress) {
        [_address insertDBWithUUID:_uid.intValue withID:[self withID]];
    }
	int step = [stmt step];
    if (step != SQLITE_DONE) {
        [DBConnection alert];
    }
    [stmt reset];
}

- (void)updateReadState:(BOOL)isread {
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQueryString:[NSString stringWithFormat:@"UPDATE %@ SET unread = ? WHERE rowid = ? AND currentUser = ?", [[self class] tableName]]];
    }
    int i = 1;
    [stmt bindInt32:!isread forIndex:i++];
    [stmt bindInt32:(int)rowID forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];

	int step = [stmt step];
    if (step != SQLITE_DONE) {
        [DBConnection alert];
    }
    [stmt reset];
}

- (id)ifExistInDB {
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQueryString:[NSString stringWithFormat:@"SELECT rowid,* FROM %@ WHERE rowid = ? AND currentUser = ?", [[self class] tableName]]];
    }
    int i = 1;
    [stmt bindInt32:(int)rowID forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
	int step = [stmt step];
    id res = nil;
    if (step == SQLITE_ROW) {
        res = [[Message alloc] initWithStatement:stmt];
    }
    [stmt reset];
    return res;
}

- (void)insertDB {
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQueryString:[NSString stringWithFormat:@"REPLACE INTO %@ VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", [[self class] tableName]]];
    }
    int i = 1;
//   imgUrlL, imgWidth, imgHeight, voiceUrl, voiceTime, sendTime, tag, errorCode, errorMessage, currentUser, primary key(uid, fromId, currentUser
    [stmt bindString:_uid forIndex:i++];
    [stmt bindString:_fromId forIndex:i++];
    [stmt bindString:self.withID forIndex:i++];
    [stmt bindInt32:_isSendByMe?1:0 forIndex:i++];
    [stmt bindInt32:_state forIndex:i++];
    
    [stmt bindString:_content forIndex:i++];
    [stmt bindString:_toname forIndex:i++];
    [stmt bindString:_tohead forIndex:i++];
    [stmt bindString:_displayName forIndex:i++];
    [stmt bindString:_displayImgUrl forIndex:i++];
    
    [stmt bindInt32:_typefile forIndex:i++];
    [stmt bindInt32:_typechat forIndex:i++];
    [stmt bindString:_imgUrlS forIndex:i++];
    [stmt bindString:_imgUrlL forIndex:i++];
    [stmt bindDouble:_imgWidth forIndex:i++];
    
    [stmt bindDouble:_imgHeight forIndex:i++];
    [stmt bindString:_voiceUrl forIndex:i++];
    [stmt bindString:_voiceTime forIndex:i++];
    [stmt bindString:_sendTime forIndex:i++];
    [stmt bindString:_tag forIndex:i++];
    
    [stmt bindInt32:_errorCode forIndex:i++];
    [stmt bindString:_errorMessage forIndex:i++];
    [stmt bindInt32:_unRead forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
    
    if (self.typefile == forFileAddress) {
        [_address insertDBWithUUID:_uid.intValue withID:self.withID];
    }
	int step = [stmt step];
    if (step != SQLITE_DONE) {
        [DBConnection alert];
    }
    rowID = [self getRowId];
    [stmt reset];
}

- (int)getRowId {
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQueryString:[NSString stringWithFormat:@"SELECT rowid from %@ WHERE sendTime = ? AND withID = ? AND currentUser = ?", [[self class] tableName]]];
    }
    int i = 1;
    [stmt bindString:_sendTime forIndex:i++];
    [stmt bindString:self.withID forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
	int step = [stmt step];
    int rid = -1;
    if (step == SQLITE_ROW) {
        rid = [stmt getInt32:0];
    }
    [stmt reset];
    return rid;
}

- (id)initWithStatement:(Statement *)stmt {
	if (self = [super init]) {
        int i = 0;
        //uid, fromId, withID, isSendByMe, state, content, toname, tohead, displayName, displayImgUrl, typefile, typechat, imgUrlS, imgUrlL, imgWidth, imgHeight, voiceUrl, voiceTime, sendTime, tag, errorCode, errorMessage, currentUser, primary key(uid, fromId, currentUser
        rowID = [stmt getInt32:i++];
        _uid = [stmt getString:i++];
        _fromId = [stmt getString:i++];
        _toId = [stmt getString:i++];
//        _withID = [stmt getString:i++];
        _isSendByMe = [stmt getInt32:i++];
        _state = [stmt getInt32:i++];
        _content = [stmt getString:i++];
        _toname = [stmt getString:i++];
        _tohead = [stmt getString:i++];
        _displayName = [stmt getString:i++];
        _displayImgUrl = [stmt getString:i++];
        _typefile = [stmt getInt32:i++];
        _typechat = [stmt getInt32:i++];
        _imgUrlS = [stmt getString:i++];
        _imgUrlL = [stmt getString:i++];
        _imgWidth = [stmt getDouble:i++];
        _imgHeight = [stmt getDouble:i++];
        
        _voiceUrl = [stmt getString:i++];
        _voiceTime = [stmt getString:i++];
        _sendTime = [stmt getString:i++];
        _tag = [stmt getString:i++];
        _errorCode = [stmt getInt32:i++];
        _errorMessage = [stmt getString:i++];
        _unRead = [stmt getInt32:i++];
        
        if (self.typefile == forFileAddress) {
            self.address = [Address AddressWithUUID:_uid.intValue];
        }
        if (_typechat != forChatTypeUser) {
            self.toId = self.withID;
        } else {
            if ([_fromId isEqualToString:[BSEngine currentUserId]]) {
                self.toId = self.withID;
            } else {
                self.toId = [BSEngine currentUserId];
            }
        }
    }
    
	return self;
}

+ (id)valuelistForKeyFromeDB:(NSString *)key keyname:(id)keyname {
    Message* result = nil;
    Statement *stmt = [DBConnection statementWithQueryString:[NSString stringWithFormat:@"SELECT rowid,* FROM %@ WHERE %@ like ? and currentUser = ? and typefile = 1 order by rowid desc limit 0,?", [[self class] tableName], keyname]];
    int i = 1;
    [stmt bindString:[NSString stringWithFormat:@"%%%@%%",key] forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
    [stmt bindInt32:defaultSizeInt forIndex:i++];
    
    NSMutableArray * list = [NSMutableArray array];
    int ret = [stmt step];
    while (ret == SQLITE_ROW) {
        result = [[Message alloc] initWithStatement:stmt];
        if (result) {
            [list insertObject:result atIndex:0];
        }
        ret = [stmt step];
    }
    
    return list;
}


+ (NSArray*)getListFromDBWithID:(NSString*)wID sinceRowID:(NSInteger)rID {
    if (rID < 0) {
        return [self getListFromDBSinceNowWithID:wID];
    }
    NSMutableArray* list = [NSMutableArray array];
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQueryString:[NSString stringWithFormat:@"SELECT rowid,* FROM %@ WHERE withID = ? and rowid < ? and currentUser = ? order by rowid desc limit 0,?", [self tableName]]];
    }
    
    int i = 1;
    [stmt bindString:wID forIndex:i++];
    [stmt bindInt32:(int)rID forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
    [stmt bindInt32:defaultSizeInt forIndex:i++];
    
    int ret = [stmt step];
    
    while (ret == SQLITE_ROW) {
        Message* item = [[Message alloc] initWithStatement:stmt];
        if (item) {
            [list insertObject:item atIndex:0];
        }
        ret = [stmt step];
    }
    
    [stmt reset];
	return list;
}

+ (NSArray*)getListFromDBSinceNowWithID:(NSString *)wID {
    NSMutableArray* list = [NSMutableArray array];
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQueryString:[NSString stringWithFormat:@"SELECT rowid,* FROM %@ WHERE withID = ? and currentUser = ? order by rowid desc limit 0,?", [self tableName]]];
    }
    
    int i = 1;
    [stmt bindString:wID forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
    [stmt bindInt32:defaultSizeInt forIndex:i++];
    
    int ret = [stmt step];
    
    while (ret == SQLITE_ROW) {
        Message * item = [[Message alloc] initWithStatement:stmt];
        if (item) {
            [list insertObject:item atIndex:0];
        }
        
        ret = [stmt step];
    }
    
    [stmt reset];
	return list;
}

+ (Message*)getLatestMessageWithID:(NSString*)wID {
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQueryString:[NSString stringWithFormat:@"SELECT rowid,* FROM %@ WHERE withID = ? and currentUser = ? order by rowid desc limit 0,1", [self tableName]]];
    }
    
    int i = 1;
    [stmt bindString:wID forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
    
    int ret = [stmt step];
    
    Message* item = nil;
    if (ret == SQLITE_ROW) {
        item = [[Message alloc] initWithStatement:stmt];
    }
    [stmt reset];
    
	return item;
}

+ (void)deleteWithSendTime:(NSString *)sendTime {
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQueryString:[NSString stringWithFormat:@"delete from %@ where sendTime = ? and currentUser = ?", [self tableName]]];
        
    }
    int i = 1;
    [stmt bindString:sendTime forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
    
	int step = [stmt step];
    if (step != SQLITE_DONE) {
        [DBConnection alert];
    }
    [stmt reset];
}

+ (void)deleteWithID:(NSString *)wID {
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQueryString:[NSString stringWithFormat:@"delete from %@ where withID = ? and currentUser = ?", [self tableName]]];
        
    }
    int i = 1;
    [stmt bindString:wID forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
    
	int step = [stmt step];
    if (step != SQLITE_DONE) {
        [DBConnection alert];
    }
    [stmt reset];
    
    [Address deleteWithUID:wID];
}

- (BOOL)hasOtherImage {
    return (self.typefile == forFileImage || self.typefile == forFileAddress);
}

@end
