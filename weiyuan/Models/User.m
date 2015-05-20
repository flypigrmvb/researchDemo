//
//  User.h
//
//  AppDelegate.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "User.h"
#import "BSEngine.h"
#import "DBConnection.h"
#import "EmotionInputView.h"
#import <objc/runtime.h>
#import "Globals.h"

#define UserStorageMaxCount 3
static NSMutableArray* uidArrStorage;
static NSMutableDictionary* userDicStorage;

@implementation User

// 增加星标朋友
+ (NSMutableArray *)sortData:(NSArray*)tempArray hasHeader:(NSArray*)hasHeader
{
    // Sort data
    NSMutableArray * star = [NSMutableArray array];
    [tempArray enumerateObjectsUsingBlock:^(User * user, NSUInteger idx, BOOL *stop) {
        if (user.isstar) {
            [star addObject:user];
        }
    }];
    for (User *user in tempArray) {
        if (user.sort.length == 0) {
            user.sort = @"26";
        } else {
        }
    }
    //    NSInteger sectionTitlesCount = [[theCollation sectionTitles] count]; //返回的应该是27，是a－z,...
    NSMutableArray *newSectionsArray = [NSMutableArray array];
    
    // 27个索引 a－z,... 再加个＃号
	for (int index = 0; index < 27; index++) {
		[newSectionsArray addObject:[NSMutableArray array]];
	}
    
	for (User *user in tempArray) {
        //获得section的数组
		NSMutableArray *sectionArr = [newSectionsArray objectAtIndex:user.sort.intValue];
        //添加到section中
		[sectionArr addObject:user];
	}
    
    if (hasHeader) {
        [newSectionsArray insertObject:star atIndex:0];
    }
    if (hasHeader && hasHeader.count>0) {
        [newSectionsArray insertObject:hasHeader atIndex:0];
    }
    return newSectionsArray;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        unsigned int propertyCount = 0;
        objc_property_t * propertyList = class_copyPropertyList([self class], &propertyCount);
        for (int i=0; i<propertyCount; i++) {
            objc_property_t * thisProperty = propertyList + i;
            const char * propertyName = property_getName(*thisProperty);
            NSString * key = [NSString stringWithUTF8String:propertyName];
            id value = [aDecoder decodeObjectForKey:key];
            if (value) {
                [self setValue:value forKey:key];
            }
        }
        free(propertyList);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    unsigned int propertyCount = 0;
    objc_property_t * propertyList = class_copyPropertyList([self class], &propertyCount);
    for (int i=0; i<propertyCount; i++) {
        objc_property_t *thisProperty = propertyList + i;
        const char* propertyName = property_getName(*thisProperty);
        NSString * key = [NSString stringWithUTF8String:propertyName];
        id value = [self valueForKey:key];
        [aCoder encodeObject:value forKey:key];
    }
    free(propertyList);
}

- (void)updateWithJsonDic:(NSDictionary *)dic {
    isInitSuccuss = NO;
    if (dic != nil && [dic isKindOfClass:[NSDictionary class]]) {
        isInitSuccuss = YES;
    }
    if (isInitSuccuss) {
        _uid = [dic getStringValueForKey:@"uid" defaultValue:nil];
        _phone = [dic getStringValueForKey:@"phone" defaultValue:nil];
        _password = [dic getStringValueForKey:@"password" defaultValue:nil];
        _nickname = [dic getStringValueForKey:@"nickname" defaultValue:nil];
        _remark = [dic getStringValueForKey:@"remark" defaultValue:nil];
        _headsmall = [dic getStringValueForKey:@"headsmall" defaultValue:nil];
        _headlarge = [dic getStringValueForKey:@"headlarge" defaultValue:nil];
        _sign = [dic getStringValueForKey:@"sign" defaultValue:nil];
        _gender = [dic getStringValueForKey:@"gender" defaultValue:nil];
        _province = [dic getStringValueForKey:@"province" defaultValue:nil];
        _city = [dic getStringValueForKey:@"city" defaultValue:nil];
        _getmsg = [dic getIntValueForKey:@"getmsg" defaultValue:0];
        _isstar = [dic getIntValueForKey:@"isstar" defaultValue:0];
        _isfriend = [dic getIntValueForKey:@"isfriend" defaultValue:0];
        _verify = [dic getIntValueForKey:@"verify" defaultValue:0];
        _sort = [dic getStringValueForKey:@"sort" defaultValue:nil];
        _isblack = [dic getIntValueForKey:@"isblack" defaultValue:0];
        _waitforadd = [dic getIntValueForKey:@"waitforadd" defaultValue:0];
        _type = [dic getIntValueForKey:@"type" defaultValue:0];
        _fauth1 = [dic getIntValueForKey:@"fauth1" defaultValue:0];
        _fauth2 = [dic getIntValueForKey:@"fauth2" defaultValue:0];
        _cover = [dic getStringValueForKey:@"cover" defaultValue:nil];
        _picture1 = [dic getStringValueForKey:@"picture1" defaultValue:nil];
        _picture2 = [dic getStringValueForKey:@"picture2" defaultValue:nil];
        _picture3 = [dic getStringValueForKey:@"picture3" defaultValue:nil];
        
        UILocalizedIndexedCollation * theCollation = [UILocalizedIndexedCollation currentCollation];
        NSInteger sect = [theCollation sectionForObject:self
                      collationStringSelector:@selector(displayName)];
        _sort = [NSString stringWithFormat:@"%d", (int)sect];
        
    }
    _nickname = [EmotionInputView decodeMessageEmoji:_nickname];
//    if (_sort.length == 0) {
//        self.sort = @"27";
//    } else {
//        self.sort = [NSString stringWithFormat:@"%d", [LETTERS rangeOfString:_sort].location + 1];
//    }
}

- (NSMutableDictionary*)descriptionDictionary {
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    [dic setValue:_nickname forKey:@"nickname"];
    [dic setValue:_gender forKey:@"gender"];
    [dic setValue:_sign forKey:@"sign"];
    [dic setValue:_province forKey:@"province"];
    [dic setValue:_city forKey:@"city"];
    return dic;
}

/**标准情况下, 只要姓名存在即可以登录*/
- (BOOL)canLogin {
    return self.nickname.length>0;
}

/**新的朋友：状态 0 未添加 1*/
- (void)contactType {
    
}

/**显示的名字，有备注名优先显示备注名*/
- (NSString*)displayName {
    if (self.remark && self.remark.length > 0) {
        return _remark;
    } else {
        return _nickname;
    }
}

#pragma DB

#pragma mark - DB
+ (void)createTableIfNotExists
{
    Statement *stmt = [DBConnection statementWithQueryString:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (uid, phone, password, nickname, remark, headsmall, headlarge, sign, gender, province, city, getmsg, isstar, isfriend, verify, sort, isblack, waitforadd, type, fauth1, fauth2, cover, picture1, picture2, picture3, currentUser, primary key(uid, currentUser))", [self tableName]]];
    int step = [stmt step];
    if (step != SQLITE_DONE) {
        [DBConnection alert];
    }
}

- (id)initWithStatement:(Statement *)stmt {
	if (self = [super init]) {
        int i = 0;
        _uid = [stmt getString:i++];
        _phone = [stmt getString:i++];
        _password = [stmt getString:i++];
        _nickname = [stmt getString:i++];
        _remark = [stmt getString:i++];
        _headsmall = [stmt getString:i++];
        _headlarge = [stmt getString:i++];
        _sign = [stmt getString:i++];
        _gender = [stmt getString:i++];
        _province = [stmt getString:i++];
        _city = [stmt getString:i++];
        _getmsg = [stmt getInt32:i++];
        _isstar = [stmt getInt32:i++];
        _isfriend = [stmt getInt32:i++];
        _verify = [stmt getInt32:i++];
        _sort = [stmt getString:i++];
        _isblack = [stmt getInt32:i++];
        _waitforadd = [stmt getInt32:i++];
        _type = [stmt getInt32:i++];
        _fauth1 = [stmt getInt32:i++];
        _fauth2 = [stmt getInt32:i++];
        _cover = [stmt getString:i++];
        _picture1 = [stmt getString:i++];
        _picture2 = [stmt getString:i++];
        _picture3 = [stmt getString:i++];
    }
	return self;
}

- (void)insertDB {
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQuery:"REPLACE INTO tb_User VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"];
    }
    int i = 1;
    //uid, phone, password, nickname, remark, headsmall, headlarge, sign, gender, province, city, getmsg, isstar, isfriend, verify, sort, isblack, waitforadd, type, fauth1, fauth2, cover, picture1, picture2, picture3
    [stmt bindString:_uid forIndex:i++];
    [stmt bindString:_phone forIndex:i++];
    [stmt bindString:_password forIndex:i++];
    [stmt bindString:_nickname forIndex:i++];
    [stmt bindString:_remark forIndex:i++];
    [stmt bindString:_headsmall forIndex:i++];
    [stmt bindString:_headlarge forIndex:i++];
    [stmt bindString:_sign forIndex:i++];
    [stmt bindString:_gender forIndex:i++];
    [stmt bindString:_province forIndex:i++];
    [stmt bindString:_city forIndex:i++];
    [stmt bindInt32:_getmsg forIndex:i++];
    [stmt bindInt32:_isstar forIndex:i++];
    [stmt bindInt32:_isfriend forIndex:i++];
    [stmt bindInt32:_verify forIndex:i++];
    [stmt bindString:_sort forIndex:i++];
    [stmt bindInt32:_isblack forIndex:i++];
    [stmt bindInt32:_waitforadd forIndex:i++];
    [stmt bindInt32:_type forIndex:i++];
    [stmt bindInt32:_fauth1 forIndex:i++];
    [stmt bindInt32:_fauth2 forIndex:i++];
    [stmt bindString:_cover forIndex:i++];
    [stmt bindString:_picture1 forIndex:i++];
    [stmt bindString:_picture2 forIndex:i++];
    [stmt bindString:_picture3 forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
    
	int step = [stmt step];
    if (step != SQLITE_DONE) {
        [DBConnection alert];
    }
    [stmt reset];
}

+ (void)initUserStorage {
    if (uidArrStorage) {
        uidArrStorage = nil;
    }
    uidArrStorage = [[NSMutableArray alloc] init];
    
    if (userDicStorage) {
        userDicStorage = nil;
    }
    userDicStorage = [[NSMutableDictionary alloc] init];
}

+ (User*)userWithID:(NSString *)uid {
    if ([[BSEngine currentUserId] isEqualToString:uid]) {
        return [BSEngine currentEngine].user;
    }
    NSUInteger index = [uidArrStorage indexOfObject:uid];
    if (index == NSNotFound) {
        User* result = nil;
        static Statement *stmt = nil;
        if (stmt == nil) {
            stmt = [DBConnection statementWithQueryString:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE uid = ? and currentUser = ?", [self tableName]]];
        }
        
        int i = 1;
        [stmt bindString:uid forIndex:i++];
        [stmt bindString:[BSEngine currentUserId] forIndex:i++];
        
        int ret = [stmt step];
        if (ret == SQLITE_ROW) {
            result = [[User alloc] initWithStatement:stmt];
        }
        [stmt reset];
        if (result) {
            if (uidArrStorage.count >= UserStorageMaxCount) {
                NSString* tmpUid = [uidArrStorage lastObject];
                [userDicStorage removeObjectForKey:tmpUid];
                [uidArrStorage removeLastObject];
            }
            [userDicStorage setObject:result forKey:uid];
            [uidArrStorage insertObject:uid atIndex:0];
        }
        return result;
    } else {
        [uidArrStorage removeObjectAtIndex:index];
        [uidArrStorage insertObject:uid atIndex:0];
        return [userDicStorage objectForKey:uid];
    }
}

+ (User*)userWithPhone:(NSString *)phone {
    User* result = nil;
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQuery:[[NSString stringWithFormat:@"SELECT * FROM %@ WHERE phone = ? and currentUser = ?", [self tableName]] UTF8String]];
    }
    
    int i = 1;
    [stmt bindString:phone forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
    
    int ret = [stmt step];
    if (ret == SQLITE_ROW) {
        result = [[User alloc] initWithStatement:stmt];
    }
    [stmt reset];
    
    return result;
}

+ (id)valueWaitForAddlistFromeDB {
    id result = nil;
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQuery:[[NSString stringWithFormat:@"SELECT * FROM %@ WHERE waitforadd = ? and currentUser = ?", [self tableName]] UTF8String]];
    }
    
    int i = 1;
    [stmt bindString:@"1" forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
    NSMutableArray * list = [NSMutableArray array];
    int ret = [stmt step];
    
    while (ret == SQLITE_ROW) {
        result = [[[self class] alloc] initWithStatement:stmt];
        if (result) {
            [list insertObject:result atIndex:0];
        }
        ret = [stmt step];
    }
    [stmt reset];
    
    return list;
}

+ (id)valuelistForKeyFromeDB:(NSString *)key keyname:(id)keyname {
    id result = nil;
    Statement * stmt = [DBConnection statementWithQueryString:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ like ? and currentUser = ? and isblack = 0", [[self class] tableName], keyname]];
    
    int i = 1;
    
    [stmt bindString:[NSString stringWithFormat:@"%%%@%%",key] forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
    NSMutableArray * list = [NSMutableArray array];
    int ret = [stmt step];
    while (ret == SQLITE_ROW) {
        result = [[[self class] alloc] initWithStatement:stmt];
        if (result) {
            [list insertObject:result atIndex:0];
        }
        ret = [stmt step];
    }
    
    return list;
}

+ (id)friendlistFromeDB {
    id result = nil;
    static Statement * stmt;
    if (!stmt) {
        stmt = [DBConnection statementWithQueryString:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE isfriend = 1 and currentUser = ? ", [[self class] tableName]]];
    }
    [stmt bindString:[BSEngine currentUserId] forIndex:1];
    NSMutableArray * list = [NSMutableArray array];
    int ret = [stmt step];
    while (ret == SQLITE_ROW) {
        result = [[[self class] alloc] initWithStatement:stmt];
        if (result) {
            [list insertObject:result atIndex:0];
        }
        ret = [stmt step];
    }
    [stmt reset];
    return list;
}


#pragma mark - user Config

- (NSString*)readConfigWithKey:(NSString*)key
{
    NSString * plistPath = [NSString stringWithFormat:@"%@/Library/Cache/Images/config.plist",NSHomeDirectory()];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSDictionary *config = [dictionary objectForKey:self.uid];
    if (config && config.count > 0) {
        return [config getStringValueForKey:key defaultValue:nil];
    }
    return nil;
}

- (id)readValueWithKey:(NSString*)key
{
    NSString * plistPath = [NSString stringWithFormat:@"%@/Library/Cache/Images/config.plist",NSHomeDirectory()];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSDictionary *config = [dictionary objectForKey:self.uid];
    return [config objectForKey:key];
}

- (void)saveConfigWhithKey:(NSString*)key value:(id)value
{
    if (key && value) {
        NSString * plistPath = [NSString stringWithFormat:@"%@/Library/Cache/Images/config.plist",NSHomeDirectory()];
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        NSMutableDictionary *dic = [dictionary objectForKey:self.uid];
        if (!dictionary) {
            dictionary = [NSMutableDictionary dictionary];
        }
        if (!dic) {
            dic = [NSMutableDictionary dictionary];
        }
        [dic setObject:value forKey:key];
        [dictionary setObject:dic forKey:self.uid];
        [dictionary writeToFile:plistPath atomically:YES];
    }
}

- (void)checkConfig
{
    NSString *isVerify = [self readConfigWithKey:@"isVerify"];
    if (!isVerify) {
        [self saveConfigWhithKey:@"isVerify" value:@"1"]; // 默认加我为朋友时需要验证
    }
    NSString *isNoticedNewFriend = [self readConfigWithKey:@"isNoticedNewFriend"];
    if (!isNoticedNewFriend) {
        [self saveConfigWhithKey:@"isNoticedNewFriend" value:@"1"]; // 默认自动推荐通讯录朋友
    }
    NSString *canreceiveNewMessage = [self readConfigWithKey:@"canreceiveNewMessage"];
    if (!canreceiveNewMessage) {
        [self saveConfigWhithKey:@"canreceiveNewMessage" value:@"1"]; // 默认接受消息推送
    }
    NSString *newNotifyCount = [self readConfigWithKey:@"newNotifyCount"];
    if (!newNotifyCount) {
        [self saveConfigWhithKey:@"newNotifyCount" value:@"0"]; // 默认重置新消息数量
    }
    NSString *canplayVoice = [self readConfigWithKey:@"canplayVoice"];
    if (!canplayVoice) {
        [self saveConfigWhithKey:@"canplayVoice" value:@"1"]; // 默认播放声音
    }
    NSString *canplayShake = [self readConfigWithKey:@"canplayShake"];
    if (!canplayShake) {
        [self saveConfigWhithKey:@"canplayShake" value:@"0"]; // 默认不震动
    }
    NSString *friendsCircle = [self readConfigWithKey:@"FriendsCircle"];
    if (!friendsCircle) {
        [self saveConfigWhithKey:@"FriendsCircle" value:@"0"]; // 默认发现不需要红点
    }
    // 默认加我为朋友时需要验证
    [self saveConfigWhithKey:@"isVerify" value:[NSString stringWithFormat:@"%d", self.verify]];
}

@end
