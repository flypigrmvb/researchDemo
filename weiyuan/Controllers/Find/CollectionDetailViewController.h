//
//  CollectionDetailViewController.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "BaseViewController.h"
@class Favorite;
typedef void(^Delblock)(Favorite * it);

@interface CollectionDetailViewController : BaseViewController
@property (nonatomic, strong) Favorite * item;
@property (nonatomic, strong) Delblock black;
@end
