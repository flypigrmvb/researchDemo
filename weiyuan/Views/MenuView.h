//
//  MenuView.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MenuViewDelegate;

@interface MenuView : UIView

@property (nonatomic, strong) UITableView * buttonView;
@property (nonatomic, strong) NSMutableArray *buttonTitles;
@property (nonatomic, assign) NSInteger numberOfButtons;
@property (nonatomic, assign) BOOL hasImage;
@property (nonatomic, assign) id <MenuViewDelegate> delegate;
@property (nonatomic, strong) UIImageView  * bkgView;

- (id)initWithButtonTitles:(NSArray *)titlesArray withDelegate:(id)del;
- (void)showInView:(id)view origin:(CGPoint)origin;
- (void)hide;

@end

@protocol MenuViewDelegate <NSObject>
@optional
- (void)popoverView:(MenuView *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex;
- (void)popoverViewCancel:(MenuView *)sender;
@end
