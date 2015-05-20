//
//  ShareViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ShareViewController.h"
#import "PhotoView.h"
#import "CircleMessage.h"
#import "SharePicture.h"
#import "UIImage+FlatUI.h"
#import "ImageTouchView.h"
#import "ShareDetailController.h"
#import "Globals.h"
#import "MenuView.h"
#import "KAlertView.h"
#import "Message.h"
#import "UIImage+Resize.h"
#import "TextEditController.h"
#import "JSON.h"
#import "Notify.h"
#import <EventKit/EventKit.h>
// 滑动方向
typedef enum {
    forDirectionOriginal = 0,   // 初始
    forDirectionRight = 1,      // 向右,页面增加
    forDirectionLeft = -1,      // 向左,页面减少
}DirectionType;

@interface KButtonInShareView : UIButton {
    CGFloat imgOffSet;
    CGFloat titleOffset;
    CGFloat imgWidth;
}

@end

@implementation KButtonInShareView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    imgOffSet = 6.0;
    imgWidth = 26;
    titleOffset = 4.0;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    return CGRectMake(imgOffSet, imgOffSet, imgWidth, contentRect.size.height-imgOffSet*2);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    return CGRectMake(imgOffSet+imgWidth+titleOffset, 0, contentRect.size.width - (imgOffSet+imgWidth+titleOffset*2), contentRect.size.height);
}

@end

@interface KInfoInShareView : UIButton {
    CGFloat titleOffset;
}

@property (nonatomic, strong) NSString* contentDisplay;

@end

@implementation KInfoInShareView

@synthesize contentDisplay;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    titleOffset = 10.0;
}

- (void)dealloc {
    Release(contentDisplay);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    return CGRectMake(titleOffset, titleOffset, contentRect.size.width - titleOffset*2, contentRect.size.height - titleOffset*2);
}

- (void)setContentDisplay:(NSString *)str {
    contentDisplay = [str copy];
    
    [self setTitle:contentDisplay forState:UIControlStateNormal];
    
    CGRect tmpFrame = self.frame;
    CGSize size = [contentDisplay sizeWithFont:self.titleLabel.font maxWidth:tmpFrame.size.width - titleOffset*2 maxNumberLines:0];
    size.height += titleOffset*2;
    tmpFrame.origin.y -= (size.height - tmpFrame.size.height);
    tmpFrame.size.height = size.height;
    self.frame = tmpFrame;
}

@end

@interface ShareViewController () <UIAlertViewDelegate, PhotoViewDelegate, ImageTouchViewDelegate,UIScrollViewDelegate> {
    IBOutlet UIScrollView       *   contentView;
    IBOutlet KInfoInShareView   *   btnInfo;
    IBOutlet UIView             *   footerView;
    IBOutlet UIButton           *   btnLike;
    IBOutlet UILabel            *   labLike;
    IBOutlet UILabel            *   labComment;
    IBOutlet UIButton           *   btnComment;
    IBOutlet ImageTouchView     *   detailView;
    
    NSMutableArray              *   contentArr;
    
    PhotoView                   *   photoViewLeft;
    PhotoView                   *   photoViewMid;
    PhotoView                   *   photoViewRight;
    
    UILabel                     *   labPos;
    NSInteger                   currentIndex;
    int pageWidth;
    
    ShareViewRequestType typeRequest;
}

@property (nonatomic, strong) CircleMessage*    share;
@property (nonatomic, assign) BOOL      isHideInfo;

@end

@implementation ShareViewController

@synthesize share;
@synthesize isHideInfo;

- (id)initWithShare:(CircleMessage *)itemS index:(NSInteger)index
{
    self = [super initWithNibName:@"ShareViewController" bundle:nil];
    if (self) {
        // Custom initialization
        self.share = itemS;
        contentArr = [[NSMutableArray alloc] init];
        for (SharePicture * itemP in itemS.picsArray) {
            [contentArr addObject:itemP.originUrl];
        }
        currentIndex = index;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"分享详细";
    
    [self loadingtitleView];
    [self setEdgesNone];
    
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [singleTapGesture setNumberOfTapsRequired:1];
    [footerView addGestureRecognizer:singleTapGesture];
    [self setRightBarButtonImage:LOADIMAGE(@"btn_more") highlightedImage:nil selector:@selector(menu)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedFriendCircle:) name:@"receivedFriendCircle" object:nil];
    
    btnInfo.contentDisplay = share.content;
    
    CGRect frame = contentView.frame;
    contentView.userInteractionEnabled = YES;
    contentView.pagingEnabled = YES;
    contentView.showsHorizontalScrollIndicator = NO;
    contentView.showsVerticalScrollIndicator = NO;
    
    photoViewLeft = [[PhotoView alloc] initWithFrame:frame delegate:self];
    photoViewMid = [[PhotoView alloc] initWithFrame:frame delegate:self];
    photoViewRight = [[PhotoView alloc] initWithFrame:frame delegate:self];
    
    photoViewLeft.autoresizingMask =
    photoViewMid.autoresizingMask =
    photoViewRight.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    [contentView addSubview:photoViewLeft];
    [contentView addSubview:photoViewMid];
    [contentView addSubview:photoViewRight];
    
    contentView.alwaysBounceHorizontal = YES;
    pageWidth = App_Frame_Width;
    contentView.contentSize = CGSizeMake(pageWidth*contentArr.count, contentView.height);
    [contentView setContentOffset:CGPointMake(pageWidth*currentIndex, 0)];
    [self setCurrentIndex:currentIndex direction:forDirectionOriginal];
    
    [self updateUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!isFirstAppear) {
        [self updateUI];
    } else {
    }
    contentView.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    contentView.delegate = nil;
}

- (void)loadingtitleView {
    UIView * tView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    UILabel * timeLab = [UILabel linesText:[Globals convertDateFromString:[NSString stringWithFormat:@"%f", share.time] timeType:3] font:[UIFont systemFontOfSize:13] wid:200 lines:0 color:[UIColor whiteColor]];
    timeLab.frame = CGRectMake(0, 8, tView.width, timeLab.height);
    [tView addSubview:timeLab];
    labPos = [UILabel singleLineText:@"1/1" font:[UIFont systemFontOfSize:12] wid:200 color:[UIColor whiteColor]];
    labPos.frame = CGRectMake(0, timeLab.bottom + 2, tView.width, labPos.height);
    [tView addSubview:labPos];
    labPos.text = [NSString stringWithFormat:@"1/%d", (int)share.picsArray.count];
    self.navigationItem.titleView = tView;
}

- (void)menu {
    // 查看自己的收藏时候，可以删除
    NSArray * arr = nil;
    if ([share.uid isEqualToString:[BSEngine currentUserId]]) {
        arr = @[@"发送给朋友", @"保存到手机", @"收藏", @"删除"];
    } else {
        arr = @[@"发送给朋友", @"保存到手机", @"收藏"];
    }
    MenuView * menuView = [[MenuView alloc] initWithButtonTitles:arr withDelegate:self];
    menuView.hasImage = NO;
    [menuView showInView:self.view origin:CGPointMake(self.view.width - 180, Sys_Version>=7?64:0)];
}

- (void)popoverView:(MenuView *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex {
    SharePicture * itemp = share.picsArray[currentIndex];
    if (buttonIndex == 0) {
        Message * msg = [[Message alloc] init];
        msg.content = @"[图片]";
        msg.typefile = forFileImage;
        msg.imgUrlS = itemp.originUrl;
        msg.imgUrlL = itemp.smallUrl;
        UIImage * image = [photoViewMid.imageView.image resizeImageGreaterThan:200];
        msg.imgHeight = image.size.height;
        msg.imgWidth = image.size.width;
        [self forwordWithMsg:msg];
    } else if (buttonIndex == 1) {
        UIImageWriteToSavedPhotosAlbum(photoViewMid.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    } else if (buttonIndex == 2) {
        [self startRequest];
        UIImage * image = [photoViewMid.imageView.image resizeImageGreaterThan:200];
        typeRequest = forShareViewRequestfav;
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        [dic setObject:itemp.originUrl forKey:@"urllarge"];
        [dic setObject:itemp.smallUrl forKey:@"urlsmall"];
        [dic setObject:[NSString stringWithFormat:@"%f", image.size.width]  forKey:@"width"];
        [dic setObject:[NSString stringWithFormat:@"%f", image.size.height]  forKey:@"height"];
        [dic setObject:[NSString stringWithFormat:@"%d", forFileImage]  forKey:@"typefile"];
        [client addfavorite:share.uid otherid:nil content:[dic JSONString]];
    } else if (buttonIndex == 3) {
        typeRequest = forShareViewRequestDelete;
        [self sendRequest];
    }
}

- (IBAction)imageTouchViewDidSelected:(id)sender {
    ShareDetailController * con = [[ShareDetailController alloc] initWithShare:share];
    [self pushViewController:con];
}

- (void)btnPressed:(UIButton*)sender {
    if (sender == btnInfo) {
        self.isHideInfo = !isHideInfo;
    } else if (sender == btnLike) {
        typeRequest = forShareViewRequestLike;
        [self sendRequest];
    } else if (sender == btnComment) {
        TextEditController * con = [[TextEditController alloc] initWithDel:self type:TextEditTypeMultipleLines title:@"评论" value:nil];
        con.maxTextCount = 100;
        [self pushViewController:con];
    }
}

- (void)textEditControllerDidEdit:(NSString*)text idx:(NSIndexPath*)idx {
    [super startRequest];
    typeRequest = forShareViewRequestComment;
    [client shareReply:share.fid fuid:share.uid content:text];
}

- (void)handleSingleTap:(UIGestureRecognizer *)gesture {
    self.isHideInfo = !isHideInfo;
}

- (void)updateUI {
    btnLike.selected = share.ispraise;
    labLike.text = [NSString stringWithFormat:@"%d",share.praises];
    labComment.text = [NSString stringWithFormat:@"%d",share.replys];
    labComment.width = [labComment.text sizeWithFont:labComment.font maxWidth:100 maxNumberLines:1].width;
    labLike.width = [labLike.text sizeWithFont:labLike.font maxWidth:100 maxNumberLines:1].width;
    detailView.width = 39+labLike.width + labComment.width;
    detailView.left = self.view.width - detailView.width - 4;
    
    labPos.text = [NSString stringWithFormat:@"%d/%d", (int)currentIndex + 1, (int)share.picsArray.count];
}

- (void)setIsHideInfo:(BOOL)value {
    isHideInfo = value;
    [UIView animateWithDuration:0.35 animations:^{
        btnInfo.alpha = isHideInfo?0.0:1.0;
        footerView.alpha = isHideInfo?0.0:1.0;
        [self.navigationController setNavigationBarHidden:isHideInfo animated:YES];
    }];
}

- (void)setCurrentIndex:(NSInteger)page direction:(DirectionType)dir {
    currentIndex = page;
    if (dir == forDirectionOriginal) {
        [self moveListView:photoViewMid page:page];
        [self moveListView:photoViewRight page:page+1];
        [self moveListView:photoViewLeft page:page-1];
    } else {
        PhotoView* tmpList = nil;
        [photoViewMid initializeScale];
        if (dir == forDirectionRight) {
            tmpList = photoViewLeft;
            photoViewLeft = photoViewMid;
            photoViewMid = photoViewRight;
            photoViewRight = tmpList;
        } else if (dir == forDirectionLeft) {
            tmpList = photoViewRight;
            photoViewRight = photoViewMid;
            photoViewMid = photoViewLeft;
            photoViewLeft = tmpList;
        }
        [self moveListView:tmpList page:page+dir];
    }
    labPos.text = [NSString stringWithFormat:@"%d/%d", (int)currentIndex + 1, (int)share.picsArray.count];
}

- (void)moveListView:(PhotoView*)listView page:(NSInteger)page {
    CGRect frame = listView.frame;
    frame.origin.x = pageWidth*page;
    listView.frame = frame;
    if (page >= 0 && page < contentArr.count) {
        listView.hidden = NO;
        listView.imgUrl = [contentArr objectAtIndex:page];
    } else {
        listView.hidden = YES;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    if (sender == contentView) {
        int page = floor((sender.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        if (page != currentIndex) {
            if (page > currentIndex) {
                [self setCurrentIndex:page direction:forDirectionRight];
            } else {
                [self setCurrentIndex:page direction:forDirectionLeft];
            }
        }
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        return;
    }
    if (sender.tag == 1) {
        if (buttonIndex == 1) {
            typeRequest = forShareViewRequestDelete;
            [self sendRequest];
        }
    }
}

#pragma mark - Request

- (BOOL)sendRequest {
    if ([super startRequest]) {
        if (typeRequest == forShareViewRequestLike) {
            [client addZan:share.fid];
        } else if (typeRequest == forShareViewRequestDelete) {
            [client deleteShare:share.fid];
        }
        return YES;
    }
    return NO;
}

- (BOOL)requestDidFinish:(BSClient*)sender obj:(NSDictionary *)obj {
    [self showText:sender.errorMessage];
    if ([super requestDidFinish:sender obj:obj]) {
        if (typeRequest == forShareViewRequestLike) {
            share.ispraise = !share.ispraise;
            [self updateUI];
        } else if (typeRequest == forShareViewRequestDelete) {
            [Notify deleteFromDBWithShareID:share.fid];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshFriendCircle" object:nil];
            [self popViewController];
        } else if (typeRequest == forShareViewRequestfav) {
            
        }
        return YES;
    }
    return NO;
}

#pragma mark - PhotoViewDelegate

- (void)photoViewDidPress:(id)sender {
    self.isHideInfo = !isHideInfo;
}

- (void)image:(UIImage*)img didFinishSavingWithError:(NSError*)error contextInfo:(void*)context {
    NSString * msg;
    KAlertType ty;
    if (error == nil) {
        msg = @"保存成功";
        ty = KAlertTypeCheck;
    } else {
        msg = [error localizedFailureReason];
        ty = KAlertTypeError;
    }
    [KAlertView showType:ty text:msg for:1.0 animated:YES];
}

#pragma mark - 赞或评论的通知
- (void)receivedFriendCircle:(NSNotification*)sender {
    Notify * ntf = sender.object;
    if (ntf.type == forNotifyComment) {
        CircleComment * comment = [[CircleComment alloc] init];
        comment.nickname = ntf.user.nickname;
        comment.uid = ntf.user.uid;
        comment.content = ntf.content;
        [share.replylist addObject:comment];
        share.replys++;
    } else if (ntf.type == forNotifyZan) {
        CircleZan *circleZan = [[CircleZan alloc] init];
        circleZan.nickname = ntf.user.nickname;
        circleZan.uid = ntf.user.uid;
        [share.praiselist addObject:circleZan];
        share.praises++;
    } else if (ntf.type == forNotifyCancelZan) {
        [share.praiselist enumerateObjectsUsingBlock:^(CircleZan * zan, NSUInteger idx, BOOL *stop) {
            if ([zan.uid isEqualToString:ntf.user.uid]) {
                [share.praiselist removeObject:zan];
                *stop= YES;
            }
        }];
        share.praises--;
    }
    [self updateUI];
}
@end
