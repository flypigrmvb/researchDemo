//
//  QRcodeViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "QRcodeViewController.h"
#import "ImageGridInView.h"
#import "Room.h"
#import "QRCodeGenerator.h"
#import "ImageProgressQueue.h"
#import "Session.h"

@interface QRcodeViewController ()<UIActionSheetDelegate> {
    IBOutlet UILabel            * nameLabel;
    IBOutlet UIImageView        * qrCodeView;
    IBOutlet UIView             * bkgView;
    IBOutlet ImageGridInView    * headView;
}

@end

@implementation QRcodeViewController
@synthesize item;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    self.item = nil;
    Release(headView);
    Release(nameLabel);
    Release(qrCodeView);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"群聊名片";
    bkgView.layer.masksToBounds = YES;
    bkgView.layer.borderColor = RGBCOLOR(233, 233, 233).CGColor;
    bkgView.layer.borderWidth = 2;
    [self setRightBarButton:@"保存" selector:@selector(btnRightPressed)];
    qrCodeView.image = [QRCodeGenerator qrImageForString:[NSString stringWithFormat:@"%@%@",KBSSDKAPIURL,[item.uid base64EncodedString]] imageSize:qrCodeView.width];
    [self setEdgesNone];
    
    headView.isHead = YES;
    nameLabel.text = item.name;
    
    NSArray * array = [_session.headsmall componentsSeparatedByString:@","];
    
    headView.numberOfItems = array.count;
    [array enumerateObjectsUsingBlock:^(NSString * url, NSUInteger idx, BOOL *stop) {
        ImageProgress * progress = [[ImageProgress alloc] initWithUrl:url delegate:nil];
        [headView setImage:progress.image forIndex:idx];
    }];
}

- (void)btnRightPressed {
    UIImageWriteToSavedPhotosAlbum(qrCodeView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

#pragma mark - didFinishSavingWithError

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (!error) {
        [self showText:@"保存成功!"];
    }
}

@end
