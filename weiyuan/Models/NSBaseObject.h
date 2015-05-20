//
//  NSBaseObject.h
//  CarPool
//
//  Created by kiwi on 6/17/13.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionaryAdditions.h"
#import "DBConnection.h"

@interface NSBaseObject : NSObject {
    BOOL isInitSuccuss;
}

@property (nonatomic, strong) id  value;
+ (id)objWithJsonDic:(NSDictionary*)dic;
- (id)initWithJsonDic:(NSDictionary*)dic;
- (void)updateWithJsonDic:(NSDictionary*)dic;

/** 创建为该类服务的数据表 */
+ (void)createTableIfNotExists;
+ (NSArray*)valueListFromDB;
+ (id)valuelistForKeyFromeDB:(NSString *)key keyname:(id)keyname;
+ (NSString*)primaryKey;
- (void)updateVaule:(id)value key:(NSString*)key;

+ (NSString*)tableName;
- (void)insertDB;
- (void)deleteFromDB;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	根据字段名字和字段值 查询 NSBaseObject
 *
 *	@param 	key 	字段值
 *	@param 	keyname 	字段名字
 *
 *	@return	返回查询的结果
 */
+ (id)valueForKeyFromeDB:(NSString *)key keyname:(id)keyname;

- (id)initWithStatement:(Statement *)stmt;
@end
