//
//  Room.m
//
//  AppDelegate.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "Room.h"
#import "DBConnection.h"
#import "BSEngine.h"
#import "User.h"
#import "GTMBase64Coder.h"
#import "Message.h"

@implementation Room

- (id)value {
    return [self.head componentsSeparatedByString:@","];
}

- (void)updateWithJsonDic:(NSDictionary *)dic {
    isInitSuccuss = NO;
    if (dic != nil && [dic isKindOfClass:[NSDictionary class]]) {
        isInitSuccuss = YES;
    }
    if (isInitSuccuss) {
        _uid = [dic getStringValueForKey:@"id" defaultValue:nil];
        _name = [dic getStringValueForKey:@"name" defaultValue:nil];
        _isjoin = [dic getIntValueForKey:@"isjoin" defaultValue:0];
        _usercount = [dic getIntValueForKey:@"count" defaultValue:0];
        _creator = [dic getStringValueForKey:@"creator" defaultValue:nil];
        _createtime = [dic getStringValueForKey:@"createtime" defaultValue:nil];
        _role = [dic getStringValueForKey:@"role" defaultValue:nil];
        _mynickname = [dic getStringValueForKey:@"mynickname" defaultValue:nil];
        _getmsg = [dic getIntValueForKey:@"getmsg" defaultValue:0];
        _isOwer = ([[[BSEngine currentUser] uid] isEqualToString:[dic getStringValueForKey:@"uid" defaultValue:@""]]);
        // 群成员 如果有
        ;
        NSArray * array = [dic getArrayForKey:@"list"];
        NSMutableArray * useridArr = [NSMutableArray array];
        NSMutableArray * userheadArr = [NSMutableArray array];
        NSMutableArray * userNameArr = [NSMutableArray array];
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            User * user = [User objWithJsonDic:obj];
//            if (![User userWithID:user.uid]) {
//                [user insertDB];
//            }
            
            [useridArr addObject:user.uid];
            [userNameArr addObject:user.nickname];
            [userheadArr addObject:user.headsmall];
        }];
        _idUserList = [useridArr componentsJoinedByString:@","];
        _nameUserList = [userNameArr componentsJoinedByString:@","];
        self.head = [userheadArr componentsJoinedByString:@","];
    }
}


#pragma mark - DB
+ (void)createTableIfNotExists
{
    Statement *stmt = [DBConnection statementWithQueryString:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (uid, name, head, usercount, isjoin, creator, createtime, role, mynickname, getmsg, isOwer, idUserList, nameUserList, currentUser, primary key(uid, currentUser))", [self tableName]]];
    int step = [stmt step];
    if (step != SQLITE_DONE) {
        [DBConnection alert];
    }
}

- (id)initWithStatement:(Statement *)stmt {
	if (self = [super init]) {
        int i = 0;
        _uid = [stmt getString:i++];
        _name = [stmt getString:i++];
        _head = [stmt getString:i++];
        _usercount = [stmt getInt32:i++];
        _isjoin = [stmt getInt32:i++];
        _creator = [stmt getString:i++];
        _createtime = [stmt getString:i++];
        _role = [stmt getString:i++];
        _mynickname = [stmt getString:i++];
        _getmsg = [stmt getInt32:i++];
        _isOwer = [stmt getInt32:i++];
        _idUserList = [stmt getString:i++];
        _nameUserList = [stmt getString:i++];
    }
	return self;
}

- (void)insertDB {
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQuery:"REPLACE INTO tb_Room VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"];
    }
    int i = 1;
    [stmt bindString:_uid forIndex:i++];
    [stmt bindString:_name forIndex:i++];
    [stmt bindString:_head forIndex:i++];
    [stmt bindInt32:_usercount forIndex:i++];
    [stmt bindInt32:_isjoin?1:0 forIndex:i++];
    
    [stmt bindString:_creator forIndex:i++];
    [stmt bindString:_createtime forIndex:i++];
    [stmt bindString:_role forIndex:i++];
    [stmt bindString:_mynickname forIndex:i++];
    [stmt bindInt32:_getmsg?1:0 forIndex:i++];
    [stmt bindInt32:_isOwer?1:0 forIndex:i++];
    
    [stmt bindString:_idUserList forIndex:i++];
    [stmt bindString:_nameUserList forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
    
	int step = [stmt step];
    if (step != SQLITE_DONE) {
        [DBConnection alert];
    }
    [stmt reset];
}

+ (Room*)roomForUid:(NSString*)uid {
    Statement * stmt = [DBConnection statementWithQuery:"SELECT * FROM tb_Room where uid = ? and currentUser = ? "];
    int i = 1;
    [stmt bindString:uid forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
    Room * room = nil;
    int step = [stmt step];
    if (step == SQLITE_ROW) {
        room = [[Room alloc] initWithStatement:stmt];
    }
    return room;
}

- (void)updateUserList {
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQueryString:[NSString stringWithFormat:@"UPDATE %@ SET head = ?, idUserList = ?, nameUserList = ?, usercount = ? WHERE uid = ? AND currentUser = ?", [[self class] tableName]]];
    }
    int i = 1;
    [stmt bindString:_head forIndex:i++];
    [stmt bindString:_idUserList forIndex:i++];
    [stmt bindString:_nameUserList forIndex:i++];
    [stmt bindInt32:_usercount forIndex:i++];
    [stmt bindString:_uid forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];

	int step = [stmt step];
    if (step != SQLITE_DONE) {
        [DBConnection alert];
    }
    [stmt reset];
}

+ (void)kickOrAddUser:(User*)user toRoom:(NSString*)rid isAdd:(BOOL)isAdd {
    Room * it = [Room roomForUid:rid];
    [it addUser:user isAdd:isAdd];
}

- (void)addUser:(User*)user isAdd:(BOOL)isAdd {
    NSMutableArray * arrid = [NSMutableArray arrayWithArray:[self.idUserList componentsSeparatedByString:@","]];
    NSMutableArray * arrname = [NSMutableArray arrayWithArray:[self.nameUserList componentsSeparatedByString:@","]];
    NSMutableArray * arrhead = [NSMutableArray arrayWithArray:[self.head componentsSeparatedByString:@","]];
    if (isAdd) {
        [arrid addObject:user.uid];
        [arrname addObject:user.nickname];
        [arrhead addObject:user.headsmall];
        self.usercount ++;
    } else {
        [arrid removeObject:user.uid];
        [arrname removeObject:user.nickname];
        [arrhead removeObject:user.headsmall];
        self.usercount --;
    }
    self.idUserList = [arrid componentsJoinedByString:@","];
    self.nameUserList = [arrname componentsJoinedByString:@","];
    self.head = [arrhead componentsJoinedByString:@","];
    [self updateUserList];
}

- (NSInteger)userNickNameChanged:(NSString*)uid name:(NSString*)name {
    NSMutableArray * arrid = [NSMutableArray arrayWithArray:[self.idUserList componentsSeparatedByString:@","]];
    NSMutableArray * arrname = [NSMutableArray arrayWithArray:[self.nameUserList componentsSeparatedByString:@","]];
    __block NSInteger index = -1;
    [arrid enumerateObjectsUsingBlock:^(NSString *userid, NSUInteger idx, BOOL *stop) {
        if ([userid isEqualToString:uid]) {
            [arrname replaceObjectAtIndex:idx withObject:name];
            self.nameUserList = [arrname componentsJoinedByString:@","];
            index = idx;
            *stop = YES;
        }
    }];
    return index;
}

- (NSInteger)userIndex:(NSString*)uid {
    NSMutableArray * arrid = [NSMutableArray arrayWithArray:[self.idUserList componentsSeparatedByString:@","]];
    __block NSInteger index = -1;
    [arrid enumerateObjectsUsingBlock:^(NSString *userid, NSUInteger idx, BOOL *stop) {
        if ([userid isEqualToString:uid]) {
            index = idx;
            *stop = YES;
        }
    }];
    return index;
}
@end
