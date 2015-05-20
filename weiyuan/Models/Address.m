//
//  Address.m
//
//  AppDelegate.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "Address.h"
#import "DBConnection.h"
#import "BSEngine.h"
#import "JSON.h"

@implementation Address

@synthesize address, lat, lng;

- (void)updateWithJsonDic:(NSDictionary*)dic {
    [super updateWithJsonDic:dic];
    if (isInitSuccuss) {
        self.address = [dic getStringValueForKey:@"address" defaultValue:@""];
        self.lat = [dic getFloatValueForKey:@"lat" defaultValue:0.0];
        self.lng = [dic getFloatValueForKey:@"lng" defaultValue:0.0];
    }
}

- (NSString*)description {
    NSMutableDictionary * dic =[NSMutableDictionary dictionary];
    [dic setObject:self.address forKey:@"address"];
    [dic setObject:[NSString stringWithFormat:@"%f", self.lat] forKey:@"lat"];
    [dic setObject:[NSString stringWithFormat:@"%f", self.lng] forKey:@"lng"];
    return [dic JSONString];
}

- (Location)location {
    return kLocationMake(lat, lng);
}

- (void)setLocation:(Location)loc {
    lat = loc.lat;
    lng = loc.lng;
}

#pragma DB

+ (void)createTableIfNotExists
{
	Statement *stmt = [DBConnection statementWithQueryString:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (address, lat, lon, uuid, withid, currentUser, primary key(uuid, currentUser))", [self tableName]]];
    int step = [stmt step];
	if (step != SQLITE_DONE) {
        [DBConnection alert];
    }
}

+ (Address*)AddressWithUUID:(int)uuid {
    Address* result = nil;
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQueryString:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE uuid = ? and currentUser = ?", [self tableName]]];
    }
    
    int i = 1;
    [stmt bindInt32:uuid forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
    
    int ret = [stmt step];
    if (ret == SQLITE_ROW) {
        result = [[Address alloc] initWithStatement:stmt];
    }
    [stmt reset];
    
    return result;
}

+ (void)deleteWithUID:(NSString*)uid {
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQueryString:[NSString stringWithFormat:@"delete from %@ where withid = ? and currentUser = ?", [self tableName]]];
    }
    int i = 1;
    [stmt bindString:uid forIndex:i++];
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
        self.address = [stmt getString:i++];
        self.lat = [stmt getDouble:i++];
        self.lng = [stmt getDouble:i++];
	}
	return self;
}

- (void)insertDBWithUUID:(int)uuid withID:(NSString*)withID {
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQueryString:[NSString stringWithFormat:@"REPLACE INTO %@ VALUES(?, ?, ?, ?, ?, ?)", [[self class] tableName]]];
    }
    int i = 1;
    [stmt bindString:address forIndex:i++];
    [stmt bindDouble:lat forIndex:i++];
    [stmt bindDouble:lng forIndex:i++];
    [stmt bindInt32:uuid forIndex:i++];
    [stmt bindString:withID forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
    
	int step = [stmt step];
    if (step != SQLITE_DONE) {
        [DBConnection alert];
    }
    [stmt reset];
}

@end
