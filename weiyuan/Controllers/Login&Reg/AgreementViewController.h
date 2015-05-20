//
//  AgreementViewController.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@class Notify;

@interface AgreementViewController : BaseViewController

@property (nonatomic, strong) NSString * notice;
@property (nonatomic, strong) Notify * item;
/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	0 用户协议 1 注册协议
 */
@property (nonatomic, assign) int arType;
@end
