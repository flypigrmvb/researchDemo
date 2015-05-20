//
//  ChatMessagesCell.h
//
//  AppDelegate.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "BaseTableViewCell.h"
#import "Declare.h"

@class Message;

@interface ChatMessagesCell : BaseTableViewCell
@property (nonatomic, assign) BOOL  right;
@property (nonatomic, assign) BOOL  loading;
@property (nonatomic, assign) BOOL  playing;
@property (nonatomic, assign) BOOL  hasSubsImage;
@property (nonatomic, strong) NSString  * detailText;
@property (nonatomic, strong) NSString  * createTime;
@property (nonatomic, strong) UIImage   * conImage;
@property (nonatomic, assign) CGFloat   audioLength; //0.0 - 1.0
@property (nonatomic, assign) CGRect    imageFrame; //0.0 - 1.0
@property (nonatomic, assign) CGSize    imageSize; //0.0 - 1.0
@property (nonatomic, strong) NSString * timeText;
@property (nonatomic, strong) NSString  * personName;

@property (nonatomic, assign) MessageState      state;
@property (nonatomic, strong) Message   * item;

+ (CGFloat)heightForMessage:(id)item;

@end
