//
//  VisibleViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "VisibleViewController.h"
#import "UserCollectionViewCell.h"
#import "SessionNewController.h"
#import "UIButton+NSIndexPath.h"
#import "UserCell.h"
#import "Globals.h"
#import "UIImage+FlatUI.h"
#import "KWAlertView.h"
#import "UserInfoViewController.h"

@interface VisibleViewController ()<UICollectionViewDataSource, UICollectionViewDelegate> {
    NSIndexPath * selectedIndexPath;
}

@property (nonatomic, assign) CGFloat               collectionViewHeight;
@property (nonatomic, strong) UICollectionView      * collectionView;
@end

@implementation VisibleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"选择可见范围";
    
    _collectionViewHeight = 50;
    self.tableViewCellHeight = 44;
    
    // headerView
    UIView * tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 40)];
    UILabel * lab = [UILabel linesText:@"可见范围" font:[UIFont systemFontOfSize:14] wid:100 lines:1 color:RGBCOLOR(145, 145, 145)];
    lab.origin = CGPointMake(15, 20);
    [tableHeaderView addSubview:lab];
    tableView.tableHeaderView = tableHeaderView;
    
    // collectionView
    [self updateCollectionView];
    if (!_selectedArray) {
        self.selectedArray = [NSMutableArray array];
    }
    [contentArr addObjectsFromArray:@[@"公开", @"私密"]];
    
    _collectionView.hidden = (_selectedArray.count == 0);
    selectedIndexPath = [NSIndexPath indexPathForRow:(_selectedArray.count > 0)?1:0 inSection:0];
}

- (void)popViewController {
    if (_block) {
        if (selectedIndexPath.row == 0) {
            [_selectedArray removeAllObjects];
        }
        _block(_selectedArray);
    }
    _block = nil;
    [super popViewController];
}

- (void)updateCollectionView {
    // 重新生成 UICollectionView
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 10, tableView.width, tableView.height - 98) collectionViewLayout:flowLayout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[UserCollectionViewCell class] forCellWithReuseIdentifier:@"UserCollectionViewCell"];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.clipsToBounds = NO;
    _collectionView.allowsSelection = NO;
    _collectionView.backgroundColor = RGBCOLOR(247, 247, 247);
    tableView.tableFooterView = _collectionView;
}

#pragma mark - tableView

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 30;
}

- (UIView *)tableView:(UITableView *)sender viewForFooterInSection:(NSInteger)section {
    UIImageView *clearView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, sender.width, 30)];
    clearView.backgroundColor = [UIColor clearColor];
    return clearView;
}

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"BaseHeadCell";
    BaseTableViewCell* cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
    UIButton * selectedView = VIEWWITHTAG(cell.contentView, 7);
    if (cell == nil) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        selectedView = [UIButton buttonWithType:UIButtonTypeCustom];
        [cell.contentView addSubview:selectedView];
        selectedView.tag = 7;
        [selectedView setImage:LOADIMAGECACHES(@"CellNotSelected") forState:UIControlStateNormal];
        [selectedView setImage:LOADIMAGECACHES(@"CellGraySelected") forState:UIControlStateSelected];
    }
    selectedView.indexPath = indexPath;
    cell.imageView.hidden = YES;
    selectedView.selected = (selectedView.indexPath.row == selectedIndexPath.row);
    cell.textLabel.text = contentArr[indexPath.row];
    cell.backgroundColor =
    cell.contentView.backgroundColor = sender.backgroundColor;
    [cell update:^(NSString *name) {
        cell.textLabel.frame = CGRectMake(20, 0, 40, cell.height);
        cell.topLineView.frame = CGRectMake(10, 0, cell.width, 1);
        cell.topLineView.highlightedImage =
        cell.topLineView.image = [UIImage imageWithColor:RGBCOLOR(235, 235, 235) cornerRadius:0];
        selectedView.frame = CGRectMake(cell.width - 22, (cell.height-12)/2, 12, 12);
    }];
    return cell;
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    if (selectedIndexPath.row == indexPath.row) {
        return;
    }
    _collectionView.hidden = (indexPath.row == 0);
    NSIndexPath * temp = [selectedIndexPath copy];
    selectedIndexPath = [indexPath copy];
    [tableView reloadRowsAtIndexPaths:@[temp, indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark UICollectionViewDelegateFlowLayout
- (int)numberofCollectionView {
    return 5;
}

//设置分区
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)sender{
    return 1;
}

//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)sender numberOfItemsInSection:(NSInteger)section
{
    return _selectedArray.count + 1;
}

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
    cell.imageView.hidden = NO;
    [cell enableLongPress];
    if (indexPath.row == _selectedArray.count) {
        cell.image = LOADIMAGE(@"btn_room_add");
        cell.imageView.highlightedImage = LOADIMAGE(@"btn_room_add_d");
    } else {
        NSString * url = [_selectedArray[indexPath.row] headsmall];
        [Globals imageDownload:^(UIImage *img) {
            if (!img) {
                img = [Globals getImageUserHeadDefault];
            }
            cell.image = img;
        } url:url];
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
        if (_selectedArray.count==0 || indexPath.row == _selectedArray.count) {
            SessionNewController * con = [[SessionNewController alloc] init];
            con.isShowGroup = NO;
            NSMutableArray * arr = [NSMutableArray array];
            [_selectedArray enumerateObjectsUsingBlock:^(User *obj, NSUInteger idx, BOOL *stop) {
                [arr addObject:obj.uid];
            }];
            con.sourceArr = arr;
            [con setMbsUserBlack:^(NSMutableArray * array) {
                [_selectedArray addObjectsFromArray:array];
                [self updateCollectionView];
            }];
            [self pushViewController:con];
        } else{
            User * user = _selectedArray[indexPath.row];
            UserInfoViewController *con = [[UserInfoViewController alloc] init];
            [con setUser:user];
            [self pushViewController:con];
        }
    }
}

- (void)handleTableviewCellLongPressed:(NSIndexPath*)indexPath {
    User * user = _selectedArray[indexPath.row];
    [self showAlertWithTag:[NSString stringWithFormat:@"确定要删除 %@ 吗", user.displayName] isNeedCancel:YES tag:indexPath.row];
}

- (void)kwAlertView:(KWAlertView*)sender didDismissWithButtonIndex:(NSInteger)index {
    if (index == 1) {
        [_selectedArray removeObjectAtIndex:sender.tag];
        [UIView animateWithDuration:0.2 animations:^{
            [_collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:sender.tag inSection:0]]];
        } completion:^(BOOL finished) {
            if (finished) {
                [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
            }
        }];
    }
}

@end
