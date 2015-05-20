//
//  ShareDetailController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "ShareDetailController.h"
#import "CircleMessage.h"
#import "CircleMessageCell.h"
#import "EmotionInputView.h"
#import "Declare.h"
#import "Notify.h"
#import "ShareCommentView.h"
#import "SharePicture.h"
#import "Globals.h"
#import "UIImage+FlatUI.h"
#import "UserCollectionViewCell.h"
#import "ImagePhotoViewController.h"
#import "BasicNavigationController.h"
#import "KWAlertView.h"

@interface ShareDetailController () <UICollectionViewDataSource, UICollectionViewDelegate> {
    IBOutlet UITextField * textField;
    EmotionInputView    * emojiView;
    IBOutlet UIView      * actionBar;
    IBOutlet UIButton    * zanbtn;
    IBOutlet UIButton    * commentSendbtn;
    IBOutlet UIView      * btnsView; // 赞和评论
    CommentType cType;
    NSMutableArray * replylist;
    NSMutableArray * praiselist;
}
@property (nonatomic, strong) CircleMessage * item;
@property (nonatomic, strong) UITapGestureRecognizer* tapGesture;
@end

@implementation ShareDetailController

- (id)initWithShare:(CircleMessage *)itemS {
    if (self = [super init]) {
        self.item = itemS;
        replylist = [NSMutableArray array];
        praiselist = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"详情";
    [self setEdgesNone];
    [actionBar removeFromSuperview];
    [self.view addSubview:actionBar];
    textField.layer.masksToBounds = YES;
    textField.layer.cornerRadius = 2;
    textField.layer.borderColor = RGBCOLOR(220, 220, 220).CGColor;
    textField.layer.borderWidth = 1;
    textField.backgroundColor = [UIColor whiteColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedFriendCircle:) name:@"receivedFriendCircle" object:nil];
    [commentSendbtn navBlackStyle];
    commentSendbtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [commentSendbtn setTitle:@"发送" forState:UIControlStateNormal];
    [commentSendbtn addTarget:self action:@selector(sendCommentMessage:) forControlEvents:UIControlEventTouchUpInside];
    tableView.height -= actionBar.height;
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                              action:@selector(didTap:)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (isFirstAppear) {
        cType = forGetCommentList;
        [self startRequest];
        [client getShareDetail:_item.fid];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    __block ShareDetailController * blockd = self;
    actionBar.width = tableView.width;
    [blockd.view addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView, BOOL opening, BOOL closing) {
        actionBar.top = keyboardFrameInView.origin.y - actionBar.height;
        if (opening) {
            tableView.userInteractionEnabled = NO;
        }
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    [super scrollViewDidScroll:sender];
    [self.view removeGestureRecognizer:self.tapGesture];
    if (btnsView.left!= tableView.width) {
        [UIView animateWithDuration:0.25 animations:^{
            btnsView.left = tableView.width;
        } completion:^(BOOL finished) {
            if (finished) {
                [btnsView removeFromSuperview];
                btnsView.hidden = YES;
            }
        }];
    }
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return contentArr.count;
    } else if (section == 1) {
        return praiselist.count>0?1:0;
    } else {
        return replylist.count;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)sender heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [CircleMessageCell getHeightWithItem:[contentArr objectAtIndex:indexPath.row]];
    } else if (indexPath.section == 1) {
        if (praiselist.count >0) {
            CGFloat number = (CGFloat)praiselist.count/4;
            if (number!= ceil(6/4)){
                number = (int)number + 1;
            }
            return number*66+16;
        }
    } else if (indexPath.section == 2) {
        CGFloat height = 5+15+8+5;
        CircleComment * msg = [replylist objectAtIndex:indexPath.row];
        CGSize size = [msg.content sizeWithFont:[UIFont systemFontOfSize:13] maxWidth:sender.width-145 maxNumberLines:0];
        height += size.height;
        if (praiselist.count == 0 && indexPath.row == 0) {
            height += 12;
        }
        return height <50?50:height;
    }
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        // 微博详情
        static NSString * CellIdentifier = @"CircleMessageCell";
        if (!fileNib) {
            fileNib = [UINib nibWithNibName:@"CircleMessageCell" bundle:nil];
            [sender registerNib:fileNib forCellReuseIdentifier:CellIdentifier];
        }
        CircleMessageCell * cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        CircleMessage * item = [contentArr objectAtIndex:indexPath.row];
        cell.superTableView = sender;
        
        [cell setGridViewnumbers:item.picsArray.count];
        [cell setItem:item];
        cell.topLine = NO;
        return cell;
    } else if (indexPath.section == 1) {
        // 赞
        static NSString * CellIdentifier = @"CollectionView";
        BaseTableViewCell * cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
        UIImageView * _backgroundView = VIEWWITHTAG(cell.contentView, 18);
        UICollectionView * collectionView = VIEWWITHTAG(_backgroundView, 10);
        UIImageView * imageComment = VIEWWITHTAG(_backgroundView, 9);
        if (collectionView) {
            [collectionView reloadData];
        }
        if (!cell) {
            cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            _backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, cell.width- 20, cell.height)];
            _backgroundView.tag = 18;
            _backgroundView.image = [LOADIMAGECACHES(@"bkg_coment") resizableImageWithCapInsets:UIEdgeInsetsMake(12, 26, 4, 4)];
            _backgroundView.userInteractionEnabled = YES;
            _backgroundView.clipsToBounds = YES;
            [cell.contentView addSubview:_backgroundView];
            
            imageComment = [[UIImageView alloc] initWithFrame:CGRectMake(10, 20, 13, 14)];
            imageComment.tag = 9;
            imageComment.image = LOADIMAGECACHES(@"icon_zan_s");
            [_backgroundView addSubview:imageComment];
            cell.imageView.hidden = YES;
            if (!collectionView) {
                UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
                [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
                collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(20, 4, _backgroundView.width-20, _backgroundView.height-4) collectionViewLayout:flowLayout];
                //注册
                [collectionView registerClass:[UserCollectionViewCell class] forCellWithReuseIdentifier:@"UserCollectionViewCell"];
                //设置代理
                collectionView.tag = 10;
                collectionView.delegate = self;
                collectionView.dataSource = self;
                collectionView.backgroundColor = [UIColor clearColor];
                [_backgroundView addSubview:collectionView];
                collectionView.scrollEnabled = NO;
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.topLine = NO;
        }
        
        cell.contentView.clipsToBounds = (indexPath.row != 0);
        [cell update:^(NSString *name) {
            cell.imageView.frame = CGRectMake(5, 0, 13, 14);
            collectionView.top = 8;
            collectionView.height = cell.height - 12;
            _backgroundView.height = cell.height;
        }];
        return cell;
    } else if (indexPath.section == 2) {
        // 评论
        static NSString * CellIdentifier = @"BaseTableViewCell";
        BaseTableViewCell * cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
        UIImageView * _backgroundView = VIEWWITHTAG(cell.contentView, 17);
        UILabel * timeLab = VIEWWITHTAG(_backgroundView, 21);
        UIImageView * imageComment = VIEWWITHTAG(_backgroundView, 22);
        if (!cell) {
            cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            _backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, cell.width - 20, cell.height)];
            _backgroundView.tag = 17;
            _backgroundView.userInteractionEnabled = YES;
            _backgroundView.clipsToBounds = YES;
            [cell.contentView insertSubview:_backgroundView atIndex:0];
            
            timeLab = [[UILabel alloc] initWithFrame:CGRectMake(_backgroundView.width - 95, 10, 90, 14)];
            timeLab.textColor = [UIColor grayColor];
            timeLab.tag = 21;
            timeLab.font = [UIFont systemFontOfSize:12];
            timeLab.highlightedTextColor = [UIColor whiteColor];
            timeLab.backgroundColor = [UIColor clearColor];
            
            imageComment = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 13, 14)];
            imageComment.tag = 22;
            imageComment.image = LOADIMAGECACHES(@"icon_comment_d");
            [_backgroundView addSubview:imageComment];
            
            [_backgroundView insertSubview:timeLab atIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.clipsToBounds = YES;
            cell.contentView.clipsToBounds = YES;
        }
        
        imageComment.hidden = (indexPath.row != 0);
        if (praiselist.count == 0) {
            if (indexPath.row == 0) {
                _backgroundView.image = [LOADIMAGECACHES(@"bkg_coment") resizableImageWithCapInsets:UIEdgeInsetsMake(12, 26, 10, 4)];
                
                imageComment.top = 16;
            } else {
                _backgroundView.image = [UIImage imageWithColor:RGBCOLOR(233, 233, 233) cornerRadius:0];
                
                imageComment.top = 10;
            }
        } else {
            _backgroundView.image = [UIImage imageWithColor:RGBCOLOR(233, 233, 233) cornerRadius:0];
        }
        CircleComment * item = [replylist objectAtIndex:indexPath.row];
        cell.textLabel.text = item.nickname;
        cell.detailTextLabel.text = item.content;
        
        cell.topLine = NO;
        [cell update:^(NSString *name) {
            cell.textLabel.textColor = RGBCOLOR(31, 47, 88);
            if (praiselist.count == 0) {
                if (indexPath.row == 0) {
                    cell.imageView.top =
                    cell.textLabel.top = 13;
                } else {
                    cell.imageView.top =
                    cell.textLabel.top = 5;
                }
            } else {
                cell.imageView.top =
                cell.textLabel.top = 5;
            }
            
            _backgroundView.height = cell.height+10;
            timeLab.top = cell.textLabel.top;
            
            cell.imageView.left = 40;
            
            cell.textLabel.left = cell.detailTextLabel.left = cell.imageView.right + 10;
            CGSize size = [item.content sizeWithFont:[UIFont systemFontOfSize:13] maxWidth:sender.width-125 maxNumberLines:0];
            cell.detailTextLabel.size = size;
            cell.textLabel.height = 15;
            cell.detailTextLabel.top = cell.textLabel.bottom + 8;
            cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
            cell.textLabel.width = cell.width - cell.imageView.right - 10 - 100;
            timeLab.text = [Globals timeStringForListWith:item.createtime.doubleValue];
            
           
        }];
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)sender willDisplayCell:(CircleMessageCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.imageView.image = [Globals getImageUserHeadDefault];
    NSInvocationOperation * opHeadItem = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadHeadImageWithIndexPath:) object:indexPath];
    [baseOperationQueue addOperation:opHeadItem];
    
    NSInvocationOperation * opItem = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadImageWithIndexPath:) object:indexPath];
    [baseOperationQueue addOperation:opItem];
}

- (void)tableView:(id)sender didTapHeaderAtIndexPath:(NSIndexPath*)indexPath {
    CircleMessage * item = contentArr[indexPath.row];
    [self getUserByName:item.uid];
}

- (void)loadImageWithIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        CircleMessage * circleMessage = [contentArr objectAtIndex:indexPath.row];
        [circleMessage.picsArray enumerateObjectsUsingBlock:^(SharePicture *pic, NSUInteger idx, BOOL *stop) {
            NSString * url = pic.smallUrl;
            UIImage * img = [baseImageCaches getImageCache:[url md5Hex]];
            if (!img) {
                ImageProgress * progress = [[ImageProgress alloc] initWithUrl:url delegate:baseImageQueue];
                progress.indexPath = indexPath;
                progress.tag = 0;
                progress.idx = idx;
                [self performSelectorOnMainThread:@selector(startLoadingWithProgress:) withObject:progress waitUntilDone:YES];
            } else {
                dispatch_async(kQueueMain, ^{
                    CircleMessageCell * cell = (CircleMessageCell*)[tableView cellForRowAtIndexPath:indexPath];
                    [cell setImage:img atIndex:idx];
                });
            }
        }];
    }
}

- (void)baseTableView:(NSInteger)tag imageUpdateAtIndexPath:(NSIndexPath*)indexPath image:(UIImage *)image idx:(NSInteger)idx {
    if (indexPath.section == 0) {
        CircleMessageCell * cell = (CircleMessageCell*)[tableView cellForRowAtIndexPath:indexPath];
        if (image) {
            if (tag == -1) {
                cell.imageView.image = image;
            } else {
                [cell setImage:image atIndex:idx];
            }
        }
    } else if (indexPath.section == 2) {
        CircleMessageCell * cell = (CircleMessageCell*)[tableView cellForRowAtIndexPath:indexPath];
        cell.imageView.image = image;
    }
}

- (void)kwAlertView:(KWAlertView * )sender didDismissWithButtonIndex:(NSInteger)index {
    if (index == 1) {
        CircleMessage * item = [contentArr objectAtIndex:sender.indexPath.row];
        if (client) {
            return ;
        }
        [self setLoading:YES content:@"删除分享真的有必要吗亲..."];
        client = [[BSClient alloc] initWithDelegate:self action:@selector(requestDeleteDidFinish:obj:)];
        client.indexPath = sender.indexPath;
        [client deleteShare:item.fid];
    }
}

#pragma mark - didTapButtonAtIndexPath
- (void)tableView:(UIButton*)sender didTapButtonAtIndexPath:(NSIndexPath*)idx {
    if (sender.tag == 2) {
        // 删除自己
        KWAlertView * kw = [[KWAlertView alloc] initWithTitle:nil message:@"确定删除吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitle:@"确定"];
        kw.indexPath = idx;
        [kw show];
    } else {
        [self.view addGestureRecognizer:self.tapGesture];
        btnsView.hidden = !btnsView.hidden;
        if (btnsView.alpha != 0) {
            [btnsView removeFromSuperview];
        }
        CircleMessageCell * cell = (CircleMessageCell*) [tableView cellForRowAtIndexPath:idx];
        zanbtn.selected = cell.item.ispraise;
        CGRect ceframe = [cell convertRect:sender.frame toView:tableView];
        btnsView.top = ceframe.origin.y - 4;
        btnsView.left = ceframe.origin.x;
        [tableView addSubview:btnsView];
        btnsView.alpha = 0;
        [UIView animateWithDuration:0.25 animations:^{
            btnsView.left -= btnsView.width - 8;
            btnsView.alpha = 1;
        }];
    }
}

- (void)tableViewDidTapImageAtIndexPath:(NSIndexPath*)indexPath tag:(NSString*)tag {
    // 查看大图
    CircleMessage * item = [contentArr objectAtIndex:indexPath.row];
    CircleMessageCell * cell = (CircleMessageCell*)[tableView cellForRowAtIndexPath:indexPath];
    ImagePhotoViewController * con = [[ImagePhotoViewController alloc] initWithPicArray:item.picsArray defaultIndex:tag.intValue];
    [con showInCell:cell];
}

- (NSString*)baseTableView:(UITableView *)sender imageURLAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        CircleMessage * item = [contentArr objectAtIndex:indexPath.row];
        return item.imgHeadUrl;
    } else if (indexPath.section == 1) {
        if (praiselist.count>0) {
            CircleZan * item = [praiselist objectAtIndex:indexPath.row];
            return item.headsmall;
        }
        return nil;
    } else {
        if (replylist.count>0) {
            CircleComment * item = [replylist objectAtIndex:indexPath.row];
            return item.headsmall;
        }
        return nil;
    }
}

- (CGFloat)baseTableView:(UITableView *)sender imageSizeAtIndexPath:(NSIndexPath*)indexPath {
    return 160;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    tableView.userInteractionEnabled = YES;
    [textField resignFirstResponder];
}

#pragma mark - btnsView Methods
- (IBAction)btnCommentPressed:(UIButton*)sender {
    [self.view removeGestureRecognizer:self.tapGesture];
    [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    [UIView animateWithDuration:0.25 animations:^{
        btnsView.left += btnsView.width - 8;
        btnsView.alpha = 0;
    } completion:^(BOOL finished) {
        [btnsView removeFromSuperview];
        [textField becomeFirstResponder];
    }];
}

- (IBAction)btnZanPressed:(UIButton *)sender idx:(NSIndexPath *)idx {
    [self.view removeGestureRecognizer:self.tapGesture];
    [UIView animateWithDuration:0.25 animations:^{
        btnsView.left += btnsView.width - 8;
        btnsView.alpha = 0;
    } completion:^(BOOL finished) {
        [btnsView removeFromSuperview];
        cType = forSendZan;
        [self sendRequest];
    }];
}

// 切换表情
- (IBAction)ShowEmotionKeyboard:(UIButton*)sender {
    sender.selected = !sender.selected;
    if (emojiView == nil) {
        tableView.userInteractionEnabled = NO;
        emojiView = [[EmotionInputView alloc] initWithOrigin:CGPointMake(10, tableView.height - 216) del:self];
    }
    [UIView animateWithDuration:0.25 animations:^{
        UIView*view = textField.inputView;
        if (!view) {
            [textField setInputView:emojiView];
        } else {
            [emojiView removeFromSuperview];
            tableView.userInteractionEnabled = YES;
            [textField setInputView:nil];
        }
        [textField resignFirstResponder];
        [textField becomeFirstResponder];
    }];
}

// 发送评论
- (IBAction)sendCommentMessage:(UIButton*)btn {
    if (textField.text.length == 0 || ![textField.text isKindOfClass:[NSString class]]) {
        return;
    }
    [textField resignFirstResponder];
    cType = forSendComment;
    [self sendRequest];
}

#pragma mark - Request
- (void)sendRequest {
    [super startRequest];
    if (cType == forGetCommentList) {
        [client shareList:currentPage];
    } else if (cType == forSendComment) {
        CircleMessage * item = [contentArr objectAtIndex:0];
        [client shareReply:item.fid fuid:item.uid content:textField.text];
        client.indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    } else if (cType == forSendZan) {
        CircleMessage *item = [contentArr objectAtIndex:0];
        [client addZan:item.fid];
        client.indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
}

- (BOOL)requestDidFinish:(BSClient*)sender obj:(NSDictionary *)obj
{
    if ([super requestDidFinish:sender obj:obj]) {
        if (cType == forGetCommentList) {
            NSDictionary * dic = [obj getDictionaryForKey:@"data"];
            CircleMessage * it = [CircleMessage objWithJsonDic:dic];
            [contentArr addObject:it];
            NSDictionary * commentdic = [dic getDictionaryForKey:@"data"];
            NSArray * list = [commentdic getArrayForKey:@"praiselist"];
            [list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                CircleZan * zan = [CircleZan objWithJsonDic:obj];
                [praiselist insertObject:zan atIndex:0];
            }];
            list = [commentdic getArrayForKey:@"replylist"];
            [list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                CircleComment * comment = [CircleComment objWithJsonDic:obj];
                [replylist insertObject:comment atIndex:0];
            }];
            [tableView reloadData];
        } else {
            if (cType == forSendZan) {
                CircleMessageCell * cell = (CircleMessageCell*) [tableView cellForRowAtIndexPath:sender.indexPath];
                cell.item.ispraise = !cell.item.ispraise;
            } else if (cType == forSendComment) {
                textField.text = @"";
            }
            [self showTipText:sender.errorMessage top:YES];
        }
    }
    return YES;
}

- (BOOL)requestDeleteDidFinish:(BSClient*)sender obj:(NSDictionary *)obj {
    [textField resignFirstResponder];
    if ([super requestDidFinish:sender obj:obj]) {
        [self showTipText:sender.errorMessage top:YES];
        CircleMessage * item = contentArr[0];
        [Notify deleteFromDBWithShareID:item.fid];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshFriendCircle" object:nil];
        if (item.picsArray.count > 0) {
            [self.navigationController popToViewController:self.navigationController.viewControllers[2] animated:YES];
        } else {
            [self popViewController];
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
    return praiselist.count;
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)sender layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(50,50);
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
    
    cell.imageView.frame = CGRectMake(0, 0, 40, 40);
    CircleZan * zan = praiselist[indexPath.row];
    [Globals imageDownload:^(UIImage *img) {
        cell.image = img;
    } url:zan.headsmall];
    cell.contentView.height = cell.height;
    return cell;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10,10,10,10);
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)sender shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)sender didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CircleZan * zan = praiselist[indexPath.row];
    [self getUserByName:zan.uid];
}

#pragma mark - 赞或评论的通知
- (void)receivedFriendCircle:(NSNotification*)sender {
    Notify * ntf = sender.object;
    CircleMessage * obj = [contentArr objectAtIndex:0];
    if ([obj.fid isEqualToString:ntf.shareID]) {
        if (ntf.type == forNotifyComment) {
            CircleComment * comment = [[CircleComment alloc] init];
            comment.nickname = ntf.user.nickname;
            comment.uid = ntf.user.uid;
            comment.content = ntf.content;
            comment.headsmall = ntf.user.headsmall;
            comment.createtime = ntf.time;
            [replylist addObject:comment];
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
        } else if (ntf.type == forNotifyZan) {
            CircleZan *circleZan = [[CircleZan alloc] init];
            circleZan.nickname = ntf.user.nickname;
            circleZan.uid = ntf.user.uid;
            circleZan.headsmall = ntf.user.headsmall;
            [praiselist addObject:circleZan];
            if (praiselist.count == 1) {
                [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationTop];
                [tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
            } else {
                [tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
            }
        } else if (ntf.type == forNotifyCancelZan) {
            [praiselist enumerateObjectsUsingBlock:^(CircleZan * zan, NSUInteger idx, BOOL *stop) {
                if ([zan.uid isEqualToString:ntf.user.uid]) {
                    [praiselist removeObject:zan];
                    *stop= YES;
                }
            }];
            if (praiselist.count == 0) {
                [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationTop];
                [tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
            } else {
                [tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
            }
            
        }
    }
}

#pragma mark - EmotionInputViewDelegate

- (void)emotionInputView:(id)sender output:(NSString*)str {
    if ([textField.text isKindOfClass:[NSString class]] && textField.text.length > 0) {
        textField.text = [NSString stringWithFormat:@"%@%@", textField.text, [EmotionInputView emojiText4To5:str]];
    } else {
        textField.text = [EmotionInputView emojiText4To5:str];
    }
}

#pragma mark - UIGestureRecognizer implementations
- (void)didTap:(UITapGestureRecognizer*) gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.25 animations:^{
            btnsView.left = tableView.width;
        } completion:^(BOOL finished) {
            if (finished) {
                [btnsView removeFromSuperview];
                btnsView.hidden = YES;
                [self.view removeGestureRecognizer:self.tapGesture];
            }
        }];
    }
}
@end
