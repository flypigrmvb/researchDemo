//
//  ImageCaches.m
//  kiwi
//
//  Created by kiwi on 6/21/13.
//  Copyright (c) 2013 Kiwaro. All rights reserved.
//

#import "ImageCaches.h"

@interface ImageCaches () {
    NSMutableArray * cacheKeys;
    NSMutableDictionary * cachesDictionary;
}

@end

@implementation ImageCaches
@synthesize maxCount;

- (id)initWithMaxCount:(int)mc {
    if (self = [super init]) {
        self.maxCount = mc;
        cacheKeys = [[NSMutableArray alloc] init];
        cachesDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc {
    Release(cacheKeys);
    Release(cachesDictionary);
}

- (BOOL)insertImageCache:(UIImage*)img withKey:(id)key {
    BOOL res = NO;
    UIImage * obj = [cachesDictionary objectForKey:key];
    if (obj == nil) {
        if (cacheKeys.count >= maxCount) {
            [cachesDictionary removeObjectForKey:[cacheKeys lastObject]];
            [cacheKeys removeLastObject];
            res = YES;
        }
        [cachesDictionary setObject:img forKey:key];
        [cacheKeys insertObject:key atIndex:0];
    } else {
        for (NSString * sk in cacheKeys) {
            if ([sk isEqualToString:key]) {
                [cacheKeys removeObject:sk];
                break;
            }
        }
        [cacheKeys insertObject:key atIndex:0];
    }
    return res;
}

- (UIImage*)getImageCache:(id)key {
    return [cachesDictionary objectForKey:key];
}

@end
