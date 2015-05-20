//
//  UILabelAdditions.m
//  ALHomeland
//
//  Created by kiwi on 8/21/13.
//  Copyright (c) 2013 Kiwaro. All rights reserved.
//

#import "UILabelAdditions.h"

@implementation UILabel (Additions)

+ (UILabel*)singleLineText:(NSString*)text font:(UIFont*)font wid:(CGFloat)wid {
    return [UILabel singleLineText:text font:font wid:wid color:[UIColor blackColor]];
}
+ (UILabel*)singleLineText:(NSString*)text font:(UIFont*)font wid:(CGFloat)wid color:(UIColor*)color {
    return [UILabel linesText:text font:font wid:wid lines:1 color:color];
}

+ (UILabel*)multLinesText:(NSString*)text font:(UIFont*)font wid:(CGFloat)wid {
    return [UILabel multLinesText:text font:font wid:wid color:[UIColor blackColor]];
}
+ (UILabel*)multLinesText:(NSString*)text font:(UIFont*)font wid:(CGFloat)wid color:(UIColor*)color {
    return [UILabel linesText:text font:font wid:wid lines:0 color:color];
}

+ (UILabel*)linesText:(NSString*)text font:(UIFont*)font wid:(CGFloat)wid lines:(int)lines {
    return [UILabel linesText:text font:font wid:wid lines:lines color:[UIColor blackColor]];
}
+ (UILabel*)linesText:(NSString*)text font:(UIFont*)font wid:(CGFloat)wid lines:(int)lines color:(UIColor*)color {
    CGFloat maxH = 0;
    if (lines > 0) {
        maxH = (font.pointSize + 2) * lines + 3;
    } else {
        maxH = 6000;
    }
    CGSize size = CGSizeMake(wid, maxH);
    size = [text sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];
    UILabel * lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    lab.numberOfLines = lines;
    lab.textAlignment = NSTextAlignmentCenter;
    lab.backgroundColor = [UIColor clearColor];
    lab.lineBreakMode = NSLineBreakByTruncatingTail;
    lab.textColor = color;
    lab.font = font;
    lab.text = text;
    lab.highlightedTextColor = [UIColor whiteColor];
    return lab;
}

+ (UILabel*)defaultLabel:(NSString*)text font:(UIFont*)font maxWid:(CGFloat)maxWid
{
    CGSize size = CGSizeMake(maxWid, 3000);
    size = [text sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, maxWid, size.height)];
    lab.numberOfLines = 0;
    lab.textAlignment = NSTextAlignmentCenter;
    lab.backgroundColor = [UIColor clearColor];
    lab.lineBreakMode = NSLineBreakByWordWrapping;
    lab.textColor = [UIColor blackColor];
    lab.font = font;
    lab.text = text;
    return lab;
}

@end
