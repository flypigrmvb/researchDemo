//
//  CollectionViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "CollectionViewController.h"
#import "BaseTableViewCell.h"
#import "Favorite.h"
#import "SessionCell.h"
#import "CameraActionSheet.h"
#import "Globals.h"
#import "Address.h"
#import "MapViewController.h"
#import "CollectionDetailViewController.h"
#import "ImageTouchView.h"
#import "UserCollectionViewCell.h"
#import "Message.h"
#import "TextInput.h"

@interface CollectionViewController ()<CameraActionSheetDelegate, ImageTouchViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>{
    BOOL isSearch;
    NSMutableArray * picArray;
    UICollectionView * collectionView;
}

@end

@implementation CollectionViewController

- (void)viewDidLoad {
    enablefilter = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"我的收藏";
    self.navigationItem.titleView = self.titleView;
    [self enableSlimeRefresh];
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    collectionView = [[UICollectionView alloc] initWithFrame:tableView.bounds collectionViewLayout:flowLayout];
    [self setEdgesNone];
    //注册
    [collectionView registerClass:[UserCollectionViewCell class] forCellWithReuseIdentifier:@"UserCollectionViewCell"];
    //设置代理
    collectionView.tag = 10;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.backgroundColor = [UIColor clearColor];
    [self.view insertSubview:collectionView atIndex:0];
    collectionView.scrollEnabled = NO;
    picArray = [NSMutableArray array];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (isFirstAppear) {
        [super startRequest];
        [self prepareLoadMoreWithPage:currentPage sinceID:0];
    }
    isSearch = NO;
}

- (void)individuationTitleView {
    self.addButton.tag = @"normalList";
    self.addButton.image = LOADIMAGE(@"icon_favorite_list");
    self.addButton.left = self.titleView.width - 35;
    
    self.searchButton.image = LOADIMAGE(@"btn_search");
    self.searchButton.left = self.titleView.width - 75;
    self.searchView.width = 0;
}

- (void)popViewController {
    if (self.searchView.width != 0) {
        [self imageTouchViewDidSelected:self.searchButton];
    } else {
        [super popViewController];
    }
}

- (void)prepareLoadMoreWithPage:(int)page sinceID:(int)sinceID {
    [UIView animateWithDuration:0.25 animations:^{
        self.searchButton.alpha =
        self.addButton.alpha = 0;
    }];
    isloadByslime = YES;
    [client favoriteList];
}

- (BOOL)requestDidFinish:(id)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        [UIView animateWithDuration:0.25 animations:^{
            self.searchButton.alpha =
            self.addButton.alpha = 1;
        }];
        NSArray * data = [obj getArrayForKey:@"data"];
        [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Favorite * item = [Favorite objWithJsonDic:obj];
            [contentArr addObject:item];
        }];
        [tableView reloadData];
    }
    return YES;
}

- (CGFloat)tableView:(UITableView *)sender heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Favorite * item = [inFilter?filterArr:contentArr objectAtIndex:indexPath.row];
    return [Favorite HeightOfFavorite:item];
}

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"SessionCell";
    SessionCell * cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
    UIImageView * photoView = VIEWWITHTAG(cell.contentView, 17);
    UIImageView * voiceView = VIEWWITHTAG(cell.contentView, 18);
    UIImageView * audioView = VIEWWITHTAG(voiceView, 1);
    if (!cell) {
        cell = [[SessionCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        [cell enableLongPress];
        if (!photoView) {
            photoView = [[UIImageView alloc] initWithFrame:CGRectMake(60, 26, 120, 50)];
            photoView.tag = 17;
            photoView.contentMode = UIViewContentModeScaleAspectFill;
            photoView.clipsToBounds = YES;
            [cell.contentView addSubview:photoView];
        }
        if (!voiceView) {
            voiceView = [[UIImageView alloc] initWithFrame:CGRectMake(60, 35, 60, 30)];
            voiceView.image = [LOADIMAGECACHES(@"bkg_message_msg_L") resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 4, 4)];
            
            audioView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 14, 23)];
            audioView.image = LOADIMAGECACHES(@"talk_l_voice2");
            [voiceView addSubview:audioView];
        }
        [cell.contentView insertSubview:voiceView atIndex:0];
    }
    photoView.hidden = YES;
    voiceView.hidden = YES;
    cell.superTableView = sender;
    
    Favorite * item = [inFilter?filterArr:contentArr objectAtIndex:indexPath.row];
    if (item.typefile == forFileImage||item.typefile == forFileAddress) {
        photoView.hidden = NO;
    }
    if (item.typefile == forFileVoice) {
        voiceView.hidden = NO;
        cell.detailTextLabel.text = item.voiceTime;
    } else {
        cell.detailTextLabel.text = item.content;
    }
    if (item.typefile == forFileImage) {
        photoView.size = CGSizeMake(120, 50);
    } else if (item.typefile == forFileAddress) {
        photoView.size = CGSizeMake(200, 120);
        cell.detailTextLabel.text = item.address.address;
        [cell.contentView bringSubviewToFront:photoView];
    }
    cell.textLabel.text = item.nickname;
    cell.labTime.text = [Globals timeStringForListWith:item.createtime.doubleValue];
    cell.labTime.hidden = NO;
    [cell update:^(NSString *name) {
        cell.imageView.frame = CGRectMake(10, 10, 40, 40);
        cell.textLabel.top = 10;
        cell.textLabel.height = 16;
        cell.textLabel.left = 60;
        
        photoView.top = cell.textLabel.bottom + 4;
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        if (item.typefile == forFileAddress) {
            CGSize size = [cell.detailTextLabel.text sizeWithFont:[UIFont systemFontOfSize:14] maxWidth:photoView.width maxNumberLines:2];
            photoView.size = CGSizeMake(200, 120);
            cell.detailTextLabel.text = item.address.address;
            [cell.contentView bringSubviewToFront:cell.detailTextLabel];
            cell.detailTextLabel.frame = CGRectMake(photoView.left, cell.height - size.height - 4, photoView.width, size.height);
            cell.detailTextLabel.backgroundColor = RGBACOLOR(100, 100, 100, 0.7);
            cell.detailTextLabel.textColor = [UIColor whiteColor];
        } else {
            CGSize size = [cell.detailTextLabel.text sizeWithFont:[UIFont systemFontOfSize:14] maxWidth:cell.width-70 maxNumberLines:0];
            if (item.typefile == forFileVoice) {
                CGFloat audioLength = [item.voiceTime doubleValue];
                CGFloat len = 16 + audioLength/10*18;
                CGSize audioSize = [[NSString stringWithFormat:@"%d'", (int)len] sizeWithFont:[UIFont systemFontOfSize:15] maxWidth:180 maxNumberLines:0];
                size = CGSizeMake(len + audioSize.width, 23);
                voiceView.width = size.width;
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%d'", (int)audioLength];
                cell.detailTextLabel.frame = CGRectMake(70, 40, size.width, size.height);
                audioView.left = [cell.detailTextLabel.text sizeWithFont:cell.detailTextLabel.font maxWidth:180 maxNumberLines:0].width+10;
                audioView.top = 4;
            } else {
                cell.detailTextLabel.frame = CGRectMake(cell.textLabel.left, cell.textLabel.bottom + 4, cell.width - 70, size.height);
            }
            cell.detailTextLabel.numberOfLines = 0;
            cell.detailTextLabel.textColor = [UIColor whiteColor];
            cell.detailTextLabel.textColor = RGBCOLOR(111, 111, 111);
        }
    }];
    
    cell.bottomLine = (indexPath.row == contentArr.count - 1);
    return cell;
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    Favorite * item = [inFilter?filterArr:contentArr objectAtIndex:indexPath.row];
    if (item.typefile == forFileAddress) {
        // 查看地图
        MapViewController* con = [[MapViewController alloc] init];
        con.location = kLocationMake(item.address.lat, item.address.lng);
        con.readOnly = YES;
        con.pointAnnotationTitle = item.address.address;
        Message * it = [[Message alloc] init];
        it.address = item.address;
        it.uid = [BSEngine currentUserId];
        con.value = it;
        [self pushViewController:con];
    } else {
        // 查看详情
        CollectionDetailViewController * con = [[CollectionDetailViewController alloc] init];
        con.item = item;
        [con setBlack:^(Favorite* it){
            [contentArr removeObject:it];
            [inFilter?filterTableView:tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        }];
        [self pushViewController:con];
    }

}

- (void)tableView:(UITableView *)sender willDisplayCell:(SessionCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInvocationOperation * opHeadItem = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadHeadImageWithIndexPath:) object:indexPath];
    [baseOperationQueue addOperation:opHeadItem];
    
    NSInvocationOperation * opItem = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadImageWithIndexPath:) object:indexPath];
    [baseOperationQueue addOperation:opItem];
}

- (NSString*)baseTableView:(UITableView *)sender imageURLAtIndexPath:(NSIndexPath *)indexPath {
    Favorite * item = [inFilter?filterArr:contentArr objectAtIndex:indexPath.row];
    return item.headsmall;
}

- (int)baseTableView:(UITableView *)sender imageTagAtIndexPath:(NSIndexPath*)indexPath {
    return -1;
}

- (CGFloat)baseTableView:(UITableView *)sender imageSizeAtIndexPath:(NSIndexPath*)indexPath {
    
    Favorite * item = [inFilter?filterArr:contentArr objectAtIndex:indexPath.row];
    if (item.typefile == forFileImage) {
        return 100;
    } else if (item.typefile == forFileAddress) {
        return 240;
    }
    return headImageViewSize;
}

- (void)loadImageWithIndexPath:(NSIndexPath *)indexPath {
    Favorite * item = [inFilter?filterArr:contentArr objectAtIndex:indexPath.row];
    if (item.imgUrl) {
        UIImage * img = [baseImageCaches getImageCache:[item.imgUrl md5Hex]];
        if (!img) {
            ImageProgress * progress = [[ImageProgress alloc] initWithUrl:item.imgUrl delegate:baseImageQueue];
            progress.indexPath = indexPath;
            progress.tag = 0;
            [self performSelectorOnMainThread:@selector(startLoadingWithProgress:) withObject:progress waitUntilDone:YES];
        } else {
            dispatch_async(kQueueMain, ^{
                BaseTableViewCell * cell = (BaseTableViewCell*)[inFilter?filterTableView:tableView cellForRowAtIndexPath:indexPath];
                UIImageView * photoView = VIEWWITHTAG(cell.contentView, 17);
                photoView.image = img;
            });
        }
    }
}

- (void)baseTableView:(NSInteger)tag imageUpdateAtIndexPath:(NSIndexPath*)indexPath image:(UIImage *)image idx:(NSInteger)idx {
    if (image) {
        BaseTableViewCell * cell = (BaseTableViewCell*)[inFilter?filterTableView:tableView cellForRowAtIndexPath:indexPath];
        if (tag == -1) {
            cell.imageView.image = image;
        } else {
            UIImageView * photoView = VIEWWITHTAG(cell.contentView, 17);
            photoView.image = image;
        }
    }
}

- (void)tableView:(id)sender handleTableviewCellLongPressed:(NSIndexPath*)indexPath {
    CameraActionSheet * sheet = [[CameraActionSheet alloc] initWithActionTitle:nil TextViews:nil CancelTitle:@"取消" withDelegate:self otherButtonTitles:@"删除", nil];
    sheet.idx = [NSString stringWithFormat:@"%d", (int)indexPath.row];
    [sheet show];
}

#pragma mark - CameraActionSheetDelegate

- (void)cameraActionSheet:(CameraActionSheet *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        client = [[BSClient alloc] initWithDelegate:self action:@selector(requestDiddelFinish:obj:)];
        self.loading = YES;
        client.tag = sender.idx;
        Favorite * item = [inFilter?filterArr:contentArr objectAtIndex:sender.idx.intValue];
        [client deleteFavorite:item.fid];
    }
}

- (BOOL)requestDiddelFinish:(BSClient*)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        [self showText:sender.errorMessage];
        [contentArr removeObjectAtIndex:sender.tag.intValue];
        [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:sender.tag.intValue inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
    }
    return YES;
}

- (void)imageTouchViewDidSelected:(ImageTouchView*)sender {
    if ([sender.tag isEqualToString:@"picList"] || [sender.tag isEqualToString:@"normalList"]) {
        if (self.searchView.width != 0) {
            self.searchField.text = @"";
            [self textFieldDidChange:self.searchField];
            [self.searchField resignFirstResponder];
        } else {
            // 正常情况下，切换到图片列表模式
            if ([sender.tag isEqualToString:@"normalList"]) {
                self.addButton.image = LOADIMAGE(@"icon_favorite_list_d");
                self.addButton.highlightedImage = nil;
                sender.tag = @"picList";
                [picArray removeAllObjects];
                // 加载图片
                [contentArr enumerateObjectsUsingBlock:^(Favorite * obj, NSUInteger idx, BOOL *stop) {
                    if (obj.imgUrl && obj.imgUrl.length > 0) {
                        [picArray addObject:obj];
                    }
                }];
                [UIView animateWithDuration:0.25 animations:^{
                    [collectionView reloadData];
                    self.searchButton.alpha =
                    tableView.alpha = 0;
                } completion:^(BOOL finished) {
                    self.searchButton.hidden =
                    tableView.hidden = YES;
                }];
            } else {
                // 返回正常模式
                self.addButton.image = LOADIMAGE(@"icon_favorite_list");
                self.addButton.highlightedImage = nil;
                self.searchButton.hidden =
                tableView.hidden = NO;
                sender.tag = @"normalList";
                [UIView animateWithDuration:0.25 animations:^{
                    self.searchButton.alpha =
                    tableView.alpha = 1;
                }];
            }
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
                    if (finished) {
                        [self.searchField becomeFirstResponder];
                    }
                }];
                
            }];
        } else {
            sender.tag = @"none";
            self.searchField.text = @"";
            [self textFieldDidChange:self.searchField];
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
                        self.addButton.image = LOADIMAGE(@"icon_favorite_list");
                        self.addButton.highlightedImage = nil;
                    } completion:^(BOOL finished) {
                        if (finished) {
                            [self.searchField resignFirstResponder];
                        }
                    }];
                }
            }];
        }
        
    }
}

#pragma mark - filter

- (void)filterContentForSearchText:(NSString*)searchText
                             scope:(NSString*)scope {
    for (Favorite *it in contentArr) {
        if ([it.content rangeOfString:searchText].location <= it.content.length) {
            [filterArr addObject:it];
        }
    }
}

#pragma mark - collectionView delegate
//设置分区
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)sender{
    return 1;
}

//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)sender numberOfItemsInSection:(NSInteger)section
{
    return picArray.count;
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)sender layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(95,95);
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
    cell.imageView.frame = CGRectMake(0, 0, 90, 85);
    Favorite * zan = picArray[indexPath.row];
    [Globals imageDownload:^(UIImage *img) {
        cell.image = img;
    } url:zan.imgUrl];
    cell.contentView.height = cell.height;
    return cell;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10,10,0,5);
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)sender shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)sender didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    Favorite * item = picArray[indexPath.row];
    if (item.typefile == forFileAddress) {
        // 查看地图
        MapViewController* con = [[MapViewController alloc] init];
        con.location = kLocationMake(item.address.lat, item.address.lng);
        con.readOnly = YES;
        con.pointAnnotationTitle = item.address.address;
        Message * it = [[Message alloc] init];
        it.uid = [BSEngine currentUserId];
        it.address = item.address;
        con.value = it;
        [self pushViewController:con];
    } else {
        CollectionDetailViewController * con = [[CollectionDetailViewController alloc] init];
        con.item = item;
        [con setBlack:^(Favorite* it){
            [picArray removeObject:it];
            [collectionView deleteItemsAtIndexPaths:@[indexPath]];
            [contentArr enumerateObjectsUsingBlock:^(Favorite * obj, NSUInteger idx, BOOL *stop) {
                if ([obj.fid isEqualToString:it.fid]) {
                    [contentArr removeObject:obj];
                    [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
                    *stop = YES;
                }
            }];
        }];
        [self pushViewController:con];
    }
}

@end
