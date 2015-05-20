//
//  JSON.m
//  JSON
//
//  Created by kiwi on 3/4/13.
//  Copyright (c) 2013 Kiwaro.com. All rights reserved.
//

#import "JSON.h"

@implementation JSON

+(id)objectFromJSONString:(NSString*)string{
    NSData *data=[string dataUsingEncoding:NSUTF8StringEncoding];
    return [self objectFromJSONData:data];
}
+(id)mutableObjectFromJSONString:(NSString*)string{
    NSData *data=[string dataUsingEncoding:NSUTF8StringEncoding];
    return [self mutableObjectFromJSONData:data];
}
+(id)objectFromJSONData:(NSData*)data{
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
}
+(id)mutableObjectFromJSONData:(NSData*)data{
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
}

+(NSString*)stringWithObject:(id)object{
    NSString *string=nil;
    NSData *data=[self dataWithObject:object];
    if (data) {
        string=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    }
    return string;
}
+(NSData*)dataWithObject:(id)object{
    NSData *data=nil;
    if ([NSJSONSerialization isValidJSONObject:object]) {
        data=[NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:nil];
    }else{
        DLog(@"--->>object %@ not a json object",object);
    }
    return data;
}
@end



@implementation NSString (JSONDeserializing)
- (id)objectFromJSONString{
    return [JSON objectFromJSONString:self];
}
- (id)mutableObjectFromJSONString{
    return [JSON mutableObjectFromJSONString:self];
}
@end

@implementation NSData (JSONDeserializing)
// The NSData MUST be UTF8 encoded JSON.
- (id)objectFromJSONData{
    return [JSON objectFromJSONData:self];
}
- (id)mutableObjectFromJSONData{
    return [JSON mutableObjectFromJSONData:self];
}
@end


@implementation NSString (JSONSerializing)
- (NSData *)JSONData{
    return [JSON dataWithObject:self];
}
- (NSString *)JSONString{
    return [JSON stringWithObject:self];
}
@end

@implementation NSArray (JSONSerializing)
- (NSData *)JSONData{
    return [JSON dataWithObject:self];
}
- (NSString *)JSONString{
    return [JSON stringWithObject:self];
}
@end

@implementation NSDictionary (JSONSerializing)
- (NSData *)JSONData{
    return [JSON dataWithObject:self];
}
- (NSString *)JSONString{
    return [JSON stringWithObject:self];
}
@end
