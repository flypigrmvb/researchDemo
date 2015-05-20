//
//  SystemSettingViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "SystemSettingViewController.h"
#import "UpdateManager.h"
#import "BaseTableViewCell.h"
#import "CameraActionSheet.h"
#import "AppDelegate.h"

@interface SystemSettingViewController () <CameraActionSheetDelegate> {
    IBOutlet UIButton *exitBtn;
}
@property (nonatomic, strong) UpdateManager * updateManager;
@end

@implementation SystemSettingViewController
@synthesize updateManager;

- (id)init {
    if (self = [super initWithNibName:@"SystemSettingViewController" bundle:NULL]) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    if (updateManager) {
        [updateManager cancel];
    }
    self.updateManager = nil;
    Release(exitBtn);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"设置";
    self.tableViewCellHeight = 53;
    [exitBtn infoStyle];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)sender {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.tableViewCellHeight;
}

- (NSInteger)tableView:(UITableView *)sender numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 3;
    }
    return 4;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"tableCell";
    BaseTableViewCell* cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    [cell addArrowRight];
    [cell setBottomLine:NO];
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = @"修改密码";
            cell.className = @"PasswordViewController";
            [cell setBottomLine:YES];
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    cell.className = @"NewMessageViewController";
                    cell.textLabel.text = @"新消息通知";
                    break;
                case 1:
                    cell.className = @"PrivacyViewController";
                    cell.textLabel.text = @"隐私";
                    break;
                case 2:
                    cell.className = @"BlackListViewController";
                    cell.textLabel.text = @"黑名单";
                    [cell setBottomLine:YES];
                    break;
                default:
                    break;
            }
            
            break;
        case 2:
            switch (indexPath.row) {
                case 0:
                    cell.className = nil;
                    cell.textLabel.text = @"检测更新";
                    break;
                case 1:
                    cell.className = @"FeedbackViewController";
                    cell.textLabel.text = @"反馈意见";
                    break;
                case 2:
                    cell.className = @"HelpViewController";;
                    cell.textLabel.text = @"帮助中心";
                    break;
                case 3:
                    cell.textLabel.text = @"关于我们";
                    cell.className = @"AboutViewController";
                    [cell setBottomLine:YES];
                    break;
                default:
                    break;
            }
            
            break;
        default:
            break;
    }
    cell.backgroundColor =
    cell.contentView.backgroundColor = [UIColor whiteColor];
    [cell update:^(NSString *name) {
        cell.imageView.frame = CGRectMake(10, (cell.height - 35)/2, 35, 35);
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        cell.textLabel.left = 55;
        cell.textLabel.textColor = RGBCOLOR(50, 50, 50);
        cell.textLabel.font = [UIFont boldSystemFontOfSize:13];
    }];
    return cell;
}

#pragma mark - UITableViewDataSource

- (UIView *)tableView:(UITableView *)sender viewForFooterInSection:(NSInteger)section {
    UIImageView *clearView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, sender.width, 15)];
    clearView.backgroundColor = [UIColor clearColor];
    return clearView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 15;
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    BaseTableViewCell *cell = (BaseTableViewCell*)[sender cellForRowAtIndexPath:indexPath];
    if (!cell.className) {
        /*检查更新**/
        self.updateManager = [[UpdateManager alloc] initCheckNow:YES del:self];
    } else {
        /*跳转到下一级页面**/
        Class class = NSClassFromString(cell.className);
        id tmpCon = [[class alloc] init];
        if ([tmpCon isKindOfClass:[UIViewController class]]) {
            UIViewController* con = (UIViewController*)tmpCon;
            [self pushViewController:con];
        }
    }
}

- (void)tableView:(UITableView *)sender willDisplayCell:(BaseTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.imageView.image = LOADIMAGE(cell.textLabel.text);
}

/*退出登陆**/
- (IBAction)signOut:(id)sender {
    CameraActionSheet *actionSheet = [[CameraActionSheet alloc] initWithActionTitle:@"确定要退出登陆吗?"  TextViews:nil CancelTitle:@"取消" withDelegate:self otherButtonTitles:@"确定退出", nil];
    [actionSheet show];
}

#pragma mark - CameraActionSheetDelegate
- (void)cameraActionSheet:(CameraActionSheet *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        return;
    }
	if (buttonIndex == 0){
        [[AppDelegate instance] signOut];
	}
}

#pragma mark
#pragma mark - UpdateManagerDelegate
/*检查更新的回调**/
- (void)updateManagerDidCheck:(UpdateManager*)sender update:(BOOL)up {
    [sender showAlert];
}

@end
