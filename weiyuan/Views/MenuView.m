//
//  MenuView.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "MenuView.h"
#import "BSEngine.h"
#import "BSClient.h"
#import "UIImage+FlatUI.h"
#import "BaseTableViewCell.h"
#import "ImageTouchView.h"
#import "Globals.h"

@interface MenuView () <UITableViewDataSource, UITableViewDelegate, ImageTouchViewDelegate>
@property (nonatomic, strong) UIImageView * blackView;
@property (nonatomic, strong) UIImageView * backgroundView;
@property (nonatomic, assign) CGFloat maximumButtonHeight;
@property (nonatomic, assign) CGFloat maximumButtonWidth;
@property (nonatomic, assign) int playCount;
@end

@implementation MenuView
@synthesize delegate, bkgView, maximumButtonHeight, maximumButtonWidth, buttonTitles;

- (id)initWithButtonTitles:(NSArray *)titlesArray withDelegate:(id)del
{
    CGRect rect = [UIScreen mainScreen].bounds;
    self = [self initWithFrame:rect];
    if (self) {
        _hasImage = YES;
        //  Minimum Button Height
        maximumButtonHeight = 42;
        //  Maximum button width
        maximumButtonWidth = 158;
        
        self.delegate = del;
        self.buttonTitles = [NSMutableArray arrayWithArray:titlesArray];
        
        //  1. Add bkgView
        [self addSubview:[self bkgView]];
        
        //  2.
        [self addSubview:[self backgroundView]];
        
        // 3. Add buttonView
        [_backgroundView addSubview:[self buttonView]];
        
        self.numberOfButtons = buttonTitles.count;
        [[self buttonView] reloadData];
        self.playCount = 2;
    }
    return self;
}

- (void)dealloc {
    self.delegate = nil;
    self.bkgView = nil;
    self.buttonTitles = nil;
}

- (UIImageView*)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 168, [self getHeight]+10)];
        _backgroundView.image = [UIImage imageWithColor:RGBCOLOR(34, 34, 34) cornerRadius:5];
        _backgroundView.userInteractionEnabled = YES;
        _backgroundView.clipsToBounds = YES;
    }
    return _backgroundView;
}

- (UIScrollView*)buttonView {
    if (!_buttonView) {
        _buttonView = [[UITableView alloc] initWithFrame:CGRectMake(5, 5, maximumButtonWidth, [self getHeight])];
        _buttonView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _buttonView.delegate = self;
        _buttonView.dataSource = self;
        _buttonView.showsVerticalScrollIndicator = NO;
        _buttonView.backgroundColor = [UIColor clearColor];
    }
    return _buttonView;
}

- (UIImageView*)blackView {
    if (!_blackView) {
        UIWindow * win = [[UIApplication sharedApplication] keyWindow];
        _blackView = [[ImageTouchView alloc] initWithFrame:CGRectMake(0, 0, win.bounds.size.width, 64) delegate:self];
        _blackView.backgroundColor = [UIColor clearColor];
        _blackView.userInteractionEnabled = YES;
        _blackView.clipsToBounds = YES;
        [win addSubview:_blackView];
    }
    return _blackView;
}

- (CGFloat)getHeight {
    return buttonTitles.count*maximumButtonHeight;
}

- (UIImageView*)bkgView {
    if (!bkgView) {
        bkgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, Main_Screen_Width, Main_Screen_Height)];
        bkgView.backgroundColor = [RGBCOLOR(34, 34, 34) colorWithAlphaComponent:0.7];
        bkgView.userInteractionEnabled = YES;
        bkgView.layer.masksToBounds = YES;
        bkgView.alpha = 0;
    }
    return bkgView;
}


#pragma mark - UIResponder Delegate
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self hide];
    if([delegate respondsToSelector:@selector(popoverViewCancel:)]){
        [delegate popoverViewCancel:self];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

#pragma mark - ImageTouchViewDelegate
- (void)imageTouchViewDidSelected:(id)sender {
    [self touchesEnded:nil withEvent:nil];
}

#pragma mark - tableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return maximumButtonHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.buttonTitles.count;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"UserCell";
    BaseTableViewCell * cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        sender.separatorStyle = UITableViewCellSeparatorStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
    }
    cell.textLabel.text = self.buttonTitles[indexPath.row];
    cell.imageView.hidden = !_hasImage;
    [cell update:^(NSString *name) {
        cell.textLabel.textColor = [UIColor whiteColor];
        if (self.tag == -1 && indexPath.row == 0) {
            cell.imageView.frame = CGRectMake(5, 5, cell.height - 10, cell.height - 10);
            cell.textLabel.left = cell.height;
        } else {
            cell.imageView.frame = CGRectMake(5, (cell.height - 18)/2, 20, 18);
            cell.textLabel.left = _hasImage?32:10;
        }
        cell.contentView.backgroundColor =
        cell.backgroundColor = RGBCOLOR(34, 34, 34);
        cell.textLabel.top = 0;
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.height = cell.height;
        cell.topLineView.image = cell.topLineView.highlightedImage = [UIImage imageWithColor:RGBCOLOR(46, 46, 46) cornerRadius:0];
        cell.selectedBackgroundView.backgroundColor = RGBCOLOR(46, 46, 46);
        cell.topLineView.frame = CGRectMake(0, cell.height-1, cell.width, 1);
        if (indexPath.row == self.buttonTitles.count - 1) {
            [cell setTopLine:NO];
        } else {
            [cell setTopLine:YES];
        }
    }];
    return cell;
}

- (void)tableView:(UITableView *)sender willDisplayCell:(BaseTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tag == -1 && indexPath.row == 0) {
        cell.imageView.image = [Globals getImageUserHeadDefault];
        [Globals imageDownload:^(UIImage * image) {
            if (image) {
                cell.imageView.image = image;
            }
        } url:[BSEngine currentUser].headsmall];
    } else {
        cell.imageView.image = LOADIMAGE(cell.textLabel.text);
    }
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    [self hide];
    if([delegate respondsToSelector:@selector(popoverView:didDismissWithButtonIndex:)]){
        [delegate popoverView:self didDismissWithButtonIndex:indexPath.row];
    }
}

#pragma mark - Presentation

- (void)showInView:(UIView*)view origin:(CGPoint)origin {
    self.blackView.alpha = 0;
    _backgroundView.top = - 200;
    _backgroundView.left = origin.x;
    [view addSubview:self];
    [UIView
     animateWithDuration:0.3
     animations:^{
         self.blackView.alpha = 1;
         [_backgroundView setTransform:CGAffineTransformTranslate(_backgroundView.transform, 0, 200)];              bkgView.alpha = 1;
     } completion:^(BOOL finished) {
         [self playagain];
     }];
}

- (void)playagain {
    CGFloat far;
    if (self.playCount==0) {
        return;
    }
    far = 15.f-(15/self.playCount);
    if (self.playCount > 0) {
        self.playCount --;
    } else {
        return;
    }
    [UIView
     animateWithDuration:0.15
     animations:^{
         [_backgroundView setTransform:CGAffineTransformTranslate(_backgroundView.transform, 0, -far)];
     } completion:^(BOOL finished) {
         [UIView
          animateWithDuration:0.15
          animations:^{
              [_backgroundView setTransform:CGAffineTransformTranslate(_backgroundView.transform, 0, far)];
              bkgView.alpha = 1;
          } completion:^(BOOL finished) {
              if (finished) {
                  [self playagain];
              }
          }];
     }];
}

- (void)hide {
    // Animate everything out of place
    
    [UIView
     animateWithDuration:0.3
     animations:^{
         self.blackView.alpha = 0;
         _backgroundView.top = -_buttonView.height;
         bkgView.alpha = 0;
     } completion:^(BOOL finished) {
         if (finished) {
             [_blackView removeFromSuperview];
             [self removeFromSuperview];
         }
     }];
}

@end