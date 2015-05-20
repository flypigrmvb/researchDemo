//
//  ImageCaches.h
//  kiwi
//
//  Created by kiwi on 6/21/13.
//  Copyright (c) 2013 Kiwaro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageCaches : NSObject
@property (nonatomic, assign) int maxCount;

/**
 *	Copyright © 2013 Kiwaro Inc. All rights reserved.
 *
 *	initialize a cache pool for images
 *
 *	@param 	mc 	max count of images
 *
 *	@return	An ImageCaches object
 */
- (id)initWithMaxCount:(int)mc;

/**
 *	Copyright © 2013 Kiwaro Inc. All rights reserved.
 *
 *	insert an image into cache pool
 *
 *	@param 	img 	Image Object
 *	@param 	key 	Image identifier
 *
 *	@return	YES if the pool is full
 */
- (BOOL)insertImageCache:(UIImage*)img withKey:(id)key;

/**
 *	Copyright © 2013 Kiwaro Inc. All rights reserved.
 *
 *	get an image for given identifier
 *
 *	@param 	key 	Image identifier
 *
 *	@return	an image in pool for given identifier, nil when not found
 */
- (UIImage*)getImageCache:(id)key;

@end
