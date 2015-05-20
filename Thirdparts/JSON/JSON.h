//
//  JSON.h
//  JSON
//
//  Created by kiwi on 3/4/13.
//  Copyright (c) 2013 Kiwaro.com. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *	@class	JSON,for 5.0++
 */
@interface JSON : NSObject

+(id)objectFromJSONString:(NSString*)string;
+(id)mutableObjectFromJSONString:(NSString*)string;
+(id)objectFromJSONData:(NSData*)data;
+(id)mutableObjectFromJSONData:(NSData*)data;

+(NSString*)stringWithObject:(id)object;
+(NSData*)dataWithObject:(id)object;
@end

@interface NSString (YRJSONDeserializing)
- (id)objectFromJSONString;
- (id)mutableObjectFromJSONString;
@end

@interface NSData (YRJSONDeserializing)
// The NSData MUST be UTF8 encoded JSON.
- (id)objectFromJSONData;
- (id)mutableObjectFromJSONData;
@end

@interface NSString (YRJSONSerializing)
- (NSData *)JSONData;
- (NSString *)JSONString;
@end

@interface NSArray (YRJSONSerializing)
- (NSData *)JSONData;
- (NSString *)JSONString;
@end

@interface NSDictionary (YRJSONSerializing)
- (NSData *)JSONData;
- (NSString *)JSONString;
@end