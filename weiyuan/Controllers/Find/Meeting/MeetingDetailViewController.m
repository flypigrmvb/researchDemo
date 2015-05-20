//
//  MeetingDetailViewController.m
//  ReSearch
//
//  Created by kiwi on 14-9-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "MeetingDetailViewController.h"
#import "BaseTableViewCell.h"
#import "Meet.h"
#import "KWAlertView.h"
#import "TextInput.h"
#import "MeetingManagerController.h"
#import "Session.h"
#import "TalkingViewController.h"
#import "SessionNewController.h"
#import "Notify.h"
#import "KBadgeView.h"
#import "Message.h"

@interface MeetingDetailViewController () {
    UIButton * joinButton;
    UIButton * inviteButton;
    UIButton * managerButton;
    int meetHeight;
}

@property (nonatomic, strong) KBadgeView   * badgeView;
@property (nonatomic, strong) UIView * meetTheamview;
@end

@implementation MeetingDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"会议详细";
    
    [contentArr addObjectsFromArray:@[@"会议名称", @"主持人", @"起始时间", @"结束时间"]];
    self.tableViewCellHeight = 44;
    tableView.allowsSelection = NO;
    
    //  会议主题
    self.meetTheamview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 0)];
    _meetTheamview.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _meetTheamview.backgroundColor = self.view.backgroundColor;
    UILabel * label = [UILabel singleLineText:@"会议主题" font:[UIFont systemFontOfSize:14] wid:100 color:RGBCOLOR(44, 44, 44)];
    label.origin = CGPointMake(15, 5);
    [_meetTheamview addSubview:label];
    
    UILabel * lab = [[UILabel alloc] initWithFrame:CGRectMake(15, 35, _meetTheamview.width - 30, 0)];
    lab.font = [UIFont systemFontOfSize:14];
    lab.backgroundColor = tableView.backgroundColor;
    lab.text = _item.content;
    lab.numberOfLines = 0;
    lab.textColor = RGBCOLOR(44, 44, 44);
    CGSize size = [lab.text sizeWithFont:lab.font maxWidth:_meetTheamview.width - 30 maxNumberLines:0];
    lab.size = size;
    [_meetTheamview addSubview:lab];
    
    meetHeight = 10 + size.height + 35;
    
    if (_item.isInValid) {
        /*  如果已经加入会议, 则显示[进入会议];
         如果没有加入会议, 则显示[申请参会], 申请会议需要填写申请理由;
         只有主持人才显示[邀请参会]和[会议管理].*/
        joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [joinButton setTitle:@"进入会议" forState:UIControlStateNormal];
        joinButton.frame = CGRectMake(20, lab.bottom + 50, _meetTheamview.width - 40, 40);
        [joinButton defaultStyle];
        joinButton.tag = 1;
        [joinButton addTarget:self action:@selector(itemPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_meetTheamview addSubview:joinButton];
        meetHeight += 110;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedMeetNot:) name:@"receivedMeetNot" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedMessage:) name:@"receivedMessage" object:nil];
    
    self.meetTheamview.height = meetHeight;
    
    self.badgeView.text = [NSString stringWithFormat:@"%d", self.item.unreadCount];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_item.isInValid) {
        if (_item.isjoin) {
            [joinButton defaultStyle];
            [joinButton setTitle:@"进入会议" forState:UIControlStateNormal];
            if (_item.isOwer) {
                if (!inviteButton) {
                    inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    inviteButton.frame = CGRectMake(20, joinButton.bottom + 20, _meetTheamview.width - 40, 40);
                    [inviteButton defaultStyle];
                    inviteButton.tag = 2;
                    [inviteButton addTarget:self action:@selector(itemPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [inviteButton setTitle:@"邀请参会" forState:UIControlStateNormal];
                    [_meetTheamview addSubview:inviteButton];
                    
                    managerButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    managerButton.frame = CGRectMake(20, inviteButton.bottom + 20, _meetTheamview.width - 40, 40);
                    [managerButton navStyle];
                    managerButton.tag = 3;
                    [managerButton addTarget:self action:@selector(itemPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [managerButton setTitle:@"会议管理" forState:UIControlStateNormal];
                    [_meetTheamview addSubview:managerButton];
                }
                
                self.meetTheamview.height = meetHeight + 120;
                managerButton.hidden = inviteButton.hidden = NO;
            } else {
                managerButton.hidden = inviteButton.hidden = YES;
            }
        } else {
            [joinButton setTitle:@"申请参会" forState:UIControlStateNormal];
            [joinButton navStyle];
            self.meetTheamview.height = meetHeight;
            managerButton.hidden = inviteButton.hidden = YES;
        }
    }
    tableView.tableFooterView = _meetTheamview;
}

- (void)itemPressed:(UIButton*)sender {
    if (sender.tag == 1) {
        if (_item.isjoin) {
            Session * session = [Session sessionWithMeet:_item];
            self.badgeView.text = nil;
            TalkingViewController * talking = [[TalkingViewController alloc] initWithSession:session];
            [self pushViewController:talking];
        } else {
            [KWAlertView showAlertFieldWithTitle:@"验证信息" delegate:self tag:(int)sender.tag];
        }
    } else if (sender.tag == 2) {
        SessionNewController * con = [[SessionNewController alloc] init];
        con.sourceArr = [NSMutableArray arrayWithArray:[_item.idUserList componentsSeparatedByString:@","]];
        [con setMbsUserBlack:^(NSArray * array) {
            [super startRequest];
            NSMutableArray * arr = [NSMutableArray array];
            [array enumerateObjectsUsingBlock:^(User * obj, NSUInteger idx, BOOL *stop) {
                [arr addObject:obj.uid];
            }];
            [client inviteMeeting:_item.id uids:[arr componentsJoinedByString:@","]];
        }];
        [self pushViewController:con];
    } else {
        MeetingManagerController * con = [[MeetingManagerController alloc] init];
        con.item = self.item;
        [self pushViewController:con];
    }
}

- (KBadgeView*)badgeView {
    if (!_badgeView) {
        _badgeView = [[KBadgeView alloc] initWithFrame:CGRectMake(180, (joinButton.height - 18)/2, 7, 7)];
        [joinButton addSubview:_badgeView];
    }
    return _badgeView;
}

#pragma mark - KWAlertViewDelegate
- (void)kwAlertView:(KWAlertView*)sender didDismissWithButtonIndex:(NSInteger)index {
    if (sender.tag == 2) {
        [self popViewController];
    } else if (index == 1) {
        if (sender.field.text && sender.field.text.length > 0) {
            [super startRequest];
            [client applyMeeting:_item.id content:sender.field.text];
        } else {
            [self showText:@"请输入验证信息！"];
        }
    }
}

- (BOOL)requestDidFinish:(BSClient*)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        [self showText:sender.errorMessage];
    }
    return YES;
}

#pragma mark -  tableView

- (CGFloat)tableView:(UITableView *)sender heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (UIView *)tableView:(UITableView *)sender viewForHeaderInSection:(NSInteger)section {
    UIImageView *clearView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, sender.width, 20)];
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
    cell.imageView.hidden = YES;
    cell.topLineView.hidden = indexPath.row == 0;
    
    cell.selectionStyle = indexPath.row == 0?UITableViewCellSelectionStyleNone:UITableViewCellSelectionStyleGray;
    [cell update:^(NSString *name) {
        cell.detailTextLabel.text = nil;
        if (indexPath.row == 0) {
            
            cell.detailTextLabel.text = _item.name;
        } else if (indexPath.row == 1) {
            cell.detailTextLabel.text = _item.creator;
        } else if (indexPath.row == 2) {
            cell.detailTextLabel.text = _item.start;
        } else if (indexPath.row == 3) {
            cell.detailTextLabel.text = _item.end;
        }
        cell.detailTextLabel.left = 100;
        cell.detailTextLabel.width = cell.width - 110;
        cell.backgroundColor =
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.textLabel.left = 15;
        cell.textLabel.textColor = RGBCOLOR(44, 44, 44);
        cell.topLineView.frame = CGRectMake(10, 0, cell.width - 20, 0.5);
        cell.detailTextLabel.textAlignment = NSTextAlignmentRight;
    }];
    return cell;
}

#pragma mark - 会议相关通知
- (void)receivedMeetNot:(NSNotification*)sender {
    Notify * ntf = sender.object;
    if (ntf.type == forNotifyMeetKicked) {
        self.view.userInteractionEnabled = NO;
        KWAlertView * k = [[KWAlertView alloc] initWithTitle:nil message:ntf.content delegate:self cancelButtonTitle:nil otherButtonTitle:@"确定"];
        k.tag = 2;
        [k show];
    } else if (ntf.type == forNotifyMeetAgreeAdd) {
        _item.isjoin = YES;
        [self viewWillAppear:NO];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMeetList" object:nil];
}

#pragma mark -
#pragma mark - Messages

- (void)receivedMessage:(NSNotification*)sender {
    if (self.navigationController.viewControllers.lastObject == self) {
        self.badgeView.text = [NSString stringWithFormat:@"%d", self.item.unreadCount];
    } else {
        self.badgeView.text = nil;
    }
    
}

@end
