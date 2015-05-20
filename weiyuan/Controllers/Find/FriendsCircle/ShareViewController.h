//
//  ShareViewControllesr.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "BaseViewController.h"

typedef enum {
    forShareViewRequestDelete = 0,
    forShareViewRequestLike,
    forShareViewRequestComment,
    forShareViewRequestfav,
}ShareViewRequestType;

@class CircleMessage;

@interface ShareViewController : BaseViewController

- (id)initWithShare:(CircleMessage*)itemS index:(NSInteger)index;

@end
