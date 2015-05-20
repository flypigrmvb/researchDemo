//
//  StRequest.m
//
//  AppDelegate.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "StRequest.h"
#import "Globals.h"
#import "EmotionInputView.h"
#import "JSON.h"

#define KSTRequestTimeOutInterval   30.0
#define KSTRequestStringBoundary    @"This is an evil dividing line"

@interface StRequest () {
    NSMutableData       * responseData;
}

@property (nonatomic, strong)   NSURLConnection         * connection;
@property (nonatomic, assign)   StRequestPostDataType   postDataType;
@property (nonatomic, strong)   NSString                * url;
@property (nonatomic, strong)   NSString                * httpMethod;
@property (nonatomic, strong)   NSDictionary            * params;
@property (nonatomic, strong)   NSDictionary            * httpHeaderFields;

@end

@implementation StRequest
@synthesize delegate;
@synthesize postDataType, url, httpMethod, params, httpHeaderFields, connection;

#pragma mark - StRequest Life Circle

- (void)dealloc {
    responseData = nil;
    [connection cancel];
    self.connection = nil;
    self.url = nil;
    self.httpMethod = nil;
    self.params = nil;
    self.httpHeaderFields = nil;
}

#pragma mark - StRequest Private Methods
/** 在变量之间添加&区别 */
+ (NSString *)stringFromDictionary:(NSDictionary *)dict {
    NSMutableArray *pairs = [NSMutableArray array];
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [obj URLEncodedString]]];
    }];
	return [pairs componentsJoinedByString:@"&"];
}

/** 将body字符串转化为UTF8格式的二进制 */
+ (void)appendUTF8Body:(NSMutableData *)body dataString:(NSString *)dataString {
    [body appendData:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
}

/** 构造 访问服务器的数据结构体 采用NSUTF8StringEncoding对数据进行编码，如果有声音／图片则添加相应表头申明*/
- (NSMutableData *)postBody {
    NSMutableData *body = [NSMutableData data];
    
    if (postDataType == KSTRequestPostDataTypeNormal) {
        [StRequest appendUTF8Body:body dataString:[StRequest stringFromDictionary:params]];
    } else if (postDataType == KSTRequestPostDataTypeMultipart) {
        NSString *bodyPrefixString = [NSString stringWithFormat:@"--%@\r\n", KSTRequestStringBoundary];
        NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionary];
        
        [StRequest appendUTF8Body:body dataString:bodyPrefixString];
        
        [params enumerateKeysAndObjectsUsingBlock:^(NSString * key, id obj, BOOL *stop) {
            if (([obj isKindOfClass:[UIImage class]]) || ([obj isKindOfClass:[NSData class]])){
				[dataDictionary setObject:obj forKey:key];
			} else {
                [StRequest appendUTF8Body:body dataString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n", key, obj]];
                [StRequest appendUTF8Body:body dataString:bodyPrefixString];
            }
        }];

		NSString *endItemBoundary = [NSString stringWithFormat:@"\r\n--%@\r\n",KSTRequestStringBoundary];
        [dataDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSData* imageData = nil;
            if ([obj isKindOfClass:[UIImage class]]) {
                imageData = UIImageJPEGRepresentation((UIImage *)obj, 0.7);
                [StRequest appendUTF8Body:body dataString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@.jpg\"\r\n", key, key]];
                [StRequest appendUTF8Body:body dataString:@"Content-Type: image/jpg\r\nContent-Transfer-Encoding: binary\r\n\r\n"];
            } else if ([obj isKindOfClass:[NSData class]]) {
                imageData = (NSData*)obj;
                [StRequest appendUTF8Body:body dataString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@.mp3\"\r\n", key, key]];
                [StRequest appendUTF8Body:body dataString:@"Content-Type: image/mp3\r\nContent-Transfer-Encoding: binary\r\n\r\n"];
            }
            [body appendData:(NSData*)imageData];
            [StRequest appendUTF8Body:body dataString:endItemBoundary];
        }];

        [StRequest appendUTF8Body:body dataString:[NSString stringWithFormat:@"\r\n--%@--\r\n", KSTRequestStringBoundary]];
    }
#if ShouldLogJsonUrlString == 1
    NSString* strBody;
    strBody = [[NSString alloc] initWithData:body encoding:NSASCIIStringEncoding];
    DLog(@"POST BODY (原始数据):\r\n%@",strBody);
#endif
    //    DLog(@"POST BODY (解码后的数据):\r\n%@",[strBody URLDecodedString]);
    
    return body;
}

/**成功获取到数据后, 开始尝试解析数据*/
- (void)handleResponseData:(NSData *)data {
    if ([delegate respondsToSelector:@selector(request:didReceiveRawData:)]) {
        [delegate request:self didReceiveRawData:data];
    }
	
	NSError* error = nil;
	id result = [self parseJSONData:data error:&error];
    
	if (error) {
        NSString* gotResult =  nil;
        if (gotResult == nil) {
            gotResult = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
        if (gotResult == nil) {
            NSStringEncoding gbkEncoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            gotResult = [[NSString alloc] initWithData:data encoding:gbkEncoding];
        }
        if (gotResult == nil) {
            gotResult = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        }
        if (!gotResult) {
            [self failedWithError:error];
        } else if ([delegate respondsToSelector:@selector(request:didFinishLoadingWithResult:)]) {
            id result = [gotResult mutableObjectFromJSONString];
            if (result) {
                [delegate request:self didFinishLoadingWithResult:result];
            } else {
                [delegate request:self didFailWithError:error];
            }
            
		}
	} else {
        if ([delegate respondsToSelector:@selector(request:didFinishLoadingWithResult:)]) {
            [delegate request:self didFinishLoadingWithResult:result];
		}
	}
}

/**将获取到的数据进行json标准华解析并返回*/
- (id)parseJSONData:(NSData *)data error:(NSError **)error {
	NSError *parseError = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&parseError];
	if (parseError) {
        if (error != nil) {
           *error = [self errorWithCode:KBSErrorCodeSDK
                                userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d", KBSSDKErrorCodeParseError]
                                                                     forKey:KBSSDKErrorCodeKey]];
        }
	}
	return result;
}

- (id)errorWithCode:(NSInteger)code userInfo:(NSDictionary *)userInfo {
    return [NSError errorWithDomain:KBSSDKErrorDomain code:code userInfo:userInfo];
    return nil;
}

- (void)failedWithError:(NSError *)error {
	if ([delegate respondsToSelector:@selector(request:didFailWithError:)]) {
		[delegate request:self didFailWithError:error];
	}
}

#pragma mark - BMRequest Public Methods

+ (StRequest *)requestWithURL:(NSString *)url
                   httpMethod:(NSString *)httpMethod
                       params:(NSDictionary *)params
                 postDataType:(StRequestPostDataType)postDataType
             httpHeaderFields:(NSDictionary *)httpHeaderFields
                     delegate:(id)delegate {
    
    StRequest *request = [[StRequest alloc] init];
    request.url = url;
    request.httpMethod = httpMethod;
    request.params = params;
    request.postDataType = postDataType;
    request.httpHeaderFields = httpHeaderFields;
    request.delegate = delegate;
    
    return request;
}

+ (NSString *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params httpMethod:(NSString *)httpMethod {
    if (![httpMethod isEqualToString:@"GET"]) {
        return baseURL;
    }
	NSString * queryPrefix = @"&";
	NSString * query = [StRequest stringFromDictionary:params];
	return [NSString stringWithFormat:@"%@%@%@", baseURL, queryPrefix, query];
}

- (void)connect {
    NSString *urlString = [StRequest serializeURL:url params:params httpMethod:httpMethod];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
														   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
													   timeoutInterval:KSTRequestTimeOutInterval];
    [request setHTTPMethod:httpMethod];
#if ShouldLogJsonUrlString
    DLog(@"URL : %@", urlString);
#endif
    if ([httpMethod isEqualToString:@"POST"]) {
        if (postDataType == KSTRequestPostDataTypeMultipart) {
            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", KSTRequestStringBoundary];
            [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
        }
        
        NSData* postBody = [self postBody];
        NSTimeInterval timeinterval = KSTRequestTimeOutInterval + ([postBody length]>>14);
//        DLog(@"超时时间 : %.2f s \nPost Body Length : %d bytes",timeinterval,[postBody length]);
        [request setTimeoutInterval:timeinterval];
        [request setHTTPBody:postBody];
    }
    
    for (NSString *key in [httpHeaderFields keyEnumerator]) {
        [request setValue:[httpHeaderFields objectForKey:key] forHTTPHeaderField:key];
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

- (void)disconnect {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    delegate = nil;
    responseData = nil;
    [connection cancel];
    connection = nil;
}

#pragma mark - NSURLConnection Delegate Methods
// NSURLConnection 系统的回调函数 ［具体参考苹果文档］ 这里解析后交给StRequestDelegate对应的回调

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	responseData = [[NSMutableData alloc] init];
	
	if ([delegate respondsToSelector:@selector(request:didReceiveResponse:)]) {
		[delegate request:self didReceiveResponse:response];
	}
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    // 上传进度
//    DLog(@"bytesWritten %d [%%%0.f]", bytesWritten, ((double)totalBytesWritten/totalBytesExpectedToWrite)*100);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
				  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
	return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
#if ShouldLogAfterRequest == 1
    NSString* gotResult =  nil;
    if (gotResult == nil) {
        gotResult = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    }
    if (gotResult == nil) {
        NSStringEncoding gbkEncoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        gotResult = [[NSString alloc] initWithData:responseData encoding:gbkEncoding];
    }
    if (gotResult == nil) {
        gotResult = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
    }
    DLog(@"connectionDidFinishLoading\r\n%@",gotResult);
#endif
    
	[self handleResponseData:responseData];
    responseData = nil;
    
    [connection cancel];
    connection = nil;
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self failedWithError:error];
    responseData = nil;
    [connection cancel];
    connection = nil;
}

@end
