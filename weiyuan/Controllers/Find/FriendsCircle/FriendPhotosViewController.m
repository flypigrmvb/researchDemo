//
//  FriendPhotosViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "FriendPhotosViewController.h"
#import "CircleMessage.h"
#import "User.h"
#import "UserCell.h"
#import "Globals.h"
#import "PhotosViewController.h"
#import "TextSeeViewController.h"
#import "ImageGridInView.h"
#import "EmotionInputView.h"
#import "UIImageView+WebCache.h"
#import "ImageTouchView.h"
#import "UserInfoViewController.h"
#import "SharePicture.h"
#import "ShareViewController.h"
#import "ShareDetailController.h"
#import "MenuView.h"
#import "MessageListViewController.h"
#import "CameraActionSheet.h"
#import "UIImage+Resize.h"
#import "PhotoSeeViewController.h"
#import "ImageGridInView.h"

@interface tmpViewCell : BaseTableViewCell
@property (nonatomic, strong) ImageTouchView * touchView;
@end

@implementation tmpViewCell

@end
@interface FriendPhotosViewController ()<ImageTouchViewDelegate, CameraActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    IBOutlet ImageTouchView * headView;// 头像
    IBOutlet UIImageView * photoFaceView;// 相册封面
    IBOutlet UILabel * nameLabel;
    IBOutlet UILabel * signLabel;
}
@property (nonatomic, retain) User *user;

@end

@implementation FriendPhotosViewController
@synthesize user;

- (id)initWithUser:(User*)it;
{
    self = [super initWithNibName:@"FriendPhotosViewController" bundle:NULL];
    if (self) {
        // Custom initialization
        self.user = it;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    nameLabel.text = user.nickname;
    signLabel.text = user.sign;
    [headView sd_setImageWithUrlString:user.headsmall placeholderImage:[Globals getImageUserHeadDefault]];
    headView.tag = @"head";
    headView.layer.masksToBounds = YES;
    headView.layer.cornerRadius = 12;
    headView.clipsToBounds = YES;
    
    [photoFaceView sd_setImageWithUrlString:user.cover placeholderImage:[UIImage imageNamed:@"默认背景"]];
    [self setEdgesNone];
    tableView.allowsSelection = NO;
    if ([user.uid isEqualToString:[BSEngine currentUserId]]) {
        [self setRightBarButtonImage:LOADIMAGE(@"btn_more") highlightedImage:nil selector:@selector(menu)];
    }
    self.navigationItem.title = @"个人相册";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFriendCircle) name:@"refreshFriendCircle" object:nil];
    [self enableSlimeRefresh];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (isFirstAppear) {
        [super startRequest];
        [client userAlbum:self.user.uid page:currentPage];
    }
}

- (void)refreshFriendCircle {
    if (client) {
        return;
    }
    isloadByslime = YES;
    currentPage = 1;
    [super startRequest];
    [client userAlbum:self.user.uid page:currentPage];
}

- (void)menu {
    MenuView * menuView = [[MenuView alloc] initWithButtonTitles:@[@"消息列表"] withDelegate:self];
    [menuView showInView:self.view origin:CGPointMake(tableView.width - 180, Sys_Version>=7?64:0)];
}

- (void)popoverView:(MenuView *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex {
    MessageListViewController * con = [[MessageListViewController alloc] init];
    [self pushViewController:con];
}

- (void)prepareLoadMoreWithPage:(int)page sinceID:(int)sinceID {
    if (isloadByslime) {
        [self setLoading:YES content:@"正在重新获取..."];
    } else {
        [self setLoading:YES content:@"正在获取更多分享"];
    }
    [client userAlbum:self.user.uid page:page];
}

- (void)imageTouchViewDidSelected:(ImageTouchView*)sender {
    if ([sender.tag isEqualToString:@"head"]) {
        UserInfoViewController *con = [[UserInfoViewController alloc] init];
        [con setUser:user];
        [self pushViewController:con];
    } else {
        [self performSelector:@selector(tableView:didSelectRowAtIndexPath:) withObject:tableView withObject:[NSIndexPath indexPathForRow:0 inSection:sender.tag.intValue]];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)sender
{
    return contentArr.count;
}

#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)sender heightForFooterInSection:(NSInteger)section {
    return 20;
}

- (UIView*)tableView:(UITableView *)sender viewForFooterInSection:(NSInteger)section {
    UIImageView *bkImageView = [[UIImageView alloc] init];
    bkImageView.backgroundColor = [UIColor clearColor];
    return bkImageView;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.imageView.image = [Globals getImageRoomHeadDefault];
    NSInvocationOperation * opHeadItem = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadHeadImageWithIndexPath:) object:indexPath];
    [baseOperationQueue addOperation:opHeadItem];
}

#pragma mark - UITableViewDelegate

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"CircleMessageCell";
    CircleMessage * item = [contentArr objectAtIndex:indexPath.section];
    tmpViewCell * cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UIImageView *bkImageView = VIEWWITHTAG(cell.contentView, 11);
    if (!cell) {
        cell = [[tmpViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.touchView = [[ImageTouchView alloc] initWithFrame:CGRectMake(60, 0, sender.width - 70, 60) delegate:self];
        [cell.contentView insertSubview:cell.touchView belowSubview:cell.imageView];
        bkImageView = [[UIImageView alloc] init];
        bkImageView.tag = 11;
        [cell.contentView addSubview:bkImageView];
    }
    cell.touchView.tag = [NSString stringWithFormat:@"%d", (int)indexPath.section];
    if (item.fid.intValue == -1) {
        cell.touchView.backgroundColor = [UIColor clearColor];
        cell.touchView.image = LOADIMAGECACHES(@"btn_room_add");
        cell.touchView.highlightedImage = LOADIMAGECACHES(@"btn_room_add_d");
        cell.touchView.width = 66;
    } else {
        cell.touchView.image =
        cell.touchView.highlightedImage = nil;
        cell.touchView.backgroundColor = RGBCOLOR(234, 234, 234);
        cell.touchView.width = sender.width - 70;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.superTableView = sender;
    NSInteger number = item.picsArray.count;
    if (number > 4) {
        number = 4;
    }
    [cell setNumberOfGroupHead:number];
    if (item.fid.intValue == -1) {
        cell.textLabel.text = nil;
        cell.imageView.hidden = YES;
    } else {
        cell.textLabel.text = item.content;
        cell.imageView.hidden = (item.picsArray.count == 0);
    }
    
    [cell setTopLine:NO];
    cell.backgroundView = nil;
    cell.backgroundColor =
    cell.contentView.backgroundColor = sender.backgroundColor;
    [cell update:^(NSString *name) {
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.imageView.frame = CGRectMake(65, (cell.height - 40)/2, 40, 40);
        cell.textLabel.frame = CGRectMake(cell.imageView.hidden?65:115, 0, cell.width - (cell.imageView.hidden?70:130), 60);
        cell.textLabel.numberOfLines = 3;
    }];
    
    bkImageView.backgroundColor = [UIColor clearColor];
    NSString * day = [self getDate:item.time];
    BOOL needShow = NO;
    if (indexPath.section == 0) {
        needShow = YES;
    } else {
        CircleMessage * lastitem = [contentArr objectAtIndex:indexPath.section-1];
        NSString *daypre = [self getDate:lastitem.time];
        needShow = YES;
        if ([day isEqualToString:daypre] && [day isEqualToString:@"今天"]) {
            needShow = NO;
        } else if ([day isEqualToString:daypre] && [day isEqualToString:@"昨天"]) {
            needShow = NO;
        } else if ([day isEqualToString:daypre] && [day isEqualToString:@"前天"]) {
            needShow = NO;
        } else if ([day isEqualToString:daypre]) {
            needShow = NO;
        }
    }
    if (needShow) {
        // 计算时间显示
        static NSDateFormatter *dateFormatter;
        if (dateFormatter == nil) {
            dateFormatter = [[NSDateFormatter alloc] init];
        }
        
        NSDate * now = [NSDate date];
        NSDate * date = [NSDate dateWithTimeIntervalSince1970:item.time];
        [dateFormatter setDateFormat:@"YY"];
        
        NSString * timestampYear = [dateFormatter stringFromDate:date];
        NSString * timestampYearNow = [dateFormatter stringFromDate:now];
        
        [dateFormatter setDateFormat:@"MM"];
        NSString * timestampMonth = [dateFormatter stringFromDate:date];
        NSString * timestampMonthNow = [dateFormatter stringFromDate:now];
        
        [dateFormatter setDateFormat:@"dd"];
        NSString * timestampDay = [dateFormatter stringFromDate:date];
        NSString * timestampDayNow = [dateFormatter stringFromDate:now];
        
        NSString * str = nil;
        UIFont * font = [UIFont boldSystemFontOfSize:21];
        CGRect frame = CGRectZero;
        for (int i = 20; i<23; i++) {
            UILabel * tLabel = VIEWWITHTAG(bkImageView, i);
            tLabel.hidden = YES;
        }
        if ([timestampYear isEqualToString:timestampYearNow] && [timestampMonth isEqualToString:timestampMonthNow]) {
            if ([timestampDay isEqualToString:timestampDayNow]) {
                // 今天
                str = needShow?@"今天":@"";
                frame = CGRectMake(6, 0, 42, 60);
                UILabel * tLabel = VIEWWITHTAG(bkImageView, 20);
                if (!tLabel) {
                    tLabel = [[UILabel alloc] initWithFrame:frame];
                    tLabel.tag = 20;
                    [bkImageView addSubview:tLabel];
                } else {
                    tLabel.frame = frame;
                }
                tLabel.hidden = NO;
                tLabel.textColor=[UIColor blackColor];
                tLabel.backgroundColor = [UIColor clearColor];
                tLabel.font = font;
                tLabel.text = str;
            } else if ((timestampDay.intValue - timestampDayNow.intValue == -1)) {
                // 昨天
                str = needShow?@"昨天":@"";
                frame = CGRectMake(6, 0, 42, 60);
                UILabel * tLabel = VIEWWITHTAG(bkImageView, 20);
                if (!tLabel) {
                    tLabel = [[UILabel alloc] initWithFrame:frame];
                    tLabel.tag = 20;
                    [bkImageView addSubview:tLabel];
                } else {
                    tLabel.frame = frame;
                }
                tLabel.hidden = NO;
                tLabel.textColor=[UIColor blackColor];
                tLabel.backgroundColor = [UIColor clearColor];
                tLabel.font = font;
                tLabel.text = str;
            } else if ((timestampDay.intValue - timestampDayNow.intValue == -2)) {
                // 前天
                str = needShow?@"前天":@"";
                frame = CGRectMake(6, 0, 42, 60);
                UILabel * tLabel = VIEWWITHTAG(bkImageView, 20);
                if (!tLabel) {
                    tLabel = [[UILabel alloc] initWithFrame:frame];
                    tLabel.tag = 20;
                    [bkImageView addSubview:tLabel];
                } else {
                    tLabel.frame = frame;
                }
                tLabel.hidden = NO;
                tLabel.textColor=[UIColor blackColor];
                tLabel.backgroundColor = [UIColor clearColor];
                tLabel.font = font;
                tLabel.text = str;
            } else {
                str = timestampDay;
                str = needShow?str:@"";
                frame = CGRectMake(4, 10, 27, 28);
                font = [UIFont boldSystemFontOfSize:23];
                UILabel * tLabel = VIEWWITHTAG(bkImageView, 20);
                if (!tLabel) {
                    tLabel = [[UILabel alloc] initWithFrame:frame];
                    tLabel.tag = 20;
                    [bkImageView addSubview:tLabel];
                } else {
                    tLabel.frame = frame;
                }
                tLabel.hidden = NO;
                tLabel.textColor=[UIColor blackColor];
                tLabel.backgroundColor = [UIColor clearColor];
                tLabel.font = font;
                tLabel.text = str;
                
                [dateFormatter setDateFormat:@"M"];
                NSString * timestampMonth = [dateFormatter stringFromDate:date];
                
                font = [UIFont boldSystemFontOfSize:14];
                str = [NSString stringWithFormat:@"%@月", timestampMonth];
                frame = CGRectMake(30, 20, 31, 21);
                str = needShow?str:@"";
                tLabel = VIEWWITHTAG(bkImageView, 21);
                if (!tLabel) {
                    tLabel = [[UILabel alloc] initWithFrame:frame];
                    tLabel.tag = 21;
                    [bkImageView addSubview:tLabel];
                } else {
                    tLabel.frame = frame;
                }
                tLabel.hidden = NO;
                tLabel.textColor=[UIColor blackColor];
                tLabel.backgroundColor = [UIColor clearColor];
                tLabel.font = font;
                tLabel.text = str;
                [bkImageView addSubview:tLabel];
                
                str = timestampYear;
                frame = CGRectMake(7, 37, 42, 21);
                str = needShow?str:@"";
                tLabel = VIEWWITHTAG(bkImageView, 22);
                if (!tLabel) {
                    tLabel = [[UILabel alloc] initWithFrame:frame];
                    tLabel.tag = 22;
                    [bkImageView addSubview:tLabel];
                } else {
                    tLabel.frame = frame;
                }
                tLabel.hidden = NO;
                tLabel.textColor=[UIColor blackColor];
                tLabel.backgroundColor = [UIColor clearColor];
                tLabel.font = font;
                tLabel.text = str;
            }
        } else {
            str = timestampDay;
            str = needShow?str:@"";
            frame = CGRectMake(4, 10, 27, 28);
            font = [UIFont boldSystemFontOfSize:23];
            UILabel * tLabel = VIEWWITHTAG(bkImageView, 20);
            if (!tLabel) {
                tLabel = [[UILabel alloc] initWithFrame:frame];
                tLabel.tag = 20;
                [bkImageView addSubview:tLabel];
            } else {
                tLabel.frame = frame;
            }
            tLabel.hidden = NO;
            tLabel.textColor=[UIColor blackColor];
            tLabel.backgroundColor = [UIColor clearColor];
            tLabel.font = font;
            tLabel.text = str;
            [bkImageView addSubview:tLabel];
            
            [dateFormatter setDateFormat:@"MM"];
            NSString * timestampMonth = [dateFormatter stringFromDate:date];
            
            font = [UIFont boldSystemFontOfSize:14];
            str = [NSString stringWithFormat:@"%@月", timestampMonth];
            frame = CGRectMake(30, 20, 31, 21);
            str = needShow?str:@"";
            tLabel = VIEWWITHTAG(bkImageView, 21);
            if (!tLabel) {
                tLabel = [[UILabel alloc] initWithFrame:frame];
                tLabel.tag = 21;
                [bkImageView addSubview:tLabel];
            } else {
                tLabel.frame = frame;
            }
            tLabel.hidden = NO;
            tLabel.textColor=[UIColor blackColor];
            tLabel.backgroundColor = [UIColor clearColor];
            tLabel.font = font;
            tLabel.text = str;
            
            str = timestampYear;
            frame = CGRectMake(7, 37, 42, 21);
            str = needShow?str:@"";
            tLabel = VIEWWITHTAG(bkImageView, 22);
            if (!tLabel) {
                tLabel = [[UILabel alloc] initWithFrame:frame];
                tLabel.tag = 22;
                [bkImageView addSubview:tLabel];
            } else {
                tLabel.frame = frame;
            }
            tLabel.hidden = NO;
            tLabel.textColor=[UIColor blackColor];
            tLabel.backgroundColor = [UIColor clearColor];
            tLabel.font = font;
            tLabel.text = str;
        }
    }
    bkImageView.hidden = !needShow;
    return cell;
}

- (void)baseTableView:(NSInteger)tag imageUpdateAtIndexPath:(NSIndexPath*)indexPath image:(UIImage *)image idx:(NSInteger)idx {
    if (tag == -1) {
        [self setHeadImage:image forIndex:indexPath];
    } else {
        [self setGroupHeadImage:image forIndex:indexPath forPos:idx];
    }
}

- (NSString*)baseTableView:(UITableView *)sender imageURLAtIndexPath:(NSIndexPath *)indexPath {
    CircleMessage * item = [contentArr objectAtIndex:indexPath.section];
    NSMutableArray * array = [NSMutableArray array];
    [item.picsArray enumerateObjectsUsingBlock:^(SharePicture * obj, NSUInteger idx, BOOL *stop) {
        [array addObject:obj.smallUrl];
        if (idx == 3) {
            *stop = YES;
        }
    }];
    return (id)array;
}

- (int)baseTableView:(UITableView *)sender imageTagAtIndexPath:(NSIndexPath*)indexPath {
    return -2;
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    CircleMessage * item = [contentArr objectAtIndex:indexPath.section];
    if (item.fid.intValue < 0) {
        CameraActionSheet *actionSheet = [[CameraActionSheet alloc] initWithActionTitle:nil TextViews:nil CancelTitle:@"取消" withDelegate:self otherButtonTitles:@"从相册选择",  @"拍一张", nil];
        actionSheet.tag = -1;
        [actionSheet show];
        return;
    }
    id con = nil;
    if (item.picsArray.count > 0) {
        // 图片feng xiang
        con = [[ShareViewController alloc] initWithShare:item index:0];
    } else {
        con = [[ShareDetailController alloc] initWithShare:item];
    }
    [self pushViewController:con];
}

- (void)tableView:(id)sender didTapHeaderAtIndexPath:(NSIndexPath*)indexPath {
    [self tableView:sender didSelectRowAtIndexPath:indexPath];
}

- (BOOL)requestDidFinish:(BSClient *)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        NSArray * data = [obj getArrayForKey:@"data"];
        
        if ([user.uid isEqualToString:[BSEngine currentUserId]] && contentArr.count == 0) {
            CircleMessage * item = [[CircleMessage alloc] init];
            item.time = [[NSDate date] timeIntervalSince1970];
            item.name = @"今天";
            item.uid = item.fid = @"-1";
            [contentArr addObject:item];
        }
        [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            CircleMessage * item = [CircleMessage objWithJsonDic:obj];
            [contentArr addObject:item];
        }];
        [tableView reloadData];
        return YES;
    }
    return NO;
}

- (NSString*)getDate:(NSTimeInterval)createtime {
    NSString *str = nil;
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
    }
    
    NSDate * now = [NSDate date];
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:createtime];
    [dateFormatter setDateFormat:@"YY"];
    
    NSString * timestampYear = [dateFormatter stringFromDate:date];
    NSString * timestampYearNow = [dateFormatter stringFromDate:now];
    
    [dateFormatter setDateFormat:@"dd"];
    NSString * timestampDay = [dateFormatter stringFromDate:date];
    NSString * timestampDayNow = [dateFormatter stringFromDate:now];
    
    if ([timestampYear isEqualToString:timestampYearNow]) {
        if ([timestampDay isEqualToString:timestampDayNow]) {
            // 今天
            str = @"今天";
        } else if ((timestampDay.intValue - timestampDayNow.intValue == -1)) {
            // 昨天
            str = @"昨天";
        }  else if ((timestampDay.intValue - timestampDayNow.intValue == -2)) {
            // 昨天
            str = @"前天";
        } else {
            [dateFormatter setDateFormat:@"dd日M月%d年"];
            str = [dateFormatter stringFromDate:date];
        }
    } else {
        [dateFormatter setDateFormat:@"dd日M月%d年"];
        str = [dateFormatter stringFromDate:date];
    }
    return str;
}
#pragma mark - CameraActionSheetDelegate

- (void)cameraActionSheet:(CameraActionSheet *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 2) {
        return;
    }
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    if (buttonIndex == 0){
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    } else if (buttonIndex == 1) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        } else {
            [self showText:@"无法打开相机"];
        }
    }
    [self presentModalController:picker animated:YES];
}

#pragma mark - imagePicker

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage * img = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        img = [img resizeImageGreaterThan:1024];
        PhotoSeeViewController * con = [[PhotoSeeViewController alloc] init];
        con.preImage = img;
        [self pushViewController:con];
    }];
    
}
@end
