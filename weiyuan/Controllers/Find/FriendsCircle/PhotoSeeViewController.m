//
//  PhotoSeeViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//
#import "PhotoSeeViewController.h"
#import "UIImage+Resize.h"
#import "UIImage+FlatUI.h"
#import "UIColor+FlatUI.h"
#import "CameraActionSheet.h"
#import "ImageViewController.h"
#import "TextInput.h"
#import "BaseTableViewCell.h"
#import "ImageTouchView.h"
#import "MapViewController.h"
#import "VisibleViewController.h"
#import "EmotionInputView.h"

@interface PhotoSeeViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, CameraActionSheetDelegate, ImageTouchViewDelegate, MapViewDelegate>
{
    NSMutableArray          * picArr;
    NSMutableArray          * buttonSArr;
    IBOutlet KTextView      * textView;
    IBOutlet ImageTouchView * touchView;
    IBOutlet UIView         * headerView;
}
@property (nonatomic, strong) NSMutableArray * visibleArray;
@property (nonatomic, strong) NSMutableArray * visibleIdArray;
@property (nonatomic, strong) BMKPoiInfo * selectBMKPoiInfo;
@end

@implementation PhotoSeeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    picArr = [[NSMutableArray alloc] init];
    buttonSArr = [[NSMutableArray alloc] init];
    self.visibleIdArray = [NSMutableArray array];
    // Do any additional setup after loading the view from its nib.
    textView.layer.masksToBounds = YES;
    textView.layer.cornerRadius = 2;
    textView.layer.borderWidth = 1;
    textView.layer.borderColor = RGBCOLOR(228, 228, 228).CGColor;
    textView.placeholder = @"说点儿什么...";
    self.navigationItem.title = @"分享";
    textView.font = [UIFont systemFontOfSize:16];
    [contentArr addObjectsFromArray:@[@[@"所在位置"],@[@"可见范围"]]];
    tableView.tableHeaderView = headerView;
    touchView.image = LOADIMAGECACHES(@"btn_room_add");
    touchView.highlightedImage = LOADIMAGECACHES(@"btn_room_add_d");
    touchView.tag = @"touchView";
    self.tableViewCellHeight = 44;
    [self setRightBarButton:@"发送" selector:@selector(saveBtnPressed:)];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [textView resignFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (isFirstAppear) {
        if (_preImage) {
            [picArr addObject:_preImage];
            [self refresh];
        }
    }
}

- (void)imageTouchViewDidSelected:(ImageTouchView*)sender {
    [textView resignFirstResponder];
    if ([sender.tag isEqualToString:@"touchView"]) {
        CameraActionSheet *actionSheet = [[CameraActionSheet alloc] initWithActionTitle:nil TextViews:nil CancelTitle:@"取消" withDelegate:self otherButtonTitles:@"从相册选择",  @"拍一张", nil];
        [actionSheet show];
    } else {
        CGRect cellF = [tableView convertRect:sender.frame toView:self.navigationController.view];
        ImageViewController * con = [[ImageViewController alloc] initWithFrameStart:cellF supView:self.navigationController.view pic:nil preview:(id)sender.image];
        con.bkgImage = [self.view screenshot];
        con.lookPictureState = forLookPictureStateDelete;
        [con setBlock:^(BOOL isDel) {
            if (isDel) {
                [picArr removeObjectAtIndex:sender.tag.intValue];
                ImageTouchView * sbItem = [buttonSArr objectAtIndex:sender.tag.intValue];
                [sbItem removeFromSuperview];
                [buttonSArr removeObjectAtIndex:sender.tag.intValue];
                [UIView animateWithDuration:0.35 animations:^{
                    [buttonSArr enumerateObjectsUsingBlock:^(ImageTouchView * imageView, NSUInteger idx, BOOL *stop) {
                        imageView.left = idx*(imageView.width+10) + 10;
                    }];
                    
                    touchView.left = 10;
                    if (buttonSArr.count != 0) {
                        touchView.left += buttonSArr.count*(touchView.width+10);
                    }
                }];
                if (picArr.count > 5) {
                    touchView.hidden = YES;
                } else {
                    touchView.hidden = NO;
                }
            }
        }];
        [self.navigationController pushViewController:con animated:NO];
    }
}

- (void)saveBtnPressed:(UIButton*)sender {
    if (picArr.count>0 || textView.text.length>0) {
        [super startRequest];
        [client addNewshare:picArr content:textView.text lng:_selectBMKPoiInfo.pt.longitude lat:_selectBMKPoiInfo.pt.latitude address:_selectBMKPoiInfo.address visible:_visibleIdArray];
    } else {
        [self showText:@"请输入分享文字或者图片!"];
    }
}

#pragma mark - textViewDelegate
- (BOOL)textViewShouldEndEditing:(UITextView *)sender
{
    [sender resignFirstResponder];
    return YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    [textView resignFirstResponder];
}

- (BOOL)requestDidFinish:(BSClient*)sender obj:(NSDictionary*)obj
{
    if ([super requestDidFinish:sender obj:obj]) {
        [self showText:sender.errorMessage];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshFriendCircle" object:nil];
        [self popViewController];
    }
    return NO;
}

#pragma mark - CameraActionSheetDelegate

- (void)cameraActionSheet:(CameraActionSheet *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 2) {
        return;
    }
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.view.tag = sender.tag;
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

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage * img = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        img = [UIImage rotateImage:img];
        img = [img resizeImageGreaterThan:1024];
        [picArr addObject:img];
        [self refresh];
    }];
}

- (void)refresh {
    CGRect frame = touchView.frame;
    ImageTouchView* sbItem = [[ImageTouchView alloc] initWithFrame:frame delegate:self];
    sbItem.layer.masksToBounds = YES;
    sbItem.layer.cornerRadius = 2;
    frame.origin.x += frame.size.width+10;
    [UIView animateWithDuration:0.25 animations:^{
        touchView.frame = frame;
    }];
    UIImage *image = [picArr lastObject];
    sbItem.image = image;
    sbItem.tag = [NSString stringWithFormat:@"%d", (int)buttonSArr.count];
    [buttonSArr addObject:sbItem];
    [headerView addSubview:sbItem];
    if (picArr.count > 5) {
        touchView.hidden = YES;
    } else {
        touchView.hidden = NO;
    }
}

#pragma mark - UITableViewDataSource

- (UIView *)tableView:(UITableView *)sender viewForHeaderInSection:(NSInteger)section {
    UIImageView * clearView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, sender.width, 10)];
    clearView.backgroundColor = [UIColor clearColor];
    return clearView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UIView *)tableView:(UITableView *)sender viewForFooterInSection:(NSInteger)section {
    UIImageView *clearView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, sender.width, 10)];
    clearView.backgroundColor = [UIColor clearColor];
    return clearView;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)sender {
    return 2;
}

- (NSInteger)tableView:(UITableView *)sender numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BaseTableViewCell * cell = (BaseTableViewCell*) [super tableView:sender cellForRowAtIndexPath:indexPath];
    cell.textLabel.text = [[contentArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.topLine = NO;
    cell.bottomLine = YES;
    cell.backgroundView = nil;
    cell.backgroundColor =
    cell.contentView.backgroundColor = sender.backgroundColor;
    [cell update:^(NSString *name) {
        cell.textLabel.font = [UIFont systemFontOfSize:13];
        cell.imageView.size = cell.imageView.image.size;
        cell.imageView.origin = CGPointMake(10, (cell.height - cell.imageView.size.height)/2);
        cell.textLabel.height = cell.height;
        cell.textLabel.left = 35;
        cell.textLabel.textColor = RGBCOLOR(32, 32, 32);
        cell.bottomLineView.frame = CGRectMake(10, cell.height - 1, cell.width - 20, 1);
        cell.bottomLineView.highlightedImage =
        cell.bottomLineView.image = [UIImage imageWithColor:RGBCOLOR(235, 235, 235) cornerRadius:0];
    }];
    return cell;
}

- (void)tableView:(UITableView *)sender willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * str = nil;
    if (indexPath.section == 0) {
        if (_selectBMKPoiInfo) {
            str = @"icon_location_d";
        } else {
            str = @"icon_location";
        }
    } else {
        if (_visibleIdArray.count > 0) {
            str = @"icon_public_d";
        } else {
            str = @"icon_public";
        }
    }
    
    cell.imageView.image = LOADIMAGECACHES(str);
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    id con = nil;
    if (indexPath.section == 0) {
        con = [[MapViewController alloc] initWithDelegate:self];
    } else {
        // 选择可见范围
        con = [[VisibleViewController alloc] init];
        ((VisibleViewController*)con).selectedArray = _visibleArray;
        [(VisibleViewController*)con setBlock:^(NSArray * array) {
            // 更新 选择可见范围
            [_visibleIdArray removeAllObjects];
            _visibleArray = [NSMutableArray arrayWithArray:array];
            if (array.count > 0) {
                NSMutableArray * arr = [NSMutableArray array];
                [_visibleArray enumerateObjectsUsingBlock:^(User * obj, NSUInteger idx, BOOL *stop) {
                    [arr addObject:obj.nickname];
                    [_visibleIdArray addObject:obj.uid];
                }];
            }
            [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
        }];
    }
    [self pushViewController:con];
}

// 更新 地理位置
- (void)mapViewControllerSetPoiInfo:(BMKPoiInfo *)selectBMKPoiInfo {
    [contentArr removeObjectAtIndex:0];
    [contentArr insertObject:@[selectBMKPoiInfo.address] atIndex:0];
    _selectBMKPoiInfo = selectBMKPoiInfo;
    [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

@end
