//
//  NSDictionaryAdditions.h
//  WeiboPad
//
//  Created by junmin liu on 10-10-6.
//  Copyright 2010 Openlab. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDictionary (Additions)

- (BOOL)getBoolValueForKey:(NSString *)key defaultValue:(BOOL)defaultValue;
- (int)getIntValueForKey:(NSString *)key defaultValue:(int)defaultValue;
- (float)getFloatValueForKey:(NSString*)key defaultValue:(float)defaultValue;
- (double)getDoubleValueForKey:(NSString*)key defaultValue:(double)defaultValue;
- (long long)getLongLongValueValueForKey:(NSString *)key defaultValue:(long long)defaultValue;
- (NSString *)getStringValueForKey:(NSString *)key defaultValue:(NSString *)defaultValue;

- (NSDictionary*)getDictionaryForKey:(NSString*)key;
- (NSArray*)getArrayForKey:(NSString*)key;
@end

@interface NSDictionary (CollationAdditions)
- (NSString*)getNameValue;
- (NSString*)getCodeValue;
@end