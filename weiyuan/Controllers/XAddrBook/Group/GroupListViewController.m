//
//  GroupListViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "GroupListViewController.h"
#import "SessionInfoController.h"
#import "Room.h"
#import "BaseTableViewCell.h"
#import "Session.h"
#import "SessionNewController.h"
#import "ImageTouchView.h"
#import "Message.h"
#import "Globals.h"
#import "TextInput.h"
#import "TalkingViewController.h"

@interface GroupListViewController () <ImageTouchViewDelegate>
@end

@implementation GroupListViewController

- (void)viewDidLoad
{
    enablefilter = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"群聊";
    self.navigationItem.titleView = self.titleView;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshGroupName:) name:@"refreshGroupName" object:nil];
    [self enableSlimeRefresh];
}

- (void)viewDidAppear:(BOOL)animated {
    if (isFirstAppear) {
        [super startRequest];
        [client getMyGroupWithPage:currentPage];
    }
    [self.view addKeyboardPanningWithActionHandler:nil];
}

- (void)refreshGroupName:(NSNotification*)notification {
    Room * room = notification.object;
    [contentArr enumerateObjectsUsingBlock:^(Room * obj, NSUInteger idx, BOOL *stop) {
        if ([room.uid isEqualToString:obj.uid]) {
            obj.name = room.name;
            [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            *stop = YES;
        }
    }];
}

- (void)individuationTitleView {
    self.addButton.tag = @"addTouchView";
    self.addButton.image = LOADIMAGE(@"btn_add");

    self.addButton.left = self.titleView.width - 35;
    if (self.value) {
        self.addButton.userInteractionEnabled = NO;
    }
    
    self.searchButton.image = LOADIMAGE(@"btn_search");
    self.searchButton.highlightedImage = LOADIMAGE(@"btn_search_d");
    self.searchButton.left = self.titleView.width - 75;
    
    self.searchView.width = 0;
    self.addButton.alpha = 1;
    self.searchButton.alpha = 1;
}

- (void)popViewController {
    if (self.searchView.width != 0) {
        [self imageTouchViewDidSelected:self.searchButton];
        [self textFieldDidChange:self.searchField];
    } else {
        [super popViewController];
    }
}

- (void)prepareLoadMoreWithPage:(int)page sinceID:(int)sinceID {
    if (self.searchView.width == 0) {
        [client getMyGroupWithPage:page];
    } else {
        self.loading = NO;
        client = nil;
    }
}

- (BOOL)requestDidFinish:(id)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        NSArray* array = [obj objectForKey:@"data"];
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Room * room = [Room objWithJsonDic:obj];
            if (room) {
                [room insertDB];
                [contentArr addObject:room];
            } else {
                
            }
        }];
        [tableView reloadData];
    }
    return YES;
}

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BaseTableViewCell * cell = (BaseTableViewCell*)[super tableView:sender cellForRowAtIndexPath:indexPath];
    Room * room = [inFilter?filterArr:contentArr objectAtIndex:indexPath.row];
    [cell update:^(NSString *name) {
        cell.textLabel.height = cell.height;
    }];
    NSInteger number = [room.value count];
    if (number > 4) {
        number = 4;
    }
    [cell setNumberOfGroupHead:number];
    cell.textLabel.text = [NSString stringWithFormat:@"%@(%d)", room.name, room.usercount];
    return cell;
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    Room * room = [inFilter?filterArr:contentArr objectAtIndex:indexPath.row];
    if ([self.searchButton.tag isEqualToString: @"changed"]) {
        [self imageTouchViewDidSelected:self.searchButton];
        [self textFieldDidChange:self.searchField];
    }
    if (self.value) {
        Message * fmsg = [self.value copy];
        fmsg.displayName =
        fmsg.toname = room.name;
        fmsg.displayImgUrl =
        fmsg.tohead = room.head;
        fmsg.toId = room.uid;
        fmsg.typechat = forChatTypeGroup;
        Session * itemS = [Session sessionWithMessage:fmsg];
        id con = [[TalkingViewController alloc] initWithSession:itemS];
        [self pushViewControllerAfterPop:con];
    } else {
        Session * session = [Session getSessionWithID:room.uid];
        if (!session || !session.uid) {
            session = [Session sessionWithRoom:room];
        }
        if (self.fromGroup) {
            TalkingViewController * con = [[TalkingViewController alloc] initWithSession:session];
            [self pushViewController:con];
        } else {
            SessionInfoController * con = [[SessionInfoController alloc] initWithSession:session delegate:self];
            con.onlylook = YES;
            [self pushViewController:con];
        }
    }
}

- (void)baseTableView:(NSInteger)tag imageUpdateAtIndexPath:(NSIndexPath*)indexPath image:(UIImage *)image idx:(NSInteger)idx {
    if (tag == -1) {
        [self setHeadImage:image forIndex:indexPath];
    } else {
        [self setGroupHeadImage:image forIndex:indexPath forPos:idx];
    }
}

- (NSString*)baseTableView:(UITableView *)sender imageURLAtIndexPath:(NSIndexPath *)indexPath {
    Room * room = [inFilter?filterArr:contentArr objectAtIndex:indexPath.row];
    NSMutableArray * array = [NSMutableArray array];
    [room.value enumerateObjectsUsingBlock:^(NSString * url, NSUInteger idx, BOOL *stop) {
        [array addObject:url];
        if (idx == 3) {
            *stop = YES;
        }
    }];
    return (id)array;
}

- (int)baseTableView:(UITableView *)sender imageTagAtIndexPath:(NSIndexPath*)indexPath {
    return -2;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.imageView.image = [Globals getImageRoomHeadDefault];
    NSInvocationOperation * opHeadItem = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadHeadImageWithIndexPath:) object:indexPath];
    [baseOperationQueue addOperation:opHeadItem];
}

#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)sender heightForFooterInSection:(NSInteger)section {
    return 30;
}

- (UIView*)tableView:(UITableView *)sender viewForFooterInSection:(NSInteger)section {
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, sender.width, 30)];
    if (sender == tableView) {
        if (contentArr.count > 0) {
            lab.text = [NSString stringWithFormat:@"%d个群", (int)contentArr.count];
        }
    } else {
        lab.text = [NSString stringWithFormat:@"%d个群", (int)filterArr.count];
    }
    
    
    lab.backgroundColor = sender.backgroundColor;
    lab.textAlignment = NSTextAlignmentCenter;
    lab.textColor = [UIColor lightGrayColor];
    return lab;
}

- (void)imageTouchViewDidSelected:(ImageTouchView*)sender {
    if ([sender.tag isEqualToString:@"addTouchView"]) {
        if (self.searchView.width == 0) {
            SessionNewController * con = [[SessionNewController alloc] init];
            con.isShowGroup = YES;
            [self pushViewController:con];
        } else {
            self.searchField.text = @"";
            [self textFieldDidChange:self.searchField];
        }
    } else {
        if ([sender.tag isEqualToString:@"none"]) {
            sender.tag = @"changed";
            [UIView animateWithDuration:0.3 animations:^{
                self.searchView.width = self.view.width - 65;
                self.searchButton.left = self.searchView.left + 5;
                self.addButton.left = self.titleView.width - 45;
                self.searchButton.image = LOADIMAGE(@"btn_search_d");
                self.addButton.transform = CGAffineTransformMakeRotation((45.0f * M_PI) / 180.0f);
                self.searchView.alpha = 1;
            } completion:^(BOOL finished) {
                self.addButton.transform = CGAffineTransformIdentity;
                [UIView animateWithDuration:0.15 animations:^{
                    self.addButton.image = LOADIMAGE(@"btn_clear");
                    self.addButton.highlightedImage = LOADIMAGE(@"btn_clear_d");
                } completion:^(BOOL finished) {
                    [self.searchField becomeFirstResponder];
                }];
                
            }];
        } else {
            sender.tag = @"none";
            self.searchField.text = @"";
            [UIView animateWithDuration:0.3 animations:^{
                self.addButton.transform = CGAffineTransformMakeRotation((45.0f * M_PI) / 180.0f);
                self.searchButton.left = self.titleView.width - 75;
                self.searchView.width = 0;
            } completion:^(BOOL finished) {
                if (finished) {
                    self.addButton.transform = CGAffineTransformIdentity;
                    [UIView animateWithDuration:0.15 animations:^{
                        self.addButton.left = self.titleView.width - 35;
                        self.searchButton.image = LOADIMAGE(@"btn_search");
                        self.addButton.image = LOADIMAGE(@"btn_add");
                        self.addButton.highlightedImage = nil;
                    } completion:^(BOOL finished) {
                        [self.searchField resignFirstResponder];
                    }];
                }
            }];
        }
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)sender {
    tableView.userInteractionEnabled =
    filterTableView.userInteractionEnabled = NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.searchField resignFirstResponder];
    tableView.userInteractionEnabled =
    filterTableView.userInteractionEnabled = YES;
}

#pragma filter

- (void)filterContentForSearchText:(NSString*)searchText
                             scope:(NSString*)scope {
    for (Room *it in contentArr) {
        if ([it.name rangeOfString:searchText].location <= it.name.length) {
            [filterArr addObject:it];
        }
    }
}

@end
