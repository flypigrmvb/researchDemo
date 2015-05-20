//
//  UILabelAdditions.h
//  ALHomeland
//
//  Created by kiwi on 8/21/13.
//  Copyright (c) 2013 Kiwaro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UILabel (Additions)

+ (UILabel*)singleLineText:(NSString*)text font:(UIFont*)font wid:(CGFloat)wid;
+ (UILabel*)singleLineText:(NSString*)text font:(UIFont*)font wid:(CGFloat)wid color:(UIColor*)color;
+ (UILabel*)multLinesText:(NSString*)text font:(UIFont*)font wid:(CGFloat)wid;
+ (UILabel*)multLinesText:(NSString*)text font:(UIFont*)font wid:(CGFloat)wid color:(UIColor*)color;
+ (UILabel*)linesText:(NSString*)text font:(UIFont*)font wid:(CGFloat)wid lines:(int)lines;
+ (UILabel*)linesText:(NSString*)text font:(UIFont*)font wid:(CGFloat)wid lines:(int)lines color:(UIColor*)color;

+ (UILabel*)defaultLabel:(NSString*)text font:(UIFont*)font maxWid:(CGFloat)maxWid;
@end
