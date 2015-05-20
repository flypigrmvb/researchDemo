//
//  CommentCell.m
//  LfMall
//
//  Created by 微慧Sam团队 on 13-8-19.
//  Copyright (c) 2013年 微慧Sam团队. All rights reserved.
//

#import "CircleMessageCell.h"
#import "Globals.h"
#import "CircleMessage.h"
#import "BSEngine.h"
#import "ImageTouchView.h"
#import "UIImage+FlatUI.h"
#import "TTTAttributedLabel.h"

UIKIT_STATIC_INLINE NSMutableDictionary * mutableLinkAttributes() {
    NSMutableDictionary * mutableLinkAttributes = [NSMutableDictionary dictionary];
    [mutableLinkAttributes setValue:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTSuperscriptAttributeName];
    [mutableLinkAttributes setValue:(__bridge id)[RGBCOLOR(31, 47, 88) CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
    return mutableLinkAttributes;
};

@interface CircleMessageCell ()<ImageTouchViewDelegate, TTTAttributedLabelDelegate, UITouchableLabelDelegate> {
    IBOutlet UIView      * imageGridView;
    ImageTouchView       * bkgtouchView;
    IBOutlet UILabel     * labTime;
    IBOutlet UIButton    * btndel;
    IBOutlet UITouchableLabel     * labContent;
    IBOutlet UITouchableLabel     * labloc; // 位置

    IBOutlet UIButton    * btnTool;
}

@property (nonatomic, strong) UIImageView * iconZan;
@property (nonatomic, strong) TTTAttributedLabel     * labzan;
@property (nonatomic, strong) UIImageView * commentView;
@property (nonatomic, strong) UIView * commentbkgView;
@end

@implementation CircleMessageCell
@synthesize item;

+ (CGFloat)sizeFontWithName {
    return 14;
}

+ (CGFloat)sizeFontWithContent {
    return 13;
}

+ (CGFloat)sizeFontWithTime {
    return 12;
}

+ (CGFloat)getHeightWithItem:(CircleMessage*)it {
    CGFloat cellHeight = 16.f;// 上边距8下边距8
    UIFont* font = [UIFont systemFontOfSize:[CircleMessageCell sizeFontWithName]];
    CGFloat maxWidth = Main_Screen_Width - 90;
    cellHeight+=[it.name sizeWithFont:font maxWidth:maxWidth maxNumberLines:0].height;
    
    if (it.content.length > 0) {
        font = [UIFont systemFontOfSize:[CircleMessageCell sizeFontWithContent]];
        cellHeight+=[it.content sizeWithFont:font maxWidth:maxWidth maxNumberLines:0].height;
    }
    
    cellHeight += 8;
    if (it.picsArray.count > 0) {
        if (it.picsArray.count > 3) {
            cellHeight += 162;
        } else {
            cellHeight += 80;
        }
    }
    // 位置
    if (it.address && it.address.address.length > 0) {
        font = [UIFont systemFontOfSize:[CircleMessageCell sizeFontWithTime]];
        cellHeight+=[it.address.address sizeWithFont:font maxWidth:maxWidth maxNumberLines:0].height+ 8;
    }
    
    font = [UIFont systemFontOfSize:[CircleMessageCell sizeFontWithContent]];
    cellHeight+=[it.createtime sizeWithFont:font maxWidth:maxWidth maxNumberLines:0].height+ 8;
    BOOL has = NO;
    // 赞
    if (it.praiselist.count > 0) {
        NSMutableArray * arr = [NSMutableArray array];
        [it.praiselist enumerateObjectsUsingBlock:^(CircleZan * obj, NSUInteger idx, BOOL *stop) {
            [arr addObject:obj.nickname];
        }];
        NSString * str = [NSString stringWithFormat:@"❤️%@", [arr componentsJoinedByString:@","]];
        cellHeight += [str sizeWithFont:font maxWidth:maxWidth - 10 maxNumberLines:0].height+4;
        has = YES;
    }
    // 评论
    for (CircleComment *cc in it.replylist) {
        NSString * say = [NSString stringWithFormat:@" %@: %@",cc.nickname, cc.content];
        cellHeight+= [say sizeWithFont:font maxWidth:maxWidth - 10 maxNumberLines:0].height+4;
        has = YES;
    }
    if (has) {
        cellHeight += 20;
    }
    return cellHeight;
}

- (void)initialiseCell {
    [super initialiseCell];
    self.textLabel.font = [UIFont systemFontOfSize:14];
    imageGridView.clipsToBounds = YES;
    
    labContent = [[UITouchableLabel alloc] initWithFrame:CGRectMake(64, 37, 244, 35)];
    labContent.font = [UIFont systemFontOfSize:[[self class] sizeFontWithContent]];
    labContent.textColor = [UIColor blackColor];
    labContent.lineBreakMode = NSLineBreakByWordWrapping;
    labContent.numberOfLines = 0;
    labContent.textAlignment = NSTextAlignmentLeft;
    labContent.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:labContent];
    
    UILongPressGestureRecognizer *longPress =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(longPressed:)];
    longPress.delegate = self;
    longPress.minimumPressDuration = 0.5f;
    [labContent addGestureRecognizer:longPress];
    
    [imageGridView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIImageView class]]) {
            UILongPressGestureRecognizer *longPress =
            [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                          action:@selector(longPressed:)];
            longPress.delegate = self;
            longPress.minimumPressDuration = 0.5f;
            [obj addGestureRecognizer:longPress];
        }
    }];
    self.textLabel.textColor = RGBCOLOR(31, 47, 88);
}

- (void)longPressed:(UIGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        return;
    } else if (sender.state == UIGestureRecognizerStateBegan) {
        ImageTouchView * view = (id)sender.view;
        if ([self.superTableView.delegate respondsToSelector:@selector(tableViewDidLongPressedImageAtIndexPath:tag:)]) {
            [self.superTableView.delegate performSelector:@selector(tableViewDidLongPressedImageAtIndexPath:tag:) withObject:self.indexPath withObject:view.tag];
        }
    }
}

- (UIImageView*)commentView {
    if (!_commentView) {
        _commentView = [[UIImageView alloc] init];
        _commentView.image = [LOADIMAGECACHES(@"bkg_coment") resizableImageWithCapInsets:UIEdgeInsetsMake(12, 26, 2, 2)];
        [self.contentView addSubview:_commentView];
    }
    return _commentView;
}

- (UIView*)commentbkgView {
    if (!_commentbkgView) {
        _commentbkgView = [[UIView alloc] init];
        [self.contentView addSubview:_commentbkgView];
    }
    return _commentbkgView;
}

- (UILabel*)labzan {
    if (!_labzan) {
        _labzan = [self defaultLabelWithTag:99 inView:self.contentView];
        [_labzan addSubview:[self iconZan]];
        [self.contentView addSubview:_labzan];
    }
    return _labzan;
}

- (UIImageView*)iconZan {
    if (!_iconZan) {
        _iconZan = [[UIImageView alloc] initWithImage:LOADIMAGECACHES(@"icon_zan_s")];
        _iconZan.origin = CGPointMake(1, 1);
    }
    return _iconZan;
}

- (TTTAttributedLabel*)defaultLabelWithTag:(NSInteger)tag inView:(UIView*)view{
    TTTAttributedLabel * tLabel = VIEWWITHTAG(view, tag);
    if (!tLabel) {
        tLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        tLabel.delegate = self;
        tLabel.tag = tag;
        tLabel.font = [UIFont systemFontOfSize:[[self class] sizeFontWithContent]];
        tLabel.textColor = [UIColor blackColor];
        tLabel.numberOfLines = 0;
        tLabel.textAlignment = NSTextAlignmentLeft;
        tLabel.backgroundColor = [UIColor clearColor];
        [view addSubview:tLabel];
    }
    tLabel.hidden = NO;
    return tLabel;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.origin = CGPointMake(10, 10);
    self.textLabel.text = self.item.name;
    
    self.imageView.top = 10;
    bkgtouchView.frame = self.contentView.bounds;
    self.textLabel.frame = CGRectMake(self.imageView.right + 10, 10, self.width - 90, 20);
    __block CGFloat originY = 34;
    labContent.text = @"";
    if (item.content.length > 0 ) {
        CGSize size = [self.item.content sizeWithFont:labContent.font maxWidth:self.width-90 maxNumberLines:0];
        labContent.frame = CGRectMake(self.textLabel.left, originY, size.width, size.height);
        originY += size.height + 4;
        labContent.text = self.item.content;
    }
    labContent.hidden = (item.content.length==0);
    [imageGridView.subviews enumerateObjectsUsingBlock:^(UIImageView *obj, NSUInteger idx, BOOL *stop) {
        obj.hidden = YES;
    }];
    imageGridView.hidden = (item.picsArray.count == 0);
    if (item.picsArray.count > 0) {
        // 排列 图片
        imageGridView.origin = CGPointMake(self.textLabel.left, originY);
        imageGridView.height = 0;
        if (item.picsArray.count > 0) {
            if (item.picsArray.count > 3) {
                imageGridView.height = 162;
            } else {
                imageGridView.height = 80;
            }
        }
        originY += imageGridView.height + 4;
    }
    
    CGFloat maxWidth = self.width - 90;
    // 排列位置
    labloc.hidden = YES;
    if (item.address&& item.address.address.length > 0) {
        originY += 4;
        if (!labloc) {
            labloc = [[UITouchableLabel alloc] initWithFrame:CGRectMake(labContent.left, originY, 0, 0)];
            labloc.font = [UIFont systemFontOfSize:[[self class] sizeFontWithTime]];
            labloc.textColor = RGBCOLOR(31, 47, 88);
            labloc.lineBreakMode = NSLineBreakByWordWrapping;
            labloc.numberOfLines = 0;
            labloc.textAlignment = NSTextAlignmentLeft;
            labloc.backgroundColor = [UIColor clearColor];
            labloc.touchdelegate = self;
            [self.contentView addSubview:labloc];
        }
        labloc.top = originY;
        labloc.hidden = NO;
        UIFont * font = [UIFont systemFontOfSize:[CircleMessageCell sizeFontWithTime]];
        CGSize size = [item.address.address sizeWithFont:font maxWidth:maxWidth maxNumberLines:0];
        labloc.size = size;
        labloc.text = item.address.address;
        originY+= size.height+ 4;
        
    }
        // 排列 时间
    labTime.top = btnTool.top = originY;
    labTime.left = self.textLabel.left;
    labTime.text = item.createtime;
    CGSize size = [labTime.text sizeWithFont:labTime.font maxWidth:150 maxNumberLines:1];
    labTime.size = size;
    btndel.left = labTime.right;
    btndel.top = labTime.top - 2;
    btndel.hidden = (![item.uid isEqualToString:[BSEngine currentUserId]]);
    originY += 23;
    __block CGFloat height = 0;
    CGFloat oy = originY;
    // 赞
    UIFont * font = [UIFont systemFontOfSize:[CircleMessageCell sizeFontWithContent]];
    NSMutableArray * zanarr = [NSMutableArray array];
    _labzan.hidden =
    _commentView.hidden = YES;
    if (item.praiselist.count > 0) {
        self.commentView.hidden = NO;
        self.labzan.hidden = NO;
        [item.praiselist enumerateObjectsUsingBlock:^(CircleZan * obj, NSUInteger idx, BOOL *stop) {
            [zanarr addObject:obj.nickname];
        }];
        
        NSString * str = [NSString stringWithFormat:@"     %@", [zanarr componentsJoinedByString:@", "]];
        CGFloat hei = [str sizeWithFont:font maxWidth:maxWidth maxNumberLines:0].height+4;
        _labzan.text = str;
        _labzan.frame = CGRectMake(labContent.left+5, originY+12, maxWidth-10, hei - 4);

         NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:@"[^%&',;]+" options:0 error:nil];
        [_labzan addLinksWithTextCheckingResults:[regex matchesInString:str options:0 range:NSMakeRange(0, [str length])] attributes:mutableLinkAttributes()];
        originY+= hei;
        height += hei;
    }
    
    // 评论
    
    _commentbkgView.hidden = (item.replylist.count == 0);
    [_commentbkgView.subviews enumerateObjectsUsingBlock:^(UILabel *obj, NSUInteger idx, BOOL *stop) {
        obj.text = @"";
        obj.hidden = YES;
    }];
    if (item.replylist.count > 0) {
        self.commentView.hidden = NO;
        self.commentbkgView.hidden = NO;
    }
    __block CGFloat bkgHeight = 0;
    _commentbkgView.origin = CGPointMake(labContent.left+5, ((_labzan&&!_labzan.hidden)?_labzan.bottom:originY+8)+4);
    [item.replylist enumerateObjectsUsingBlock:^(CircleComment * cc, NSUInteger idx, BOOL *stop) {
        NSString * say = [NSString stringWithFormat:@"%@: %@",cc.nickname, cc.content];
        CGFloat hei = [say sizeWithFont:font maxWidth:maxWidth maxNumberLines:0].height+4;
        TTTAttributedLabel * lab = [self defaultLabelWithTag:idx+100 inView:_commentbkgView];
        lab.frame = CGRectMake(0, bkgHeight, maxWidth - 10, hei-4);
        
        lab.text = say;
        NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:cc.nickname options:0 error:nil];
        NSTextCheckingResult * result = [regex firstMatchInString:cc.nickname options:0 range:NSMakeRange(0, cc.nickname.length)];
        if (result) {
            [lab addLinkWithTextCheckingResult:result attributes:mutableLinkAttributes()];
        }
        
        originY+= hei;
        height += hei;
        bkgHeight += hei;
    }];
    
    _commentbkgView.size = CGSizeMake(maxWidth-10, bkgHeight);
    _commentView.frame = CGRectMake(labContent.left, oy, maxWidth, height + 14);
    if (height != 0) {
    }
}

- (IBAction)btnPressed:(id)sender
{
    if ([self.superTableView.delegate respondsToSelector:@selector(tableView:didTapButtonAtIndexPath:)]) {
        [self.superTableView.delegate performSelector:@selector(tableView:didTapButtonAtIndexPath:) withObject:sender withObject:self.indexPath];
    }
}

//- (void)setDelegate:(id)_delegate {
//    delegate = _delegate;
//    gridView.delegate = _delegate;
//}

- (void)setImage:(UIImage*)image atIndex:(NSInteger)index
{
    ImageTouchView * subImageView = VIEWWITHTAG(imageGridView, (index+1));
    subImageView.tag = [NSString stringWithFormat:@"%d", (int)index];
    subImageView.contentMode =  UIViewContentModeScaleAspectFill;
    subImageView.clipsToBounds = YES;
    subImageView.image = image;
    subImageView.hidden = NO;
}

- (CGRect)imageFrameAtIndex:(NSInteger)index {
    ImageTouchView * subImageView = VIEWWITHTAG(imageGridView, (index+1));
    CGRect imageFrame = [self convertRect:subImageView.frame fromView:imageGridView];
    return imageFrame;
}

- (void)imageTouchViewDidSelected:(ImageTouchView*)sender {
    if ([sender.tag isEqualToString:@"bkgtouchView"]) {
        if ([self.superTableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
            [self.superTableView.delegate performSelector:@selector(tableView:didSelectRowAtIndexPath:) withObject:self.superTableView withObject:self.indexPath];
        }
    } else if ([self.superTableView.delegate respondsToSelector:@selector(tableViewDidTapImageAtIndexPath:tag:)]) {
        [self.superTableView.delegate performSelector:@selector(tableViewDidTapImageAtIndexPath:tag:) withObject:self.indexPath withObject:sender.tag];
    }
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)sender
didSelectLinkWithTextCheckingResult:(NSTextCheckingResult *)result {
    NSRange resultRange = [result rangeAtIndex:0];
    NSString *str = [[sender.text substringWithRange:resultRange] replaceSpace];
    [self.superTableView.delegate performSelector:@selector(statusDetailViewAction:) withObject:str];
}

#pragma mark - UITouchableLabelDelegate
- (void)touchableLabelLabel:(UITouchableLabel *)_label touchesWtihTag:(NSInteger)tag {
    [self.superTableView.delegate performSelector:@selector(didMapAtIndexPath:) withObject:self.indexPath];
}

@end
