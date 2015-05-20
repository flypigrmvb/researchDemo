//
//  UIImageAddtions.h
//  CarPool
//
//  Created by kiwi on 14-2-19.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (Addtions)

+ (UIImage*)imageNamed:(NSString *)imgName isCache:(BOOL)isCache;

+ (UIImage *)rotateImage:(UIImage *)aImage;

@end
