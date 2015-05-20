//
//  UserCell.m
//
//  AppDelegate.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "UserCell.h"
#import "User.h"
#import "Message.h"

@interface UserCell () {
    UIImageView    * imgSelectView;
    UILabel        * labTime;
    UILabel        * labAttach;
}

@end

@implementation UserCell
@synthesize time;
@synthesize withItem;
@synthesize withFriendItem;
@synthesize selected;
@synthesize isAdded;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setCornerRadius:5];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)initialiseCell {
    [super initialiseCell];
    labTime = [[UILabel alloc] initWithFrame:CGRectMake(self.width -100, 10, 90, 18)];
    labTime.backgroundColor = [UIColor clearColor];
    labTime.font = [UIFont systemFontOfSize:12];
    labTime.textAlignment = NSTextAlignmentRight;
    labTime.textColor = [UIColor grayColor];
    [self.contentView addSubview:labTime];
    imgSelectView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (60-12)/2, 12, 12)];
    [self.contentView addSubview:imgSelectView];
}

- (void)setWithItem:(id)wItem {
    if (wItem != nil && [wItem isKindOfClass:[User class]]) {
        User* item = wItem;
        self.textLabel.text = item.nickname;
        self.detailTextLabel.text = item.sign;
    }
}

- (void)setWithFriendItem:(id)wItem {
    if ([wItem isKindOfClass:[User class]]) {
        User * item = wItem;
        self.textLabel.text = (item.remark&&item.remark.length>0)?item.remark:item.nickname;
        self.detailTextLabel.text = item.sign;
        labTime.text = @"";
    }
}

- (void)setSelected:(UserSelectCellType)value {
    selected = value;
    imgSelectView.highlighted = selected;
     if (selected == forUserSelectCellSelected) {
        imgSelectView.image = [UIImage imageNamed:@"CellGraySelected" isCache:YES];
     } else if (selected == forUserSelectCellSource) {
         self.backgroundColor = RbkgColor;
         imgSelectView.image = [UIImage imageNamed:@"CellBlueSelected" isCache:YES];
     } else if (selected == forUserSelectCellNormal){
         imgSelectView.image = [UIImage imageNamed:@"CellNotSelected" isCache:YES];
     } else {
         imgSelectView.image = nil;
     }
}

- (void)setTime:(NSString *)t {
    if (!t) {
        labTime.hidden = YES;
    } else {
        labTime.text = t;
        labTime.hidden = NO;
    }
}

- (void)setIsAdded:(BOOL)value {
    isAdded = value;
    if (isAdded) {
        self.textLabel.textColor = [UIColor grayColor];
        labAttach.hidden = NO;
    } else {
        self.textLabel.textColor = [UIColor blackColor];
        labAttach.hidden = YES;
    }
}

- (void)setlabTimeHide:(BOOL)hide {
    labTime.hidden = hide;
}
@end
