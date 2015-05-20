//
//  UIButton+NSIndexPath.m
//  UIButton+NSIndexPath
//
//  Created by kiwi on 14-6-5.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//
#import "UIButton+NSIndexPath.h"
#import <objc/runtime.h>

@implementation UIButton (NSIndexPath)

- (void)setIndexPath:(NSIndexPath *)indexPath {
    objc_setAssociatedObject(self, BSUIButtonKey, indexPath, OBJC_ASSOCIATION_RETAIN);
}

- (NSIndexPath *)indexPath {
    id obj = objc_getAssociatedObject(self, BSUIButtonKey);
    if([obj isKindOfClass:[NSIndexPath class]]) {
        return (NSIndexPath *)obj;
    }
    return nil;
}

@end
