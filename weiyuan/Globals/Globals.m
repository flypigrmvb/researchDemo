//
//  Globals.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "Globals.h"
#import "User.h"
#import "Session.h"
#import "Declare.h"
#import "Message.h"
#import "Notify.h"
#import "Contact.h"
#import "Room.h"
#import "UserMsg.h"
#import "Meet.h"

@implementation Globals

+ (UIColor*)getColorViewBkg {
    return bkgColor;
}

+ (UIColor*)getColorGrayLine {
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"bkg_gray_line"]];
}

+ (UIImage*)getImageInputViewBkg {
    return [[UIImage imageNamed:bkgNameOfInputView] stretchableImageWithLeftCapWidth:20 topCapHeight:20];
}

+ (UIImage*)getImageRoomHeadDefault {
    return [UIImage imageNamed:@"roomHeadImage"];
}

+ (UIImage*)getImageUserHeadDefault {
    return [UIImage imageNamed:@"defaultHeadImage"];
}

+ (UIImage*)getImageDefault {
    return [UIImage imageNamed:@"default_image_none"];
}

+ (UIImage*)getImageGray {
    return [[UIImage imageNamed:@"bkg_gray_line"] stretchableImageWithLeftCapWidth:2 topCapHeight:2];
}

+ (UIImage *)getImageWithColor:(UIColor*)color {
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (NSString*)timeStringForListWith:(NSTimeInterval)timestamp {
    NSString *_timestamp;
    // Calculate distance time string
    //
    time_t now;
    time(&now);
    
    int distance = (int)difftime(now, timestamp);
    if (distance < 0) distance = 0;
    
    if (distance < 10) {
        _timestamp = [NSString stringWithFormat:@"刚刚"];
    } else if (distance < 60) {
        _timestamp = [NSString stringWithFormat:@"%d%@", distance, @"秒前"];
    } else if (distance < 60 * 60) {
        distance = distance / 60;
        _timestamp = [NSString stringWithFormat:@"%d%@", distance, @"分钟前"];
    } else {
        static NSDateFormatter *dateFormatter = nil;
        if (dateFormatter == nil) {
            dateFormatter = [[NSDateFormatter alloc] init];
        }
        
        NSDate * now = [NSDate date];
        NSDate * date = [NSDate dateWithTimeIntervalSince1970:timestamp];
        [dateFormatter setDateFormat:@"YY"];
        NSString * timestampYear = [dateFormatter stringFromDate:date];
        NSString * timestampYearNow = [dateFormatter stringFromDate:now];
        if ([timestampYear isEqualToString:timestampYearNow]) {
            [dateFormatter setDateFormat:@"dd"];
            NSString * timestampDay = [dateFormatter stringFromDate:date];
            NSString * timestampDayNow = [dateFormatter stringFromDate:now];
            if ([timestampDay isEqualToString:timestampDayNow]) {
                // 同一天内
                [dateFormatter setDateFormat:@"hh:mm"];
            } else {
                [dateFormatter setDateFormat:@"M月dd日"];
            }
        } else {
            // 跨年了
            [dateFormatter setDateFormat:@"YY.MM.dd"];
        }
        _timestamp = [dateFormatter stringFromDate:date];
    }
    return _timestamp;
}


+ (NSString*)sendTimeString:(double)sendTime {
    NSString * _timestamp;
    NSTimeInterval timestamp = sendTime/ 1000;
    time_t now;
    time(&now);
    
    int distance = (int)difftime(now, timestamp);
    if (distance < 0) distance = 0;
    
    if (distance < 10) {
        _timestamp = [NSString stringWithFormat:@"刚刚"];
    } else if (distance < 60) {
        _timestamp = [NSString stringWithFormat:@"%d%@", distance, @"秒前"];
    } else if (distance < 60 * 60) {
        distance = distance / 60;
        _timestamp = [NSString stringWithFormat:@"%d%@", distance, @"分钟前"];
    } else if (distance < 60 * 60 * 24) {
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"M月d日 hh:mm"];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
        _timestamp = [dateFormatter stringFromDate:date];
    } else if (distance < 60 * 60 * 24 * 30) {
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"M月d日 hh:mm"];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
        _timestamp = [dateFormatter stringFromDate:date];
    } else {
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-M-d hh:mm"];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
        _timestamp = [dateFormatter stringFromDate:date];
    }
    
    return _timestamp;
}

+ (NSDate *)dateFromString:(NSString *)dateString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm"];
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    return destDate;
}

+ (NSString *)convertDateFromString:(NSString*)uiDate timeType:(int)timeType
{
    NSDate *data = [NSDate dateWithTimeIntervalSince1970:uiDate.doubleValue];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if (timeType == 0) {
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    } else if (timeType == 1){
        [dateFormatter setDateFormat:@"yyyy年MM月dd日 HH:mm"];
    } else if (timeType == 2){
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    } else if (timeType == 3){
        [dateFormatter setDateFormat:@"M月dd日 HH:mm"];
    }
    NSString *strDate = [dateFormatter stringFromDate:data];
    return strDate;
}

+ (NSDate *)convertStringtoDate:(NSString*)strDate timeType:(int)timeType
{
    NSDate *data = nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if (timeType == 0) {
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    } else if (timeType == 1){
        [dateFormatter setDateFormat:@"yyyy年MM月dd日 HH:mm"];
    } else if (timeType == 2){
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    } else if (timeType == 3){
        [dateFormatter setDateFormat:@"MM月dd日 HH:mm"];
    }
    data = [dateFormatter dateFromString:strDate];
    return data;
}

+ (void)initializeGlobals {
    NSFileManager * fMan = [NSFileManager defaultManager];
    NSString * new_path_b = [NSString stringWithFormat:@"%@/Library/Cache",NSHomeDirectory()];
    NSString * new_path = [NSString stringWithFormat:@"%@/Library/Cache/Images",NSHomeDirectory()];
    NSString * new_path_a = [NSString stringWithFormat:@"%@/Library/Cache/Audios",NSHomeDirectory()];
    if ((![fMan fileExistsAtPath:new_path_b]) || (![fMan fileExistsAtPath:new_path])) {
        [fMan createDirectoryAtPath:new_path_b withIntermediateDirectories:YES attributes:nil error:nil];
        [fMan createDirectoryAtPath:new_path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (![fMan fileExistsAtPath:new_path_a]) {
        [fMan createDirectoryAtPath:new_path_a withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

+ (NSString*)getBaiduAdrPic:(CGFloat)lat lng:(CGFloat)lng {
    return [NSString stringWithFormat:@"http://api.map.baidu.com/staticimage?center=%f,%f&width=300&height=200&zoom=11", lng, lat];
}

+ (NSString*)getBaiduAdrPicForTalk:(CGFloat)lat lng:(CGFloat)lng {
    return [NSString stringWithFormat:@"http://api.map.baidu.com/staticimage?center=%f,%f&width=200&height=120&zoom=16&markers=%f,%f&markerStyles=s", lng, lat, lng, lat];
}

+ (void)createTableIfNotExists {
    [DBConnection getSharedDatabase];
    [Message createTableIfNotExists];
    [Address createTableIfNotExists];
    [User createTableIfNotExists];
    [User initUserStorage];
    [Session createTableIfNotExists];
    [Notify createTableIfNotExists];
    [Contact createTableIfNotExists];
    [Room createTableIfNotExists];
    [UserMsg createTableIfNotExists];
    [Meet createTableIfNotExists];
}

+ (void)removeAllItemsInFolder:(NSString*)path {
    NSFileManager * fm = [NSFileManager defaultManager];
    NSArray * tmps = [fm subpathsAtPath:path];
    for (NSString * fileName in tmps) {
        NSString* fileAbsolutePath = [path stringByAppendingPathComponent:fileName];
        [fm removeItemAtPath:fileAbsolutePath error:nil];
    }
}

+ (NSTimeInterval)fileCreateDate:(NSString*)filePath {
    NSFileManager * fm = [NSFileManager defaultManager];
    NSDate * fileModDate = nil;
    NSDictionary * fileAttributes = [fm attributesOfItemAtPath:filePath error:nil];
    if ((fileModDate = [fileAttributes objectForKey:NSFileModificationDate])) {
        return [fileModDate timeIntervalSinceNow];
    }
    return 0;
}

+ (NSString*)timeString {
    return [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]*1000];
}

+ (void)imageDownload:(Img_Block)block url:(NSString*)url {
    if (url && url.length > KBSSDKAPIURL.length) {
        dispatch_async(kQueueDEFAULT, ^{
            @autoreleasepool {
                NSString * path = [NSString stringWithFormat:@"%@/Library/Cache/Images/%@.dat",NSHomeDirectory(),[url md5Hex]];
                NSData * data = [NSData dataWithContentsOfFile:path];
                if (!data) {
                    data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
                    [data writeToFile:path atomically:YES];
                }
                dispatch_async(kQueueMain, ^{
                    UIImage *img = [UIImage imageWithData:data];
                    block(img);
                });
            }
        });
    } else {
        block(nil);
    }
}

+(BOOL)isValidateEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

Location kLocationMake(double la, double ln) {
    Location res;
    res.lat = la;
    res.lng = ln;
    return res;
}

+ (NSString *)generateUUID
{
	NSString *result = nil;
	
	CFUUIDRef uuid = CFUUIDCreate(NULL);
	if (uuid)
	{
		result = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
		CFRelease(uuid);
	}
	
	return result;
}

+ (NSString *)getTime:(NSTimeInterval)createtime {
    NSDate *data = [NSDate dateWithTimeIntervalSince1970:createtime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *strDate = [dateFormatter stringFromDate:data];
    return strDate;
}

+ (void)callAction:(NSString *)phone parentView:(UIView*)view {
    NSString * num = [NSString stringWithFormat:@"tel:%@", phone];
    UIWebView * callWebview = [[UIWebView alloc] init];
    NSURL *telURL =[NSURL URLWithString:num];
    [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
    [view addSubview:callWebview];
}

+ (BOOL)isNotify {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return ![defaults boolForKey:kBaseIfCloseAPNS];
}

+ (void)setIsNotify:(BOOL)value {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:!value forKey:kBaseIfCloseAPNS];
    [defaults synchronize];
}

+ (void)setPreSendMsg:(id)it {
    preSendMsg = nil;
    if (it) {
        preSendMsg = it;
    }
}

+ (Message *)preSendMsg {
    return preSendMsg;
}

@end
