//
//  Config.h
//
//  AppDelegate.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#ifndef Spartan_Education_Config_h
#define Spartan_Education_Config_h

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
#define kCGImageAlphaPremultipliedLast  (kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast)
#else
#define kCGImageAlphaPremultipliedLast  kCGImageAlphaPremultipliedLast
#endif
#define String(__key) NSLocalizedString(__key, nil)

#define kbColor RGBCOLOR(177, 22, 49)
#define BkgBlackColor RGBCOLOR(47, 53, 53)

#define NtfLogin @"BSNotificationLogin"
#define NtSubfLogin @"BSSubNotificationLogin"
#define NtfInfoUpdate @"BSNotificationInfoUpdate"
#define UMShareKey @"53d5fda456240bbd0f0096b0"
#define kBaseIfCloseAPNS                @"baseIfCloseAPNS"

/*****  release   *****/

#define Release(__object) if(__object){__object=nil;}


#define KBSSDKAPIURL                 @"http://123.56.101.233:8082/weiyuan/"
#define KBSSDKAPIDomain              @"http://123.56.101.233:8082/weiyuan/index.php/"
#define KBSSDKAPIDomainXMPP         @"123.56.101.233"
#define KBSSDKAPIDomainXMPPPort     5222
#define KBSSDKAPIDomainXMPPServer   @"iz25g1h3h6kz"
#define bkgColor RGBCOLOR(164, 158, 163)
#define RbkgColor RGBACOLOR(164, 158, 163, 0.382)
#define bkgViewColor RGBCOLOR(234, 234, 234)
#define Sys_Version [[UIDevice currentDevice].systemVersion doubleValue]
#define APPKEY @"0e93f53b5b02e29ca3eb6f37da3b05b9"

#define kQueueDEFAULT dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define kQueueHIGH dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
#define kQueueLOW dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)
#define kQueueBACKGROUND dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
#define kQueueMain dispatch_get_main_queue()

#define LOADIMAGE(file) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:file ofType:@"png"]]
#define LOADIMAGECACHES(file) [UIImage imageNamed:file]
/******************************************************/

/****  debug log **/ //NSLog输出信息

#ifdef DEBUG

#define DLog( s, ... ) NSLog( @"< %@:(%d) > %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )

#else

#define DLog( s, ... ) NSLog(@"")

#endif


/***  DEBUG RELEASE  */

#if DEBUG

#define MCRelease(x)

#else

#define MCRelease(x)

#endif


#pragma mark - Frame(宏 x,y,width,height)

#define MainScreenScale [[UIScreen mainScreen]scale] //屏幕的分辨率 当结果为1时，显示的是普通屏幕，结果为2时，显示的是Retian屏幕
// App Frame Height&Width
#define Application_Frame  [[UIScreen mainScreen] applicationFrame] //除去信号区的屏幕的frame
#define APP_Frame_Height   [[UIScreen mainScreen] applicationFrame].size.height //应用程序的屏幕高度
#define App_Frame_Width    [[UIScreen mainScreen] applicationFrame].size.width  //应用程序的屏幕宽度
/*** MainScreen Height Width */
#define Main_Screen_Height [[UIScreen mainScreen] bounds].size.height //主屏幕的高度
#define Main_Screen_Width  [[UIScreen mainScreen] bounds].size.width  //主屏幕的宽度

/*** KeyWindow Height Width */
#define KeyWindow_Height [[[UIApplication sharedApplication] keyWindow] frame].size.height //KeyWindow的高度
#define KeyWindow_Width  [[[[UIApplication sharedApplication] keyWindow] frame].size..width  //KeyWindow的宽度

// View 坐标(x,y)和宽高(width,height)
#define X(v)               (v).frame.origin.x
#define Y(v)               (v).frame.origin.y
#define ViewWIDTH(v)           (v).frame.size.width
#define ViewHEIGHT(v)          (v).frame.size.height

#define MinX(v)            CGRectGetMinX((v).frame) // 获得控件屏幕的x坐标
#define MinY(v)            CGRectGetMinY((v).frame) // 获得控件屏幕的Y坐标

#define MidX(v)            CGRectGetMidX((v).frame) //横坐标加上到控件中点坐标
#define MidY(v)            CGRectGetMidY((v).frame) //纵坐标加上到控件中点坐标

#define MaxX(v)            CGRectGetMaxX((v).frame) //横坐标加上控件的宽度
#define MaxY(v)            CGRectGetMaxY((v).frame) //纵坐标加上控件的高度

#define CONTRLOS_FRAME(x,y,width,height)     CGRectMake(x,y,width,height)

//    系统控件的默认高度
#define kStatusBarHeight   (20.f)
#define kTopBarHeight      (44.f)
#define kBottomBarHeight   (49.f)

#define kCellDefaultHeight (44.f)

// 当控件为全屏时的横纵左边
#define kFrameX             (0.0)
#define kFrameY             (0.0)

#define kPhoneFrameWidth                 (320.0)
#define kPhoneWithStatusNoPhone5Height   (480.0)
#define kPhoneNoWithStatusNoPhone5Height (460.0)
#define kPhoneWithStatusPhone5Height     (568.0)
#define kPhoneNoWithStatusPhone5Height   (548.0)

#define kPadFrameWidth                   (768.0)
#define kPadWithStatusHeight             (1024.0)
#define kPadNoWithStatusHeight           (1004.0)

//中英状态下键盘的高度
#define kEnglishKeyboardHeight  (216.f)
#define kChineseKeyboardHeight  (252.f)

#pragma mark - Funtion Method (宏 方法)

//加载图片
#define IMAGE(NAME,EXT)        [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:(NAME) ofType:(EXT)]]
#define IMAGENAMED(NAME)       [UIImage imageNamed:NAME]

//字体大小（常规/粗体）
#define BOLDSYSTEMFONT(FONTSIZE) [UIFont boldSystemFontOfSize:FONTSIZE]
#define SYSTEMFONT(FONTSIZE)     [UIFont systemFontOfSize:FONTSIZE]
#define FONT(NAME,FONTSIZE)      [UIFont fontWithName:(NAME) size:(FONTSIZE)]

//当前版本
#define FSystenVersion            ([[[UIDevice currentDevice] systemVersion] floatValue])
#define DSystenVersion            ([[[UIDevice currentDevice] systemVersion] doubleValue])
#define SSystemVersion            ([[UIDevice currentDevice] systemVersion])

//当前语言
#define CURRENTLANGUAGE           ([[NSLocale preferredLanguages] objectAtIndex:0])

//是否Retina屏
#define isRetina                  ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) :NO)
//是否iPhone5
#define ISIPHONE                  [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone
#define ISIPHONE5                 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

// UIView - viewWithTag 通过tag值获得子视图
#define VIEWWITHTAG(_OBJECT,_TAG)   (id)[_OBJECT viewWithTag : _TAG]

//应用程序的名字
#define AppDisplayName              [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]

//判断设备室真机还是模拟器
#if TARGET_OS_IPHONE
/** iPhone Device */
#endif

#if TARGET_IPHONE_SIMULATOR
/** iPhone Simulator */
#endif

#endif
