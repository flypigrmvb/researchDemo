//
//  ChatMessagesCell.m
//
//  AppDelegate.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "ChatMessagesCell.h"
#import "ImageTouchView.h"
#import "Globals.h"
#import "UIImage+FlatUI.h"
#import "UIColor+FlatUI.h"
#import "Message.h"
#import "JSON.h"

@interface ChatMessagesCell ()<ImageTouchViewDelegate> {
    UIImageView * imageContentView;
    UIImageView * audioView;
    UIImageView * errorView;
    UILabel * labTip; // 提示或者时间
}
@property (nonatomic, strong) UILabel * contentLabel;
@property (nonatomic, strong) ImageTouchView *touchView;
@end
@implementation ChatMessagesCell
@synthesize right, loading, state, playing, hasSubsImage, detailText, createTime, conImage, audioLength, timeText;
@synthesize imageFrame, imageSize;
@synthesize touchView;

+ (CGFloat)heightForMessage:(Message*)item {
    CGFloat height = 0;
    if (item.typefile == forFileText) {
        CGFloat maxWidth = 220;
        CGSize textSize = [item.content sizeWithFont:[UIFont systemFontOfSize:15] maxWidth:maxWidth maxNumberLines:0];
        height = textSize.height + 8; // 文字上下间隙
        if (textSize.height < 65) {
            height = 65;
        }
        height += 10; // touchView上下间隙
    } else if (item.typefile == forFileImage) {
        height = item.imgHeight/2 + 16;
    } else if (item.typefile == forFileVoice) {
        height = 70;
    } else if (item.typefile == forFileAddress) {
        height = 128;
    } else if (item.typefile == forFileNameCard) {
        height = 96;
    }
    return height;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.touchView = [[ImageTouchView alloc] initWithFrame:CGRectMake(self.width - 80, 8, 10 , 10) delegate:self];
        self.touchView.backgroundColor = [UIColor clearColor];
        touchView.contentMode = UIViewContentModeScaleToFill;
        [self.contentView addSubview:touchView];
        
        UILongPressGestureRecognizer *longPress =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(longPressed:)];
        longPress.delegate = self;
        longPress.minimumPressDuration = 1.0f;
        [touchView addGestureRecognizer:longPress];
        
        imageContentView = [[UIImageView alloc] init];
        imageContentView.clipsToBounds = YES;
        imageContentView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        imageContentView.layer.masksToBounds = YES;
        imageContentView.layer.borderWidth = 0;
        imageContentView.layer.cornerRadius = 3;
        [touchView addSubview:imageContentView];
    }
    return self;
}

- (void)dealloc {
    Release(detailText);
    Release(createTime);
    Release(conImage);
    
    self.touchView = nil;
    Release(imageContentView);
    Release(audioView);
}

- (void)initialiseCell {
    [super initialiseCell];
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.borderWidth = 0;
    self.imageView.layer.cornerRadius = 5;
    self.imageView.frame = CGRectMake(10, 10, 50, 50);
    self.contentView.backgroundColor =
    self.backgroundColor = RGBCOLOR(247, 247, 247);
    errorView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
    errorView.image = LOADIMAGECACHES(@"talk_send_failed");
    errorView.hidden = YES;
    [self.contentView addSubview:errorView];
    
    labTip = [[UILabel alloc] initWithFrame:CGRectMake(120, -23, 80, 18)];
    labTip.layer.masksToBounds = YES;
    labTip.layer.borderWidth = 0;
    labTip.layer.cornerRadius = 4;
    labTip.backgroundColor = RGBACOLOR(163, 163, 163, 0.5);
    labTip.textColor = [UIColor whiteColor];
    labTip.textAlignment = NSTextAlignmentCenter;
    labTip.font = [UIFont systemFontOfSize:12];
    labTip.hidden = YES;

    [self.contentView addSubview:labTip];
}

- (void)setTimeText:(NSString *)time {
    timeText = time;
    labTip.hidden = time?NO:YES;
    if (time) {
        // 提示时间
        labTip.text = time;
        CGSize size = [time sizeWithFont:labTip.font constrainedToSize:CGSizeMake(200, 20)];
        CGRect fra = labTip.frame;
        fra.size.width = size.width + 20;
        fra.origin.x = 160 - fra.size.width / 2;
        labTip.frame = fra;
    }
}

- (void)setItem:(Message *)item {
    _item = item;
    self.timeText = nil;
    self.right = item.isSendByMe;
    if (item.typefile == forFileText) {
        self.contentLabel.text = item.content;
    } else if (item.typefile == forFileVoice) {
        self.contentLabel.text = [NSString stringWithFormat:@"%@\"", item.voiceTime];
        self.audioLength = [item.voiceTime doubleValue];
    } else if (item.typefile == forFileAddress) {
        self.contentLabel.text = item.address.address;
        self.conImage = LOADIMAGECACHES(@"location_msg");
    } else if (item.typefile == forFileVoice) {
        self.imageSize = CGSizeMake(37, 37);
        self.imageSize = CGSizeZero;
        self.audioLength = [item.voiceTime doubleValue];
        self.contentLabel.text = [NSString stringWithFormat:@"%@\"", item.voiceTime];
    } else if (item.typefile == forFileNameCard) {
        self.imageSize = CGSizeMake(80, 80);
        if (!item.value) {
            item.value = [JSON objectFromJSONString:item.content];
        }
        self.contentLabel.text = [item.value getStringValueForKey:@"nickname" defaultValue:@""];
    }
    self.state = item.state;
    
}

- (UILabel*)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.tag = 9;
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.textColor = [UIColor blackColor];
        _contentLabel.numberOfLines = 0;
        _contentLabel.textAlignment = NSTextAlignmentLeft;
        _contentLabel.backgroundColor = [UIColor wetAsphaltColor];
        _contentLabel.font = [UIFont systemFontOfSize:15];
        [touchView addSubview:_contentLabel];
    }
    return _contentLabel;
}

- (void)layoutSubviews {
    self.contentView.height = self.height;
    
    // textLabel替代
    _contentLabel.hidden = YES;

    // 名片用的背景
    UIView * bkgView = VIEWWITHTAG(touchView, 10);
    bkgView.hidden = YES;
    // 名片用的名字
    UILabel * detailTextLabel = VIEWWITHTAG(touchView, 11);
    detailTextLabel.hidden = YES;
    // 名片用的分割线
    UIView * lineView = VIEWWITHTAG(touchView, 12);
    lineView.hidden = YES;
    
    // 地图用的地址
    UILabel * addressTextLabel = VIEWWITHTAG(touchView, 13);
    addressTextLabel.hidden = YES;

    self.imageView.origin = CGPointMake(right?self.width-self.imageView.width - 10:12, 5);
    
    imageContentView.hidden = audioView.hidden = YES;

    CGSize size = CGSizeZero;
    detailTextLabel.text = nil;
    // 计算与赋予
    if (_item.typefile == forFileText) {
        CGFloat maxWidth = 220;
        size = [_contentLabel.text sizeWithFont:[UIFont systemFontOfSize:15] maxWidth:maxWidth maxNumberLines:0];
    } else if (_item.typefile == forFileImage) {
        size = CGSizeMake(imageSize.width/2, imageSize.height/2);
    } else if (_item.typefile == forFileAddress) {
        size = CGSizeMake(200, 120);
    } else if (_item.typefile == forFileVoice) {
        // audioLength/10*18
        CGFloat len = 16 + audioLength/10*18;
        CGSize audioSize = [[NSString stringWithFormat:@"%d'", (int)len] sizeWithFont:[UIFont systemFontOfSize:15] maxWidth:180 maxNumberLines:0];
        size = CGSizeMake(len + audioSize.width, 23);
        _contentLabel.text = [NSString stringWithFormat:@"%d'", (int)audioLength];
    }  else if (_item.typefile == forFileNameCard) {
        size = CGSizeMake(self.width - 150, 78);
        _contentLabel.text = @"名片";
    }
    
    // 设置 touchView 大小
    if (_item.typefile == forFileImage || _item.typefile == forFileAddress) {
        touchView.size = size;
    } else {
        touchView.size = CGSizeMake(size.width + 14.f, size.height + 10.f);
    }
    
    // 设置 touchView 坐标
    NSString * imageName = nil;
    if (right) {
        touchView.origin = CGPointMake(self.imageView.left - size.width - 24, 4);
        if (_item.typefile == forFileImage || _item.typefile == forFileAddress) {
            imageName = @"bkg_image_msg_R";
        } else {
            imageName = @"bkg_message_msg_R";
        }
        touchView.edgingImage = [LOADIMAGECACHES(imageName) resizableImageWithCapInsets:UIEdgeInsetsMake(10, 4, 4, 10)];
    } else {
        touchView.origin = CGPointMake(self.imageView.right + 10, 4);
        if (_item.typefile == forFileImage || _item.typefile == forFileAddress) {
            imageName = @"bkg_image_msg_L";
        } else {
            imageName = @"bkg_message_msg_L";
        }
        touchView.edgingImage = [LOADIMAGECACHES(imageName) resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 4, 4)];
    }
    
    self.imageFrame = touchView.frame;
    
    _contentLabel.hidden = (_item.typefile == forFileImage);
    _contentLabel.textColor = [UIColor blackColor];
    _contentLabel.font = [UIFont systemFontOfSize:15];
    _contentLabel.backgroundColor = [UIColor clearColor];
    // _contentLabel界面
    if (_item.typefile == forFileText) {
        _contentLabel.frame = CGRectMake(right?4:10, 5, size.width, size.height);
    } else if (_item.typefile == forFileVoice) {
        if (audioView == nil) {
            audioView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 14, 23)];
            audioView.animationRepeatCount = 0;
            audioView.animationDuration = 1.5;
            [touchView addSubview:audioView];
        }
        
        if (right) {
            audioView.origin = CGPointMake(touchView.width - audioView.width - 12, (touchView.height - audioView.height)/2);
        } else {
            audioView.origin = CGPointMake(12, (touchView.height - audioView.height)/2);
        }
        
        audioView.hidden = NO;
        NSString * direct;
        if (right) {
            direct = @"r";
        } else {
            direct = @"l";
        }
        NSString * path = [NSString stringWithFormat:@"talk_%@_voice2", direct];
        audioView.image = [UIImage imageNamed:path];
        NSMutableArray * imgs = [NSMutableArray array];
        for (int i = 0; i < 3; i++) {
            NSString * path = [NSString stringWithFormat:@"talk_%@_voice%d", direct, i];
            UIImage * im = [UIImage imageNamed:path];
            [imgs addObject:im];
        }
        audioView.animationImages = imgs;
        
        CGFloat textLen = [[NSString stringWithFormat:@"%d'", (int)audioLength] sizeWithFont:[UIFont systemFontOfSize:15] maxWidth:175 maxNumberLines:0].width;
        _contentLabel.frame = CGRectMake(right?touchView.width - textLen - 6 - 23:textLen + 16, 5, textLen, size.height);
    } if (_item.typefile == forFileAddress) {
        imageContentView.hidden = NO;
        imageContentView.frame = CGRectMake(0, 0, size.width, size.height);
        addressTextLabel.hidden = NO;
        if (!addressTextLabel) {
            addressTextLabel = [[UILabel alloc] init];
            addressTextLabel.backgroundColor  = RGBACOLOR(0, 0, 0, 0.4);
            addressTextLabel.font = [UIFont systemFontOfSize:12];
            addressTextLabel.textAlignment = NSTextAlignmentCenter;
            addressTextLabel.textColor = [UIColor whiteColor];
            addressTextLabel.tag = 13;
            [touchView addSubview:detailTextLabel];
        }
        addressTextLabel.text = _contentLabel.text;
        addressTextLabel.frame = CGRectMake(0, touchView.height - 20, touchView.width, 20);
    } else if (_item.typefile == forFileImage) {
        imageContentView.hidden = NO;
        imageContentView.frame = CGRectMake(0, 0, size.width, size.height);
        _contentLabel.text = nil;
    } else if (_item.typefile == forFileNameCard) {
        imageContentView.hidden = NO;
        bkgView.hidden = NO;
        if (!bkgView) {
            bkgView = [[UIView alloc] initWithFrame:CGRectMake(2, 2, 0, 0)];
            bkgView.layer.cornerRadius = 4;
            bkgView.backgroundColor = [UIColor whiteColor];
            bkgView.tag = 10;
            [touchView addSubview:bkgView];
        }
        detailTextLabel.hidden = NO;
        if (!detailTextLabel) {
            detailTextLabel = [[UILabel alloc] init];
            detailTextLabel.backgroundColor = [UIColor clearColor];
            detailTextLabel.font = [UIFont systemFontOfSize:15];
            detailTextLabel.tag = 11;
            [touchView addSubview:detailTextLabel];
        }
        detailTextLabel.text = [_item.value getStringValueForKey:@"nickname" defaultValue:@""];
        
        lineView.hidden = NO;
        if (!lineView) {
            lineView = [[UIView alloc] init];
            lineView.tag = 12;
            lineView.backgroundColor = RGBCOLOR(230, 230, 230);
            [touchView addSubview:lineView];
        }
        
        _contentLabel.textColor = RGBCOLOR(149, 149, 149);
        _contentLabel.frame = CGRectMake(right?10:18 , 8, 100, 15);
        imageContentView.frame = CGRectMake(right?10:18, touchView.height - 50, 40, 40);
        detailTextLabel.frame = CGRectMake(right?55:62, touchView.height - 50, self.width - 200, 40);
        bkgView.frame = CGRectMake(right?2:8,2,touchView.width - 10, touchView.height - 4);
        lineView.frame = CGRectMake(right?12:18, imageContentView.top-5, touchView.width - 34, 1);
        [touchView bringSubviewToFront:_contentLabel];
    }
    
    [imageContentView removeFromSuperview];
    if (_item.typefile == forFileNameCard) {
        [touchView insertSubview:imageContentView aboveSubview:bkgView];
    } else if (conImage) {
        [touchView insertSubview:imageContentView atIndex:0];
    }
    _contentLabel.hidden = YES;
    if (addressTextLabel && !addressTextLabel.hidden) {
        [addressTextLabel removeFromSuperview];
        [touchView insertSubview:addressTextLabel belowSubview:touchView.edgingImageView];
    } else {
        _contentLabel.hidden = NO;
    }
    touchView.clipsToBounds = YES;
    
    errorView.hidden = (state != forMessageStateError);
    if (!errorView.hidden) {
        errorView.origin = CGPointMake(touchView.left - 20, touchView.height/2);
    }
    
    UILabel *nameLab = VIEWWITHTAG(self.contentView, 541);
    nameLab.hidden = YES;
    if (!right) {
        if (_personName) {
            nameLab.hidden = NO;
            if (!nameLab) {
                nameLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 18)];
                [self.contentView addSubview:nameLab];
                nameLab.backgroundColor = [UIColor clearColor];
                nameLab.font = [UIFont systemFontOfSize:13];
                nameLab.textColor = [UIColor lightGrayColor];
                nameLab.tag = 541;
            }
            nameLab.text = _personName;
            nameLab.origin = CGPointMake(self.imageView.right + 10, 4);
            touchView.top = 26;
        }
    }
}

- (void)setConImage:(UIImage *)conimage {
    [self.contentView bringSubviewToFront:imageContentView];
    if (!conimage) {
        conimage = [UIImage imageWithColor:[UIColor grayColor] cornerRadius:0];
        conImage = [conimage copy];
        imageContentView.contentMode = UIViewContentModeScaleAspectFill;
    } else if (conImage != conimage) {
        imageContentView.contentMode = UIViewContentModeScaleAspectFit;
        conImage = [conimage copy];
        imageContentView.image = conimage;
    }
}

- (void)setLoading:(BOOL)ld {
    loading = ld;
}

- (void)setState:(MessageState)_state {
    state = _state;
    touchView.userInteractionEnabled = YES;
    [UIView animateWithDuration:0.3 animations:^{
        switch (_state) {
            case forMessageStateNormal:
                imageContentView.alpha = 1.;
                break;
            case forMessageStateError:
                imageContentView.alpha = 0.6;
                break;
            default:
                break;
        }
    }];
}

- (void)setPlaying:(BOOL)pl {
    if (audioView) {
        if (pl) {
            [audioView startAnimating];
        } else {
            [audioView stopAnimating];
        }
    }
}

- (void)longPressed:(UIGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        return;
    } else if (sender.state == UIGestureRecognizerStateBegan) {
        if ([self.superTableView.delegate respondsToSelector:@selector(tableView:handleTableviewCellLongPressed:)]) {
            [self.superTableView.delegate performSelector:@selector(tableView:handleTableviewCellLongPressed:) withObject:self.superTableView withObject:self.indexPath];
        }
    }
}

- (void)imageTouchViewDidSelected:(id)sender {
    if ([self.superTableView.delegate respondsToSelector:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)]) {
        [self.superTableView.delegate tableView:self.superTableView accessoryButtonTappedForRowWithIndexPath:self.indexPath];
    }
}

@end
