//
//  QRcodeReaderViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "QRcodeReaderViewController.h"
#import "ZBarSDK.h"
#import "GTMBase64Coder.h"
#import "AppDelegate.h"
#import "TalkingViewController.h"
#import "BSEngine.h"
#import "Room.h"
#import "Session.h"
#import "AddGroupViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface QRcodeReaderViewController ()<ZBarReaderViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    ZBarReaderView *readerView;
    IBOutlet UIView * scanView;
}

@property (nonatomic, retain) UIView *overlayView;
@end

@implementation QRcodeReaderViewController

- (id)init
{
    self = [super initWithNibName:@"QRcodeReaderViewController" bundle:NULL];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"扫一扫";
    [self setEdgesNone];
    //    [self setRightBarButton:@"相册" selector:@selector(scanPhotoImage)];
}

- (void)viewDidAppear:(BOOL)animated {
    if (isFirstAppear) {
        if (Sys_Version >= 7) {
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]; // 获取对摄像头的访问权限。
            if (authStatus == AVAuthorizationStatusDenied) {
                [self showAlert:@"您已经拒绝了我们使用您的相机，请前往‘设置-隐私-相机’中允许我们访问您的相机" isNeedCancel:NO];
                return;
            }
        }
        
        readerView = [[ZBarReaderView alloc] init];
        readerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        readerView.frame = self.view.bounds;
        readerView.readerDelegate = self;
        
        self.overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
        self.overlayView.alpha = .5f;
        self.overlayView.backgroundColor = [UIColor blackColor];
        self.overlayView.userInteractionEnabled = NO;
        self.overlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:self.overlayView];
        
        //关闭闪光灯
        readerView.torchMode = 0;
        readerView.trackingColor = kbColor;
        //扫描区域
        CGRect scanMaskRect = scanView.frame;
        //扫描区域计算
        readerView.scanCrop = [self getScanCrop:scanMaskRect];
        //处理模拟器
        
        ZBarImageScanner * scanner = readerView.scanner;
        // 例如: 禁用很少使用的I2/5来改善性能
        [scanner setSymbology: ZBAR_I25 config: ZBAR_CFG_ENABLE to: 0];
        [self.view addSubview:readerView];
        [self.view sendSubviewToBack:readerView];
        [readerView start];
        [self overlayClipping];
    }
}

- (void)overlayClipping  {
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    // Left side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(0, 0, scanView.left, self.overlayView.height));
    // Right side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(scanView.right, 0, self.overlayView.width - scanView.right, readerView.height));
    // Top side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(0, 0, self.overlayView.width, scanView.top));
    // Bottom side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(0, scanView.bottom, self.overlayView.width, self.overlayView.height - scanView.bottom));
    maskLayer.path = path;
    self.overlayView.layer.mask = maskLayer;
    CGPathRelease(path);
}

- (CGRect)getScanCrop:(CGRect)rect
{
    CGFloat x,y,width,height;
    x = rect.origin.x / readerView.width;
    y = rect.origin.y / readerView.height;
    width = rect.size.width / readerView.width;
    height = rect.size.height / readerView.height;
    return CGRectMake(x, y, width, height);
}

#pragma mark - ZBarReaderViewDelegate

- (void)readerView:(ZBarReaderView *)sender didReadSymbols:(ZBarSymbolSet *)symbols fromImage:(UIImage *)image {
    [self decodeZBarView:symbols];
}

- (void)decodeZBarView:(id) symbols{
    NSString *str = nil;
    if ([symbols isKindOfClass:[ZBarSymbol class]]) {
        str = ((ZBarSymbol*)symbols).data;
    } else {
        for (ZBarSymbol *symbol in (ZBarSymbolSet*)symbols) {
            str = symbol.data;
            break;
        }
    }
#ifdef DEBUG
    DLog(@"%@", str);
#endif
    if (str && [str isKindOfClass:[NSString class]] && [str hasPrefix:KBSSDKAPIURL]) {
        NSRange range = [str rangeOfString:KBSSDKAPIURL];
        str = [str substringFromIndex:range.length];
        str = [GTMBase64Coder decodeBase64String:str];
        if (str && [super startRequest]) {
            [client groupDetail:str];
        }
    }
}
#pragma mark - Request

- (BOOL)requestDidFinish:(BSClient*)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        NSDictionary * dic = [obj getDictionaryForKey:@"data"];
        Room * room = [Room objWithJsonDic:dic];
        if (room.isjoin) {
            // 如果加入了该群， 直接跳转聊天
            Session * item = [Session getSessionWithID:room.uid];
            if (!item) {
                item = [Session sessionWithRoom:room];
            }
            id con = [[TalkingViewController alloc] initWithSession:item];
            [self pushViewController:con];
        } else {
            // 跳转加入该群
            AddGroupViewController * con = [[AddGroupViewController alloc] init];
            con.room = room;
            [self pushViewController:con];
        }
    } else {
        [readerView start];
    }
    return YES;
}

- (void)scanPhotoImage {
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentModalController:picker animated:YES];
}

- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info {
    
    UIImage * img = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    img = [UIImage rotateImage:img];
    ZBarImage * zimg= [[ZBarImage alloc] initWithCGImage:img.CGImage];
    ZBarImageScanner *scanner = readerView.scanner;
    [scanner scanImage:zimg];
    ZBarSymbol * symbols = nil;
    for (symbols in scanner.results) {
        break;
    }
    
    [self decodeZBarView:symbols];
    [reader dismissViewControllerAnimated:YES completion:nil];
}

@end
