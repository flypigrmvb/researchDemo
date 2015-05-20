//
//  SessionNewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "SessionNewController.h"
#import "TalkingViewController.h"
#import "UserCell.h"
#import "SButton.h"
#import "User.h"
#import "Globals.h"
#import "Room.h"
#import "Session.h"
#import "AppDelegate.h"
#import "XMPPManager.h"
#import "GroupListViewController.h"
#import "Message.h"

@interface SessionNewController () {
    NSMutableArray  * selectedArr;
    NSMutableArray  * buttonSArr;
    
    SButton         * newButton;
    UIScrollView    * contentView;
    SessionNewRequestType   typeRequest;
    
}

@property (nonatomic, strong) Room * cuRoom;
@property (nonatomic, strong) Session* session;
@property (nonatomic, strong) NSMutableArray* inviteUserArr;
@end

@implementation SessionNewController
@synthesize session;
@synthesize inviteUserArr, sourceArr;

- (id)init {
    return [self initWithSession:nil];
}

- (id)initWithSession:(Session *)item {
    if (self = [super init]) {
        // Custom initialization
        selectedArr = [[NSMutableArray alloc] init];
        buttonSArr = [[NSMutableArray alloc] init];
        sourceArr = [[NSMutableArray alloc] init];
        typeRequest = forSessionNewRequestFriendList;
        
        if (item) {
            self.session = item;
            if (item.isRoom) {
                Room * room = [Room roomForUid:item.uid];
                [sourceArr addObjectsFromArray:[room.idUserList componentsSeparatedByString:@","]];
            } else {
                [sourceArr addObject:item.uid];
            }
        }
    }
    return self;
}

- (void)dealloc {
    self.session = nil;
    self.inviteUserArr = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (_isGroup) {
        self.navigationItem.title = @"发起群聊";
    } else {
        self.navigationItem.title = @"选择联系人";
    }
    [self setEdgesNone];
    self.mySearchDisplayController.searchBar.placeholder = @"搜索";
    contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, Main_Screen_Height, tableView.width, 49)];
    contentView.backgroundColor = kbColor;
    [self.view addSubview:contentView];
    CGFloat sizeHeight = contentView.height;
    CGRect frame = CGRectMake(0, 0, sizeHeight, sizeHeight);
    newButton = [[SButton alloc] initWithFrame:frame];
    newButton.enabled = NO;
    [newButton setImage:[UIImage imageNamed:@"btn_icon_add" isCache:NO] forState:UIControlStateNormal];
    [contentView addSubview:newButton];
    [buttonSArr addObject:newButton];
    tableView.clipsToBounds = YES;
    
    [self.view bringSubviewToFront:contentView];
    [self setRightBarButton:@"确定" selector:@selector(btnPressed:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    if (self.isShowGroup) {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = tableView.backgroundColor;
        btn.frame = CGRectMake(0, 0, tableView.width, 44);
        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, tableView.width/2 +40)];
        [btn setTitle:@"选择一个群" forState:UIControlStateNormal];
        btn.titleLabel.textAlignment = NSTextAlignmentLeft;
        [btn setBackgroundImage:[Globals getImageGray] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(existGroups) forControlEvents:UIControlEventTouchUpInside];
        tableView.tableHeaderView = btn;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (isFirstAppear) {
        [self sendRequest];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_userBlack) {
        _userBlack = nil;
    }
    if (_inviteBlack) {
        _inviteBlack = nil;
    }
    if (_mbsUserBlack) {
        _mbsUserBlack = nil;
    }
}

/**退出群组*/
- (void)existGroups {
    GroupListViewController * con = [[GroupListViewController alloc] init];
    con.value = self.value;
    con.fromGroup = self.isShowGroup;
    [self pushViewController:con];
}

- (IBAction)btnPressed:(UIButton*)sender {
    if ([sender isKindOfClass:[SButton class]]) {
        SButton* sbItem = (SButton*)sender;
        [self removeIndexPath:sbItem.indexPath];
    } else {
        if (_isForword) {
            if (selectedArr.count == 1) {
                // 如果是转发，确定后直接开始聊天
                NSIndexPath* indexPath = selectedArr[0];
                User* item = [[contentArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                Message * fmsg = [self.value copy];
                fmsg.displayName =
                fmsg.toname = item.nickname;
                fmsg.displayImgUrl =
                fmsg.tohead = item.headsmall;
                fmsg.toId = item.uid;
                fmsg.typechat = forChatTypeUser;
                [Globals setPreSendMsg:fmsg];
                Session * itemS = [Session sessionWithMessage:fmsg];
                id con = [[TalkingViewController alloc] initWithSession:itemS];
                [self pushViewControllerAfterPop:con];
            } else {
                // 新建 群聊 并转发
                NSMutableArray* selectedUserArr = [NSMutableArray array];
                for (NSIndexPath* indexPath in selectedArr) {
                    User* item = [[contentArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    [selectedUserArr addObject:item];
                }
                [self createRoomAndInviteUsers:selectedUserArr];
            }
            return;
        }
        if (_mbsUserBlack) {
            // 回调上层 多选用户
            NSMutableArray* selectedUserArr = [NSMutableArray array];
            for (NSIndexPath* indexPath in selectedArr) {
                User* item = [[contentArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                [selectedUserArr addObject:item];
            }
            
            _mbsUserBlack(selectedUserArr);
            _mbsUserBlack = nil;
            [self popViewController];
            return;
        }
        if (session == nil) {
            if (selectedArr.count == 1) {
                // 新建 单聊
                NSIndexPath* indexPath = [selectedArr objectAtIndex:0];
                User* item = [[contentArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                TalkingViewController *con = [[TalkingViewController alloc] initWithSession:[Session sessionWithUser:item]];
                [self pushViewController:con];
            } else {
                // 新建 群聊
                NSMutableArray* selectedUserArr = [NSMutableArray array];
                for (NSIndexPath* indexPath in selectedArr) {
                    User* item = [[contentArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    [selectedUserArr addObject:item];
                }
                [self createRoomAndInviteUsers:selectedUserArr];
            }
        } else {
            if (!session.isRoom) {
                // 单聊 转 群聊 (与新建群聊类似)
                NSMutableArray* selectedUserArr = [NSMutableArray array];
                User * user = [[User alloc] init];
                user.uid = session.uid;
                user.nickname = session.name;
                [selectedUserArr addObject:user];
                for (NSIndexPath* indexPath in selectedArr) {
                    User* item = [[contentArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    [selectedUserArr addObject:item];
                }
                [self createRoomAndInviteUsers:selectedUserArr];
            } else {
                // 群聊 增加 用户
                NSMutableArray* selectedUserArr = [NSMutableArray array];
                for (NSIndexPath* indexPath in selectedArr) {
                    User* item = [[contentArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    [selectedUserArr addObject:item.uid];
                }
                [self inviteUsers:selectedUserArr];
            }
        }
    }
}

/**设置Black回调并记录群组room*/
- (void)setInviteBlack:(Invite)inviteBlack currectRoom:(Room*)currectRoom {
    _inviteBlack = inviteBlack;
    self.cuRoom = currectRoom;
    [sourceArr removeAllObjects];
    [sourceArr addObjectsFromArray:[currectRoom.idUserList componentsSeparatedByString:@","]];
}

/**开始邀请用户进入群组*/
- (void)inviteUsers:(NSMutableArray*)arr {
    self.inviteUserArr = arr;
    typeRequest = forSessionNewRequestInviteUser;
    [self sendRequest];
}

/**创建群组并邀请用户*/
- (void)createRoomAndInviteUsers:(NSMutableArray*)arr {
    self.inviteUserArr = arr;
    typeRequest = forSessionNewRequestCreateRoom;
    [self sendRequest];
}

/**判断是否已经选了*/
- (BOOL)isContainsFilterIndexPath:(NSIndexPath*)indexPath {
    User* item = [filterArr objectAtIndex:indexPath.row];
    NSIndexPath* sIndexPath = [NSIndexPath indexPathForRow:[contentArr indexOfObject:item] inSection:0];
    if ([selectedArr containsObject:sIndexPath]) {
        return YES;
    } else {
        return [self isContainsInSourceArr:item];
    }
}

/**判断是否在不能选择的数组里*/
- (BOOL)isContainsInSourceArr:(User*)item {
    for (NSString *uid in sourceArr) {
        if ([uid isEqualToString:item.uid]) {
            return YES;
        }
    }
    return NO;
}

// 加进已选数组
- (void)addIndexPath:(NSIndexPath*)indexPath {
    [selectedArr addObject:indexPath];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    CGFloat sizeHeight = contentView.height;
    CGRect frame = newButton.frame;
    SButton* sbItem = [[SButton alloc] initWithFrame:frame];
    frame.origin.x += frame.size.width;
    [UIView animateWithDuration:0.25 animations:^{
        newButton.frame = frame;
    }];

    [sbItem addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UserCell* cell = (UserCell*)[tableView cellForRowAtIndexPath:indexPath];
    [sbItem setImage:cell.imageView.image forState:UIControlStateNormal];
    sbItem.indexPath = indexPath;
    [contentView addSubview:sbItem];
    [buttonSArr insertObject:sbItem atIndex:buttonSArr.count-1];
    [contentView setContentSize:CGSizeMake(sizeHeight * buttonSArr.count, sizeHeight)];
    if (contentView.contentSize.width > contentView.width) {
        [UIView animateWithDuration:0.35 animations:^{
            [contentView setContentOffset:CGPointMake(contentView.contentSize.width - contentView.width, 0)];
        }];
    }
    
    cell.selected = forUserSelectCellSelected;
    if (selectedArr.count > 1&&contentView.top == Main_Screen_Height) {
        [UIView animateWithDuration:0.25 animations:^{
            contentView.top = self.view.height - 49;
            tableView.height -= 49;
        }];
    }
}

// 移除已选数组
- (void)removeIndexPath:(NSIndexPath*)indexPath {
    NSInteger index = [selectedArr indexOfObject:indexPath];
    [selectedArr removeObject:indexPath];
    if (selectedArr.count == 0) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    SButton* sbItem = [buttonSArr objectAtIndex:index];
    [sbItem removeFromSuperview];
    [buttonSArr removeObjectAtIndex:index];
    [UIView animateWithDuration:0.35 animations:^{
        for (NSInteger i = index; i < buttonSArr.count; i++) {
            SButton* item = [buttonSArr objectAtIndex:i];
            CGRect frame = item.frame;
            frame.origin.x -= item.width;
            item.frame = frame;
        }
        CGFloat sizeHeight = contentView.height;
        [contentView setContentSize:CGSizeMake(sizeHeight * buttonSArr.count, sizeHeight)];
    }];
    
    UserCell* cell = (UserCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.selected = forUserSelectCellNormal;
    
    if (selectedArr.count==1 && contentView.top == self.view.height - 49) {
        [UIView animateWithDuration:0.25 animations:^{
            contentView.top = Main_Screen_Height;
            tableView.height += 49;
        }];
    }
    if (selectedArr.count==0) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

#pragma mark - Request

- (BOOL)sendRequest {
    if ([super startRequest]) {
        if (typeRequest == forSessionNewRequestCreateRoom) {
            [client createGroupAndInviteUsers:inviteUserArr groupname:nil];
        } else if (typeRequest == forSessionNewRequestInviteUser) {
            [client inviteUser:session.uid inviteduids:inviteUserArr];
        }  else {
            [client friendList];
        }
        return YES;
    }
    return NO;
}

- (BOOL)requestDidFinish:(BSClient*)sender obj:(NSDictionary *)obj{
    if ([super requestDidFinish:sender obj:obj]) {
        if (typeRequest == forSessionNewRequestFriendList) {
            NSMutableArray *array = [NSMutableArray array];
            if (obj != nil && [obj isKindOfClass:[NSDictionary class]]) {
                if (obj && obj.count > 0) {
                    NSArray *arr = [obj getArrayForKey:@"data"];
                    if (arr != nil) {
                        for (NSDictionary* dic in arr) {
                            User * item = [User objWithJsonDic:dic];
                            if (item) {
                                [item insertDB];
                                if ([sourceArr containsObject:item.uid]) {
                                    continue;
                                }
                                [array addObject:item];
                            }
                        }
                        NSArray *sortArr = [User sortData:array hasHeader:nil];
                        [contentArr addObjectsFromArray:sortArr];
                        [tableView reloadData];
                    }
                }
            }
        } else if (typeRequest == forSessionNewRequestInviteUser) {
            [self showText:sender.errorMessage];
            NSMutableArray* selectedUserArr = [NSMutableArray array];
            for (NSIndexPath* indexPath in selectedArr) {
                User* item = [[contentArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                [selectedUserArr addObject:item];
            }
            _inviteBlack(selectedUserArr);
            _inviteBlack = nil;
            [self popViewController];
        } else if (typeRequest == forSessionNewRequestCreateRoom) {
            // 创建成功后立即跳转
            NSDictionary * data = [obj getDictionaryForKey:@"data"];
            Room * room = [Room objWithJsonDic:data];
            [room insertDB];
            if (_isForword) {
                Message * fmsg = [self.value copy];
                fmsg.displayName =
                fmsg.toname = room.name;
                fmsg.displayImgUrl =
                fmsg.tohead = room.head;
                fmsg.toId = room.uid;
                fmsg.typechat = forChatTypeGroup;
                [Globals setPreSendMsg:fmsg];
                Session * itemS = [Session sessionWithMessage:fmsg];
                id con = [[TalkingViewController alloc] initWithSession:itemS];
                [self pushViewControllerAfterPop:con];
            } else {
                TalkingViewController *con = [[TalkingViewController alloc] initWithSession:[Session sessionWithRoom:room]];
                [self pushViewControllerAfterPop:con];
            }

        }
    }
    return YES;
}

- (NSString*)baseTableView:(UITableView *)sender imageURLAtIndexPath:(NSIndexPath *)indexPath {
    User *user = nil;
    if (sender == tableView ) {
        user = [[contentArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    } else {
        user = [filterArr objectAtIndex:indexPath.row];
    }
    return user.headsmall;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender {
    if (sender.contentOffset.y > 0 && sender.contentOffset.y < self.searchDisplayController.searchBar.height) {
        [sender setContentOffset:CGPointZero animated:YES];
    }
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)sender heightForHeaderInSection:(NSInteger)section
{
    if ([[contentArr objectAtIndex:section] count] > 0 && sender == tableView ) {
        return tableView.sectionHeaderHeight;
    }
    return 0;
}

- (UIView*)tableView:(UITableView *)sender viewForHeaderInSection:(NSInteger)section {
    if ([[contentArr objectAtIndex:section] count] > 0 && sender ==tableView ) {
        UIImageView *bkImageView = [[UIImageView alloc] init];
        bkImageView.backgroundColor = RGBCOLOR(229, 228, 226);
        UILabel *tLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 20, 20)];
        tLabel.textColor=[UIColor darkGrayColor];
        tLabel.backgroundColor = [UIColor clearColor];
        tLabel.text = [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
        [bkImageView addSubview:tLabel];
        return bkImageView;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)sender numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    if (sender == tableView ) {
        rows = [[contentArr objectAtIndex:section] count];
    } else {
        rows = filterArr.count;
    }
    return rows;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)sender {
    if (sender == tableView ) {
        return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
    } else {
        return nil;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)sender
{
    if (sender == tableView ) {
        return contentArr.count;
    } else {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)section {
    if (contentArr.count > 0 && sender ==tableView ) {
        return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
    } else {
        return nil;
    }
}

#pragma mark - UITableViewDelegate

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"UserCell";
    UserCell * cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
    if (sender == self.searchDisplayController.searchResultsTableView) {
        if (!cell) {
            cell = [[UserCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            [cell setlabTimeHide:YES];
        }
    } else {
        if (!cell) {
            cell = [[UserCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            [cell setlabTimeHide:YES];
        }
    }
    User * user = nil;
    if (sender == tableView ) {
        user = [[contentArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        if (indexPath.row == [[contentArr objectAtIndex:indexPath.section] count] - 1) {
            
        }
    } else {
        user = [filterArr objectAtIndex:indexPath.row];
        if (indexPath.row == filterArr.count - 1) {
            
        }
    }
    cell.withFriendItem = user;
    [cell update:^(NSString *name) {
        [cell autoAdjustText];
        cell.imageView.frame = CGRectMake(32, (cell.height - 40)/2, 40, 40);
        cell.textLabel.frame = CGRectMake(cell.imageView.right + 10, 0, cell.width - cell.imageView.left - 20, cell.height);
        cell.detailTextLabel.text = @"";
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)sender willDisplayCell:(UserCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:sender willDisplayCell:cell forRowAtIndexPath:indexPath];
    if (!_userBlack) {
        if (sender == tableView) {
            if ([selectedArr containsObject:indexPath]) {
                cell.selected = forUserSelectCellSelected;
            } else {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                if ([self isContainsInSourceArr:[[contentArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]]) {
                    cell.selected = forUserSelectCellSource;
                } else {
                    cell.selected = forUserSelectCellNormal;
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                }
            }
        } else {
            User* item = [filterArr objectAtIndex:indexPath.row];
            if ([self isContainsInSelectedArr:item]) {
                cell.selected = forUserSelectCellSelected;
            } else {
                if ([self isContainsInSourceArr:item]) {
                    cell.selected = forUserSelectCellSource;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                } else {
                    cell.selected = forUserSelectCellNormal;
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                }
            }
        }
    }
}

- (BOOL)sourceArrHasit:(User*)item {
    for (NSString *uid in sourceArr) {
        if ([uid isEqualToString:item.uid]) {
            return YES;
        }
    }
    return NO;
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    User * item = nil;
    if (sender == self.searchDisplayController.searchResultsTableView) {
        item = [filterArr objectAtIndex:indexPath.row];
    } else {
        item = [[contentArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    if (_userBlack) {
        _userBlack(item);
        _userBlack = nil;
        [self popViewController];
    } else if (self.value) {
        // 这个value 是 Message对象
        if (!_isForword) {
            // 如果是新建转发， 则根据选择对象初始化Message并传给TalkingViewController
            Message * fmsg = [self.value copy];
            fmsg.displayName =
            fmsg.toname = item.nickname;
            fmsg.displayImgUrl =
            fmsg.tohead = item.headsmall;
            fmsg.toId = item.uid;
            fmsg.typechat = forChatTypeUser;
            [Globals setPreSendMsg:fmsg];
            Session * itemS = [Session sessionWithMessage:fmsg];
            id con = [[TalkingViewController alloc] initWithSession:itemS];
            [self pushViewControllerAfterPop:con];
        } else {
            // 选择对象
            if (sender == tableView) {
                // 被锁定的不能选
                if ([self sourceArrHasit:item]) {
                    return;
                }
                // 已经存在则移除
                for (NSIndexPath *idx in selectedArr) {
                    if (idx.section == indexPath.section && idx.row == indexPath.row) {
                        [self removeIndexPath:indexPath];
                        return;
                    }
                }
                // 反之添加
                [self addIndexPath:indexPath];
            } else if (sender == self.searchDisplayController.searchResultsTableView) {
                // 在过滤后的TableView里，只需要直接进行判断移除/添加
                CGPoint point = [self positionInItem:item];
                NSIndexPath *idx = [self idxInSelectedArr:point];
                if (idx) {
                    [self removeIndexPath:idx];
                } else {
                    NSIndexPath* sIndexPath = [NSIndexPath indexPathForRow:point.y inSection:point.x];
                    [self addIndexPath:sIndexPath];
                }
                [self.searchDisplayController setActive:NO animated:YES];
            }
        }
    } else {
        // 这里是没有Message对象的选择，大体同上
        if (sender == tableView) {
            if ([self sourceArrHasit:item]) {
                return;
            }
            for (NSIndexPath *idx in selectedArr) {
                if (idx.section == indexPath.section && idx.row == indexPath.row) {
                    [self removeIndexPath:indexPath];
                    return;
                }
            }
            [self addIndexPath:indexPath];
        } else if (sender == self.searchDisplayController.searchResultsTableView) {
            CGPoint point = [self positionInItem:item];
            NSIndexPath *idx = [self idxInSelectedArr:point];
            if (idx) {
                [self removeIndexPath:idx];
            } else {
                NSIndexPath* sIndexPath = [NSIndexPath indexPathForRow:point.y inSection:point.x];
                [self addIndexPath:sIndexPath];
            }
            self.searchBar.text = @"";
            [self.mySearchDisplayController setActive:NO animated:YES];
            [self.searchBar resignFirstResponder];
        }
    }
}

/** 返回二维坐标是否已经存在数组里*/
- (NSIndexPath *)idxInSelectedArr:(CGPoint)position {
    NSIndexPath* sIndexPath = [NSIndexPath indexPathForRow:position.y inSection:position.x];
    for (NSIndexPath *idx in selectedArr) {
        if (idx.section == sIndexPath.section && idx.row == sIndexPath.row) {
            return idx;
        }
    }
    return nil;
}

/** 返回传入对象在队列的二维坐标*/
- (CGPoint)positionInItem:(User *)item {
    CGPoint point = CGPointMake(0, 0);
    for (NSArray * arr in contentArr) {
        BOOL find = NO;
        point.y = 0;
        for (User *user in arr) {
            if ([user.uid isEqualToString:item.uid]) {
                find = YES;
                break;
            }
            point.y++;
        }
        if (find) {
            break;
        }
        point.x++;
    }
    return point;
}

/** 返回选择数组是否包含这个对象*/
- (BOOL)isContainsInSelectedArr:(User*)item {
    BOOL result = NO;
    for (NSIndexPath *idx in selectedArr) {
        User* tmpItem = [[contentArr objectAtIndex:idx.section] objectAtIndex:idx.row];
        if ([item.uid isEqualToString:tmpItem.uid]) {
            result = YES;
            break;
        }
    }
    return result;
}

#pragma mark - Filter

- (void)filterContentForSearchText:(NSString*)searchText
                             scope:(NSString*)scope {
    for (NSArray *arr in contentArr) {
        for (User *it in arr) {
            if (!_isGroup) {
                if (it.sign && [it.sign rangeOfString:searchText].location <= it.sign.length) {
                    [filterArr addObject:it];
                    continue;
                }
            }
            if ([it.displayName rangeOfString:searchText].location <= it.displayName.length) {
                [filterArr addObject:it];
            }
        }
    }
    [self.view bringSubviewToFront:contentView];
}

@end
