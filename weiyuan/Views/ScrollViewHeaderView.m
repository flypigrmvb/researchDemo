//
//  ScrollViewHeaderView.m
//
//  AppDelegate.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "ScrollViewHeaderView.h"
#import "UIImage+FlatUI.h"
#import "UIColor+FlatUI.h"
#import "JSBadgeView.h"

@interface ScrollViewHeaderView ()

@end
@implementation ScrollViewHeaderView
@synthesize nameArray, selectedBtn, selecdBlock, selecedBlackgroundView;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self loadView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self loadView];
    }
    return self;
}

- (void)loadView {
    self.showsHorizontalScrollIndicator = NO;
    self.backgroundColor = RGBCOLOR(247, 247, 247);
    self.alwaysBounceHorizontal = YES;
    self.selecedBlackgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.height - 2, 94, 2)];
    self.selecedBlackgroundView.image = [UIImage imageWithColor:kbColor cornerRadius:1];
    [self addSubview:[self selecedBlackgroundView]];
}

- (void)dealloc {
    self.selecedBlackgroundView = nil;
    self.nameArray = nil;
}

- (void)setNameArray:(NSArray *)arr {
    nameArray = arr;
    if (arr.count <= 4) {
        self.maxButtonWidth = self.width/arr.count;
    } else {
        self.maxButtonWidth = 80;
    }
    
    self.selecedBlackgroundView.width = self.maxButtonWidth;
    self.selecedBlackgroundView.left = 0;
    [self reloadData];
}

- (void)setSelectedBtn:(NSInteger)selected {
    selectedBtn = selected + 100;
    for (UIButton *btn in self.subviews) {
        if ([btn isKindOfClass:[UIButton class]]) {
            btn.selected = NO;
            if (btn.tag == selected) {
                btn.selected = YES;
                [UIView animateWithDuration:0.1 animations:^{
                    self.selecedBlackgroundView.left = selected*selecedBlackgroundView.width;
                }];
            }
        }
    }
}

/**
 *  为指定按钮更新消息数
 *
 */
- (void)setBadgeValueAtIndex:(NSInteger)idx withContent:(NSString*)content {
    if ([content isEqualToString:@"0"]) {
        content = nil;
    }
    UIView * btn = VIEWWITHTAG(self, idx);
    UIImageView * badgeView = VIEWWITHTAG(btn, 11);
    badgeView.hidden = YES;
    if ([content isEqual:@"-1"]) {
        badgeView.hidden = NO;
    } else {
        UIButton * btn = VIEWWITHTAG(self, idx);
        JSBadgeView * badgeView = VIEWWITHTAG(btn, 10);
        badgeView.badgeText = content;
    }
    
}

- (void)reloadData
{
    // 计算排列间距，每页最大为4；
    for (UIButton *btn in self.subviews) {
        if ([btn isKindOfClass:[UIButton class]]) {
            [btn removeFromSuperview];
        }
        if ([btn isKindOfClass:[UIImageView class]] && btn.tag > 0) {
            [btn removeFromSuperview];
        }
    }
    CGFloat totalWidth = 0;
    for (int i = 0;i < nameArray.count;i++) {
        UIButton *btn = [self buttonWithTitle:nameArray[i]];
        btn.tag = i;
        if (i == selectedBtn) {
            btn.selected = YES;
        }
        btn.frame = CGRectMake(totalWidth, 0, _maxButtonWidth, self.height);
        [self addSubview:btn];
        JSBadgeView * badgeView = [[JSBadgeView alloc] init];
        badgeView.badgeAlignment = JSBadgeViewAlignmentNone;
        badgeView.origin = CGPointMake(btn.titleLabel.right+2, self.height);
        [btn addSubview:badgeView];
        badgeView.tag = 10;
        
        UIImageView * redView = [[UIImageView alloc] init];
        redView.size = CGSizeMake(7, 7);
        redView.image = LOADIMAGE(@"bkg_find");
        redView.origin = CGPointMake(btn.titleLabel.right+5, (self.height - redView.height)/2);
        [btn addSubview:redView];
        redView.hidden = YES;
        redView.tag = 11;
        
        UIImageView * view = [[UIImageView alloc] initWithFrame:CGRectMake(totalWidth, 10, 1, 24)];
        view.image = [UIImage imageNamed:@"SecretaryCut_line" isCache:YES];
        [self addSubview:view];
        totalWidth += _maxButtonWidth;
    }
    
    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(totalWidth, 10, 1, 24)];
    view.image = [UIImage imageNamed:@"SecretaryCut_line" isCache:YES];
    [self addSubview:view];
    
    // 翻页
    [self setContentSize:CGSizeMake(totalWidth, self.height)];
}

- (UIButton *)buttonWithTitle:(NSString *)title {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor] cornerRadius:0] forState:UIControlStateNormal];
    [btn setTitleColor:kbColor forState:UIControlStateSelected];
    [btn setTitleColor:RGBCOLOR(126, 126, 126) forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(reloadBySelect:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:title forState:UIControlStateNormal];
    return btn;
}


- (void)reloadBySelect:(UIButton*)sender
{
    if (selectedBtn == sender.tag) {
        return;
    }
    sender.selected = !sender.selected;
    selectedBtn = sender.tag;
    for (UIButton *btn in self.subviews) {
        if ([btn isKindOfClass:[UIButton class]]) {
            if (sender.tag != btn.tag) {
                btn.selected = NO;
            }
        }
    }
    [UIView animateWithDuration:0.1 animations:^{
        self.selecedBlackgroundView.left = sender.tag*selecedBlackgroundView.width;
    } completion:^(BOOL finished) {
        if (finished) {
            if (self.selecdBlock) {
                self.selecdBlock(selectedBtn);
            }
        }
    }];
}

@end
