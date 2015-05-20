//
//  BaseTableViewCell.m
//
//  AppDelegate.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "BaseTableViewCell.h"
#import "KBadgeView.h"
#import "ImageGridInView.h"

@interface BaseTableViewCell ()
@end

@implementation BaseTableViewCell
@synthesize cornerRadius;
@synthesize newBadge;
@synthesize superTableView;
@synthesize newbadgeView;
@synthesize layoutBlock;
@synthesize customSwitch;
@synthesize switchON;
@synthesize topLineView;
@synthesize bottomLine;
@synthesize topLine;
@synthesize arrowlayer;
@synthesize hasUpdate;
@synthesize badgeValue;
@synthesize badgeView;
@synthesize labOther;
@dynamic indexPath;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self initialiseCell];
    }
    return self;
}

- (void)dealloc {
    self.className = nil;
    self.superTableView = nil;
    self.layoutBlock = nil;
    self.customSwitch = nil;
    self.bottomLineView = nil;
    self.arrowlayer = nil;
    self.badgeView = nil;
    self.newbadgeView = nil;
}

- (void)awakeFromNib {
    [self initialiseCell];
}

- (void)addArrowRight {
    if (!self.arrowlayer) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(self.width - 22, (self.height - 13)/2, 9, self.height);
        layer.contentsGravity = kCAGravityResizeAspect;
        layer.contents = (id)[UIImage imageNamed:@"arrow_right" isCache:YES].CGImage;
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
            layer.contentsScale = [[UIScreen mainScreen] scale];
        }
        [[self layer] addSublayer:layer];
        self.arrowlayer = layer;
    }
}

- (void)initialiseCell {
    self.hasUpdate = NO;
    UITapGestureRecognizer * recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headTapped:)];
    [self.imageView addGestureRecognizer:recognizer];
    self.imageView.userInteractionEnabled = YES;
    self.backgroundView = nil;
    
    self.contentView.backgroundColor =
    self.backgroundColor = [UIColor whiteColor];
    
    self.topLineView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 0.5)];
    topLineView.image = LOADIMAGECACHES(@"bkg_gray_line");
    topLineView.highlightedImage = LOADIMAGECACHES(@"bkg_gray_line");;
    [self.contentView addSubview:topLineView];
    
    [self.contentView bringSubviewToFront:topLineView];
    
    self.bottomLineView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.height - 0.5, self.width, 0.5)];
    self.bottomLineView.image = LOADIMAGECACHES(@"bkg_gray_line");
    self.bottomLineView.highlightedImage = LOADIMAGECACHES(@"bkg_gray_line");
    
    UIImageView * selectedView = [[UIImageView alloc] init];
    selectedView.frame = self.frame;
    selectedView.backgroundColor = [UIColor lightGrayColor];
    
    self.selectedBackgroundView = selectedView;
    
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.tag = 0;
    self.textLabel.font = [UIFont systemFontOfSize:15];
    self.textLabel.highlightedTextColor = [UIColor whiteColor];
    self.detailTextLabel.backgroundColor = [UIColor clearColor];
    self.detailTextLabel.tag = 1;
    self.detailTextLabel.numberOfLines = 0;
    self.detailTextLabel.font = [UIFont systemFontOfSize:14];
    self.detailTextLabel.textColor = RGBCOLOR(111, 111, 111);
    self.detailTextLabel.highlightedTextColor = [UIColor whiteColor];
    self.detailTextLabel.textAlignment = NSTextAlignmentLeft;
    self.textLabel.textColor = RGBCOLOR(0, 0, 0);
    [self setCornerRadius:3];
}

- (void)setTopLine:(BOOL)bl {
    if (bl) {
        [self.contentView addSubview:self.topLineView];
    } else {
        [self.topLineView removeFromSuperview];
    }
}

- (void)setBottomLine:(BOOL)bl {
    if (bl) {
        [self.contentView addSubview:self.bottomLineView];
    } else {
        [self.bottomLineView removeFromSuperview];
    }
}

- (UILabel*)labOther {
    if (!labOther) {
        labOther = [[UILabel alloc] init];
        labOther.highlightedTextColor =
        labOther.textColor = RGBCOLOR(111, 111, 111);
        labOther.textAlignment = NSTextAlignmentLeft;
        labOther.font = [UIFont systemFontOfSize:14];
        labOther.numberOfLines = 0;
        [self.contentView addSubview:labOther];
    }
    return labOther;
}

- (ImageGridInView*)groupHeadView {
    if (!_groupHeadView) {
        _groupHeadView = [ImageGridInView viewWithNum:0 isHead:YES];
        [self.imageView addSubview:_groupHeadView];
    }
    return _groupHeadView;
}

- (void)layoutSubviews {
    self.backgroundView.height =
    self.selectedBackgroundView.height =
    self.contentView.height = self.height;
    self.selectedBackgroundView.width = self.contentView.width = self.width;
    
    self.arrowlayer.frame = CGRectMake(self.width - 15, 0, 9, self.height);
    if (hasUpdate && !layoutBlock) {
        return;
    }
    self.imageView.frame = CGRectMake(4, (self.height - 40)/2, 40, 40);
    if (badgeView) {
        badgeView.origin = CGPointMake(self.imageView.right - 10, self.imageView.top - 6);
    }
    
    self.bottomLineView.width =
    self.topLineView.width = self.contentView.width;
    self.bottomLineView.top = self.height - 0.5;
    
    self.textLabel.frame = CGRectMake(10 + (self.imageView.hidden?0:40), 0.5, self.width - self.textLabel.left - 10, self.height-1);
    self.detailTextLabel.frame = CGRectMake(self.textLabel.left, self.imageView.hidden?0:29, self.textLabel.width, self.height);

    if (layoutBlock) {
        self.layoutBlock(@"layoutSubviews");
        self.layoutBlock = nil;
    }
    if (newbadgeView) {
        newbadgeView.origin = CGPointMake(self.imageView.right - 8, self.imageView.top - 6);
    }
}

- (void)addSwitch {
    if (!self.customSwitch) {
        self.customSwitch = [KLSwitch CustomSwitchWithOrigin:CGPointMake(self.width, (self.height - 31)/2)];
        customSwitch.tag = 999;
        [self.contentView addSubview:customSwitch];
    }
}

- (UIImageView*)newbadgeView {
    if (!newbadgeView) {
        newbadgeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,14, 14)];
        newbadgeView.image = LOADIMAGECACHES(@"msg_unread");
        [self.contentView addSubview:newbadgeView];
    }
    return newbadgeView;
}

- (void)setSwitchON:(BOOL)isOn {
    customSwitch.on = isOn;
}

- (void)setNewBadge:(BOOL)isNew {
    if (isNew) {
        [self.contentView bringSubviewToFront:self.newbadgeView];
    }
    if (newbadgeView) {
        newbadgeView.hidden = !isNew;
    }
    badgeView.text = nil;
}

- (KBadgeView*)badgeView {
    if (!badgeView) {
        badgeView = [[KBadgeView alloc] initWithFrame:CGRectMake(self.imageView.right - 6, self.imageView.top - 4, 7, 7)];
        [self.contentView addSubview:badgeView];
    }
    return badgeView;
}

- (void)setBadgeValue:(int)value {
    NSString *str = nil;
    if (value > 0) {
        str = [NSString stringWithFormat:@"%d",value];
    }
    [self.contentView bringSubviewToFront:badgeView];
    self.badgeView.text = str;
    newbadgeView.hidden = YES;
}

- (void)setCornerRadius:(NSInteger)value {
    cornerRadius = value;
    if (cornerRadius >= 0) {
        self.imageView.layer.masksToBounds = YES;
        self.imageView.layer.borderWidth = 0;
        self.imageView.layer.cornerRadius = cornerRadius;
        self.imageView.clipsToBounds = YES;
    }
}

- (void)update:(layoutCellView)block {
    self.hasUpdate = YES;
    self.layoutBlock = block;
}

- (void)autoAdjustText {
    self.textLabel.font = [UIFont systemFontOfSize:15];
    self.detailTextLabel.font = [UIFont systemFontOfSize:14];
    self.textLabel.top = 11;
    self.textLabel.height = 18;
    self.detailTextLabel.left = self.textLabel.left;
    self.detailTextLabel.top = 31;
    self.detailTextLabel.height = 16;
    self.detailTextLabel.width = self.width - 60;
    self.detailTextLabel.numberOfLines = 1;
}

- (void)setNumberOfGroupHead:(NSInteger)number {
    if (_numberOfGroupHead != number) {
        _numberOfGroupHead = number;
        self.groupHeadView.numberOfItems = number;
    }
}

- (void)setImage:(UIImage *)image AtPosition:(NSInteger)pos {
    [[self groupHeadView] setImage:image forIndex:pos];
}

- (void)enableLongPress {
    UILongPressGestureRecognizer *longPress =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(longPressed:)];
    longPress.delegate = self;
    longPress.minimumPressDuration = 0.5f;
    [self.contentView addGestureRecognizer:longPress];
}

- (void)longPressed:(UIGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        return;
    } else if (sender.state == UIGestureRecognizerStateBegan) {
        if ([superTableView.delegate respondsToSelector:@selector(tableView:handleTableviewCellLongPressed:)]) {
            [superTableView.delegate performSelector:@selector(tableView:handleTableviewCellLongPressed:) withObject:superTableView withObject:self.indexPath];
        }
    }
}

- (void)headTapped:(UITapGestureRecognizer*)recognizer {
    if ([superTableView.delegate respondsToSelector:@selector(tableView:didTapHeaderAtIndexPath:)]) {
        [superTableView.delegate performSelector:@selector(tableView:didTapHeaderAtIndexPath:) withObject:superTableView withObject:self.indexPath];
    } else {
        if ([superTableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
            [superTableView.delegate performSelector:@selector(tableView:didSelectRowAtIndexPath:) withObject:superTableView withObject:self.indexPath];
        }
    }
}

- (NSIndexPath*)indexPath {
    return [[self superTableView] indexPathForCell:self];
}

@end
