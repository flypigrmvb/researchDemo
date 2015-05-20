//
//  NSDictionaryAdditions.m
//  WeiboPad
//
//  Created by junmin liu on 10-10-6.
//  Copyright 2010 Openlab. All rights reserved.
//

#import "NSDictionaryAdditions.h"


@implementation NSDictionary (Additions)

- (BOOL)getBoolValueForKey:(NSString *)key defaultValue:(BOOL)defaultValue {
    id tmpValue = [self objectForKey:key];
    
    if (tmpValue == nil || tmpValue == [NSNull null]) {
        return defaultValue;
    }
    
    if ([tmpValue isKindOfClass:[NSNumber class]]) {
        return [tmpValue boolValue];
    } else {
        @try {
            return [tmpValue boolValue];
        }
        @catch (NSException *exception) {
            DLog(@"getBoolValueForKey : %@",key);
            DLog(@"tmpValue : %@",tmpValue);
            return defaultValue;
        }
    }
}

- (int)getIntValueForKey:(NSString *)key defaultValue:(int)defaultValue {
    id tmpValue = [self objectForKey:key];
    
    if (tmpValue == nil || tmpValue == [NSNull null]) {
        return defaultValue;
    }
    
    if ([tmpValue isKindOfClass:[NSNumber class]]) {
        return [tmpValue intValue];
    } else {
        @try {
            return [tmpValue intValue];
        }
        @catch (NSException *exception) {
            DLog(@"getIntValueForKey : %@",key);
            DLog(@"tmpValue : %@",tmpValue);
            return defaultValue;
        }
    }
}

- (float)getFloatValueForKey:(NSString *)key defaultValue:(float)defaultValue {
    id tmpValue = [self objectForKey:key];
    
    if (tmpValue == nil || tmpValue == [NSNull null]) {
        return defaultValue;
    }
    
    if ([tmpValue isKindOfClass:[NSNumber class]]) {
        return [tmpValue floatValue];
    } else {
        @try {
            return [tmpValue floatValue];
        }
        @catch (NSException *exception) {
            DLog(@"getFloatValueForKey : %@",key);
            DLog(@"tmpValue : %@",tmpValue);
            return defaultValue;
        }
    }
}

- (double)getDoubleValueForKey:(NSString*)key defaultValue:(double)defaultValue {
    id tmpValue = [self objectForKey:key];
    
    if (tmpValue == nil || tmpValue == [NSNull null]) {
        return defaultValue;
    }
    
    if ([tmpValue isKindOfClass:[NSNumber class]]) {
        return [tmpValue doubleValue];
    } else {
        @try {
            return [tmpValue doubleValue];
        }
        @catch (NSException *exception) {
            DLog(@"getDoubleValueForKey : %@",key);
            DLog(@"tmpValue : %@",tmpValue);
            return defaultValue;
        }
    }
}

- (long long)getLongLongValueValueForKey:(NSString *)key defaultValue:(long long)defaultValue {
    id tmpValue = [self objectForKey:key];
    
    if (tmpValue == nil || tmpValue == [NSNull null]) {
        return defaultValue;
    }
    
    if ([tmpValue isKindOfClass:[NSNumber class]]) {
        return [tmpValue longLongValue];
    } else {
        @try {
            return [tmpValue longLongValue];
        }
        @catch (NSException *exception) {
            DLog(@"getLongLongValueValueForKey : %@",key);
            DLog(@"tmpValue : %@",tmpValue);
            return defaultValue;
        }
    }
}

- (NSString *)getStringValueForKey:(NSString *)key defaultValue:(NSString *)defaultValue {
    id tmpValue = [self objectForKey:key];
    
    if (tmpValue == nil || tmpValue == [NSNull null]) {
        return defaultValue;
    }
    
    if ([tmpValue isKindOfClass:[NSString class]]) {
        return [NSString stringWithString:tmpValue];
    } else {
        @try {
            return [NSString stringWithFormat:@"%@",tmpValue];
        }
        @catch (NSException *exception) {
            DLog(@"getStringValueForKey : %@",key);
            DLog(@"tmpValue : %@",tmpValue);
            return defaultValue;
        }
    }
}

- (NSDictionary*)getDictionaryForKey:(NSString*)key {
    id tmpValue = [self objectForKey:key];
    if ([tmpValue isKindOfClass:[NSDictionary class]]) {
        return tmpValue;
    } else {
        return nil;
    }
}

- (NSArray*)getArrayForKey:(NSString*)key {
    id tmpValue = [self objectForKey:key];
    if ([tmpValue isKindOfClass:[NSArray class]]) {
        return tmpValue;
    } else {
        return nil;
    }
}

@end


@implementation NSDictionary (CollationAdditions)
- (NSString*)getNameValue {
    return [self getStringValueForKey:@"name" defaultValue:@""];
}
- (NSString*)getCodeValue {
    return [self getStringValueForKey:@"code" defaultValue:@""];
}
@end
