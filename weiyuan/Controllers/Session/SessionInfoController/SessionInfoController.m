//
//  SessionInfoController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SessionInfoController.h"
#import "SessionNewController.h"
#import "BaseTableViewCell.h"
#import "AppDelegate.h"
#import "Session.h"
#import "Room.h"
#import "Message.h"
#import "Globals.h"
#import "UserInfoViewController.h"
#import "KLSwitch.h"
#import "KWAlertView.h"
#import "GroupViewController.h"
#import "QRCodeGenerator.h"
#import "QRcodeViewController.h"
#import "ImageTouchView.h"
#import "TextEditController.h"
#import "TalkingViewController.h"
#import "UserMsg.h"
#import "Notify.h"
#import "UserCollectionViewCell.h"
#import "SearchChatViewController.h"

@interface SessionInfoController () <UICollectionViewDataSource, UICollectionViewDelegate> {
    UIView * headView;
}
@property (nonatomic, strong) UITapGestureRecognizer * recognizer;
@property (nonatomic, strong) Session   *   session;
@property (nonatomic, strong) NSString  *   selectedStr;
@property (nonatomic, strong) Room      *   currectRoom;
@property (nonatomic, strong) id        delegate;
@property (nonatomic, assign) CGFloat   collectionViewHeight;
@property (nonatomic, strong) UICollectionView    * collectionView;
/** collectionView是否处于编辑状态 0 不处于 2 删除*/
@property (nonatomic, assign) int      isEdit;

@end

@implementation SessionInfoController

@synthesize session;
@synthesize delegate;

- (id)initWithSession:(Session *)item delegate:(id)del {
    if (self = [super init]) {
        // Custom initialization
        self.session = item;
        self.delegate = del;
    }
    return self;
}

- (void)dealloc {
    // data
    self.session = nil;
    self.selectedStr = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = [NSString stringWithFormat:@"聊天信息(1)"];
    if (session.typechat == forChatTypeGroup) {
        self.currectRoom = [Room roomForUid:session.uid];
        if (self.currectRoom) {
            self.navigationItem.title = [NSString stringWithFormat:@"聊天信息(%d)", self.currectRoom.usercount];
        } else {
            DLog(@"shit!");
            self.navigationItem.title = [NSString stringWithFormat:@"聊天信息(1)"];
        }
    } else {
        [contentArr addObject:self.session.headsmall];
    }

    self.tableViewCellHeight = 38;
    self.view.backgroundColor =
    tableView.backgroundColor = RGBCOLOR(239, 239, 239);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotifyGroupChat:) name:@"receivedNotifyGroupChat" object:nil];
    _collectionViewHeight = 65;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.isEdit = 0;
    if (isFirstAppear) {
        if (session.typechat == forChatTypeGroup) {
            if ((!self.currectRoom || !self.currectRoom.creator)&& [super startRequest]) {
                [client groupDetail:session.uid];
                client.tag = @"groupDetail";
            }
        } else if (session.typechat == forChatTypeUser) {
            
        }
    }
    
    [self headerView];
}

- (void)receivedNotifyGroupChat:(NSNotification*)sender {
    Notify* ntf = sender.object;
    if (ntf.type == forNotifyGroupInfoUpdate) {
        self.currectRoom.name = ntf.roomName;
        if (!_onlylook) {
            [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
    } else if (ntf.type == forNotifyNameChange) {
        // 群里有人改了他的昵称
        NSInteger row = [self.currectRoom userNickNameChanged:ntf.user.uid name:ntf.user.nickname];
        [_collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]]];
    } else if (ntf.type == forNotifyDestroyRoom || ntf.type == forNotifyKickUser) {
        if ([ntf.user.uid isEqualToString:[BSEngine currentUserId]]) {
            if ([self.navigationController.viewControllers lastObject] == self) {
                KWAlertView * k = [[KWAlertView alloc] initWithTitle:nil message:ntf.content delegate:self cancelButtonTitle:nil otherButtonTitle:@"确定"];
                k.tag = 3;
                [k show];
                DLog(@"群踢人/解散消息 : %@",ntf.content);
            }
        } else {
            self.isEdit = 0;
            [self.currectRoom addUser:ntf.user isAdd:NO];
            [self headerView];
        }
    } else if (ntf.type == forNotifyaddNewOne) {
        if (self.currectRoom.isOwer && [self.currectRoom.uid isEqualToString:ntf.roomID]) {
            DLog(@"我自己加了一个人 : %@",ntf.user.nickname);
        } else {
            DLog(@"群加人通知 : %@",ntf.content);
            [self.currectRoom addUser:ntf.user isAdd:YES];
            [self headerView];
            self.navigationItem.title = [NSString stringWithFormat:@"聊天信息(%d)", self.currectRoom.usercount];
        }

    }
}

- (void)setIsEdit:(int)isEt {
    _isEdit = isEt;
    if (isEt == 2) {
        self.recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchAnyWhere)];
        [tableView addGestureRecognizer:_recognizer];
    } else {
        [tableView removeGestureRecognizer:_recognizer];
    }
}

- (void)touchAnyWhere {
    if (self.isEdit != 0) {
        self.isEdit = 0;
        [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    }
}

#pragma mark - Request
- (BOOL)requestDidFinish:(BSClient*)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        if ([sender.tag isEqualToString:@"groupDetail"]) {
            NSDictionary * data = [obj getDictionaryForKey:@"data"];
            self.currectRoom = [Room objWithJsonDic:data];
            [self.currectRoom insertDB];

            [contentArr addObjectsFromArray:self.currectRoom.value];
            [tableView reloadData];
            [self headerView];
        } else if ([sender.tag isEqualToString:@"delUserFromGroup"]) {
            
        }
        self.navigationItem.title = [NSString stringWithFormat:@"聊天信息(%d)", self.currectRoom.usercount];
    }
    return YES;
}

- (NSInteger)numberofCollectionView {
    NSInteger row = 0;
    if (self.currectRoom) {
        row = [self.currectRoom.value count] + (_onlylook?0:(self.isEdit > 1?0:(self.currectRoom.isOwer?2:1)));
    } else {
        row = 2;
    }
    return row;
}

- (void)headerView {
    self.isEdit = 0;
    
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    CGFloat number = (CGFloat)self.numberofCollectionView/4;
    if (number!= ceil(self.numberofCollectionView/4)){
        number = (int)number + 1;
    }
    CGFloat height = number*(_collectionViewHeight+5)+40;
    headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, height)];
    headView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    headView.backgroundColor = RGBCOLOR(239, 239, 239);
    tableView.tableHeaderView = headView;
    
    UIImageView * bkgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, tableView.width, headView.height-20)];
    bkgView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    bkgView.backgroundColor = [UIColor whiteColor];
    [headView addSubview:bkgView];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(10, 10, bkgView.width-20, height-40) collectionViewLayout:flowLayout];
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
    _collectionView.backgroundColor = [UIColor whiteColor];
    //注册
    [self.collectionView registerClass:[UserCollectionViewCell class] forCellWithReuseIdentifier:@"UserCollectionViewCell"];
    //设置代理
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [bkgView addSubview:self.collectionView];
    _collectionView.allowsSelection = NO;
    headView.userInteractionEnabled =
    bkgView.userInteractionEnabled = YES;
    self.collectionView.clipsToBounds = NO;
    
    [contentArr addObjectsFromArray:self.currectRoom.value];
    
    NSString *str = nil;
    if (_onlylook) {
        str = @"进入聊天";
    } else {
        if (self.currectRoom) {
            if (self.currectRoom.isOwer) {
                str = @"删除并退出";
            } else {
                if (self.currectRoom.isjoin) {
                    str = @"退出";
                } else {
                    str = @"加入群组";
                }
            }
        }
        
    }
    if (str) {
        UIView * footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 120)];
        UIButton * btnExit = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnExit setTitle:str forState:UIControlStateNormal];
        [btnExit addTarget:self action:@selector(destroyorExit:) forControlEvents:UIControlEventTouchUpInside];
        btnExit.frame = CGRectMake(40, 40, 240, 35);
        [btnExit dangerStyle];
        [footerView addSubview:btnExit];
        tableView.tableFooterView = footerView;
    }

}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)sender {
    if (_onlylook) {
        return 0;
    }
    if (session.typechat == forChatTypeUser) {
        return 2;
    }
    if (![self.currectRoom isjoin]) {
        return 1;
    }
    return 3;
}

- (NSInteger)tableView:(UITableView *)sender numberOfRowsInSection:(NSInteger)section {
    if (session.typechat == forChatTypeUser) {
        return 2;
    }
    if (section == 0) {
        return 2;
    } else if (section == 1) {
        return 4;
    } else {
        return 2;
    }
}

#pragma mark - UITableViewDelegate

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"Cell";
    BaseTableViewCell* cell = [sender dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.imageView.hidden = YES;
    }
    
    // 二维码
    UIImageView * imageView = VIEWWITHTAG(cell.contentView, 1024);
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(cell.width - 54, 2, self.tableViewCellHeight - 4, self.tableViewCellHeight - 4)];
        imageView.tag = 1024;
        [cell.contentView addSubview:imageView];
    }
    
    [cell addSwitch];
    cell.selectedBackgroundView.hidden = NO;
    cell.customSwitch.hidden = YES;
    cell.arrowlayer.hidden = NO;
    cell.detailTextLabel.text = nil;
    cell.imageView.hidden = YES;
    [cell addArrowRight];
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    [cell setBottomLine:NO];
    cell.arrowlayer.hidden = NO;
    if (session.typechat == forChatTypeUser) {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                cell.arrowlayer.hidden = YES;
                cell.textLabel.text = @"新消息提醒";
                cell.customSwitch.hidden = NO;
                UserMsg * um = [UserMsg valueForKeyFromeDB:session.uid keyname:@"uid"];
                cell.customSwitch.on = um.getmsg.boolValue;
                cell.selectedBackgroundView.hidden = YES;
                [cell.customSwitch setDidChangeHandler:^(BOOL isOn) {
                    self.loading = YES;
                    client = [[BSClient alloc] initWithDelegate:self action:@selector(setgetMsgResponse:obj:)];
                    client.indexPath = indexPath;
                    [client setGetmsg:um.uid];
                }];
            } else if (indexPath.row == 1) {
                cell.arrowlayer.hidden = YES;
                cell.textLabel.text = @"置顶聊天";
                cell.selectedBackgroundView.hidden = YES;
                cell.customSwitch.hidden = NO;
                cell.customSwitch.on = (session.istop>0)?YES:NO;
                [cell.customSwitch setDidChangeHandler:^(BOOL isOn) {
                    if (session.istop > 0) {
                        session.istop = 0;
                    } else {
                        session.istop = [Session getLastTopSession] + 1;
                    }
                    [session updateVaule:[NSNumber numberWithInt:session.istop] key:@"istop"];
                    [[AppDelegate instance] cleanMessageWithSession:session];
                }];
            }
        } else {
            if (indexPath.row == 0) {
                cell.textLabel.text = @"查找聊天记录";
                cell.detailTextLabel.text = nil;
            } else if (indexPath.row == 1) {
                cell.textLabel.text = @"清空聊天记录";
                cell.detailTextLabel.text = nil;
                [cell setBottomLine:YES];
            }
        }
    } else if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"群聊名称";
            cell.detailTextLabel.text = self.currectRoom.name;
            cell.selectionStyle = self.currectRoom.isOwer?UITableViewCellSelectionStyleGray:UITableViewCellSelectionStyleNone;
        } else if (indexPath.row == 1) {
            imageView.image = [QRCodeGenerator qrImageForString:[NSString stringWithFormat:@"%@%@",KBSSDKAPIURL,[self.currectRoom.uid base64EncodedString]] imageSize:imageView.bounds.size.width];
            imageView.hidden = YES;
            cell.textLabel.text = @"群二维码";
            imageView.hidden = NO;
            [cell setBottomLine:YES];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.arrowlayer.hidden = YES;
            cell.textLabel.text = @"新消息提醒";
            cell.customSwitch.hidden = NO;
            cell.customSwitch.on = self.currectRoom.getmsg;
            cell.selectedBackgroundView.hidden = YES;
            [cell.customSwitch setDidChangeHandler:^(BOOL isOn) {
                self.loading = YES;
                client = [[BSClient alloc] initWithDelegate:self action:@selector(setReceRoomMsgResponse:obj:)];
                client.indexPath = indexPath;
                [client groupMsgSetting:self.currectRoom.uid getmsg:self.currectRoom.getmsg];
            }];
        } else if (indexPath.row == 1) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.arrowlayer.hidden = YES;
            cell.textLabel.text = @"置顶聊天";
            cell.selectedBackgroundView.hidden = YES;
            cell.customSwitch.hidden = NO;
            cell.customSwitch.on = session.istop;
            [cell.customSwitch setDidChangeHandler:^(BOOL isOn) {
                session.istop = session.istop>0?0:1;
                [session updateVaule:[NSNumber numberWithBool:session.istop] key:@"istop"];
                [[AppDelegate instance] cleanMessageWithSession:session];
            }];
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"我的群昵称";
            cell.detailTextLabel.text = self.currectRoom.mynickname;
        } else if (indexPath.row == 3) {
            cell.arrowlayer.hidden = YES;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"显示群成员昵称";
            cell.selectedBackgroundView.hidden = YES;
            cell.customSwitch.hidden = NO;
            cell.customSwitch.on = session.isshownick;
            [cell.customSwitch setDidChangeHandler:^(BOOL isOn) {
                session.isshownick = !session.isshownick;
                [session updateVaule:[NSNumber numberWithBool:session.isshownick] key:@"isshownick"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"needShowPerconName" object:[NSString stringWithFormat:@"%d", isOn]];
            }];
        }
    } else {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"查找聊天记录";
            cell.detailTextLabel.text = nil;
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"清空聊天记录";
            cell.detailTextLabel.text = nil;
            [cell setBottomLine:YES];
        }
    }
    [cell update:^(NSString *name) {
        if (cell.selectedBackgroundView.hidden == YES) {
            cell.textLabel.highlightedTextColor = RGBCOLOR(81, 81, 81);
        } else {
            cell.textLabel.highlightedTextColor = [UIColor whiteColor];
        }
        CGRect frame = cell.arrowlayer.frame;
        frame.origin.x = cell.width - 16;
        cell.arrowlayer.frame = frame;
        cell.customSwitch.left = cell.width - 60;
        cell.textLabel.textColor = RGBCOLOR(81, 81, 81);
        cell.textLabel.font = [UIFont systemFontOfSize:13];
        cell.detailTextLabel.frame = CGRectMake(100, 0, cell.width-120, cell.height);
        cell.detailTextLabel.textAlignment = NSTextAlignmentRight;
        cell.textLabel.height = self.tableViewCellHeight - 2;
        cell.textLabel.left = 10;
        cell.imageView.frame = CGRectMake(cell.width - 50, 2, 34, 34);
        cell.contentView.backgroundColor =
        cell.backgroundColor = [UIColor whiteColor];
    }];
    return cell;
}

- (NSString*)baseTableView:(UITableView *)sender imageURLAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    if ((session.typechat == forChatTypeGroup) && indexPath.section == 0) {
        if (indexPath.row == 0) {
            if (self.currectRoom.isOwer) {
                TextEditController * con = [[TextEditController alloc] initWithDel:self type:TextEditTypeDefault title:@"群聊名称" value:self.currectRoom.name];
                con.minTextCount = 2;
                con.maxTextCount = 8;
                con.indexPath = indexPath;
                [self pushViewController:con];
            }
        } else {
            QRcodeViewController * con = [[QRcodeViewController alloc] init];
            con.session = session;
            con.item = self.currectRoom;
            [self pushViewController:con];
        }
    } else if ((session.typechat == forChatTypeGroup) && indexPath.section == 1) {
        if (indexPath.row == 2) {
            TextEditController * con = [[TextEditController alloc] initWithDel:self type:TextEditTypeDefault title:@"我的群昵称" value:self.currectRoom.mynickname];
            con.minTextCount = 2;
            con.maxTextCount = 8;
            con.indexPath = indexPath;
            [self pushViewController:con];
        }
    } else if (indexPath.section == 2 || (!self.currectRoom && indexPath.section == 1)) {
        if (indexPath.row == 1) {
            KWAlertView *k = [[KWAlertView alloc] initWithTitle:nil message:@"确定清空消息记录？" delegate:self cancelButtonTitle:@"取消" otherButtonTitle:@"确定"];
            k.tag = 1;
            [k show];
        } else {
            SearchChatViewController * con = [[SearchChatViewController alloc] init];
            con.session = session;
            [self pushViewController:con];
        }
    }
}

- (UIView *)tableView:(UITableView *)sender viewForHeaderInSection:(NSInteger)section {
    UIImageView * clearView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, sender.width, 10)];
    clearView.backgroundColor = [UIColor clearColor];
    return clearView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 6;
}

- (UIView *)tableView:(UITableView *)sender viewForFooterInSection:(NSInteger)section {
    UIImageView *clearView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, sender.width, 10)];
    clearView.backgroundColor = [UIColor clearColor];
    return clearView;
}

#pragma mark - textEditControllerDidEdit
- (void)textEditControllerDidEdit:(NSString*)text idx:(NSIndexPath*)idx {
    if (client) {
        return;
    }
    [self setLoading:YES content:@"更新群聊信息中"];
    client = [[BSClient alloc] initWithDelegate:self action:@selector(requestupdateRoomInfoDidFinish:obj:)];
    client.indexPath = idx;
    client.tag = text;
    if (idx.section == 0) {
        [client editGroupname:self.currectRoom.uid name:text];
    } else if (idx.section == 1) {
        [client setNickname:self.currectRoom.uid name:text];
    }
}

#pragma mark - request delegate
- (BOOL)requestupdateRoomInfoDidFinish:(BSClient*)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        BaseTableViewCell * cell = (BaseTableViewCell *)[tableView cellForRowAtIndexPath:sender.indexPath];
        cell.detailTextLabel.text = sender.tag;
        if (sender.indexPath.section == 0) {
            self.currectRoom.name = sender.tag;
            [self.currectRoom updateVaule:sender.tag key:@"name"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshGroupName" object:self.currectRoom];
        } else {
            self.currectRoom.mynickname = sender.tag;
            [self.currectRoom updateVaule:sender.tag key:@"mynickname"];
            NSInteger row = [self.currectRoom userNickNameChanged:[BSEngine currentUserId] name:sender.tag];
            [_collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]]];
        }
    }
    return YES;
}

#pragma mark - collectionView delegate
//设置分区
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)sender{
    return 1;
}

//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)sender numberOfItemsInSection:(NSInteger)section
{
    return self.numberofCollectionView;
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)sender layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(sender.width/5,_collectionViewHeight);
}

//每个UICollectionView展示的内容
- (UICollectionViewCell *)collectionView:(UICollectionView *)sender cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"UserCollectionViewCell";
    UserCollectionViewCell *cell = [sender dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    cell.superCollectionView = sender;
    
    cell.backgroundColor = [UIColor clearColor];
    cell.title = nil;
    NSArray * arr = [self.currectRoom.nameUserList componentsSeparatedByString:@","];
    cell.imageView.hidden = NO;
    NSInteger zcount = indexPath.row - (self.currectRoom?arr.count:1);
    if (zcount==0) {
        cell.imageView.hidden = (self.isEdit > 0);
        cell.image = LOADIMAGE(@"btn_room_add");
        cell.imageView.highlightedImage = LOADIMAGE(@"btn_room_add_d");
    } else if (zcount == 1) {
        cell.imageView.hidden = (self.isEdit > 0);
        if (self.currectRoom.isOwer) {
            cell.image = LOADIMAGE(@"btn_room_minus");
            cell.imageView.highlightedImage = LOADIMAGE(@"btn_room_minus_d");
        } else {
            cell.image = LOADIMAGE(@"btn_room_add");
            cell.imageView.highlightedImage = LOADIMAGE(@"btn_room_add_d");
        }
    } else {
        if (self.currectRoom) {
            cell.image = [Globals getImageUserHeadDefault];
            cell.title = [arr objectAtIndex:indexPath.row];
            NSString * url = [self.currectRoom.value objectAtIndex:indexPath.row];
            [Globals imageDownload:^(UIImage *img) {
                if (!img) {
                    img = [Globals getImageUserHeadDefault];
                }
                cell.image = img;
            } url:url];
        } else {
            NSString * url = session.headsmall;
            [Globals imageDownload:^(UIImage *img) {
                if (!img) {
                    img = [Globals getImageUserHeadDefault];
                }
                cell.image = img;
            } url:url];
            cell.title = session.name;
        }
       
        cell.edit = self.isEdit;
    }
    return cell;
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)sender shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)sender didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (sender && [(NSString*)sender isEqualToString:@"headTapped"]) {
        if (self.isEdit == 0) {
            if (!self.currectRoom && indexPath.row == 1) {
                SessionNewController * con = [[SessionNewController alloc] initWithSession:session];
                con.isSign = YES;
                [self pushViewController:con];
            } else {
                if (!self.currectRoom) {
                    [self getUserByName:session.uid];
                } else {
                    NSInteger zcount = indexPath.row-[self.currectRoom.nameUserList componentsSeparatedByString:@","].count;
                    if (zcount==0) {
                        self.isEdit = 1;
                        SessionNewController * con = [[SessionNewController alloc] initWithSession:session];
                        [con setInviteBlack:^(NSArray * it)  {
#ifdef DEBUG
                            DLog(@"我添加了用户进入我的群里！");
#endif
                            [it enumerateObjectsUsingBlock:^(User *user, NSUInteger idx, BOOL *stop) {
                                [self.currectRoom addUser:user isAdd:YES];
                            }];
                            [self headerView];
                            self.navigationItem.title = [NSString stringWithFormat:@"聊天信息(%d)", self.currectRoom.usercount];
                        } currectRoom:self.currectRoom];
                        [self pushViewController:con];
                    } else if (zcount==1) {
                        if (self.currectRoom.isOwer) {
                            self.isEdit = 2;
                            [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
                        } else {
                            self.isEdit = 1;
                            SessionNewController * con = [[SessionNewController alloc] initWithSession:session];
                            [self pushViewController:con];
                        }
                    } else {
                        [self getUserByName:[self.currectRoom.idUserList componentsSeparatedByString:@","][indexPath.row]];
                    }
                }
            }
        } else {
            NSArray * arr = [self.currectRoom.idUserList componentsSeparatedByString:@","];
            [super startRequest];
            client.tag = @"delUserFromGroup";
            client.indexPath = indexPath;
            [client delUserFromGroup:self.currectRoom.uid fuid:arr[indexPath.row]];
        }
        return;
    }
}

#pragma mark - KWAlertViewDelegate
- (void)kwAlertView:(KWAlertView*)sender didDismissWithButtonIndex:(NSInteger)index {
    if (sender.tag == 1) {
        if (index == 1) {
            [session cleanMessage];
            if ([delegate respondsToSelector:@selector(cleanMessageWithSession:)]) {
                [delegate performSelector:@selector(cleanMessageWithSession:) withObject:session];
            }
            [[AppDelegate instance] cleanMessageWithSession:session];
        }
    } else if (sender.tag == 2) {
        if (index == 1) {
            if (client) {
                return;
            }
            self.loading = YES;
            client = [[BSClient alloc] initWithDelegate:self action:@selector(destroyRoomResponse:obj:)];
            if (self.currectRoom.isOwer) {
                [client delGroup:self.currectRoom.uid];
            } else {
                [client exitGroup:self.currectRoom.uid];
            }
            [self.currectRoom deleteFromDB];
        }
    } else if (sender.tag == 3) {
        if (index == 1) {
            [self.currectRoom deleteFromDB];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

#pragma mark - methods

- (IBAction)destroyorExit:(id)sender {
    if (_onlylook) {
        TalkingViewController *con = [[TalkingViewController alloc] initWithSession:session];
        [self pushViewController:con];
    } else {
        KWAlertView *k = [[KWAlertView alloc] initWithTitle:nil message:@"是否要删除并退出这个群吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitle:@"确定"];
        [k show];
        k.tag = 2;
    }
}

- (BOOL)applyGroupResponse:(BSClient *)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        [self showText:sender.errorMessage];
        return YES;
    }
    return NO;
}

- (BOOL)destroyRoomResponse:(BSClient *)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        [self.currectRoom deleteFromDB];
        [session deleteFromDB];
        if ([delegate respondsToSelector:@selector(cleanMessageWithSession:)]) {
            [delegate performSelector:@selector(cleanMessageWithSession:) withObject:session];
        }
        [[AppDelegate instance] cleanMessageWithSession:session];
        [self.navigationController popToRootViewControllerAnimated:YES];
        return YES;
    }
    return NO;
}

#pragma mark - other request
- (BOOL)setReceRoomMsgResponse:(BSClient *)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        self.currectRoom.getmsg = !self.currectRoom.getmsg;
        [self.currectRoom updateVaule:[NSNumber numberWithBool:self.currectRoom.getmsg] key:@"getmsg"];
        return YES;
    }
    BaseTableViewCell * cell = (BaseTableViewCell *)[tableView cellForRowAtIndexPath:sender.indexPath];
    [cell.customSwitch setOn:self.currectRoom.getmsg animated:YES];
    return NO;
}

- (BOOL)setgetMsgResponse:(BSClient *)sender obj:(NSDictionary *)obj {
    UserMsg * um = [UserMsg valueForKeyFromeDB:session.uid keyname:@"uid"];
    if ([super requestDidFinish:sender obj:obj]) {
        User * user = [User userWithID:session.uid];
        user.getmsg = !user.getmsg;
        [user updateVaule:[NSString stringWithFormat:@"%d", user.getmsg] key:@"getmsg"];
        [um updateVaule:[NSString stringWithFormat:@"%d", user.getmsg] key:@"getmsg"];
        return YES;
    }
    BaseTableViewCell * cell = (BaseTableViewCell *)[tableView cellForRowAtIndexPath:sender.indexPath];
    [cell.customSwitch setOn:um.getmsg.boolValue animated:YES];
    return NO;
}

@end
