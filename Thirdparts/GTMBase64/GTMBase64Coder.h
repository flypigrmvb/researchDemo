//
//  GTMBase64Coder.h
//  CarPool
//
//  Created by kiwi on 14-4-23.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTMBase64Coder : NSObject

+(NSString*)encodeBase64String:(NSString *)input;
+(NSString*)decodeBase64String:(NSString *)input;
+(NSString*)encodeBase64Data:(NSData *)data;
+(NSString*)decodeBase64Data:(NSData *)data;

@end
