//
//  MeetingMessageListViewController.m
//  ReSearch
//
//  Created by kiwi on 14-9-2.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "MeetingMessageListViewController.h"
#import "CameraActionSheet.h"
#import "Notify.h"
#import "BaseTableViewCell.h"
#import "Meet.h"

@interface MeetingMessageListViewController ()<CameraActionSheetDelegate>

@end

@implementation MeetingMessageListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"申请列表";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedMeetNot:) name:@"receivedMeetNot" object:nil];
    [super startRequest];
    [client getMeetingApplyList:_item.id];
    client.tag = @"get";
}

- (CGFloat)tableView:(UITableView *)sender heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 20 + 18; // 边距加名字
    Notify * item = [contentArr objectAtIndex:indexPath.row];
    CGSize size = [item.content sizeWithFont:[UIFont systemFontOfSize:13] maxWidth:sender.width - 100  maxNumberLines:0];
    height += size.height;
    return height<self.tableViewCellHeight?self.tableViewCellHeight:height;
}

- (BaseTableViewCell *)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"BaseTableViewCell";
    BaseTableViewCell * cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];

    if (!cell) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.superTableView = sender;
    }
    
    Notify * item = [contentArr objectAtIndex:indexPath.row];
    cell.textLabel.text = item.user.nickname;
    cell.detailTextLabel.text = item.content;
    [cell update:^(NSString *name) {
        cell.textLabel.left =
        cell.detailTextLabel.left = 60;
        cell.imageView.origin = CGPointMake(10, 10);
        cell.textLabel.top = 10;
        cell.textLabel.height = 18;
        cell.textLabel.font = [UIFont systemFontOfSize:13];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
        cell.detailTextLabel.top = cell.textLabel.bottom+2;
        CGSize size = [item.content sizeWithFont:cell.detailTextLabel.font maxWidth:sender.width - 100  maxNumberLines:0];
        cell.detailTextLabel.size = size;

    }];
    [cell setBottomLine:NO];
    if (indexPath.row == contentArr.count - 1) {
        [cell setBottomLine:YES];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    CameraActionSheet * sheet = [[CameraActionSheet alloc] initWithActionTitle:nil TextViews:nil CancelTitle:@"取消" withDelegate:self otherButtonTitles:@"同意加入", @"拒绝加入", nil];
    sheet.indexPath = indexPath;
    [sheet show];
}

- (void)tableView:(id)sender didTapHeaderAtIndexPath:(NSIndexPath*)indexPath  {
    Notify * item = [contentArr objectAtIndex:indexPath.row];
    [self getUserByName:item.user.uid];
}

- (CGFloat)baseTableView:(UITableView *)sender imageSizeAtIndexPath:(NSIndexPath*)indexPath {
    return 100;
}

- (NSString*)baseTableView:(UITableView *)sender imageURLAtIndexPath:(NSIndexPath *)indexPath
{
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

#pragma mark - CameraActionSheetDelegate

- (void)cameraActionSheet:(CameraActionSheet *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != 2) {
        [super startRequest];
        client.indexPath = sender.indexPath;
        Notify * item = [contentArr objectAtIndex:sender.indexPath.row];
        if (buttonIndex == 0) {
            [client agreeApplyMeeting:_item.id fuid:item.user.uid];
            client.tag = @"agree";
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMeetList" object:nil];
        } else {
            [client disagreeApplyMeeting:_item.id fuid:item.user.uid];
            client.tag = @"disagree";
        }
    }
}

#pragma mark - 会议相关通知
- (void)receivedMeetNot:(NSNotification*)sender {
    Notify * ntf = sender.object;
    ntf.content = ntf.shareContent;
    [contentArr insertObject:ntf atIndex:0];
    [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - request
- (BOOL)requestDidFinish:(BSClient*)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        if ([sender.tag isEqualToString:@"get"]) {
            NSArray * data = [obj getArrayForKey:@"data"];
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                Notify * not = [[Notify alloc] init];
                not.user = [User objWithJsonDic:obj];
                not.content = [obj getStringValueForKey:@"content" defaultValue:@""];
                [contentArr addObject:not];
            }];
            [tableView reloadData];
        } else {
            [self showText:sender.errorMessage];
            if ([sender.tag isEqualToString:@"agree"]) {
                
            }
            Notify * not = [contentArr objectAtIndex:sender.indexPath.row];
            [contentArr removeObject:not];
            [tableView deleteRowsAtIndexPaths:@[sender.indexPath] withRowAnimation:UITableViewRowAnimationRight];
        }
    }
    return YES;
}
@end
