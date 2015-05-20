//
//  CollectionDetailViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "CollectionDetailViewController.h"
#import "ImageTouchView.h"
#import "TextInput.h"
#import "Favorite.h"
#import "UIImageView+WebCache.h"
#import "Globals.h"
#import "MenuView.h"
#import <AVFoundation/AVFoundation.h>
#import "ImagePhotoViewController.h"
#import "LDProgressView.h"
#import "AudioMsgPlayer.h"
#import "Message.h"
#import "ImageViewController.h"

@interface CollectionDetailViewController () {
    IBOutlet UILabel * nameLabel;
    IBOutlet UILabel * favtimeLab;
    IBOutlet KTextView * contentLabel;
    IBOutlet ImageTouchView * touchView;
    IBOutlet UIImageView * headImageView;
    IBOutlet UIView * audioPlayView;
    IBOutlet UILabel * timeLab;
    IBOutlet UIButton * playBtn;
    LDProgressView *progressView;
    NSTimer * timer;
}
@property (nonatomic, assign) double time;
@end

@implementation CollectionDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"详情";
    [self setEdgesNone];
    audioPlayView.layer.masksToBounds = YES;
    audioPlayView.layer.cornerRadius = 2;
    audioPlayView.layer.borderWidth = 1;
    audioPlayView.layer.borderColor = RGBCOLOR(220, 220, 220).CGColor;
    [headImageView sd_setImageWithUrlString:_item.headsmall placeholderImage:[Globals getImageUserHeadDefault]];
    if (_item.typefile == forFileImage) {
        touchView.hidden = NO;
        contentLabel.hidden = YES;
    } else {
        contentLabel.text = _item.content;
    }
    [touchView sd_setImageWithUrlString:_item.imgUrl placeholderImage:[Globals getImageDefault]];
    nameLabel.text = _item.nickname;
    favtimeLab.text = [Globals timeStringForListWith:_item.createtime.doubleValue];
    [self setRightBarButtonImage:LOADIMAGE(@"btn_more") highlightedImage:nil selector:@selector(menu)];
    if (_item.typefile == forFileVoice) {
        _time = _item.voiceTime.intValue;
        NSString * time = nil;
        if (_time > 9) {
            time = [NSString stringWithFormat:@"%.f", ceil(_time)];
        } else {
            time = [NSString stringWithFormat:@"0%.f", ceil(_time)];
        }
        timeLab.text = [NSString stringWithFormat:@"00:%@",time];
        audioPlayView.hidden = NO;
        progressView = [[LDProgressView alloc] initWithFrame:CGRectMake(80, 14, 198, 2)];
        progressView.showText = @NO;
        progressView.progress = 0.0;
        progressView.borderRadius = @0;
        progressView.color = kbColor;
        [audioPlayView addSubview:progressView];
    }
}

- (IBAction)play:(UIButton*)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        
        [AudioMsgPlayer playWithURL:_item.voiceUrl delegate:nil];
        _time = _item.voiceTime.intValue;
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0/24 target:self selector:@selector(repeat:) userInfo:nil repeats:YES];
    } else {
        [AudioMsgPlayer cancel];
        _time = 0;
        [self repeat:nil];
    }
}

- (void)popViewController {
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    [super popViewController];
    _black = nil;
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	刷新[获取时间]计数
 *
 *	@param 	tr 	计时器对象
 */
- (void)repeat:(NSTimer*)tr
{
    if (_time <= 0) {
        _time = _item.voiceTime.intValue;
        NSString * time = nil;
        if (_time > 9) {
            time = [NSString stringWithFormat:@"%.f", _time];
        } else {
            time = [NSString stringWithFormat:@"0%.f", _time];
        }
        timeLab.text = [NSString stringWithFormat:@"00:%@",time];
        if (timer) {
            [timer invalidate];
            timer = nil;
        }
        [AudioMsgPlayer cancel];
        progressView.progress = 0;
        playBtn.selected = NO;
    } else {
        double t = (double)1/(double)24;
        _time = _time - t;
        NSString * time = nil;
        if (_time > 9) {
            time = [NSString stringWithFormat:@"%.f", ceil(_time)];
        } else {
            time = [NSString stringWithFormat:@"0%.f", ceil(_time)];
        }
        timeLab.text = [NSString stringWithFormat:@"00:%@",time];
        progressView.progress = (_item.voiceTime.doubleValue-_time)/_item.voiceTime.doubleValue;

    }
}

- (void)menu {
    NSArray * arr = nil;
    if (_item.typefile == forFileText) {
        arr = @[@"发送给朋友", @"复制", @"删除"];
    } else {
        arr = @[@"发送给朋友", @"删除"];
    }
    MenuView * menuView = [[MenuView alloc] initWithButtonTitles:arr withDelegate:self];
    menuView.hasImage = NO;
    [menuView showInView:self.view origin:CGPointMake(self.view.width - 180, Sys_Version>=7?64:0)];
}

- (void)imageTouchViewDidSelected:(UIView*)sender {
//    ImagePhotoViewController * con = [[ImagePhotoViewController alloc] initWithPicArray:@[_item.imgUrl] defaultIndex:0];
//    [con showFromView:sender];
    
    
    CGRect cellF = [self.view convertRect:sender.frame toView:self.navigationController.view];
    ImageViewController * con = [[ImageViewController alloc] initWithFrameStart:cellF supView:self.navigationController.view pic:nil preview:_item.imgUrl];
    con.bkgImage = [self.view screenshot];
    [self presentModalController:con animated:NO];
    
}

- (void)popoverView:(MenuView *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        Message * msg = [[Message alloc] init];
        if (_item.typefile == forFileText) {
            msg.content = contentLabel.text;
        } else if (_item.typefile == forFileAddress) {
            msg.content = @"[位置]";
            msg.address = _item.address;
        } else if (_item.typefile == forFileImage) {
            msg.content = @"[图片]";
            msg.value = touchView.image;
            msg.imgUrlS = nil;
        } else if (_item.typefile == forFileVoice) {
            msg.content = @"[声音]";
            msg.voiceTime = _item.voiceTime;
            msg.voiceUrl = _item.voiceUrl;
        }
        msg.typefile = _item.typefile;
        [self forwordWithMsg:msg];
    } else {
        if (_item.typefile == forFileText) {
            if (buttonIndex == 1) {
                [[UIPasteboard generalPasteboard] setString:_item.content];
            } else {
                [super startRequest];
                [client deleteFavorite:_item.fid];
            }
        } else {
            [super startRequest];
            [client deleteFavorite:_item.fid];
        }
    }

}

- (BOOL)requestDidFinish:(BSClient*)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        [self showText:sender.errorMessage];
        if (_black) {
            _black(_item);
        }
        [self popViewController];
    }
    return YES;
}
@end
