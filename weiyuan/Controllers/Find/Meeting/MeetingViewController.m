//
//  MeetingViewController.m
//  ReSearch
//
//  Created by kiwi on 14-9-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "MeetingViewController.h"
#import "ImageTouchView.h"
#import "TextInput.h"
#import "MenuView.h"
#import "Meet.h"
#import "BaseTableViewCell.h"
#import "Globals.h"
#import "NewMeetViewController.h"
#import "Declare.h"
#import "MeetingDetailViewController.h"
#import "Message.h"
#import "AppDelegate.h"
#import "KBadgeView.h"
#import "Notify.h"

@interface MeetingViewController () {
    MeetType meetType;
}
@end

@implementation MeetingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    enablefilter = YES;
    [self setEdgesNone];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"进行中的会议";
    self.navigationItem.titleView = self.titleView;
    [self enableSlimeRefresh];
    meetType = forMeetLoading;
    needToLoad = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMeetList:) name:@"refreshMeetList" object:nil];
    self.tableViewCellHeight = 70;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedMessage:) name:@"receivedMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reSetConversation:) name:@"reSetConversation" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedMeetNot:) name:@"receivedMeetNot" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    if (isFirstAppear) {
        [super startRequest];
        [self setLoading:YES content:@"正在获取会议列表"];
        [client meetingListWithType:meetType page:currentPage];
    }
    [self.view addKeyboardPanningWithActionHandler:nil];
}

- (void)prepareLoadMoreWithPage:(int)page sinceID:(int)sinceID {
    if (self.searchView.width == 0) {
        if (isloadByslime) {
            [self setLoading:YES content:@"正在重置会议列表"];
        } else {
            [self setLoading:YES content:@"正在获取更多会议"];
        }
        [client meetingListWithType:meetType page:page];
    } else {
        self.loading = NO;
        client = nil;
    }
}

/**接收会议相关的通知*/
- (void)refreshMeetList:(NSNotification*)notification {
    isloadByslime = YES;
    currentPage = 1;
    needToLoad = NO;
    [super startRequest];
    [client meetingListWithType:meetType page:currentPage];
}

- (void)individuationTitleView {
    [self.titleView addSubview:[self moreButton]];
    
    self.searchButton.image = LOADIMAGE(@"btn_search");
    self.searchButton.highlightedImage = LOADIMAGE(@"btn_search_d");
    self.searchButton.left = self.titleView.width - 115;
    self.searchView.width = 0;
    
    self.addButton.tag = @"add";
    self.addButton.image = LOADIMAGE(@"btn_add");
    self.addButton.left = self.titleView.width - 75;
    if (self.value) {
        self.addButton.userInteractionEnabled = NO;
    }
    self.addButton.alpha =
    self.searchButton.alpha = 1;
    [self updateTitleLabel];
}

- (void)updateTitleLabel {
    NSString * str = self.navigationItem.title;
    titlelab.text = str;
    CGSize size = [str sizeWithFont:titlelab.font maxWidth:150 maxNumberLines:0];
    titlelab.width = size.width;
    titlelab.left = 20;
}

#pragma mark -
#pragma mark - Messages

- (void)receivedMessage:(NSNotification*)sender {
    Message * msg = sender.object;
    if (msg.typechat != forChatTypeMeet) {
        return;
    }
    [contentArr enumerateObjectsUsingBlock:^(Meet * it, NSUInteger idx, BOOL *stop) {
        NSString * str = it.id;
        if ([str isEqualToString:msg.toId]) {
            it.unreadCount ++ ;
            *stop = YES;
            [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
    }];
    [[AppDelegate instance] updateNewMeetMessage:NO];
}

- (void)reSetConversation:(NSNotification*)sender {
    NSString* withID = sender.object;
    if (withID) {
        for (int i = 0; i < contentArr.count; i++) {
            Meet* cs = [contentArr objectAtIndex:i];
            if ([cs.id isEqualToString:withID]) {
                if (cs.unreadCount > 0) {
                    cs.unreadCount = 0;
                    [Message resetAllUnReadWithID:cs.id];
                    [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                }
                break;
            }
        }
    }
    [[AppDelegate instance] updateNewMeetMessage:NO];
}

#pragma mark - imageTouchViewDelegate
- (void)imageTouchViewDidSelected:(ImageTouchView*)sender {
    if ([sender.tag isEqualToString:@"more"]) {
        if (self.searchView.width == 0) {
            MenuView * menuView = [[MenuView alloc] initWithButtonTitles:@[@"进行中的会议", @"往期会议", @"我的会议"] withDelegate:self];
            menuView.hasImage = NO;
            [menuView showInView:self.view origin:CGPointMake(self.view.width - 180, 0)];
        }
    } else if ([sender.tag isEqualToString:@"add"]) {
        if (self.searchView.width == 0) {
            // 申请新的会议
            NewMeetViewController * con = [[NewMeetViewController alloc] init];
            [self pushViewController: con];
        } else {
            self.searchField.text = @"";
            [self textFieldDidChange:self.searchField];
        }
    } else {
        if ([sender.tag isEqualToString:@"none"]) {
            // 弹出搜索框
            sender.tag = @"changed";
            [UIView animateWithDuration:0.3 animations:^{
                self.searchView.width = self.view.width - 65;
                self.searchButton.left = self.searchView.left + 5;
                self.addButton.left = self.titleView.width - 45;
                self.searchButton.image = LOADIMAGE(@"btn_search_d");
                self.addButton.transform = CGAffineTransformMakeRotation((45.0f * M_PI) / 180.0f);
            } completion:^(BOOL finished) {
                self.addButton.transform = CGAffineTransformIdentity;
                [UIView animateWithDuration:0.15 animations:^{
                    self.addButton.image = LOADIMAGE(@"btn_clear");
                    self.addButton.highlightedImage = LOADIMAGE(@"btn_clear_d");
                } completion:^(BOOL finished) {
                    [self.searchField becomeFirstResponder];
                    self.moreButton.hidden = YES;
                }];
                
            }];
        } else {
            // 收回搜索框
            sender.tag = @"none";
            self.searchField.text = @"";
            [UIView animateWithDuration:0.3 animations:^{
                self.addButton.transform = CGAffineTransformMakeRotation((45.0f * M_PI) / 180.0f);
                self.searchButton.left = self.titleView.width - 115;
                self.searchView.width = 0;
            } completion:^(BOOL finished) {
                if (finished) {
                    self.addButton.transform = CGAffineTransformIdentity;
                    [UIView animateWithDuration:0.15 animations:^{
                        self.addButton.left = self.titleView.width - 75;
                        self.searchButton.image = LOADIMAGE(@"btn_search");
                        self.addButton.image = LOADIMAGE(@"btn_add");
                        self.addButton.highlightedImage = nil;
                        self.moreButton.hidden = NO;
                    } completion:^(BOOL finished) {
                        [self.searchField resignFirstResponder];
                        self.searchField.text = @"";
                        [self textFieldDidChange:self.searchField];
                    }];
                }
            }];
        }
        
    }
}

- (void)popViewController {
    if (self.searchView.width != 0) {
        // 退出搜索状态
        [self imageTouchViewDidSelected:self.searchButton];
    } else {
        [super popViewController];
    }
}

- (BOOL)requestDidFinish:(id)sender obj:(NSDictionary *)obj {
    needToLoad = YES;
    if ([super requestDidFinish:sender obj:obj]) {
        NSArray* array = [obj objectForKey:@"data"];
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Meet * meet = [Meet objWithJsonDic:obj];
            [meet insertDB];
            [contentArr addObject:meet];
        }];
        [tableView reloadData];
    }
    return YES;
}

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BaseTableViewCell * cell = (BaseTableViewCell*)[super tableView:sender cellForRowAtIndexPath:indexPath];
    UILabel * countLab = VIEWWITHTAG(cell.contentView, 17);
    if (!countLab) {
        countLab = [[UILabel alloc] initWithFrame:CGRectZero];
        countLab.tag = 17;
        countLab.font = [UIFont systemFontOfSize:13];
        countLab.textColor = RGBCOLOR(111, 111, 111);
        countLab.highlightedTextColor = [UIColor whiteColor];
        [cell.contentView addSubview:countLab];
    }
    Meet * meet = [inFilter?filterArr:contentArr objectAtIndex:indexPath.row];
    cell.textLabel.text = meet.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", meet.start, meet.end];
    countLab.text = [NSString stringWithFormat:@"已有%d人参会",  meet.memberCount];
    cell.backgroundColor =
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.badgeValue = meet.unreadCount;
    if (meet.unreadCount == 0 && meet.isOwer) {
        cell.newbadgeView.hidden = (meet.applyCount>0)?NO:YES;
    }
    [cell update:^(NSString *name) {
        [cell autoAdjustText];
        
        cell.textLabel.height = 16;
        cell.textLabel.top = 9;
        
        cell.detailTextLabel.height = 15;
        cell.detailTextLabel.top = cell.textLabel.bottom + 2;
        cell.imageView.frame = CGRectMake(10, 10, 50, 50);
        countLab.frame = CGRectMake(70, cell.detailTextLabel.bottom+ 2, cell.width - 80, 14);
        cell.detailTextLabel.left = cell.textLabel.left = 70;
        cell.badgeView.origin = CGPointMake(50, 7.5);
        
    }];
    return cell;
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    Meet * meet = [inFilter?filterArr:contentArr objectAtIndex:indexPath.row];
    MeetingDetailViewController * con = [[MeetingDetailViewController alloc] init];
    con.item = meet;
    [self pushViewController:con];
}

- (NSString*)baseTableView:(UITableView *)sender imageURLAtIndexPath:(NSIndexPath *)indexPath {
    Meet * meet = [inFilter?filterArr:contentArr objectAtIndex:indexPath.row];
    return meet.logo;
}

#pragma mark - MenuViewDelegate
- (void)popoverView:(MenuView *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != 3) {
        self.navigationItem.title = sender.buttonTitles[buttonIndex];
        meetType = (int)buttonIndex+1;
        isloadByslime = YES;
        [self updateTitleLabel];
        [super startRequest];
        [self setLoading:YES content:@"正在切换会议列表"];
        [client meetingListWithType:meetType page:currentPage];
    }
}

#pragma filter

- (void)filterContentForSearchText:(NSString*)searchText
                             scope:(NSString*)scope {
    for (Meet *it in contentArr) {
        if ([it.name rangeOfString:searchText].location <= it.name.length) {
            [filterArr addObject:it];
        }
    }
}

#pragma mark - 会议相关通知
- (void)receivedMeetNot:(NSNotification*)sender {
    Notify * ntf = sender.object;
    if (ntf.type == forNotifyMeetAdd) {
        [contentArr enumerateObjectsUsingBlock:^(Meet * it, NSUInteger idx, BOOL *stop) {
            NSString * str = it.id;
            if ([str isEqualToString:ntf.shareID]) {
                it.applyCount ++;
                *stop = YES;
                [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            }
        }];
        [[AppDelegate instance] updateNewMeetMessage:NO];
    } else if (ntf.type == forNotifyMeetAgreeAdd) {
    } else if (ntf.type == forNotifyMeetDisAgreeAdd) {
    }

}

@end
