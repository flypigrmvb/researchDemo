//
//  ImageProgressQueue.m
//  kiwi
//
//  Created by kiwi on 1/29/13.
//  Copyright (c) 2013 Kiwaro.com. All rights reserved.
//

#import "ImageProgressQueue.h"

@implementation ImageProgress
@synthesize delegate;
@synthesize loaded;
@synthesize tag;
@synthesize idx;
@synthesize imageURLString;
@synthesize activeDownload;
@synthesize imageConnection;
@synthesize indexPath;
@synthesize image;

- (UIImage*)getImage {
	return [UIImage imageWithData:activeDownload];
}

//init image
- (id)initWithUrl:(NSString *)_url delegate:(id)del {
	// Try to load image from local.
	//1. calculate the path from url
	//2. set the image from path
	//3. if failed
	//		(1). then download image from url
	//		(2). save the image
	
	self = [super init];
    
    self.delegate = del;
    
	self.imageURLString = _url;
	// calculate localpath from url
	path = [NSString stringWithFormat:@"%@/Library/Cache/Images/%@.dat",NSHomeDirectory(),[self.imageURLString md5Hex]];
	
	//DLog(@"path: %@",path);
	
    loaded = NO;
	if ([self setImageWithPath]) {		//can not find the image from local.
        self.image = [self getImage];
        if ([image isKindOfClass:[UIImage class]]) {
            self.activeDownload = nil;
            loaded = YES;
        }
	}
	return self;
}

- (void)dealloc {
    [self.imageConnection cancel];
    self.image = nil;
}

// load Image from local path
- (BOOL)setImageWithPath {
	NSData * data = [NSData dataWithContentsOfFile:path];
	if (data != nil) {
		self.activeDownload = [[NSMutableData alloc] initWithData:data];
		return YES;
	}
	return NO;
}

- (void)startDownload {
    self.activeDownload = [NSMutableData data];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // alloc+init and start an NSURLConnection; release on completion/failure
    
    NSURL * url = [NSURL URLWithString:[self URLEncodedString:imageURLString]];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:url]
                                                            delegate:self];
    
    self.imageConnection = conn;
}

- (void)cancelDownload {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.delegate = nil;
    [self.imageConnection cancel];
    self.imageConnection = nil;
    self.activeDownload = nil;
}

#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection*)connection didReceiveResponse: (NSHTTPURLResponse*)response {
    NSInteger statusCode_ = [response statusCode];
    if (statusCode_ == 200) {
        
    }
}

//每次成功请求到数据后将调下此方法
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    //把每次得到的数据依次放到数组中，这里还可以自己做一些进度条相关的效果
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    // Release the connection now that it's finished
    self.imageConnection = nil;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if ([self.delegate respondsToSelector:@selector(imageProgress:completed:)]) {
        [self.delegate imageProgress:self completed:NO];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // Release the connection now that it's finished
    self.imageConnection = nil;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    self.image = [self getImage];
    if ([image isKindOfClass:[UIImage class]]) {
        // save Image to local with path
        [self.activeDownload writeToFile:path atomically:YES];
        self.activeDownload = nil;
        loaded = YES;
    }
    if ([self.delegate respondsToSelector:@selector(imageProgress:completed:)]) {
        [self.delegate imageProgress:self completed:loaded];
    }
}

#pragma mark -
#pragma mark - Private Methods
- (NSString *)URLEncodedString:(NSString*)url {
    NSString * res = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	return res;
}

@end



@implementation ImageProgressQueue
@synthesize delegate, operation;

- (id)initWithDelegate:(id)del {
    if (self = [super init]) {
        self.delegate = del;
        queue = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    self.delegate = nil;
}

- (void)addOperation:(ImageProgress*)op {
    if (operation && operation.indexPath.row == op.indexPath.row && operation.indexPath.section == op.indexPath.section && operation.tag == op.tag && operation.idx == op.idx) {
        return;
    }
    BOOL exist = NO;
    for (ImageProgress * opt in queue) {
        if (opt.indexPath.row == op.indexPath.row && opt.indexPath.section == op.indexPath.section && opt.tag == op.tag && operation.idx == op.idx) {
            [queue removeObject:opt];
            [queue insertObject:op atIndex:0];
            exist = YES;
            break;
        }
    }
    if (!exist) {
        [queue insertObject:op atIndex:0];
        if (!self.operation) {
            [self executeNext];
        }
    }
}

- (void)cancelOperations {
    [queue removeAllObjects];
    if (self.operation) {
        [self.operation cancelDownload];
        self.operation = nil;
    }
}

- (void)executeNext {
    if (queue.count > 0) {
        self.operation = [queue objectAtIndex:0];
        [queue removeObjectAtIndex:0];
        [self.operation startDownload];
    } else {
        self.operation = nil;
    }
}

#pragma mark -
#pragma mark - ImageProgressDelagete

- (void)imageProgress:(ImageProgress*)sender completed:(BOOL)bl {
    if (bl && sender.loaded) {
        if ([self.delegate respondsToSelector:@selector(imageProgressCompleted:indexPath:)]) {
            UIImage * img = sender.image;
            [self.delegate imageProgressCompleted:img indexPath:sender.indexPath];
        } else if ([self.delegate respondsToSelector:@selector(imageProgressCompleted:indexPath:idx:url:tag:)]) {
            UIImage * img = sender.image;
            [self.delegate imageProgressCompleted:img indexPath:sender.indexPath idx:sender.idx url:sender.imageURLString tag:sender.tag];
        }
    }
    [self executeNext];
}

@end
