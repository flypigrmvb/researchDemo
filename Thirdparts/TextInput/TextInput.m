//
//  TextInput.m
//  FamiliarMen
//
//  Created by kiwi on 14-1-17.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "TextInput.h"
#import "UITextField+Shake.h"

@implementation KTextField
@synthesize index;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}

- (void)infoStyle {
    self.layer.borderWidth = 1;
    self.layer.borderColor = RGBCOLOR(228, 228, 228).CGColor;
    self.backgroundColor = [UIColor whiteColor];
}

- (void)enableBorder {
    self.layer.borderColor = RGBCOLOR(221, 221, 221).CGColor;
    self.layer.borderWidth = 1;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
    }
    return self;
}
//控制清除按钮的位置
//- (CGRect)clearButtonRectForBounds:(CGRect)bounds {
//    return CGRectInset(bounds, 0, 0);
//}

//控制placeHolder的位置
- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    CGSize size = [self.placeholder sizeWithFont:self.font maxWidth:self.width - 12 maxNumberLines:1];
    return CGRectInset(bounds, 8, (self.height - size.height)/2);
}
//控制显示文本的位置
- (CGRect)textRectForBounds:(CGRect)bounds {
    CGSize size = [self.placeholder sizeWithFont:self.font maxWidth:self.width - 12 maxNumberLines:1];
    return CGRectInset(bounds, 8, (self.height - size.height)/2);
}
//控制编辑文本的位置
- (CGRect)editingRectForBounds:(CGRect)bounds {
    CGSize size = [self.placeholder sizeWithFont:self.font maxWidth:self.width - 12 maxNumberLines:1];
    return CGRectInset(bounds, 8, (self.height - size.height)/2);
}

@end



@implementation KTextView
@synthesize placeholder;
@synthesize textColor;
@synthesize maxCount;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:self];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:self];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.placeholder = nil;
}

- (void)setupBackgroundView {
    self.backgroundColor = [UIColor clearColor];
    CGRect frame = self.frame;frame.origin.y -= 1;frame.size.height += 2;
    if (maxCount > 0) {
        frame.size.height += 20;
    }
    UIImageView* bkgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    UIImage * tfImg = [[UIImage imageNamed:@"bkg_textInput"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
    bkgView.image = tfImg;
    bkgView.autoresizingMask = self.autoresizingMask;
    [self insertSubview:bkgView atIndex:0];
    backgroundView = bkgView;
}

#pragma mark - Setter/Getters
- (void)setPlaceholder:(NSString *)_placeholder {
    Release(placeholder);
    placeholder = _placeholder;
    if (placeholder.hasValue) {
        if (labPlaceholder == nil) {
            labPlaceholder = [UILabel singleLineText:placeholder font:self.font wid:self.width - 16 color:RGBACOLOR(199, 199, 199, 1)];
            if (Sys_Version < 7) {
                labPlaceholder.textColor = RGBACOLOR(175, 175, 175, 1);
            }
            labPlaceholder.frame = CGRectMake(8, 8, self.width - 16, labPlaceholder.height);
            labPlaceholder.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
            labPlaceholder.textAlignment = NSTextAlignmentLeft;
            [self addSubview:labPlaceholder];
        }
        labPlaceholder.text = placeholder;
    }
    labPlaceholder.hidden = (self.text.hasValue);
}

- (void)setMaxCount:(NSInteger)count {
    if (maxCount != count) {
        maxCount = count;
        if (labCount == nil) {
            NSInteger count = maxCount - self.text.length;
            UIColor * color = (count >= 0) ? [UIColor lightGrayColor] : RGBCOLOR(200, 0, 0);
            labCount = [UILabel singleLineText:[NSString stringWithFormat:@"%d", (int)count]
                                          font:[UIFont systemFontOfSize:14]
                                           wid:self.width - 16 color:color];
            labCount.frame = CGRectMake(self.left + 8, self.bottom - 2, self.width - 16, 18);
            labCount.textAlignment = NSTextAlignmentRight;
            [self.superview addSubview:labCount];
        }
        labCount.hidden = (count == 0);
    }
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    backgroundView.hidden = hidden;
}

- (void)setText:(NSString *)text {
    [super setText:text];
    if (maxCount > 0) {
        NSInteger count = maxCount - self.text.length;
        labCount.textColor = (count >= 0) ? [UIColor lightGrayColor] : RGBCOLOR(200, 0, 0);
        labCount.text = [NSString stringWithFormat:@"%d", (int)count];
    }
    labPlaceholder.hidden = (self.text.hasValue);
}

#pragma mark - Notifications
- (void)textChanged:(NSNotification*)notification {
    labPlaceholder.hidden = (self.text.hasValue);
    if (maxCount > 0) {
        NSInteger count = maxCount - self.text.length;
        labCount.textColor = (count >= 0) ? [UIColor lightGrayColor] : RGBCOLOR(200, 0, 0);
        labCount.text = [NSString stringWithFormat:@"%d", (int)count];
    }
}

@end
