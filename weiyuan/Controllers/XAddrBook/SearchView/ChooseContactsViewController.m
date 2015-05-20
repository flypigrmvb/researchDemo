//
//  ChooseContactsViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//
#import "ChooseContactsViewController.h"
#import "UserInfoViewController.h"
#import "BaseTableViewCell.h"
#import "Contact.h"
#import "Globals.h"
#import "UserCell.h"
#import "FriendsAddViewController.h"
#import "UIButton+NSIndexPath.h"
#import "AppDelegate.h"
#import "UIImage+FlatUI.h"
#import "InvitationViewController.h"
#import "KWAlertView.h"
#import "TextInput.h"
#import "CameraActionSheet.h"

@interface ChooseContactsViewController ()<CameraActionSheetDelegate> {
    NSMutableDictionary * contactDic;
}
@end

@implementation ChooseContactsViewController
@synthesize findNewFriend;

- (id)init {
    if (self = [super init]) {
        // Custom initialization
        contactDic = [NSMutableDictionary dictionary];
        findNewFriend = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (findNewFriend) {
        self.navigationItem.title = @"新的朋友";
        [self setRightBarButtonImage:LOADIMAGE(@"add_contact_n") highlightedImage:LOADIMAGE(@"add_contact_d") selector:@selector(barItemRightPressed:)];
        [contentArr addObjectsFromArray:[Contact valueListFromDB]];
    } else {
        [self setEdgesNone];
        self.mySearchDisplayController.searchBar.placeholder = @"搜索";
        self.navigationItem.title = @"添加朋友";
        self.tableViewCellHeight = 44;
    }
    [[AppDelegate instance] reSetNewFriendAdd];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateSectionZero" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[AppDelegate instance] reSetNewFriendAdd];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateSectionZero" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (isFirstAppear) {
        if ([Contact canAccessBook]) {
            NSMutableArray * arr = [Contact readABAddressBook];
            [arr enumerateObjectsUsingBlock:^(Contact * obj, NSUInteger idx, BOOL *stop) {
                if (!obj.nickname) {
                    obj.nickname = @"";
                }
                [contactDic setObject:obj.nickname forKey:obj.phone];
            }];
            if (findNewFriend) {
            } else {
                contentArr = arr;
            }
            [self performSelectorInBackground:@selector(sendRequest) withObject:nil];
        }
    }
    
    if (![Contact canAccessBook]) {
        UIView * headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 0)];
        NSString * msg = @"请在iPhone的“设置-隐私-通讯录”选项中，允许“睿社区”访问您的通讯录。";
        UILabel * lab = [UILabel linesText:msg font:[UIFont systemFontOfSize:14] wid:280 lines:0 color:RGBCOLOR(175, 175, 175)];
        lab.textAlignment = NSTextAlignmentCenter;
        lab.origin = CGPointMake(20, 10);
        headView.height = lab.height + 20;
        [headView addSubview:lab];
        tableView.tableHeaderView = headView;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (isFirstAppear) {
        [[[BSEngine currentEngine] user] saveConfigWhithKey:@"hasNewFriends" value:@"0"];
        if (_resetBlock) {
            _resetBlock(@"0");
            _resetBlock = nil;
        }
    }
}

- (void)barItemRightPressed:(id)sender {
    [self pushViewController:[[FriendsAddViewController alloc] init]];
}

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* TableViewCellCell = @"TableViewCellCell";
    Contact * item = [inFilter?filterArr:contentArr objectAtIndex:indexPath.row];
    UserCell * cell = [sender dequeueReusableCellWithIdentifier:TableViewCellCell];
    UIButton * btn = VIEWWITHTAG(cell.contentView, 992);
    if (findNewFriend) {
        if (!cell) {
            cell = [[UserCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:TableViewCellCell];
            btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = 992;
            [btn navStyle];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
            [btn setBackgroundImage:[UIImage imageWithColor:RGBCOLOR(254, 249, 233) cornerRadius:3] forState:UIControlStateDisabled];
            btn.titleLabel.font = [UIFont systemFontOfSize:12];
            btn.frame = CGRectMake(sender.width - 100, (self.tableViewCellHeight- 30)/2, 80, 30);

            [cell.contentView addSubview:btn];
            cell.superTableView = sender;
            [cell enableLongPress];
        }
        
        [btn addTarget:self action:@selector(opContact:) forControlEvents:UIControlEventTouchUpInside];
        btn.indexPath = indexPath;
        cell.backgroundView = nil;
        cell.selectedBackgroundView.backgroundColor = RGBCOLOR(254, 249, 233);
        if (item.statustype == 0) {
            btn.enabled = YES;
            [btn setTitle:@"添加" forState:UIControlStateNormal];
            cell.selectedBackgroundView.backgroundColor = [UIColor grayColor];
        } else if (item.statustype == 1) {
            btn.enabled = NO;
            [btn setTitle:@"等待验证" forState:UIControlStateNormal];
            cell.contentView.backgroundColor =
            cell.backgroundColor = RGBCOLOR(254, 249, 233);
        } else if (item.statustype == 2) {
            btn.enabled = NO;
            [btn setTitle:@"已添加" forState:UIControlStateNormal];
            cell.contentView.backgroundColor =
            cell.backgroundColor = RGBCOLOR(254, 249, 233);
        } else if (item.statustype == 3) {
            btn.enabled = YES;
            [btn setTitle:@"同意添加" forState:UIControlStateNormal];
            cell.selectedBackgroundView.backgroundColor = [UIColor grayColor];
        }
        
        cell.textLabel.text = item.nickname;
        if (item.sign) {
            cell.detailTextLabel.text = item.sign;
        } else {
            if (contactDic.count > 0) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"手机联系人: %@", [contactDic objectForKey:item.phone]];
            }
        }
        [cell update:^(NSString *name) {
            [cell autoAdjustText];
            cell.textLabel.highlightedTextColor =
            cell.detailTextLabel.highlightedTextColor = [UIColor grayColor];
        }];
        return cell;
    } else {
        if (cell == nil) {
            cell = [[UserCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TableViewCellCell];
            btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = 992;
            [btn navStyle];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
            [btn setBackgroundImage:[UIImage imageWithColor:RGBCOLOR(254, 249, 233) cornerRadius:3] forState:UIControlStateDisabled];
            btn.titleLabel.font = [UIFont systemFontOfSize:12];
            btn.frame = CGRectMake(sender.width - 70, (self.tableViewCellHeight- 30)/2, 60, 30);
            [cell.contentView addSubview:btn];
        }
        btn.indexPath = indexPath;
        cell.textLabel.font = [UIFont systemFontOfSize:12];
        cell.textLabel.text = item.nickname;
        cell.imageView.hidden = YES;
        cell.detailTextLabel.text = @"";
        btn.enabled = NO;
        [btn removeTarget:self action:@selector(inver:) forControlEvents:UIControlEventTouchUpInside];
        [btn removeTarget:self action:@selector(opOther:) forControlEvents:UIControlEventTouchUpInside];
        if (item.type == 1) {
            switch (item.statustype) {
                case 0:
                    btn.enabled = YES;
                    [btn setTitle:@"添加" forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(opOther:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case 1:
                    [btn setTitle:@"等待验证" forState:UIControlStateNormal];
                    break;
                case 2:
                    [btn setTitle:@"已经添加" forState:UIControlStateNormal];
                    break;
                default:
                    btn.enabled = YES;
                    [btn setTitle:@"添加" forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(opOther:) forControlEvents:UIControlEventTouchUpInside];
                    break;
            }
        } else {
            btn.enabled = YES;
            [btn setTitle:@"邀请" forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(inver:) forControlEvents:UIControlEventTouchUpInside];
        }
        cell.detailTextLabel.textColor = [UIColor grayColor];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
        [cell setBottomLine:NO];
        if (indexPath.row == (inFilter?filterArr.count:contentArr.count) - 1) {
            [cell setBottomLine:YES];
        }
        [cell update:^(NSString *name) {
            [cell autoAdjustText];
            
            cell.detailTextLabel.left = cell.width - 90;
            cell.detailTextLabel.width =90;
            cell.textLabel.top =
            cell.detailTextLabel.top = 0;
            cell.textLabel.height =
            cell.detailTextLabel.height = cell.height;
            cell.detailTextLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.highlightedTextColor =
            cell.detailTextLabel.highlightedTextColor = [UIColor grayColor];
        }];
        return cell;
    }
    
}

- (void)tableView:(id)sender handleTableviewCellLongPressed:(NSIndexPath*)indexPath {
    CameraActionSheet * sheet = [[CameraActionSheet alloc] initWithActionTitle:nil TextViews:nil CancelTitle:@"取消" withDelegate:self otherButtonTitles:@"删除", nil];
    sheet.indexPath= indexPath;
    [sheet show];
}

- (NSString*)baseTableView:(UITableView *)sender imageURLAtIndexPath:(NSIndexPath *)indexPath {
    if (findNewFriend) {
        Contact *item = [inFilter?filterArr:contentArr objectAtIndex:indexPath.row];
        return item.headsmall;
    }
    return nil;
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];

    Contact *item = [inFilter?filterArr:contentArr objectAtIndex:indexPath.row];
    if (findNewFriend) {
        // 查看资料
        [self getUserByName:item.uid];
    } else {
        switch (item.type) {
            case 0:
                // 邀请ta
            {
                InvitationViewController * con = [[InvitationViewController alloc] init];
                con.item = item;
                [self pushViewController:con];
            }
                break;
            case 1:
                // 查看资料
                [self getUserByName:item.uid];
                break;
            default:
                break;
        }
    }
    if (!findNewFriend) {
        self.searchBar.text = @"";
        [self.mySearchDisplayController setActive:NO animated:YES];
        [self.searchBar resignFirstResponder];
    }
}

#pragma mark - CameraActionSheetDelegate
- (void)cameraActionSheet:(CameraActionSheet *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        Contact * item = [inFilter?filterArr:contentArr objectAtIndex:sender.indexPath.row];
        [item deleteFromDB];
        [contentArr removeObject:item];
        [tableView deleteRowsAtIndexPaths:@[sender.indexPath] withRowAnimation:UITableViewRowAnimationRight];
    }
}

#pragma mark - Request
- (BOOL)sendRequest {
    if(contactDic.count > 0) {
        NSMutableArray * uploadArr = [NSMutableArray array];
        for (NSString * phone in contactDic.allKeys) {
            if (findNewFriend && ([Contact isInlastContacts:phone]||[Contact contactWithPhone:phone])) {
                continue;
            }
            [uploadArr addObject:phone];
        }
        
        if (uploadArr.count > 0) {
            NSString *str = [uploadArr componentsJoinedByString:@","];
            dispatch_async(kQueueMain, ^{
                [super startRequest];
                client.tag = str;
                if (findNewFriend) {
                    [client newFriends:str];
                } else {
                    [client telephone:[contactDic.allKeys componentsJoinedByString:@","]];
                }
            });
        }
    }
    return YES;
}

- (BOOL)requestDidFinish:(BSClient *)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        NSArray * arr = [obj getArrayForKey:@"data"];
        if (findNewFriend) {
            [Contact putInlastContacts:[sender.tag componentsSeparatedByString:@","] ];
            [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                Contact * item = [Contact objWithJsonDic:obj];
                item.nickname = [obj getStringValueForKey:@"name" defaultValue:@""];
                [item insertDB];
                [contentArr addObject:item];
            }];
        } else {
            for (int i = 0;i < arr.count; i++) {
                NSDictionary * dic = [arr objectAtIndex:i];
                NSString * phone = [dic getStringValueForKey:@"phone" defaultValue:@""];
                for (int z = 0;z < contentArr.count; z++) {
                    Contact *us = [contentArr objectAtIndex:z];
                    if ([us.phone isEqualToString:phone]) {
                        us.isfriend = [dic getIntValueForKey:@"isfriend" defaultValue:0];
                        us.uid = [dic getStringValueForKey:@"uid" defaultValue:@""];
                        us.type = [dic getIntValueForKey:@"type" defaultValue:0];
                        us.verify = [dic getIntValueForKey:@"verify" defaultValue:0];
                        if (us.isfriend) {
                            us.statustype = 2;
                        }
                    }
                }
            }
        }
        [tableView reloadData];
    }
    return NO;
}

- (BOOL)requestUserByNameDidFinish:(id)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        NSDictionary *dic = [obj getDictionaryForKey:@"data"];
        if (dic.count > 0) {
            User *user = [User objWithJsonDic:dic];
            [user insertDB];
            UserInfoViewController *con = [[UserInfoViewController alloc] init];
            [con setUser:user];
            [self pushViewController:con];
            if (!findNewFriend) {
                [self.mySearchDisplayController setActive:NO animated:YES];
            }
        }
    }
    return YES;
}

- (BOOL)requestaddContactDidFinish:(BSClient*)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        [self showText:sender.errorMessage];
        Contact * item = [inFilter?filterArr:contentArr objectAtIndex:sender.indexPath.row];
        if ([sender.tag isEqualToString:@"add"]) {
            if ([sender.errorMessage isEqualToString:@"添加成功"]) {
                item.statustype = 2;
                item.isfriend = YES;
            } else {
                item.statustype = 1;
            }
            [item updateVaule:[NSNumber numberWithInt:item.statustype] key:@"statustype"];
        } else if ([sender.tag isEqualToString:@"agree"]) {
            item.statustype = 2;
            [item updateVaule:[NSNumber numberWithInt:item.statustype] key:@"statustype"];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshList" object:nil];
        if (inFilter) {
            [self.mySearchDisplayController.searchResultsTableView reloadRowsAtIndexPaths:@[sender.indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView reloadData];
        } else {
            [tableView reloadRowsAtIndexPaths:@[sender.indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    return YES;
}

#pragma mark - metheds
- (void)inver:(UIButton*)sender {
    Contact *item = [inFilter?filterArr:contentArr objectAtIndex:sender.indexPath.row];
    InvitationViewController * con = [[InvitationViewController alloc] init];
    con.item = item;
    [self pushViewController:con];
}

- (void)opOther:(UIButton*)sender {
    
    Contact * item = [inFilter?filterArr:contentArr objectAtIndex:sender.indexPath.row];
    if (item.type == 1) {
        switch (item.isfriend) {
            case 1:
                // @"已添加"
                return;
                break;
            default:
                // @"添加"
                break;
        }
    } else {
//        @"添加"
    }

    if (item.verify) {
        [KWAlertView showAlertFieldWithTitle:@"验证信息" delegate:self tag:(int)sender.indexPath.row];
    } else {
        client = [[BSClient alloc] initWithDelegate:self action:@selector(requestaddContactDidFinish:obj:)];
        Contact * item = [inFilter?filterArr:contentArr objectAtIndex:sender.indexPath.row];
        [client to_friend:item.uid content:nil];
        client.indexPath = sender.indexPath;
        client.tag = @"add";
    }
}

- (void)opContact:(UIButton*)sender {
    if (client) {
        return;
    }
    Contact * item = [inFilter?filterArr:contentArr objectAtIndex:sender.indexPath.row];

    if (item.statustype == 0) {
        if (item.verify) {
            [KWAlertView showAlertFieldWithTitle:@"验证信息" delegate:self tag:(int)sender.indexPath.row];
        } else {
            client = [[BSClient alloc] initWithDelegate:self action:@selector(requestaddContactDidFinish:obj:)];
            self.loading = YES;
            [client to_friend:item.uid content:nil];
            client.indexPath = sender.indexPath;
            client.tag = @"add";
        }
    } else if (item.statustype == 3) {
        client = [[BSClient alloc] initWithDelegate:self action:@selector(requestaddContactDidFinish:obj:)];
        client.indexPath = sender.indexPath;
        [client agreeAddFriend:item.uid];
        client.tag = @"agree";
    }
}

#pragma mark - KWAlertViewDelegate
- (void)kwAlertView:(KWAlertView*)sender didDismissWithButtonIndex:(NSInteger)index {
    if (index == 1) {
        
        if (sender.field.text.hasValue && sender.field.text.length > 15) {
            [KWAlertView showAlertFieldWithTitle:@"验证信息" delegate:self tag:(int)sender.indexPath.row];
            [self showText:@"输入的申请信息长度在15个字以内!"];
            return;
        }
        
        sender.indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
        client = [[BSClient alloc] initWithDelegate:self action:@selector(requestaddContactDidFinish:obj:)];
        Contact * item = [inFilter?filterArr:contentArr objectAtIndex:sender.indexPath.row];
        [client to_friend:item.uid content:sender.field.text];
        client.indexPath = sender.indexPath;
        client.tag = @"add";
    }
}

#pragma mark - Filter

- (void)filterContentForSearchText:(NSString*)searchText
                             scope:(NSString*)scope {
    for (Contact *it in contentArr) {
        if ([it.nickname rangeOfString:searchText].location <= it.nickname.length) {
            [filterArr addObject:it];
        }
    }
}

@end
