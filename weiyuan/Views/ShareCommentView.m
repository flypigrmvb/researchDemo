//
//  ShareCommentView.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "ShareCommentView.h"
#import "BSEngine.h"
#import "BSClient.h"
#import "UIImage+FlatUI.h"
#import "BaseTableViewCell.h"
#import "Globals.h"
#import "CircleMessage.h"
#import "ImageProgressQueue.h"
#import "ImageCaches.h"
#import "UIImage+Resize.h"

@interface ShareCommentView () <UITableViewDataSource, UITableViewDelegate> {
    
    ImageCaches                 * baseImageCaches;
    ImageProgressQueue          * baseImageQueue;
    NSOperationQueue            * baseOperationQueue;
}
@property (nonatomic, strong) UIImageView * backgroundView;
@end

@implementation ShareCommentView
@synthesize delegate, contentArr, praiseArr;

- (id)initWithContentArr:(NSArray *)_contentArr praiseArr:(NSArray*)_praiseArr withDelegate:(id)del height:(CGFloat)height;
{
    self = [self initWithFrame:CGRectMake(10, 0, Main_Screen_Width-20, 100)];
    if (self) {
        CGFloat sh = [[self class] getHeightWithItemArray:_contentArr];
        if (sh>height) {
            sh = height;
        }
        self.height = sh;
        self.delegate = del;
        self.contentArr = [NSMutableArray arrayWithArray:_contentArr];
        self.praiseArr = [NSMutableArray arrayWithArray:_praiseArr];
        
        //  add gray backgroundView
        [self addSubview:[self backgroundView]];
        
        //  Add tableView
        [_backgroundView addSubview:[self tableView]];
        
        baseImageQueue = [[ImageProgressQueue alloc] initWithDelegate:self];
        baseImageCaches = [[ImageCaches alloc] initWithMaxCount:1500];
        baseOperationQueue = [[NSOperationQueue alloc] init];
        baseOperationQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (void)dealloc {
    self.delegate = nil;
    self.contentArr = nil;
    [baseImageQueue cancelOperations];
    [baseOperationQueue cancelAllOperations];
}

- (UIImageView*)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        _backgroundView.image = [LOADIMAGECACHES(@"bkg_coment") resizableImageWithCapInsets:UIEdgeInsetsMake(12, 26, 4, 4)];
        _backgroundView.userInteractionEnabled = YES;
        _backgroundView.clipsToBounds = YES;
    }
    return _backgroundView;
}

- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(5, 12, _backgroundView.width - 10, self.height)];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.allowsSelection = NO;
    }

    return _tableView;
}

+ (CGFloat)getHeightWithItemArray:(NSArray*)arr {
    __block CGFloat height = 20;
    if (arr.count > 0) {
        [arr enumerateObjectsUsingBlock:^(CircleMessage * msg, NSUInteger idx, BOOL *stop) {
            CGSize size = [msg.content sizeWithFont:[UIFont systemFontOfSize:13] maxWidth:Main_Screen_Width-75 maxNumberLines:0];
            height += size.height + 30;
        }];
    }
    return height <50?50:height;
}

#pragma mark - tableViewDelegate
- (CGFloat)tableView:(UITableView *)sender heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 18+4+8;
    CircleMessage * msg = [contentArr objectAtIndex:indexPath.row];
    CGSize size = [msg.content sizeWithFont:[UIFont systemFontOfSize:13] maxWidth:self.width-75 maxNumberLines:0];
    height += size.height;
    return height <50?50:height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contentArr.count;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"UserCell";
    BaseTableViewCell * cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        sender.separatorStyle = UITableViewCellSeparatorStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
    }
    CircleComment * item = self.contentArr[indexPath.row];
    cell.textLabel.text = item.nickname;
    cell.detailTextLabel.text = item.content;
    [cell setTopLine:NO];
    [cell update:^(NSString *name) {
        cell.contentView.backgroundColor =
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = RGBCOLOR(25, 29, 96);
        cell.textLabel.top = 5;
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.height = 18;
        cell.detailTextLabel.textColor = RGBCOLOR(86, 86, 86);
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.top = 27;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
        CGSize size = [cell.detailTextLabel.text sizeWithFont:cell.detailTextLabel.font maxWidth:self.width-75 maxNumberLines:0];
        cell.detailTextLabel.size = size;
    }];
    return cell;
}

- (void)tableView:(UITableView *)sender willDisplayCell:(BaseTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInvocationOperation * opHeadItem = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadHeadImageWithIndexPath:) object:indexPath];
    [baseOperationQueue addOperation:opHeadItem];
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    if([delegate respondsToSelector:@selector(didTapHeadAtIndexPath:)]){
        [delegate didTapHeadAtIndexPath:indexPath];
    }
}

- (void)loadHeadImageWithIndexPath:(NSIndexPath *)indexPath {
    CircleComment * item = self.contentArr[indexPath.row];
    NSString * url = item.headsmall;
    if (url) {
        if ([url isKindOfClass:[NSString class]]) {
            UIImage * img = [baseImageCaches getImageCache:[url md5Hex]];
            if (!img) {
                ImageProgress * progress = [[ImageProgress alloc] initWithUrl:url delegate:baseImageQueue];
                progress.indexPath = indexPath;
                progress.tag = -1;
                [self performSelectorOnMainThread:@selector(startLoadingWithProgress:) withObject:progress waitUntilDone:YES];
            } else {
                dispatch_async(kQueueMain, ^{
                    [self setHeadImage:img forIndex:indexPath];
                });
            }
        }
    }
}

- (void)startLoadingWithProgress:(ImageProgress*)sender {
    UIImage * ima = nil;
    if (sender.loaded) {
        ima = [sender.image resizeImageGreaterThan:50];
        [baseImageCaches insertImageCache:ima withKey:[sender.imageURLString md5Hex]];
    } else {
        [baseImageQueue addOperation:sender];
    }
    
    if (!ima) {
        ima = [Globals getImageUserHeadDefault];
    }
    [self setHeadImage:ima forIndex:sender.indexPath];
}

- (void)setHeadImage:(UIImage*)image forIndex:(NSIndexPath*)indexPath {
    BaseTableViewCell * cell = (BaseTableViewCell*)[_tableView cellForRowAtIndexPath:indexPath];
    cell.imageView.image = image;
}

#pragma mark - imageProgress

- (void)imageProgressCompleted:(UIImage*)img indexPath:(NSIndexPath *)indexPath idx:(int)idx url:(NSString *)url tag:(int)tag{
    img = [img resizeImageGreaterThan:50];
    [baseImageCaches insertImageCache:img withKey:[url md5Hex]];
    [self setHeadImage:img forIndex:indexPath];
}

@end