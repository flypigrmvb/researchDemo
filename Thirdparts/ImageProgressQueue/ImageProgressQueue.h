//
//  ImageProgressQueue.h
//  kiwi
//
//  Created by kiwi on 1/29/13.
//  Copyright (c) 2013 Kiwaro.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ImageProgress, ImageProgressQueue;

@protocol ImageProgressDelagete <NSObject>
@optional
- (void)imageProgress:(ImageProgress*)sender completed:(BOOL)bl;
@end

@interface ImageProgress : NSObject <NSURLConnectionDelegate> {
    NSString * path;
}
@property (nonatomic, assign) id <ImageProgressDelagete> delegate;
@property (nonatomic, readonly) BOOL loaded;
@property (nonatomic, assign) NSInteger tag;
/**显示多图的时候, idx 表示各个图的标号*/
@property (nonatomic, assign) NSInteger idx;
@property (nonatomic, strong) NSString * imageURLString;
@property (nonatomic, strong) NSMutableData * activeDownload;
@property (nonatomic, strong) NSURLConnection * imageConnection;
@property (nonatomic, strong) NSIndexPath * indexPath;
@property (nonatomic, strong) UIImage * image;

- (id)initWithUrl:(NSString *)_url delegate:(id)del;
- (void)startDownload;
- (void)cancelDownload;

@end



@protocol ImageProgressQueueDelegate <NSObject>
@optional
- (void)imageProgressCompleted:(UIImage*)img indexPath:(NSIndexPath*)indexPath;
- (void)imageProgressCompleted:(UIImage*)img indexPath:(NSIndexPath*)indexPath idx:(NSInteger)idx url:(NSString *)url tag:(NSInteger)tag;
@end

@interface ImageProgressQueue : NSObject <ImageProgressDelagete> {
    NSMutableArray * queue;
}
@property (nonatomic, assign) id <ImageProgressQueueDelegate> delegate;
@property (nonatomic, strong) ImageProgress * operation;

- (id)initWithDelegate:(id)del;
- (void)addOperation:(ImageProgress*)op;
- (void)cancelOperations;

@end
