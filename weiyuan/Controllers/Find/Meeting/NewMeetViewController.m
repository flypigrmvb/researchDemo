//
//  NewMeetViewController.m
//  ReSearch
//
//  Created by kiwi on 14-9-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "NewMeetViewController.h"
#import "BaseTableViewCell.h"
#import "TextInput.h"
#import "KPickerView.h"
#import "CameraActionSheet.h"
#import "VPImageCropperViewController.h"
#import "TextEditController.h"
#import "KPickerView.h"
#import "Meet.h"
#import "UIImage+Resize.h"
#import "Globals.h"

@interface NewMeetViewController ()<UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    KTextView * textView;
    NSString * meetTitle;
    NSString * startTime;
    NSString * endTime;
    NSString * startTimeInterval; // 传给服务器的时间戳
    NSString * endTimeInterval; // 传给服务器的时间戳
}

@property (nonatomic, strong) UIScrollView * bkgScrollView;
@property (nonatomic, strong) UIView * meetTheamview;
@property (nonatomic, strong) UIView * blackView;
@property (nonatomic, strong) UIImage * headImage;
@end

@implementation NewMeetViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"申请会议";

    [self setRightBarButton:@"确定" selector:@selector(rightPressed)];
    [contentArr addObjectsFromArray:@[@"会议图片", @"会议标题", @"起始时间", @"结束时间"]];
    self.tableViewCellHeight = 44;
    tableView.height = 256;
    tableView.scrollEnabled = NO;
    [tableView removeFromSuperview];
    //  会议主题
    
    // 遮挡
    self.blackView = [[UIView alloc] initWithFrame:self.view.frame];
    _blackView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
    _blackView.alpha = 0;
    _blackView.backgroundColor = RGBACOLOR(100, 100, 100, 0.7);
    UITapGestureRecognizer * singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap)];
    singleTapGesture.numberOfTapsRequired = 1;
    [_blackView addGestureRecognizer:singleTapGesture];
    
    // 主题层
    self.meetTheamview = [[UIView alloc] initWithFrame:CGRectMake(0, tableView.bottom, tableView.width, 215)];
    _meetTheamview.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
    _meetTheamview.backgroundColor = self.view.backgroundColor;
    UILabel * label = [UILabel singleLineText:@"会议主题" font:[UIFont systemFontOfSize:14] wid:100 color:RGBCOLOR(44, 44, 44)];
    label.origin = CGPointMake(14, 5);
    [_meetTheamview addSubview:label];
    
    textView = [[KTextView alloc] initWithFrame:CGRectMake(10, 35, _meetTheamview.width - 20, 145)];
    
    textView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
    textView.placeholder = @"每周会议";
    textView.delegate = self;
    textView.returnKeyType = UIReturnKeyDone;
    textView.layer.borderWidth = 1;
    textView.layer.masksToBounds = YES;
    textView.layer.borderColor = RGBCOLOR(220, 220, 220).CGColor;
    [_meetTheamview addSubview:textView];
    
    // 滑动盘
    self.bkgScrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    self.bkgScrollView.top = Sys_Version>=7?64:0;
    self.bkgScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.bkgScrollView];
    
    [_bkgScrollView addSubview:tableView];
    [_bkgScrollView addSubview:_blackView];
    [_bkgScrollView addSubview:_meetTheamview];
    _bkgScrollView.alwaysBounceVertical = YES;
    _bkgScrollView.showsVerticalScrollIndicator = NO;
    _bkgScrollView.contentSize = CGSizeMake(_meetTheamview.width, self.view.height +(self.view.height<=480? + 32:0));
    needToLoad = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    __block typeof(self)blockd = self;
    __block typeof(tableView)blockTableView = tableView;
    [self.view addKeyboardPanningWithFrameBasedActionHandler:^(CGRect keyboardFrameInView, BOOL opening, BOOL closing) {
        if (opening) {
            blockd.navigationItem.rightBarButtonItem.enabled = NO;
            blockd.bkgScrollView.scrollEnabled = NO;
            if (blockd.blackView.alpha <=1.f) {
                blockd.blackView.alpha ++;
            }
            blockTableView.transform = CGAffineTransformMakeScale(0.9, 0.9);
            blockd.meetTheamview.top = [blockd.view convertPoint:keyboardFrameInView.origin toView:blockd.bkgScrollView].y - blockd.meetTheamview.height+20;
        }
        if (closing) {
            blockd.navigationItem.rightBarButtonItem.enabled = YES;
            blockd.bkgScrollView.scrollEnabled = YES;
            blockd.blackView.alpha = 0;
            blockd.meetTheamview.top = blockTableView.bottom;
            blockTableView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }
    } constraintBasedActionHandler:nil];
}

- (void)rightPressed {
    if (!meetTitle) {
        [self showText:@"请输入标题!"];
    } else if (!startTimeInterval) {
        [self showText:@"请选择起始时间!"];
    } else if (!endTimeInterval) {
        [self showText:@"请选择结束时间!"];
    } else if (startTimeInterval.doubleValue > endTimeInterval.doubleValue) {
        [self showText:@"起始时间不正确，请重新选择！"];
    } else if ([[NSDate date] timeIntervalSince1970] >= endTimeInterval.doubleValue) {
        [self showText:@"结束时间不正确，请重新选择！"];
    } else {
        [super startRequest];
        [self setLoading:YES content:@"正在申请新的会议..."];
        [client addMeetingWithName:meetTitle content:textView.text start:startTimeInterval end:endTimeInterval picture:self.headImage];
    }
}

- (void)singleTap {
    [textView resignFirstResponder];
}

#pragma mark -  tableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 64;
    }
    return self.tableViewCellHeight;
}

- (CGFloat)tableView:(UITableView *)sender heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (UIView *)tableView:(UITableView *)sender viewForHeaderInSection:(NSInteger)section {
    UIImageView *clearView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, sender.width, 10)];
    clearView.backgroundColor = [UIColor clearColor];
    return clearView;
}

- (CGFloat)tableView:(UITableView *)sender heightForFooterInSection:(NSInteger)section {
    return 40;
}

- (UIView *)tableView:(UITableView *)sender viewForFooterInSection:(NSInteger)section {
    UIImageView *clearView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, sender.width, 40)];
    clearView.backgroundColor = [UIColor clearColor];
    return clearView;
}

- (UITableViewCell *)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"UITableViewCell";
    BaseTableViewCell *cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.superTableView= sender;
    }
    
    cell.textLabel.text = contentArr[indexPath.row];
    cell.imageView.hidden = indexPath.row != 0;
    cell.topLineView.hidden = indexPath.row == 0;

    cell.selectionStyle = indexPath.row == 0?UITableViewCellSelectionStyleNone:UITableViewCellSelectionStyleGray;
    [cell update:^(NSString *name) {
        cell.detailTextLabel.text = nil;
        if (indexPath.row == 1) {
            cell.detailTextLabel.text = meetTitle?meetTitle:@"2-15字";
        } else if (indexPath.row == 2) {
            cell.detailTextLabel.text = startTime;
        } else if (indexPath.row == 3) {
            cell.detailTextLabel.text = endTime;
        }
        cell.detailTextLabel.left = 100;
        cell.detailTextLabel.width = cell.width - 110;
        cell.backgroundColor =
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.textLabel.left = 10;
        cell.textLabel.textColor = RGBCOLOR(44, 44, 44);
        cell.imageView.left = cell.width - cell.imageView.width - 10;
        cell.topLineView.frame = CGRectMake(10, 0, cell.width - 20, 0.5);
        cell.detailTextLabel.textAlignment = NSTextAlignmentRight;
    }];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.headImage) {
        cell.imageView.image = self.headImage;
    } else {
        cell.imageView.image = [Globals getImageUserHeadDefault];
    }
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 1) {
        TextEditController * con = [[TextEditController alloc] initWithDel:self type:TextEditTypeDefault title:@"会议标题" value:meetTitle];
        con.indexPath = indexPath;
        con.maxTextCount = 15;
        con.minTextCount = 2;
        [self pushViewController:con];
    } else if (indexPath.row == 2) {
        KPickerView * picker = [[KPickerView alloc] initWithType:forPickViewDateAndTime delegate:self];
        picker.tag = indexPath.row;
        picker.timeDoNotInvaild = YES;
        [picker showInView:self.view];
    } else if (indexPath.row == 3) {
        KPickerView * picker = [[KPickerView alloc] initWithType:forPickViewDateAndTime delegate:self];
        [picker showInView:self.view];
        picker.timeDoNotInvaild = YES;
        UIDatePicker * tmpPicker = picker.picker;
        tmpPicker.minimumDate = [NSDate date];
        picker.tag = indexPath.row;
    }
}

- (void)tableView:(id)sender didTapHeaderAtIndexPath:(NSIndexPath*)indexPath {
    CameraActionSheet *actionSheet = [[CameraActionSheet alloc] initWithActionTitle:nil TextViews:nil CancelTitle:@"取消" withDelegate:self otherButtonTitles:@"从相册选择",  @"拍一张", nil];
    actionSheet.indexPath = indexPath;
    [actionSheet show];
}

#pragma mark - KPickerViewDelegate

- (void)kPickerViewDidDismiss:(KPickerView*)sender {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString * tmpTime = [dateFormatter stringFromDate:sender.selectedDate];
    NSString * tmpTimeInterval = [NSString stringWithFormat:@"%f", [sender.selectedDate timeIntervalSince1970]];

    if (sender.tag == 2) {
        if (endTime) {
            if ([tmpTime isEqualToString:endTime]) {
                [self showText:@"开始时间与结束时间不能相同!"];
                return;
            } else if (tmpTimeInterval.doubleValue > endTimeInterval.doubleValue) {
                [self showText:@"起始时间不正确，请重新选择！"];
                return;
            }
        }
        startTime = tmpTime;
        startTimeInterval = tmpTimeInterval;
    } else {
        if (startTime && [tmpTime isEqualToString:startTime]) {
            [self showText:@"开始时间与结束时间不能相同!"];
            return;
        } else if (tmpTimeInterval.doubleValue < startTimeInterval.doubleValue) {
            [self showText:@"结束时间不正确，请重新选择！"];
            return;
        }
        endTime = tmpTime;
        endTimeInterval = tmpTimeInterval;
    }
    
    [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:sender.tag inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - TextEditControllerDelegate

- (void)textEditControllerDidEdit:(NSString*)text idx:(NSIndexPath*)idx {
    meetTitle = text;
    [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
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

#pragma mark - 上传图片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage * img = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        img = [UIImage rotateImage:img];
        VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:img cropFrame:CGRectMake((self.view.frame.size.width - 240)/2, 100.0f, 240, 240) limitScaleRatio:3.0 title:@"上传图片"];
        [imgCropperVC setCompletionBlock:^(BOOL didFinished, UIImage *editedImage) {
            if (editedImage) {
                self.headImage = editedImage;
                [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            }
        }];
        [self pushViewController:imgCropperVC];
    }];
}

- (void)previewImageDid:(id)image{
    if (image) {
        self.headImage = image;
        [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (BOOL)requestDidFinish:(BSClient*)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        [self showText:@"会议创建成功！"];
        NSDictionary * dic = [obj objectForKey:@"data"];
        Meet * meet = [Meet objWithJsonDic:dic];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMeetList" object:meet];
        [self popViewController];
    }
    return YES;
}

@end
