//
//  SessionCell.m
//
//  AppDelegate.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "SessionCell.h"
#import "EmotionInputView.h"
#import "Session.h"
#import "User.h"
#import "Message.h"
#import "Globals.h"
#import "Room.h"
#import "Message.h"

@interface SessionCell () {
    UIImageView * imgViewHeadBkg;
}

@end

@implementation SessionCell
@synthesize withItem, otherBtn, labTime;

- (void)dealloc {
    Release(imgViewHeadBkg);
    Release(labTime);
    Release(otherBtn);
}

- (void)initialiseCell {
    [super initialiseCell];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implement/Users/微慧Sam团队/.Trash/SessionCell2.xibation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (UILabel*)labTime {
    if (!labTime) {
        labTime = [[UILabel alloc] initWithFrame:CGRectMake(self.width - 100, 5, 90, 18)];
        labTime.textAlignment = NSTextAlignmentRight;
        labTime.textColor = [UIColor lightGrayColor];
        labTime.backgroundColor = [UIColor clearColor];
        labTime.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:labTime];
    }
    return labTime;
}

- (UIButton*)otherBtn {
    if (!otherBtn) {
        otherBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [otherBtn addTarget:self action:@selector(tapOnButton:) forControlEvents:UIControlEventTouchUpInside];
        otherBtn.frame = CGRectMake(self.width - 60, 25, 50, 24);
        otherBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [otherBtn setTitle:@"屏蔽" forState:UIControlStateNormal];
        [self.contentView addSubview:otherBtn];
    }
    return otherBtn;
}

- (void)setWithItem:(id)value {
    otherBtn.hidden = YES;
    if (value != nil && [value isKindOfClass:[Session class]]) {
        Session * item = value;
        
        self.detailTextLabel.text = item.message.contentDisplay;
        self.textLabel.text = item.name;
        
        NSTimeInterval timeInterval = item.message.sendTime.doubleValue/1000;
        
        if (timeInterval > 0) {
            labTime.hidden = NO;
            self.labTime.text = [Globals timeStringForListWith:timeInterval];
        } else {
            labTime.hidden = YES;
        }
        self.badgeValue = item.unreadCount;
    } else if (value != nil && [value isKindOfClass:[User class]]) {
        self.textLabel.text = ((User*)value).nickname;
        self.textLabel.hidden = NO;
        self.detailTextLabel.hidden = YES;
        labTime.hidden = YES;
    } else if (value != nil && [value isKindOfClass:[Message class]]) {
        Message* item = value;
        self.textLabel.text = item.displayName;
        self.detailTextLabel.text = item.content;
    } else {
        self.textLabel.hidden =
        self.detailTextLabel.hidden = YES;
    }
}

- (void)setTime:(NSString*)time {
    if ([time doubleValue] > 0) {
        time = [Globals timeStringForListWith:time.doubleValue/1000];
        self.labTime.text = time;
        labTime.hidden = NO;
    } else {
        labTime.hidden = YES;
    }
}

- (void)setImageHead:(UIImage*)imgHead {
    self.imageView.image = imgHead;
}

- (IBAction)tapOnButton:(id)sender {
    if ([self.superTableView.delegate respondsToSelector:@selector(tableView:didTapOtherBtnAtIndexPath:)]) {
        [self.superTableView.delegate performSelector:@selector(tableView:didTapOtherBtnAtIndexPath:) withObject:self.superTableView withObject:self.indexPath];
    } else {
        if ([self.superTableView.delegate respondsToSelector:@selector(tableView:didTapOtherBtnAtIndexPath:)]) {
            [self.superTableView.delegate performSelector:@selector(tableView:didTapOtherBtnAtIndexPath:) withObject:self.superTableView withObject:self.indexPath];
        }
    }
}

@end

