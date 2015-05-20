//
//  KBadgeView.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "KBadgeView.h"
#import "UIImage+FlatUI.h"

@interface KBadgeView ()
@property (nonatomic, strong) UILabel * textLabel;
@end
@implementation KBadgeView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = RGBCOLOR(207, 50, 65);
        self.highlightedImage = [UIImage imageWithColor:self.backgroundColor cornerRadius:frame.size.height/2];
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (void)setText:(NSString *)text {
    if (text.intValue == 0) {
        text = nil;
    }
    self.hidden = !text;
    if (text) {
        CGSize size = [text sizeWithFont:[UIFont boldSystemFontOfSize:10] maxWidth:100 maxNumberLines:1];
        if (size.width <= 12) {
            size.width = 12;
        }
        self.textLabel.size = size;
        _textLabel.text = text;
        self.width = size.width + 4;
        self.height = size.height + 4;
        self.layer.cornerRadius = self.height/2;
        self.highlightedImage = [UIImage imageWithColor:RGBCOLOR(169, 7, 35) cornerRadius:self.height/2];
    }
}

- (UILabel*)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 2, 0, self.height)];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.highlightedTextColor = [UIColor grayColor];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.font = [UIFont boldSystemFontOfSize:10];
        [self addSubview:_textLabel];
    }
    return _textLabel;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
