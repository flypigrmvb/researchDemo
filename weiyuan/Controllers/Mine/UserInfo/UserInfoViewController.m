//
//  UserInfoViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "UserInfoViewController.h"
#import "User.h"
#import "Message.h"
#import "BaseTableViewCell.h"
#import "Globals.h"
#import "UIImageView+WebCache.h"
#import "MenuView.h"
#import "TextEditController.h"
#import "KWAlertView.h"
#import "TalkingViewController.h"
#import "Session.h"
#import "SessionNewController.h"
#import "JSON.h"
#import "FriendPhotosViewController.h"
#import "TextInput.h"
#import "FriendCircleAuthViewController.h"
#import "AppDelegate.h"

@interface UserInfoViewController () {
    IBOutlet UIImageView   * genderImageView;
    IBOutlet UIImageView   * headImg;
    IBOutlet UIView        * headView;
    IBOutlet UILabel       * nameLabel;
    IBOutlet UILabel       * marknameLabel;
    
    IBOutlet UIView        * picView;
    IBOutlet UIImageView   * picView1;
    IBOutlet UIImageView   * picView2;
    IBOutlet UIImageView   * picView3;
    IBOutlet UIButton      * button;
}

@end

@implementation UserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"详细资料";
    [self setEdgesNone];
    headImg.layer.masksToBounds = YES;
    headImg.layer.cornerRadius = 2;
    self.tableViewCellHeight = 44;
    if ([_user.uid isEqualToString:[BSEngine currentUserId]]) {
        tableView.tableFooterView = nil;
    } else {
        [button navStyle];
        if (_user.isfriend == 0) {
            [button setTitle:@"添加到通讯录" forState:UIControlStateNormal];
        } else {
            [button setTitle:@"发消息" forState:UIControlStateNormal];
            [self setRightBarButtonImage:LOADIMAGE(@"btn_more") highlightedImage:LOADIMAGE(@"btn_more_d") selector:@selector(moreBtnPressed:)];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [headImg sd_setImageWithUrlString:_user.headlarge placeholderImage:[Globals getImageUserHeadDefault]];
    [self updateName];
}

- (void)updateName {
    if (_user.remark && [_user.remark isKindOfClass:[NSString class]] && _user.remark.length > 0) {
        // 备注名存在时，备注名排头行，昵称 排第二行
        nameLabel.text = _user.remark;
        marknameLabel.text = [NSString stringWithFormat:@"昵称:%@", _user.nickname];
        marknameLabel.hidden = NO;
    } else {
        // 备注名不存在时，昵称排头行，备注名隐藏
        nameLabel.text = _user.nickname;
        marknameLabel.hidden = YES;
    }
    CGSize size = [nameLabel.text sizeWithFont:nameLabel.font maxWidth:200 maxNumberLines:0];
    nameLabel.width = size.width;
    genderImageView.left = nameLabel.right + 4;
    if ([_user.gender isEqualToString:@"1"]) {
        genderImageView.image = LOADIMAGE(@"woman");
    } else {
        genderImageView.image = LOADIMAGE(@"man");
    }
}

- (void)moreBtnPressed:(UIButton*)sender {
    MenuView * menuView = [[MenuView alloc] initWithButtonTitles:@[@"备注信息",(_user.isstar == 0?@"标为星标朋友":@"取消星标朋友"),@"设置朋友圈权限",@"发送该名片",(_user.isblack == 0?@"加入黑名单":@"移除黑名单"),@"删除"] withDelegate:self];
    [menuView showInView:self.view origin:CGPointMake(tableView.width - 180, 0)];
    menuView.tag = sender.tag;
}

- (void)bottomBtnPressed:(UIButton*)sender {
    if (_user.isfriend == 0) {
        if (_user.verify) {
            [KWAlertView showAlertFieldWithTitle:@"验证信息" delegate:self tag:-1];
        } else {
            [super startRequest];
            [client to_friend:_user.uid content:nil];
            client.tag = @"add";
        }
    } else {
        Session * session = [Session getSessionWithID:_user.uid];
        if (!session) {
            session = [Session sessionWithUser:_user];
        }
        TalkingViewController * con = [[TalkingViewController alloc] initWithSession:session];
        [self pushViewController:con];
    }
}

- (void)blackBtnPressed:(UIButton*)sender {
    [super startRequest];
    [client black:_user.uid];
    client.tag = @"black";
}

- (BOOL)requestDidFinish:(BSClient*)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        [self showText:sender.errorMessage];
        if ([sender.tag isEqualToString: @"del"]) {
            [self popViewController];
            Session * session = [Session getSessionWithID:self.user.uid];
            if (session) {
                [session deleteFromDB];
                [[AppDelegate instance] cleanMessageWithSession:session];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshList" object:_user];
        } else if ([sender.tag isEqualToString: @"black"]) {
            _user.isblack = !_user.isblack;
            if (_user.isblack) {
                [self popViewController];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshList" object:_user];
        } else if ([sender.tag isEqualToString: @"add"]) {
            if ([sender.errorMessage isEqualToString:@"添加成功"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshList" object:_user];
                [button setTitle:@"发消息" forState:UIControlStateNormal];
                [self setRightBarButtonImage:LOADIMAGE(@"btn_more") highlightedImage:LOADIMAGE(@"btn_more_d") selector:@selector(moreBtnPressed:)];
                _user.isfriend = !_user.isfriend;
            }
        } else if ([sender.tag isEqualToString:@"setStar"]) {
            _user.isstar = !_user.isstar;
            [_user updateVaule:[NSString stringWithFormat:@"%d", _user.isstar] key:@"isstar"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshList" object:_user];
        }
    }

    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        return self.tableViewCellHeight*2;
    }
    return self.tableViewCellHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            if (_user.province && _user.province.length > 0) {
                return 1;
            }
            break;
        case 1:
            if (_user.isfriend && _user.sign && _user.sign.length > 0) {
                return 1;
            }
            break;
        case 2:
            if (_user.isfriend || [_user.uid isEqualToString:[BSEngine currentUserId]]) {
                return 1;
            }
            
            break;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"BaseHeadCell";
    BaseTableViewCell* cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        
        cell.textLabel.font =
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
        
        cell.detailTextLabel.numberOfLines = 0;
        
        cell.detailTextLabel.textColor = RGBCOLOR(99, 99, 99);
        cell.textLabel.textColor = RGBCOLOR(66, 66, 66);
        
        [cell.contentView addSubview:picView];
    }
    picView1.hidden =
    picView2.hidden =
    picView3.hidden = YES;
    cell.imageView.hidden = YES;
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = @"地区";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", _user.province, _user.city];
            picView.hidden = YES;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        case 1:
            cell.textLabel.text = @"个性签名";
            cell.detailTextLabel.text = _user.sign;
            picView.hidden = YES;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        case 2:
            cell.textLabel.text = @"个人相册";
            cell.detailTextLabel.text = @"";
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            picView.hidden = NO;
            break;
        default:
            break;
    }
    [cell update:^(NSString *name) {
        cell.detailTextLabel.left = 90;
        cell.detailTextLabel.width = 190;
    }];
    return cell;
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 2) {
        FriendPhotosViewController * con = [[FriendPhotosViewController alloc] initWithUser:[self user]];
        [self pushViewController: con];
    }
}

- (NSString*)baseTableView:(UITableView *)sender imageURLAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        picView1.hidden = !(_user.picture1 && _user.picture1.length > 0);
        picView2.hidden = !(_user.picture2 && _user.picture2.length > 0);
        picView3.hidden = !(_user.picture3 && _user.picture3.length > 0);
        return (id)@[_user.picture1, _user.picture2, _user.picture3];
    }
    return nil;
}

- (CGFloat)baseTableView:(UITableView *)sender imageSizeAtIndexPath:(NSIndexPath*)indexPath {
    return 140;
}

- (void)setGroupHeadImage:(UIImage*)image forIndex:(NSIndexPath*)indexPath forPos:(NSInteger)pos {
    if (pos == 0) {
        picView1.image = image;
    } else if (pos == 1) {
        picView2.image = image;
    } else if (pos == 2) {
        picView3.image = image;
    }
}

- (void)baseTableView:(NSInteger)tag imageUpdateAtIndexPath:(NSIndexPath*)indexPath image:(UIImage *)image idx:(NSInteger)idx {
    if (tag == 1) {
        [self setGroupHeadImage:image forIndex:indexPath forPos:idx];
    }
}

- (int)baseTableView:(UITableView *)sender imageTagAtIndexPath:(NSIndexPath*)indexPath {
    return 1;
}

#pragma mark - MenuViewDelegate
- (void)popoverView:(MenuView *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSString * str = nil;
    switch (buttonIndex) {
        case 0:
            // 设置备注名
        {
            TextEditController *con = [[TextEditController alloc] initWithDel:self type:TextEditTypeDefault title:@"设置备注名" value:_user.remark];
            con.maxTextCount = 8;
            [self pushViewController:con];
        }
            break;
        case 1: {
            // 星标朋友
            if ([super startRequest]) {
                [client setStar:_user.uid];
                client.tag = @"setStar";
            }
        }
            break;
        case 2:
            // 设置朋友圈权限
        {
            FriendCircleAuthViewController * con = [[FriendCircleAuthViewController alloc] init];
            con.user = self.user;
            [self pushViewController:con];
        }
            break;
        case 3:
            // 发送名片
        {
            SessionNewController * con = [[SessionNewController alloc] init];
            con.isForword =
            con.isShowGroup = YES;
            
            Message * msg = [[Message alloc] init];
            NSMutableDictionary * dic = [NSMutableDictionary dictionary];
            [dic setObject:self.user.uid forKey:@"uid"];
            [dic setObject:self.user.nickname forKey:@"nickname"];
            [dic setObject:self.user.headlarge forKey:@"headsmall"];
            msg.typefile = forFileNameCard;
            msg.content = [dic JSONString];
            con.value = msg;
            
            [self pushViewController:con];
        }
            break;
            
        case 4:
            // 黑名单
        {
            if (!_user.isblack) {
                KWAlertView * alertView = [[KWAlertView alloc] initWithTitle:nil message:@"加入黑名单，你将不再收到对方的消息，并且你们互相看不到对方朋友圈的更新" delegate:self cancelButtonTitle:@"取消" otherButtonTitle:@"确定"];
                alertView.tag = 4;
                [alertView show];
            } else {
                [super startRequest];
                client.tag = @"black";
                [client black:_user.uid];
            }
            
        }
            break;
        case 5:
            // 删除
            [[[KWAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"将联系人%@删除，将同时删除与该联系人的聊天记录", _user.nickname] delegate:self cancelButtonTitle:@"取消" otherButtonTitle:@"删除"] show];
            break;
        default:
            break;
    }
    
    if (str) {
        UIViewController * tmpCon = [[NSClassFromString(str) alloc] init];
        [self pushViewController:tmpCon];
    }
}

- (void)kwAlertView:(KWAlertView*)sender didDismissWithButtonIndex:(NSInteger)index {
    if (sender.tag == -1) {
        if (index == 1) {
            if (sender.field.text.hasValue && sender.field.text.length > 15) {
                [KWAlertView showAlertFieldWithTitle:@"验证信息" delegate:self tag:-1];
                [self showText:@"输入的申请信息长度在15个字以内!"];
                return;
            }
            [super startRequest];
            [client to_friend:_user.uid content:sender.field.text];
            client.tag = @"add";
        }
    } else if (sender.tag == 4) {
        if (index == 1) {
            [super startRequest];
            client.tag = @"black";
            [client black:_user.uid];
        }
    } else {
        if (index == 1) {
            [super startRequest];
            client.tag = @"del";
            [client del_friend:_user.uid];
        }
    }
}

- (void)popoverViewCancel:(MenuView *)sender {
}

- (void)textEditControllerDidEdit:(NSString*)text idx:(NSIndexPath*)idx {
    if (client) {
        return;
    }
    [self setLoading:YES content:@"正在设置备注名"];
    client = [[BSClient alloc] initWithDelegate:self action:@selector(requestReMarkDidFinish:obj:)];
    client.tag = text;
    [client setMarkName:text fuid:_user.uid];
}

- (BOOL)requestReMarkDidFinish:(BSClient*)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        _user.remark = sender.tag;
        [_user insertDB];
        [self updateName];
        [self showText:sender.errorMessage];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshList" object:_user];
    }
    return YES;
}

@end
