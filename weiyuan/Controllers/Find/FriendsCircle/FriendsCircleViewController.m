//
//  FriendsCircleViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "FriendsCircleViewController.h"
#import "Globals.h"
#import "CircleMessage.h"
#import "CircleMessageCell.h"
#import "EmotionInputView.h"
#import "ImageGridView.h"
#import "ImagePhotoViewController.h"
#import "CameraActionSheet.h"
#import "PhotoSeeViewController.h"
#import "UIImageView+WebCache.h"
#import "FriendPhotosViewController.h"
#import "TextInput.h"
#import "TextSeeViewController.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Resize.h"
#import "SharePicture.h"
#import "Notify.h"
#import "JSON.h"
#import "KWAlertView.h"
#import "VPImageCropperViewController.h"

@interface FriendsCircleViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, CameraActionSheetDelegate, ImageGridViewDelegate> {
    IBOutlet UIImageView * headfaceView;    // 头像图片
    IBOutlet UIImageView * faceOfPhoto;     // 相册封面
    IBOutlet UIView      * actionBar;
    IBOutlet UILabel     * nameLabel;
    IBOutlet UIButton    * facePhotobtn;
    IBOutlet UIButton    * zanbtn;
    IBOutlet UIButton    * commentSendbtn;
    IBOutlet UIView      * btnsView;        // 赞和评论
    IBOutlet UITextField * textField;
    NSInteger            selectedRow;
    EmotionInputView     * emojiView;
    CommentType          cType;
}
@property (nonatomic, strong) UITapGestureRecognizer* tapGesture;

@end

@implementation FriendsCircleViewController

- (id)init {
    if (self = [super initWithNibName:@"FriendsCircleViewController" bundle:nil]) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"朋友圈";
    headfaceView.layer.masksToBounds = YES;
    headfaceView.layer.cornerRadius = 10;
    [self enableSlimeRefresh];
    [self setEdgesNone];
    facePhotobtn.titleLabel.font = 
    textField.font =
    nameLabel.font = [UIFont systemFontOfSize:19];
    btnsView.layer.masksToBounds = YES;
    btnsView.layer.cornerRadius = 2;
    
    textField.layer.masksToBounds = YES;
    textField.layer.cornerRadius = 2;
    textField.layer.borderColor = RGBCOLOR(220, 220, 220).CGColor;
    textField.layer.borderWidth = 1;
    textField.backgroundColor = [UIColor whiteColor];
    [commentSendbtn navBlackStyle];
    commentSendbtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [commentSendbtn setTitle:@"发送" forState:UIControlStateNormal];
    [commentSendbtn addTarget:self action:@selector(sendCommentMessage:) forControlEvents:UIControlEventTouchUpInside];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedFriendCircle:) name:@"receivedFriendCircle" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFriendCircle) name:@"refreshFriendCircle" object:nil];
    [self setRightBarButton:@"分享" selector:@selector(newShare)];
    tableView.backgroundColor = [UIColor whiteColor];
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                              action:@selector(didTap:)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (isFirstAppear) {
        actionBar.left = tableView.width;
        actionBar.top = tableView.height;
        actionBar.width = tableView.width;
    }
    __block FriendsCircleViewController*blockd = self;
    [blockd.view addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView, BOOL opening, BOOL closing) {
        CGRect toolBarFrame = actionBar.frame;
        toolBarFrame.origin.y = keyboardFrameInView.origin.y - toolBarFrame.size.height;
        actionBar.frame = toolBarFrame;
        if (closing) {
            actionBar.hidden = YES;
            actionBar.left = tableView.width;
            tableView.userInteractionEnabled = YES;
        }
        if (opening) {
            actionBar.hidden = NO;
            actionBar.left = 0;
            tableView.userInteractionEnabled = NO;
        }
    }];
    
    // 更新封面
    User *user = [[BSEngine currentEngine] user];
    NSString *face = user.cover;
    if (face && face.length > 0) {
        [facePhotobtn setTitle:@"" forState:UIControlStateNormal];
    }
    [faceOfPhoto sd_setImageWithUrlString:user.cover placeholderImage:[UIImage imageNamed:@"默认背景"]];
    
    nameLabel.text = user.nickname;
    // 更新头像
    [headfaceView sd_setImageWithUrlString:user.headsmall placeholderImage:[Globals getImageUserHeadDefault]];
    if (isFirstAppear) {
        cType = forGetCommentList;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (isFirstAppear) {
        cType = forGetCommentList;
        [self sendRequest];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"resetFriendCircle" object:nil];
    }
}

- (void)refreshFriendCircle{
    if (client) {
        return;
    }
    isloadByslime = YES;
    currentPage = 1;
    cType = forGetCommentList;
    [self sendRequest];
}

- (void)newShare {
    PhotoSeeViewController * con = [[PhotoSeeViewController alloc] init];
    [self pushViewController:con];
}

- (void)prepareLoadMoreWithPage:(int)page sinceID:(int)sinceID {
    cType = forGetCommentList;
    if (isloadByslime) {
        [self setLoading:YES content:@"正在重新获取朋友圈..."];
    } else {
        [self setLoading:YES content:@"正在获取更多的朋友分享"];
    }
    [client shareList:page];
}

- (IBAction)headImageDidSelected:(UIButton*)sender {
    User *user = [[BSEngine currentEngine] user];
    FriendPhotosViewController *con = [[FriendPhotosViewController alloc] initWithUser:user];
    [self pushViewController:con];
}

// tag = 0 随手拍
// tag = 1 封面
- (IBAction)CameraPressed:(UIButton*)sender {
    CameraActionSheet *actionSheet = [[CameraActionSheet alloc] initWithActionTitle:nil TextViews:nil CancelTitle:@"取消" withDelegate:self otherButtonTitles:@"从相册选择",  @"拍一张", nil];
    actionSheet.tag = -1;
    [actionSheet show];
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)sender heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [CircleMessageCell getHeightWithItem:[contentArr objectAtIndex:indexPath.row]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 64;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
}

#pragma mark - UITableViewDelegate

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"CircleMessageCell";
    if (!fileNib) {
        fileNib = [UINib nibWithNibName:@"CircleMessageCell" bundle:nil];
        [sender registerNib:fileNib forCellReuseIdentifier:CellIdentifier];
    }
    if (!btnsView.hidden) {
        [btnsView removeFromSuperview];
        btnsView.hidden = YES;
    }
    
    CircleMessageCell * cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    CircleMessage * item = [contentArr objectAtIndex:indexPath.row];
    cell.superTableView = sender;
    cell.topLine = (indexPath.row != 0);
    [cell setGridViewnumbers:item.picsArray.count];
    [cell setItem:item];
    return cell;
}

- (void)tableView:(UITableView *)sender willDisplayCell:(CircleMessageCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.imageView.image = [Globals getImageUserHeadDefault];
    NSInvocationOperation * opHeadItem = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadHeadImageWithIndexPath:) object:indexPath];
    [baseOperationQueue addOperation:opHeadItem];
    
    NSInvocationOperation * opItem = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadImageWithIndexPath:) object:indexPath];
    [baseOperationQueue addOperation:opItem];
}

- (int)baseTableView:(UITableView *)sender imageTagAtIndexPath:(NSIndexPath*)indexPath {
    return -1;
}

- (void)loadImageWithIndexPath:(NSIndexPath *)indexPath {
    CircleMessage * circleMessage = [contentArr objectAtIndex:indexPath.row];
    [circleMessage.picsArray enumerateObjectsUsingBlock:^(SharePicture * pic, NSUInteger idx, BOOL *stop) {
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

- (void)baseTableView:(NSInteger)tag imageUpdateAtIndexPath:(NSIndexPath*)indexPath image:(UIImage *)image idx:(NSInteger)idx {
    if (image) {
        CircleMessageCell * cell = (CircleMessageCell*)[tableView cellForRowAtIndexPath:indexPath];
        if (tag == -1) {
            cell.imageView.image = image;
        } else {
            [cell setImage:image atIndex:idx];
        }
    }
}

- (NSString*)baseTableView:(UITableView *)sender imageURLAtIndexPath:(NSIndexPath*)indexPath {
    CircleMessage * item = [contentArr objectAtIndex:indexPath.row];
    return item.imgHeadUrl;
}

- (CGFloat)baseTableView:(UITableView *)sender imageSizeAtIndexPath:(NSIndexPath*)indexPath {
    return 160;
}

- (void)tableView:(id)sender didTapHeaderAtIndexPath:(NSIndexPath *)indexPath {
    CircleMessage * item = [contentArr objectAtIndex:indexPath.row];
    [self getUserByName:item.uid];
}

- (BOOL)requestUserByNameDidFinish:(id)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        NSDictionary *dic = [obj getDictionaryForKey:@"data"];
        if (dic.count > 0) {
            User *user = [User objWithJsonDic:dic];
            [user insertDB];
            
            FriendPhotosViewController *con = [[FriendPhotosViewController alloc] initWithUser:user];
            [self pushViewController:con];
        }
    }
    return YES;
}

- (void)tableViewDidTapImageAtIndexPath:(NSIndexPath*)indexPath tag:(NSString*)tag {
    // 查看大图
    CircleMessage * item = [contentArr objectAtIndex:indexPath.row];
    CircleMessageCell * cell = (CircleMessageCell*)[tableView cellForRowAtIndexPath:indexPath];
    ImagePhotoViewController * con = [[ImagePhotoViewController alloc] initWithPicArray:item.picsArray defaultIndex:tag.intValue];
    [con showInCell:cell];
}

- (void)tableViewDidLongPressedImageAtIndexPath:(NSIndexPath*)indexPath tag:(NSString*)tag {
    CameraActionSheet * sheet = [[CameraActionSheet alloc] initWithActionTitle:nil TextViews:nil CancelTitle:@"取消" withDelegate:self otherButtonTitles:@"收藏", nil];
    sheet.tag = tag?tag.intValue:999;
    sheet.indexPath = indexPath;
    [sheet show];
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
        // 显示评论按钮
        btnsView.hidden = !btnsView.hidden;
        selectedRow = idx.row;
        if (btnsView.alpha != 0) {
            [btnsView removeFromSuperview];
        }
        CircleMessageCell * cell = (CircleMessageCell*) [tableView cellForRowAtIndexPath:idx];
        
        zanbtn.selected = cell.item.ispraise;
        CGRect cellF = [cell convertRect:sender.frame toView:tableView];
        btnsView.top = cellF.origin.y - 4;
        btnsView.left = cellF.origin.x;
        [tableView addSubview:btnsView];
        btnsView.alpha = 0;
        [UIView animateWithDuration:0.25 animations:^{
            btnsView.left -= btnsView.width - 8;
            btnsView.alpha = 1;
        }];
        selectedRow = idx.row;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    tableView.userInteractionEnabled = YES;
    [textField resignFirstResponder];
}

#pragma mark - btnsView Methods
- (IBAction)btnCommentPressed:(UIButton*)sender {
    [self.view removeGestureRecognizer:self.tapGesture];
    [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    [UIView animateWithDuration:0.25 animations:^{
        btnsView.left += btnsView.width - 8;
        btnsView.alpha = 0;
    } completion:^(BOOL finished) {
        [btnsView removeFromSuperview];
        [textField becomeFirstResponder];
        tableView.userInteractionEnabled = NO;
    }];
}

- (IBAction)btnZanPressed:(UIButton *)sender idx:(NSIndexPath *)idx {
    [self.view removeGestureRecognizer:self.tapGesture];
    [UIView animateWithDuration:0.25 animations:^{
        btnsView.left += btnsView.width - 8;
        btnsView.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [btnsView removeFromSuperview];
            btnsView.hidden = YES;
            cType = forSendZan;
            [self sendRequest];
        }
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
    cType = forSendComment;
    [self sendRequest];
}

#pragma mark - CameraActionSheetDelegate
- (void)cameraActionSheet:(CameraActionSheet *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (sender.tag >= 0) {
        // 999 为长按文字
        if (buttonIndex == 0) {
            [super startRequest];
            NSMutableDictionary * dic = [NSMutableDictionary dictionary];
            CircleMessage * msg = [contentArr objectAtIndex:sender.indexPath.row];
            if (sender.tag == 999) {
                [dic setObject:msg.content forKey:@"content"];
                [dic setObject:[NSString stringWithFormat:@"%d", forFileText]  forKey:@"typefile"];
            } else {
                SharePicture * itemp = msg.picsArray[sender.tag];
                [dic setObject:itemp.originUrl forKey:@"urllarge"];
                [dic setObject:itemp.smallUrl forKey:@"urlsmall"];
                [dic setObject:[NSString stringWithFormat:@"%d", forFileImage]  forKey:@"typefile"];
            }
            cType = forAddFav;
            [client addfavorite:msg.uid otherid:nil content:[dic JSONString]];
        }
    } else {
        if (buttonIndex == 2) {
            return;
        }
        UIImagePickerController * picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        if (buttonIndex == 0){
            picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        } else if (buttonIndex == 1) {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            } else {
                [self showText:@"无法打开相机"];
            }
        }
        [self presentModalController:picker animated:YES];
    }
}

#pragma mark - 上传图片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage * img = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        img = [UIImage rotateImage:img];
        VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:img cropFrame:CGRectMake((self.view.frame.size.width - 240)/2, 100.0f, 240, 240) limitScaleRatio:3.0 title:@"封面裁剪"];
        [imgCropperVC setCompletionBlock:^(BOOL didFinished, UIImage *editedImage) {
            if (editedImage) {
                cType = forSetCover;
                [super startRequest];
                client.indexPath = (id)editedImage;
                [client setCover:editedImage];
            }
        }];
        [self pushViewController:imgCropperVC];
    }];
}

#pragma mark - Request
- (void)sendRequest {
    [super startRequest];
    if (cType == forGetCommentList) {
        [client shareList:currentPage];
    } else if (cType == forSendComment) {
        CircleMessage * item = [contentArr objectAtIndex:selectedRow];
        [client shareReply:item.fid fuid:item.uid content:textField.text];
        client.indexPath = [NSIndexPath indexPathForRow:selectedRow inSection:0];
    } else if (cType == forSendZan) {
        CircleMessage *item = [contentArr objectAtIndex:selectedRow];
        [client addZan:item.fid];
        client.indexPath = [NSIndexPath indexPathForRow:selectedRow inSection:0];
    }
}

- (BOOL)requestDidFinish:(BSClient*)sender obj:(NSDictionary *)obj {
    [textField resignFirstResponder];
    if ([super requestDidFinish:sender obj:obj]) {
        if (cType != forGetCommentList) {
            [self showTipText:sender.errorMessage top:YES];
            if (cType == forSendComment) {
                textField.text = @"";
            } else if (cType == forSetCover) {
                NSDictionary * dic = [obj getDictionaryForKey:@"data"];
                NSString * cover = [dic getStringValueForKey:@"cover" defaultValue:nil];
                if (cover) {
                    User * user = [[BSEngine currentEngine] user];
                    user.cover = cover;
                    [[BSEngine currentEngine] setCurrentUser:user password:[BSEngine currentEngine].passWord];
                }
                faceOfPhoto.image = (id)sender.indexPath;
                [facePhotobtn setTitle:@"" forState:UIControlStateNormal];
            } else if (cType == forSendZan) {
                CircleMessageCell * cell = (CircleMessageCell*) [tableView cellForRowAtIndexPath:sender.indexPath];
                cell.item.ispraise = !cell.item.ispraise;
            }
        } else {
            User *user = [[BSEngine currentEngine] user];
            NSString *face = user.cover;
            if (face && face.length > 0) {
                [facePhotobtn setTitle:@"" forState:UIControlStateNormal];
            } else {
                [facePhotobtn setTitle:@"轻触设置相册封面" forState:UIControlStateNormal];
            }
            NSArray * list = [obj getArrayForKey:@"data"];
            [list enumerateObjectsUsingBlock:^(id dic, NSUInteger idx, BOOL *stop) {
                CircleMessage *item = [CircleMessage objWithJsonDic:dic];
                [contentArr addObject:item];
            }];
            [tableView reloadData];
        }
    }
    selectedRow = -1;
    return NO;
}

- (BOOL)requestDeleteDidFinish:(BSClient*)sender obj:(NSDictionary *)obj {
    [textField resignFirstResponder];
    if ([super requestDidFinish:sender obj:obj]) {
        [self showTipText:sender.errorMessage top:YES];
        
        CircleMessage * item = contentArr[sender.indexPath.row];
        [Notify deleteFromDBWithShareID:item.fid];
        [contentArr removeObjectAtIndex:sender.indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[sender.indexPath] withRowAnimation:UITableViewRowAnimationRight];
    }
    return YES;
}

#pragma mark -
#pragma mark - Messages
- (void)refreshFriendsCircle:(NSNotification*)sender {
    [self sendRequest];
}

#pragma mark -
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)sender {
    cType = forSendComment;
    [self sendRequest];
    return YES;
}

#pragma mark - EmotionInputViewDelegate
- (void)emotionInputView:(id)sender output:(NSString*)str {
    if ([textField.text isKindOfClass:[NSString class]] && textField.text.length > 0) {
        textField.text = [NSString stringWithFormat:@"%@%@", textField.text, [EmotionInputView emojiText4To5:str]];
    } else {
        textField.text = [EmotionInputView emojiText4To5:str];
    }
}

#pragma mark - 赞或评论的通知
- (void)receivedFriendCircle:(NSNotification*)sender {
    Notify * ntf = sender.object;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"resetFriendCircle" object:nil];
    [contentArr enumerateObjectsUsingBlock:^(CircleMessage *obj, NSUInteger idx, BOOL *stop) {
        if ([obj.fid isEqualToString:ntf.shareID]) {
            if (ntf.type == forNotifyComment) {
                CircleComment * comment = [[CircleComment alloc] init];
                comment.nickname = ntf.user.nickname;
                comment.uid = ntf.user.uid;
                comment.content = ntf.content;
                [obj.replylist addObject:comment];
            } else if (ntf.type == forNotifyZan) {
                
                CircleZan *circleZan = [[CircleZan alloc] init];
                circleZan.nickname = ntf.user.nickname;
                circleZan.uid = ntf.user.uid;
                [obj.praiselist addObject:circleZan];
                
                *stop = YES;
            } else if (ntf.type == forNotifyCancelZan) {
                [obj.praiselist enumerateObjectsUsingBlock:^(CircleZan * zan, NSUInteger idx, BOOL *stop) {
                    if ([zan.uid isEqualToString:ntf.user.uid]) {
                        [obj.praiselist removeObject:zan];
                        *stop= YES;
                    }
                }];
                *stop = YES;
            }
            [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
    }];
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
