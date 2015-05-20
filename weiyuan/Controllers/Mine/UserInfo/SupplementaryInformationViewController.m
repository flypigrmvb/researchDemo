//
//  SupplementaryInformationViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//
#import "SupplementaryInformationViewController.h"
#import "CameraActionSheet.h"
#import "TextEditController.h"
#import "BaseTableViewCell.h"
#import "Globals.h"
#import "KLocation.h"
#import "VPImageCropperViewController.h"
#import "UIImage+Resize.h"
#import "UIImageView+WebCache.h"
#import "ImageTouchView.h"
#import "KLocatePickView.h"
#import "AppDelegate.h"
#import "UIImage+FlatUI.h"

#define fontSize 12

@interface SupplementaryInformationViewController ()<CameraActionSheetDelegate,TextEditControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate, ImageTouchViewDelegate>
{
    ImageTouchView * headView;
    CGFloat height;
    BOOL hasImage;
    NSString * name;
    NSString * gender;
    NSString * province;
    NSString * city;
    NSString * sign;
}

@end

@implementation SupplementaryInformationViewController
@synthesize user, editType;

- (id)init {
    if (self = [super init]) {
        // Custom initialization
        headView = [[ImageTouchView alloc] initWithFrame:CGRectMake(216, 5, 64, 64) delegate:self];
        headView.image = [Globals getImageUserHeadDefault];
        editType = forEditInfo;
    }
    return self;
}

- (void)dealloc {
    Release(headView);
    self.user = nil;
}

- (void)viewDidLoad {
    if (editType != forEditInfo) {
        self.willShowBackButton = NO;
        [self.navigationItem setHidesBackButton:YES];
    }
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = RGBCOLOR(243, 243, 243);
    [self setRightBarButton:@"确定" selector:@selector(saveBtnPressed)];
    
    self.user = [[BSEngine currentEngine] user];
    if (editType == forEditInfo) {
        self.navigationItem.title = @"编辑资料";
    } else {
        self.navigationItem.title = @"完善资料";
    }
    if (user.headsmall && user.headsmall.length > 0) {
        hasImage = YES;
    } else {
        hasImage = NO;
    }
    headView.layer.masksToBounds = YES;
    headView.layer.cornerRadius = 5;
    [headView sd_setImageWithUrlString:user.headsmall placeholderImage:[Globals getImageUserHeadDefault]];
    
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 72)];
    headerView.backgroundColor = [UIColor clearColor];
    
    tableView.tableHeaderView = headerView;
    
    UIView * bkgView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, tableView.width, 62)];
    bkgView.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:bkgView];
    
    headView.frame = CGRectMake(headerView.width - bkgView.height - 20, 5, bkgView.height - 10, bkgView.height - 10);
    UILabel * lab = [UILabel linesText:@"头像" font:[UIFont systemFontOfSize:16] wid:100 lines:0 color:[UIColor grayColor]];
    lab.origin = CGPointMake(10, (72 - lab.height)/2);
    [bkgView addSubview:headView];
    [bkgView addSubview:lab];
    
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(bkgView.width - 22, 0, 6, bkgView.height);
    layer.contentsGravity = kCAGravityResizeAspect;
    layer.contents = (id)[UIImage imageNamed:@"arrow_right" isCache:YES].CGImage;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        layer.contentsScale = [[UIScreen mainScreen] scale];
    }
    [[bkgView layer] addSublayer:layer];
    self.tableViewCellHeight = 43;
    name = user.nickname;
    gender = user.gender;
    province = user.province;
    city = user.city;
    sign = user.sign;
}

- (void)saveBtnPressed {
    [self sendRequest];
}

#pragma mark - ImageTouchViewDelegate
- (void)imageTouchViewDidSelected:(id)sender {
    CameraActionSheet *actionSheet = [[CameraActionSheet alloc] initWithActionTitle:nil TextViews:nil CancelTitle:@"取消" withDelegate:self otherButtonTitles:@"从相册选择", @"拍一张", nil];
    [actionSheet show];
}

#pragma mark - kPickerView
- (void)showPickerView:(NSInteger)row {
    if (row == 1) {
        CameraActionSheet *actionSheet = [[CameraActionSheet alloc] initWithActionTitle:nil TextViews:nil CancelTitle:@"取消" withDelegate:self otherButtonTitles:@"男", @"女", nil];
        actionSheet.tag = 11;
        [actionSheet show];
    } else {
        KLocatePickView *locateView = [[KLocatePickView alloc] initWithTitle:@"选择城市" delegate:self];
        [locateView showInView:self.view];
    }
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)sender heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 3) {
        CGSize size = [user.sign sizeWithFont:[UIFont systemFontOfSize:18] maxWidth:190 maxNumberLines:0];
        size.height += 8;
        return size.height>self.tableViewCellHeight?size.height:self.tableViewCellHeight;
    }
    return self.tableViewCellHeight;
}

- (NSInteger)tableView:(UITableView *)sender numberOfRowsInSection:(NSInteger)section {
    return 4;
}

#pragma mark - UITableViewDelegate

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"BaseHeadCell";
    BaseTableViewCell* cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.textLabel.textColor = RGBCOLOR(80, 80, 80);
        cell.detailTextLabel.textColor = RGBCOLOR(163, 163, 163);
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.textLabel.font =
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.textAlignment = NSTextAlignmentRight;
    }
    cell.backgroundColor =
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.imageView.hidden = YES;
    UIImageView *badgeIcon = (UIImageView*)[cell.contentView viewWithTag:1000];
    if (!badgeIcon) {
        badgeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(tableView.width - 70, 4, self.tableViewCellHeight - 8, self.tableViewCellHeight - 8)];
        badgeIcon.tag = 1000;
        badgeIcon.image = [Globals getImageUserHeadDefault];
    }
    if (badgeIcon) {
        [cell.contentView addSubview:badgeIcon];
    }
    badgeIcon.hidden = YES;
    cell.detailTextLabel.text = @"";
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text =
            cell.className = @"昵称";
            if (name.length == 0) {
                cell.detailTextLabel.text = @"必填";
            } else {
                cell.detailTextLabel.text = name;
            }
            break;
        case 1:
            cell.textLabel.text =
            cell.className = @"性别";
            cell.detailTextLabel.textColor = [UIColor grayColor];
            
            if (gender.intValue == 0) {
                cell.detailTextLabel.text = @"男";
            } else if (gender.intValue == 1) {
                cell.detailTextLabel.text = @"女";
            } else {
                cell.detailTextLabel.text = @"选填";
            }
            break;
        case 2:
            cell.textLabel.text =
            cell.className = @"地区";
            if (province.length == 0) {
                cell.detailTextLabel.text = @"选填";
            } else {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", province, city];
            }
            break;
        case 3:
            cell.textLabel.text =
            cell.className = @"个性签名";
            
            if (sign.length == 0) {
                if (editType == forSupplementaryInfo) {
                    cell.detailTextLabel.text = @"选填";
                }
            } else {
                cell.detailTextLabel.text = sign;
            }
            break;
        default:
            break;
    }

    [cell addArrowRight];
    [cell update:^(NSString *name) {
        cell.detailTextLabel.left = cell.width - 220;
        cell.detailTextLabel.width = 190;
        cell.topLineView.frame = CGRectMake(10, 0.5, cell.width - 10, 0.5);
        UIImage * image = nil;
        if (indexPath.row == 0) {
            image = [UIImage imageWithColor:RGBCOLOR(217, 217, 217) cornerRadius:0];
        } else {
            image = [UIImage imageWithColor:RGBCOLOR(235, 235, 235) cornerRadius:0];
        }
        cell.topLineView.image = image;
    }];
    return cell;
}

- (void)pushEidt:(NSIndexPath*)indexPath title:(NSString*)title value:(NSString*)value {
    TextEditType tet = TextEditTypeDefault;
    NSString * str = nil;
    
    TextEditController *con = [[TextEditController alloc] initWithDel:self type:tet title:title value:nil];
    con.indexPath = indexPath;
    con.maxTextCount = 200;
    
    if (indexPath.row == 0) {
        str = name;
        con.maxTextCount = 8;
        con.minTextCount = 2;
    } else if (indexPath.row == 3) {
        str = sign;
        con.maxTextCount = 30;
        tet = TextEditTypeMultipleLines;
    } else {
        str = value;
    }
    con.editType = tet;
    con.defaultValue = str;
    [self pushViewController:con];
}

- (void)textEditControllerDidEdit:(NSString*)text idx:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            if (text.length > 8) {
                [self showText:@"昵称最大只能输入8个字哦！"];
            } else {
                name = text;
            }
            break;
        case 3:
            if (text.length > 30) {
                [self showText:@"签名最大只能输入30个字哦！"];
            } else {
                sign = text;
            }
            break;
        default:
            break;
    }
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    BaseTableViewCell* cell = (BaseTableViewCell*)[sender cellForRowAtIndexPath:indexPath];
    if (indexPath.row == 0 || indexPath.row == 3) {
        [self pushEidt:indexPath title:cell.className value:cell.detailTextLabel.text];
    } else {
        [self showPickerView:indexPath.row];
    }
}

#pragma mark - Request

- (BOOL)sendRequest {
    if (!name || name.length == 0) {
        [self showText:@"请输入名字!"];
    } else {
        if ([super startRequest]) {
            NSMutableDictionary * dic = [NSMutableDictionary dictionary];
            [dic setValue:name forKey:@"nickname"];
            [dic setValue:gender forKey:@"gender"];
            [dic setValue:sign forKey:@"sign"];
            [dic setValue:province forKey:@"province"];
            [dic setValue:city forKey:@"city"];
            [client editUserInfo:(hasImage?headView.image:nil) user:dic];
        }
    }
    return YES;
}

- (BOOL)requestDidFinish:(id)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        id data = [obj getDictionaryForKey:@"data"];
        User* item = [User objWithJsonDic:data];
        if (item) {
            [[BSEngine currentEngine] setCurrentUser:item password:[BSEngine currentEngine].passWord];
            [self showText:@"保存成功"];
            if (editType == forEditInfo) {
                [self popViewController];
            } else {
                [self dismissModalController:YES];
            }
            
            [[BSEngine currentEngine] readAuthorizeData];
            return YES;
        }
    }
    return NO;
}

#pragma mark - CameraActionSheetDelegate

- (void)cameraActionSheet:(CameraActionSheet *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 2) {
        return;
    }
    if (sender.tag == 11) {
        gender = [NSString stringWithFormat:@"%d", (int)buttonIndex];
        [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    } else {
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
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage * img = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        img = [UIImage rotateImage:img];
        VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:img cropFrame:CGRectMake((self.view.frame.size.width - 240)/2, 100.0f, 240, 240) limitScaleRatio:3.0 title:@"上传头像"];
        [imgCropperVC setCompletionBlock:^(BOOL didFinished, UIImage *editedImage) {
            if (editedImage) {
                hasImage = YES;
                headView.image = editedImage;
                [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            }
        }];
        [self pushViewController:imgCropperVC];
    }];
}

- (void)previewImageDid:(id)image{
    if (image) {
        hasImage = YES;
        headView.image = image;
        [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) {
        KLocatePickView *locateView = (KLocatePickView *)actionSheet;
        KLocation *location = locateView.locate;
        province = location.state;
        city = location.city;
        [tableView reloadData];
    }
}
@end
