//
//  ImageTouchView.h
//
//  AppDelegate.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImageTouchViewDelegate <NSObject>
/**点击图片的代理回调协议*/
- (void)imageTouchViewDidSelected:(id)sender;
@optional
- (void)imageTouchViewDidBegin:(id)sender;
- (void)imageTouchViewDidCancel:(id)sender;
@end

@interface ImageTouchView : UIImageView {
    IBOutlet id <ImageTouchViewDelegate> delegate;
}
@property (nonatomic, strong) NSString * tag;
@property (nonatomic, strong) NSIndexPath * indexPath;
@property (nonatomic, strong) UIImageView * edgingImageView;
@property (nonatomic, assign) UIImage * edgingImage;
@property (nonatomic, strong) id <ImageTouchViewDelegate> delegate;
- (id)initWithFrame:(CGRect)frame delegate:(id <ImageTouchViewDelegate>)del;

@end
