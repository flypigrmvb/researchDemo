//
//  ImagePhotoViewController.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "BaseViewController.h"

@interface ImagePhotoViewController : BaseViewController
- (id)initWithPicArray:(NSArray*)albs defaultIndex:(int)index;
- (void)showInCell:(id)cell;
- (void)showFromView:(UIView*)fromView;
@end
