//
//  UIButton+NSIndexPath.h
//  UIButton+NSIndexPath
//
//  Created by kiwi on 14-6-5.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import <UIKit/UIKit.h>

const static char * BSUIButtonKey = "BSUIButtonKey";

@interface UIButton (NSIndexPath)

- (void)setIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPath;

@end
