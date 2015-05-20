//
//  CommentCell.h
//  LfMall
//
//  Created by 微慧Sam团队 on 13-8-19.
//  Copyright (c) 2013年 微慧Sam团队. All rights reserved.
//

#import "BaseTableViewCell.h"

@class CircleMessage, ImageTouchView;

@interface CircleMessageCell : BaseTableViewCell
@property (nonatomic, strong) CircleMessage* item;
@property (nonatomic, assign) NSInteger gridViewnumbers;
@property (nonatomic, strong) IBOutlet ImageTouchView * imgView0;
@property (nonatomic, strong) IBOutlet ImageTouchView * imgView1;
@property (nonatomic, strong) IBOutlet ImageTouchView * imgView2;
@property (nonatomic, strong) IBOutlet ImageTouchView * imgView3;
@property (nonatomic, strong) IBOutlet ImageTouchView * imgView4;
@property (nonatomic, strong) IBOutlet ImageTouchView * imgView5;
+ (CGFloat)sizeFontWithContent;
+ (CGFloat)getHeightWithItem:(CircleMessage*)it;

- (void)setImage:(UIImage*)image atIndex:(NSInteger)index;
- (CGRect)imageFrameAtIndex:(NSInteger)index;

@end
