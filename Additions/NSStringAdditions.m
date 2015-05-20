//
//  NSStringAdditions.m
//  CarPool
//
//  Created by kiwi on 14-1-6.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "NSStringAdditions.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import "GTMBase64.h"

#pragma mark - NSData (kEncode)

@implementation NSData (kEncode)

- (NSString *)MD5EncodedString
{
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5([self bytes], (CC_LONG)[self length], result);
	
	return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
}

- (NSData *)HMACSHA1EncodedDataWithKey:(NSString *)key
{
	NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    void *buffer = malloc(CC_SHA1_DIGEST_LENGTH);
    CCHmac(kCCHmacAlgSHA1, [keyData bytes], [keyData length], [self bytes], [self length], buffer);
	
	NSData *encodedData = [NSData dataWithBytesNoCopy:buffer length:CC_SHA1_DIGEST_LENGTH freeWhenDone:YES];
    return encodedData;
}

- (NSString *)base64EncodedString
{
	return [GTMBase64 stringByEncodingData:self];
}

@end

#pragma mark - NSString (kEncode)

@implementation NSString (kEncode)

+ (NSString *)GUIDString
{
	CFUUIDRef theUUID = CFUUIDCreate(NULL);
	CFStringRef string = CFUUIDCreateString(NULL, theUUID);
	CFRelease(theUUID);
	return CFBridgingRelease(string);
}
- (BOOL)hasValue {
    return ([self isKindOfClass:[NSString class]] && self.length > 0);
}

- (NSString *)MD5EncodedString
{
	return [[self dataUsingEncoding:NSUTF8StringEncoding] MD5EncodedString];
}

- (NSString *)md5Hex
{
    const char *cStr = [self UTF8String];
    
    unsigned char result[32];
    
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    
    return [NSString stringWithFormat:
            
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            
            result[0],result[1],result[2],result[3],
            result[4],result[5],result[6],result[7],
            result[8],result[9],result[10],result[11],
            result[12],result[13],result[14],result[15]/*,
                                                        result[16], result[17],result[18], result[19],
                                                        result[20], result[21],result[22], result[23],
                                                        result[24], result[25],result[26], result[27],
                                                        result[28], result[29],result[30], result[31]*/];
}

- (NSData *)HMACSHA1EncodedDataWithKey:(NSString *)key
{
	return [[self dataUsingEncoding:NSUTF8StringEncoding] HMACSHA1EncodedDataWithKey:key];
}

- (NSString *) base64EncodedString
{
	return [[self dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString];
}

- (NSString *)URLEncodedString
{
	return [self URLEncodedStringWithCFStringEncoding:kCFStringEncodingUTF8];
}

- (NSString *)URLEncodedStringWithCFStringEncoding:(CFStringEncoding)encoding
{
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (__bridge CFStringRef)[self mutableCopy],
                                                                                 NULL,
                                                                                 CFSTR("￼=,!$&'()*+;@?\n\"<>#\t :/"), encoding);
}

- (NSString*)URLDecodedString
{
    return [self URLDecodedStringWithCFStringEncoding:kCFStringEncodingUTF8];
}

- (NSString *)URLDecodedStringWithCFStringEncoding:(CFStringEncoding)encoding
{
    return (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                 (__bridge CFStringRef)self,CFSTR(""),encoding);
}

- (CGSize)sizeWithFont:(UIFont *)font maxWidth:(CGFloat)width maxNumberLines:(int)num {
    CGSize size = CGSizeZero;
    if (num > 0) {
        CGFloat tmpHeight = ceilf(font.lineHeight * num);
        size = [self sizeWithFont:font constrainedToSize:CGSizeMake(width, tmpHeight) lineBreakMode:NSLineBreakByTruncatingTail];
    } else if (num == 0) {
        size = [self sizeWithFont:font maxWidth:width maxNumberLines:-10];
    } else if (num < 0) {
        num = num*-1;
        int i = 1;
        CGFloat h1, h2;
        do {
            size = [self sizeWithFont:font maxWidth:width maxNumberLines:num*i];
            h1 = size.height;
            h2 = ceilf(font.lineHeight*num*i++);
        } while (h1 >= h2);
    }
    size.width = ceilf(size.width);
    size.height = ceilf(size.height);
    return size;
}

- (NSString *)replaceSpace {
    NSString *result = self;
    result = [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return result;
}

- (NSString *)iPhoneStandardFormat {
    NSString * originStr = [NSString stringWithFormat:@"%@",self];
    NSMutableString * strippedString = [NSMutableString stringWithCapacity:originStr.length];
    NSScanner * scanner = [NSScanner scannerWithString:originStr];
    NSCharacterSet * numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    while ([scanner isAtEnd] == NO) {
        NSString * buffer;
        if ([scanner scanCharactersFromSet:numbers intoString:&buffer]) {
            [strippedString appendString:buffer];
        } else {
            [scanner setScanLocation:([scanner scanLocation] + 1)];
        }
    }
    return strippedString;
}

- (NSString*)replaceOtherChar {
    NSString * result = [NSString stringWithFormat:@"%@",self];
    result = [result stringByReplacingOccurrencesOfString :@"\n" withString:@""];
    result = [result stringByReplacingOccurrencesOfString :@"\r" withString:@""];
    result = [result stringByReplacingOccurrencesOfString :@"\t" withString:@""];
    result = [result stringByReplacingOccurrencesOfString :@" " withString:@""];
    result = [result stringByReplacingOccurrencesOfString :@"　" withString:@""];
    return result;
}

- (NSDate*)convertDateFromString:(NSString*)uiDate; {
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy/MM/dd"];
    NSDate * date=[formatter dateFromString:uiDate];
    return date;
}
@end
