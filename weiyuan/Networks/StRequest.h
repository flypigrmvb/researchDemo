//
//  StRequest.h
//
//  AppDelegate.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    KSTRequestPostDataTypeNone,
	KSTRequestPostDataTypeNormal,			// for normal data post, such as "user=name&password=psd"
	KSTRequestPostDataTypeMultipart,        // for uploading images and files.
}StRequestPostDataType;

@class StRequest;

@protocol StRequestDelegate <NSObject>
@optional
/**接收数据的回调 可以用来做进度显示什么的*/
- (void)request:(StRequest*)request didReceiveResponse:(NSURLResponse *)response;
/**接收数据的回调*/
- (void)request:(StRequest*)request didReceiveRawData:(NSData *)data;
/**获取数据失败回调*/
- (void)request:(StRequest*)request didFailWithError:(NSError *)error;
/**成功获取数据回调*/
- (void)request:(StRequest*)request didFinishLoadingWithResult:(id)result;
@end

@interface StRequest : NSObject

@property (nonatomic, strong) id <StRequestDelegate> delegate;

+ (StRequest *)requestWithURL:(NSString *)url
                   httpMethod:(NSString *)httpMethod
                       params:(NSDictionary *)params
                 postDataType:(StRequestPostDataType)postDataType
             httpHeaderFields:(NSDictionary *)httpHeaderFields
                     delegate:(id<StRequestDelegate>)delegate;
/**开始访问服务器进行数据获取*/
- (void)connect;
/**关闭访问服务器*/
- (void)disconnect;

@end
