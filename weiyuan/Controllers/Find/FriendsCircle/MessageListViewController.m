//
//  MessageListViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "MessageListViewController.h"
#import "Notify.h"
#import "BaseTableViewCell.h"
#import "ShareDetailController.h"
#import "Globals.h"
#import "CircleMessage.h"
#import "CameraActionSheet.h"
#import "Meet.h"

@interface MessageListViewController ()

@end

@implementation MessageListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 消息列表
    [contentArr addObjectsFromArray:[Notify getListFromDBSinceNow]];
    self.navigationItem.title = @"消息";
    [self setRightBarButton:@"清空" selector:@selector(clearMessage)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedFriendCircle:) name:@"receivedFriendCircle" object:nil];
}

- (void)clearMessage {
    [self showAlert:@"确认清空所有消息?" isNeedCancel:YES];
}

- (void)kwAlertView:(id)sender didDismissWithButtonIndex:(NSInteger)index {
    if (index == 1) {
        [Notify deleteFromDB];
        [contentArr removeAllObjects];
        [tableView reloadData];
    }
}

- (CGFloat)tableView:(UITableView *)sender heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 20 + 18+15; // 边距加名字加时间
    Notify * item = [contentArr objectAtIndex:indexPath.row];
    CGSize size = [item.content sizeWithFont:[UIFont systemFontOfSize:13] maxWidth:sender.width - 130  maxNumberLines:0];
    return height + size.height;
}

- (BaseTableViewCell *)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"BaseTableViewCell";
    BaseTableViewCell * cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
    UILabel *timeLab = VIEWWITHTAG(cell.contentView, 7);
    UIImageView *imageContent = VIEWWITHTAG(cell.contentView, 8);
    UILabel *labContent = VIEWWITHTAG(cell.contentView, 9);
    UIImageView *imageZan = VIEWWITHTAG(cell.contentView, 10);
    if (!cell) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        [cell enableLongPress];
        if (!timeLab) {
            timeLab = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, sender.width - 70, 14)];
            timeLab.font = [UIFont systemFontOfSize:12];
            timeLab.tag = 7;
            timeLab.textColor = RGBCOLOR(194, 194, 194);
            timeLab.highlightedTextColor = [UIColor whiteColor];
            [cell.contentView addSubview:timeLab];
        }
        if (!imageContent) {
            imageContent = [[UIImageView alloc] initWithFrame:CGRectMake(cell.width - 60, 5, 50, 50)];
            imageContent.tag = 8;
            [cell.contentView addSubview:imageContent];
        }
        if (!labContent) {
            labContent = [[UILabel alloc] initWithFrame:CGRectMake(cell.width - 90, 5, 80, 50)];
            labContent.font = [UIFont systemFontOfSize:10];
            labContent.tag = 9;
            labContent.textColor = RGBCOLOR(194, 194, 194);
            labContent.highlightedTextColor = [UIColor whiteColor];
            labContent.numberOfLines = 0;
            [cell.contentView addSubview:labContent];
        }
        if (!imageZan) {
            imageZan = [[UIImageView alloc] initWithFrame:CGRectMake(cell.textLabel.left, 5, 13, 14)];
            imageZan.image = LOADIMAGE(@"icon_zan");
            imageZan.tag = 10;
            [cell.contentView addSubview:imageZan];
        }
    }
    imageZan.hidden = YES;
    Notify * item = [contentArr objectAtIndex:indexPath.row];
    cell.textLabel.text = item.user.nickname;
    if (item.type == forNotifyZan) {
        cell.detailTextLabel.text = @"";
        imageZan.hidden = NO;
    } else {
        cell.detailTextLabel.text = item.content;
    }
    
    [cell update:^(NSString *name) {
        cell.textLabel.left =
        cell.detailTextLabel.left = 60;
        cell.imageView.origin = CGPointMake(10, 10);
        cell.textLabel.top = 10;
        cell.textLabel.height = 18;
        cell.textLabel.font = [UIFont systemFontOfSize:13];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
        cell.detailTextLabel.top = cell.textLabel.bottom+2;
        CGSize size = [item.content sizeWithFont:cell.detailTextLabel.font maxWidth:sender.width - 130  maxNumberLines:0];
        cell.detailTextLabel.size = size;
        timeLab.top = cell.detailTextLabel.bottom+2;
        timeLab.text = [Globals timeStringForListWith:item.time.doubleValue];
        imageZan.origin = CGPointMake(cell.textLabel.left, cell.textLabel.bottom + 2);
        imageContent.top =
        labContent.top =  (cell.height - 50)/2;
    }];
    [cell setBottomLine:NO];
    if (indexPath.row == contentArr.count - 1) {
        [cell setBottomLine:YES];
    }
    
    imageContent.hidden =
    labContent.hidden = YES;
    if (![item.shareContent hasPrefix:@"http://"]) {
        labContent.text = item.shareContent;
        labContent.hidden = NO;
    }
    return cell;
}

- (void)tableView:(UITableView *)sender willDisplayCell:(BaseTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.imageView.image = [Globals getImageUserHeadDefault];
    NSInvocationOperation * opHeadItem = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadHeadImageWithIndexPath:) object:indexPath];
    [baseOperationQueue addOperation:opHeadItem];
    
    NSInvocationOperation * opItem = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadImageWithIndexPath:) object:indexPath];
    [baseOperationQueue addOperation:opItem];
}

- (void)tableView:(id)sender handleTableviewCellLongPressed:(NSIndexPath*)indexPath {
    CameraActionSheet * sheet = [[CameraActionSheet alloc] initWithActionTitle:nil TextViews:nil CancelTitle:@"取消" withDelegate:self otherButtonTitles:@"删除", nil];
    sheet.indexPath = indexPath;
    [sheet show];
}

- (CGFloat)baseTableView:(UITableView *)sender imageSizeAtIndexPath:(NSIndexPath*)indexPath {
    return 100;
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    CircleMessage * item = [[CircleMessage alloc] init];
    Notify * not = [contentArr objectAtIndex:indexPath.row];
    item.fid = not.shareID;
    ShareDetailController * con = [[ShareDetailController alloc] initWithShare:item];
    [self pushViewController:con];
}

- (NSString*)baseTableView:(UITableView *)sender imageURLAtIndexPath:(NSIndexPath *)indexPath {
    Notify * item = [contentArr objectAtIndex:indexPath.row];
    return item.user.headsmall;
}

- (void)baseTableView:(NSInteger)tag imageUpdateAtIndexPath:(NSIndexPath*)indexPath image:(UIImage *)image idx:(NSInteger)idx {
    BaseTableViewCell * cell = (BaseTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    if (tag == -1) {
        cell.imageView.image = image;
    } else {
        UIImageView *imageContent = VIEWWITHTAG(cell.contentView, 8);
        imageContent.image = image;
        imageContent.hidden = NO;
    }
}

- (void)loadImageWithIndexPath:(NSIndexPath *)indexPath {
    Notify * not = [contentArr objectAtIndex:indexPath.row];
    if ([not.shareContent hasPrefix:@"http://"]) {
        NSString * url = not.shareContent;
        UIImage * img = [baseImageCaches getImageCache:[url md5Hex]];
        if (!img) {
            ImageProgress * progress = [[ImageProgress alloc] initWithUrl:url delegate:baseImageQueue];
            progress.indexPath = indexPath;
            progress.tag = 0;
            [self performSelectorOnMainThread:@selector(startLoadingWithProgress:) withObject:progress waitUntilDone:YES];
        } else {
            dispatch_async(kQueueMain, ^{
                BaseTableViewCell * cell = (BaseTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
                UIImageView *imageContent = VIEWWITHTAG(cell.contentView, 8);
                imageContent.image = img;
                imageContent.hidden = NO;
            });
        }
    }
}

#pragma mark - CameraActionSheetDelegate

- (void)cameraActionSheet:(CameraActionSheet *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex {
    Notify * not = [contentArr objectAtIndex:sender.indexPath.row];
    [super startRequest];
    if (buttonIndex == 0) {
        [client disagreeApplyMeeting:not.user.uid fuid:_item.id];
    } else {
        [client agreeApplyMeeting:not.user.uid fuid:_item.id];
    }
}

#pragma mark - 赞或评论的通知
- (void)receivedFriendCircle:(NSNotification*)sender {
    Notify * ntf = sender.object;
    
    if (ntf.type == forNotifyCancelZan) {
        return;
    }
    __block BOOL find = NO;
    [contentArr enumerateObjectsUsingBlock:^(Notify * obj, NSUInteger idx, BOOL *stop) {
        if ([obj.shareID isEqualToString:ntf.shareID]&&[obj.user.uid isEqualToString:ntf.user.uid]&&(ntf.type==forNotifyZan)) {
            [contentArr removeObject:obj];
            [contentArr insertObject:ntf atIndex:0];
            [tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] toIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            find = YES;
            *stop = YES;
        }
    }];
    if (!find) {
        [contentArr insertObject:ntf atIndex:0];
        [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }

}

#pragma mark - request 
- (BOOL)requestDidFinish:(BSClient*)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        [self showText:sender.errorMessage];
    }
    return YES;
}

@end
