//
//  UpdateManager.m
//  guphoto
//
//  Created by kiwi on 4/1/13.
//  Copyright (c) 2013 Kiwaro. All rights reserved.
//

#import "UpdateManager.h"
#import "NSDictionaryAdditions.h"
#import "JSON.h"

#define APPID 774707188

static VersionType staticVersionType = 0;
static NSString * staticURL = nil;
static NSString * staticReleaseNotes = nil;

@implementation UpdateManager
@synthesize updates, updateExists, versionType, hasError, releaseNotes;

- (id)initCheckNow:(BOOL)bl del:(id)del {
    if (self = [super init]) {
        self.delegate = del;
        if (bl) {
            if (staticVersionType > 0) {
                self.versionType = staticVersionType;
                self.updateExists = (staticVersionType == VersionTypeLower);
                self.updates = staticURL;
                self.releaseNotes = staticReleaseNotes;
                if ([self.delegate respondsToSelector:@selector(updateManagerDidCheck:update:)]) {
                    [self.delegate updateManagerDidCheck:self update:updateExists];
                }
            } else [self runCheck];
        }
    }
    return self;
}

- (void)dealloc {
    if (connection) {
        connection = nil;
    }
    if (buf) {
        buf = nil;
    }
    self.updates = nil;
    self.releaseNotes = nil;
}

- (void)runCheck {
    self.updateExists = NO;
    self.hasError = NO;
    
    connection = nil;
    
    buf = nil;
    
    NSString * urlStr = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%d", APPID];
    NSURL * finalURL = [NSURL URLWithString:urlStr];
    
//    DLog(@"%@",[[finalURL absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
    
    NSMutableURLRequest* req;
    
    req = [NSMutableURLRequest requestWithURL:finalURL
                                  cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                              timeoutInterval:30];
    
    [req setHTTPShouldHandleCookies:NO];
	
    buf = [NSMutableData data];
    
	connection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)cancel {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (connection) {
        [connection cancel];
        connection = nil;
    }
}

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)aResponse {
    NSHTTPURLResponse *resp = (NSHTTPURLResponse*)aResponse;
    if (resp) {
        statusCode = resp.statusCode;
//        DLog(@"Response: %d", statusCode);
    }
	[buf setLength:0];
}

- (void)connection:(NSURLConnection *)aConn didReceiveData:(NSData *)data {
	[buf appendData:data];
}

- (void)connection:(NSURLConnection *)aConn didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
	connection = nil;
	buf = nil;
    NSString* msg = nil;
#if defined(MAC_OS_X_VERSION_10_6) && MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_6
    msg = [NSString stringWithFormat:@"Error: %@ %@",
                     [error localizedDescription],
                     [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]];
#else
    msg = [NSString stringWithFormat:@"Error: %@ %@",
                     [error localizedDescription],
                     [[error userInfo] objectForKey:NSErrorFailingURLStringKey]];
#endif
    
    DLog(@"Connection failed: %@", msg);
    
    [self URLConnectionDidFailWithError:error];
    
}


- (void)URLConnectionDidFailWithError:(NSError*)error {
    // To be implemented in subclass
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConn {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSString * s = [[NSString alloc] initWithData:buf encoding:NSUTF8StringEncoding];
    
    [self URLConnectionDidFinishLoading:s];
	//DLog(@"connectionDidFinishLoading:%@", s);
    
    connection = nil;
    buf = nil;
}

- (void)URLConnectionDidFinishLoading:(NSString*)content {
    // To be implemented in subclass
    NSObject * obj = [JSON objectFromJSONString:content];
    NSDictionary * object = (NSDictionary*)obj;
    if ([object isKindOfClass:[NSDictionary class]]) {
//        DLog(@"%@", object);
        NSArray * arr = [object objectForKey:@"results"];
        if ([arr isKindOfClass:[NSArray class]] && arr.count == 1) {
            NSDictionary * dic = [arr objectAtIndex:0];
            NSString * crtVersion = [self crtVersion];
            NSString * verOnLine = [NSString stringWithFormat:@"%@", [dic objectForKey:@"version"]];
            
            if ([crtVersion isEqualToString:verOnLine]) {
                self.versionType = VersionTypeEqual;
            } else {
                NSArray * ver_arr = [crtVersion componentsSeparatedByString:@"."];
                NSArray * ver_arrOnLine = [verOnLine componentsSeparatedByString:@"."];
                
                NSInteger maxID = ver_arr.count < ver_arrOnLine.count ? ver_arr.count : ver_arrOnLine.count;
                for (int i = 0; i < maxID; i ++) {
                    int ver = [[ver_arr objectAtIndex:i] intValue];
                    int verU = [[ver_arrOnLine objectAtIndex:i] intValue];
                    if (ver < verU) {
                        self.updateExists = YES;
                        break;
                    }
                }
                if (!updateExists && ver_arr.count < ver_arrOnLine.count) {
                    self.updateExists = YES;
                }
                if (updateExists) {
                    self.versionType = VersionTypeLower;
                } else {
                    self.versionType = VersionTypeGreater;
                }
            }
            
            self.updates = [dic getStringValueForKey:@"trackViewUrl" defaultValue:nil];
            self.releaseNotes = [dic getStringValueForKey:@"releaseNotes" defaultValue:nil];
        } else {
            self.versionType = VersionTypeGreater;
        }
        Release(staticURL);
        Release(staticReleaseNotes);
        staticVersionType = versionType;
        staticURL = [updates copy];
        staticReleaseNotes = [releaseNotes copy];
    } else {
        hasError = YES;
    }
    if ([self.delegate respondsToSelector:@selector(updateManagerDidCheck:update:)]) {
        [self.delegate updateManagerDidCheck:self update:updateExists];
    }
}

- (NSString*)crtVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
}

- (void)showAlert {
    NSString * title = nil;
    NSString * msg = nil;
    NSString * otherBtn = nil;
    NSString * cancelBtn = nil;
    if (updateExists) {
        cancelBtn = @"取消";
        otherBtn = @"马上下载";
        title = @"检测到更新";
        msg = releaseNotes;
    } else {
        cancelBtn = @"确定";
        title = @"恭喜您";
        msg = @"您使用的已经是最新版本";
    }
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:cancelBtn otherButtonTitles:otherBtn, nil];
    [alert show];
}

#pragma mark
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSURL * url = [NSURL URLWithString:updates];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

@end