//
//  NSBaseObject.h
//  CarPool
//
//  Created by kiwi on 6/17/13.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "NSBaseObject.h"
#import <objc/runtime.h>
#import "DBConnection.h"
#import "BSEngine.h"
#import "Address.h"

@implementation NSBaseObject

+ (id)objWithJsonDic:(NSDictionary *)dic {
    return [[[self class] alloc] initWithJsonDic:dic];
}

- (id)initWithJsonDic:(NSDictionary*)dic {
    if (self = [super init]) {
        isInitSuccuss = NO;
        [self updateWithJsonDic:dic];
        if (!isInitSuccuss) {
            return nil;
        }
    }
    return self;
}

- (void)updateWithJsonDic:(NSDictionary *)dic {
    isInitSuccuss = NO;
    if (dic != nil && [dic isKindOfClass:[NSDictionary class]]) {
        isInitSuccuss = YES;
    }
    if (isInitSuccuss) {
        unsigned int propertyCount; //成员变量个数
        Ivar *vars = class_copyIvarList(self.class, &propertyCount);
        
        NSString *key=nil;
        for(int i = 0; i < propertyCount; i++) {

            Ivar thisIvar = vars[i];
            key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];  //获取成员变量的名字
            key = [key stringByReplacingOccurrencesOfString:@"_" withString:@""];
            id value = [dic objectForKey:key];
            
            // see Objective-C Runtime Programming Guide > Type Encodings.
            const char * ivarType = ivar_getTypeEncoding(thisIvar);
            if (strcmp(ivarType, "c") == 0 || strcmp(ivarType, "@\"NSString\"") == 0) {
                value = [dic getStringValueForKey:key defaultValue:@"0"];
                [self setValue:value forKey:key];
            } else if (strcmp(ivarType, "d") == 0){
                double va = [dic getDoubleValueForKey:key defaultValue:0.];
                [self setValue:[NSNumber numberWithDouble:va] forKey:key];
            } else if (strcmp(ivarType, "i") == 0){
                int va = [dic getIntValueForKey:key defaultValue:0];
                [self setValue:[NSNumber numberWithInt:va] forKey:key];
            } else if (strcmp(ivarType, "f") == 0){
                float va = [dic getFloatValueForKey:key defaultValue:0];
                [self setValue:[NSNumber numberWithFloat:va] forKey:key];
            } else if (strcmp(ivarType, "B") == 0){
                BOOL va = [dic getIntValueForKey:key defaultValue:0];
                [self setValue:[NSNumber numberWithBool:va] forKey:key];
            } else {
                
            }
        }

    }
}

#pragma mark - DB service
+ (void)createTableIfNotExists {
    NSMutableArray * arr = [NSMutableArray array];
    unsigned int propertyCount = 0;
    objc_property_t * propertyList = class_copyPropertyList([self class], &propertyCount);
    for (int i=0; i<propertyCount; i++) {
        objc_property_t *thisProperty = propertyList + i;
        NSString * key = [NSString stringWithUTF8String:property_getName(*thisProperty)];
        [arr addObject:key];
    }
    NSString * st = [NSString stringWithFormat:@"%@, currentUser",[arr componentsJoinedByString:@","]];
    
    Statement *stmt = [DBConnection statementWithQuery:[[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@, primary key(%@))", self.tableName, st, self.primaryKey] UTF8String]];
    int step = [stmt step];
	if (step != SQLITE_DONE) {
        [DBConnection alert];
    }
    free(propertyList);
}

+ (NSArray*)valueListFromDB {
    id result = nil;
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQuery:[[NSString stringWithFormat:@"SELECT * FROM %@ WHERE currentUser = ?", [[self class] tableName]] UTF8String]];
    }
    int i = 1;
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

+ (NSString*)tableName {
    return [NSString stringWithFormat:@"tb_%@", NSStringFromClass([self class])];
}

+ (NSString*)primaryKey {
    return @"currentUser";
}

- (void)updateVaule:(id)value key:(NSString*)key {
    Statement *stmt = [DBConnection statementWithQueryString:[NSString stringWithFormat:@"update %@ set %@ = ? WHERE uid = ? and currentUser = ?", [[self class] tableName], key]];
    int i = 1;
    if ([value isKindOfClass:[NSString class]]) {
        [stmt bindString:value forIndex:i++];
    } else {
        [stmt bindValue:value forIndex:i++];
    }
    [stmt bindString:self.uid forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
    
	int step = [stmt step];
    if (step != SQLITE_DONE) {
        [DBConnection alert];
    }
}

- (void)insertDB {
    NSMutableArray * arr = [NSMutableArray array];
    unsigned int propertyCount = 0;
    objc_property_t * propertyList = class_copyPropertyList([self class], &propertyCount);
    NSMutableString * str = [NSMutableString string];
    for (int i=0; i<propertyCount;i++) {
        objc_property_t *thisProperty = propertyList + i;
        NSString * key = [NSString stringWithUTF8String:property_getName(*thisProperty)];
        NSString * value = [self valueForKey:key];
        if (![value isKindOfClass:[NSBaseObject class]]) {
            [str appendString:@"?,"];
            [arr addObject:key];
        }
    }
    [str appendString:@"?"];
    Statement * stmt = [DBConnection statementWithQuery:[[NSString stringWithFormat:@"REPLACE INTO %@ VALUES(%@)", [[self class] tableName], str] UTF8String]];
    __block int i = 1;
    [arr enumerateObjectsUsingBlock:^(NSString * key, NSUInteger idx, BOOL *stop) {
        NSString * str = [self valueForKey:key];
        if ([str isKindOfClass:[NSNumber class]]) {
            NSNumber * it = (NSNumber*)str;
            [stmt bindValue:it forIndex:i++];
        } else if ([str isKindOfClass:[NSString class]]) {
            [stmt bindString:str forIndex:i++];
        }
    }];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
    
	int step = [stmt step];
    if (step != SQLITE_DONE) {
        [DBConnection alert];
    }
    free(propertyList);
}

+ (id)valuelistForKeyFromeDB:(NSString *)key keyname:(id)keyname {
    id result = nil;
    Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQueryString:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ like ? and currentUser = ?", [[self class] tableName], keyname]];
    }
    int i = 1;
    [stmt bindString:[NSString stringWithFormat:@"%%%@%%",key] forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
    NSMutableArray * list = [NSMutableArray array];
    int ret = [stmt step];
    if (ret == SQLITE_ROW) {
        result = [[[self class] alloc] initWithStatement:stmt];
        if (result) {
            [list insertObject:result atIndex:0];
        }
    }
    
    ret = [stmt step];
    return list;
}

+ (id)valueForKeyFromeDB:(NSString *)key keyname:(id)keyname {
    id result = nil;
    Statement * stmt = [DBConnection statementWithQuery:[[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = ? and currentUser = ?", [self tableName], keyname] UTF8String]];
    
    int i = 1;
    [stmt bindString:key forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
    
    int ret = [stmt step];
    if (ret == SQLITE_ROW) {
        result = [[[self class] alloc] initWithStatement:stmt];
    }
    
    return result;
}

- (void)deleteFromDB {
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQueryString:[NSString stringWithFormat:@"delete from %@ where uid = ? and currentUser = ?", [[self class] tableName]]];
    }
    int i = 1;
    [stmt bindString:self.uid forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
    
	int step = [stmt step];
    if (step != SQLITE_DONE) {
        [DBConnection alert];
    }
    [stmt reset];
}

- (NSString*)uid {
    return nil;
}

- (id)initWithStatement:(Statement *)stmt {
	if (self = [super init]) {
        unsigned int ivarsCnt = 0;
        Class cls = [self class];
        Ivar *ivars = class_copyIvarList(cls, &ivarsCnt);
        int i = 0;
        for (const Ivar *p = ivars; p < ivars + ivarsCnt; ++p) {
            Ivar const ivar = *p;
            NSString * key = [NSString stringWithUTF8String:ivar_getName(ivar)];
            id value = [stmt getString:i++];
            [self setValue:value forKey:key];
        }
	}
	return self;
}

@end
