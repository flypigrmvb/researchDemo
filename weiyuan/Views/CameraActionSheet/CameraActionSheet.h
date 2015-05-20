//
//  CmeraActionSheetController.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CameraActionSheetDelegate;

@interface CameraActionSheet : UIView

@property (nonatomic, strong) NSString * mark;
@property (nonatomic, strong) NSIndexPath * indexPath;
@property (nonatomic, strong) NSString * idx;
@property (nonatomic, strong) NSMutableArray *buttonTitles;
@property (nonatomic, assign) NSInteger cancelButtonIndex;
@property (nonatomic) NSInteger destructiveButtonIndex;
@property (nonatomic, assign) NSInteger numberOfButtons;
@property (nonatomic, assign) id <CameraActionSheetDelegate> delegate;

- (id)initWithActionTitle:(NSString*)actionTitle TextViews:(NSString*)textViews CancelTitle:(NSString*)cancelTitle withDelegate:(id)del otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

//- (void)showInView:(UIView*)view;
- (void)show;
- (void)hide:(UIButton*)sender;

@end

@protocol CameraActionSheetDelegate <NSObject>
- (void)cameraActionSheet:(CameraActionSheet *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex;
@end
