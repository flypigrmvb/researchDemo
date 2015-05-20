//
//  SearchChatViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "SearchChatViewController.h"
#import "Session.h"
#import "Message.h"
#import "ImageTouchView.h"
#import "ChatMessagesCell.h"
#import "Globals.h"
#import "JSON.h"
#import "SessionCell.h"
#import "TalkingViewController.h"
#import "TextInput.h"

@interface SearchChatViewController ()<ImageTouchViewDelegate> {
    UIImageView * bkgView;
    UILabel * notFound;
}

@end

@implementation SearchChatViewController

- (void)viewDidLoad {
    enablefilter = YES;
    [super viewDidLoad];
    [self setEdgesNone];
    // 搜索聊天记录
    // Do any additional setup after loading the view.
    self.navigationItem.titleView = self.titleView;
    bkgView = [[UIImageView alloc] initWithFrame:tableView.bounds];
    bkgView.userInteractionEnabled = YES;
    bkgView.backgroundColor = RGBACOLOR(100, 100, 100, 0.7);
    [self.view addSubview:bkgView];
    [contentArr addObjectsFromArray:[Message getListFromDBWithID:_session.uid sinceRowID:-1]];
    notFound = [[UILabel alloc] initWithFrame:tableView.frame];
    notFound.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    notFound.font = [UIFont systemFontOfSize:24];
    notFound.textColor = RGBCOLOR(200, 200, 200);
    notFound.text = @"未找到结果";
    notFound.hidden = YES;
    notFound.userInteractionEnabled = YES;
    notFound.textAlignment = NSTextAlignmentCenter;
    [filterTableView addSubview:notFound];
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(handleSingleTap:)];
    [singleTapGesture setNumberOfTapsRequired:1];
    [notFound addGestureRecognizer:singleTapGesture];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.searchField performSelectorOnMainThread:@selector(becomeFirstResponder) withObject:nil waitUntilDone:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (tableView.userInteractionEnabled) {
        [self popViewController];
    } else {
        [self.searchField resignFirstResponder];
    }
    
}

- (void)handleSingleTap:(UIGestureRecognizer *)gesture {
    [self.searchField resignFirstResponder];
}

- (void)individuationTitleView {
    self.addButton.tag = @"clearView";
    self.addButton.image = LOADIMAGE(@"btn_clear");
    self.addButton.highlightedImage = LOADIMAGE(@"btn_clear_d");
    
    self.searchButton.frame = CGRectMake(self.searchView.left + 5, 0, 30, 44);
    
    self.searchView.alpha = 1;
    self.addButton.alpha = 1;
    self.searchButton.alpha = 1;
}

#pragma mark - TableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (inFilter) {
        Message * msg = [filterArr objectAtIndex:indexPath.row];
        static NSString* CellIdentifier = @"SessionCell";
        SessionCell * cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[SessionCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.superTableView = sender;
        }
        [cell setNumberOfGroupHead:0];
        cell.withItem = msg;
        
        NSString * str = msg.content;
        cell.detailTextLabel.text = @"";
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:str];
        NSRange range = [str rangeOfString:searchContent];
        if (range.location > 10 && range.location != NSNotFound) {
            // 最大18个字
            str = [msg.content substringFromIndex:range.location];
            if ((str.length < 10 && msg.content.length > 10) || str.length > 10) {
                str = [msg.content substringFromIndex:range.location - 9];
            }
            msg.content = str;
            attrString = [[NSMutableAttributedString alloc] initWithString:str];
            range = [str rangeOfString:searchContent];
        }
        [attrString addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(75, 163, 0) range:[str rangeOfString:searchContent]];
        cell.detailTextLabel.attributedText = attrString;
        [cell setBottomLine:NO];
        if (indexPath.row == filterArr.count - 1) {
            [cell setBottomLine:YES];
        }
        [cell update:^(NSString *name) {
            [cell autoAdjustText];
        }];
        return cell;
    } else {
        Message * msg = [contentArr objectAtIndex:indexPath.section];
        static NSString * CellIdentifier = @"MessageCell";
        ChatMessagesCell * cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[ChatMessagesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.superTableView = sender;
        }
        [cell setTopLine:NO];
        
        cell.timeText = nil;
        if (indexPath.row == 0) {
            cell.timeText = [Globals sendTimeString:msg.sendTime.doubleValue];
        } else {
            Message * msgLast = [inFilter?filterArr:contentArr objectAtIndex:indexPath.row - 1];
            NSString * tStr = nil;
            if (msg.sendTime.doubleValue / 1000 - msgLast.sendTime.doubleValue / 1000 > 10) {
                tStr = [Globals sendTimeString:msg.sendTime.doubleValue];
            }
            cell.timeText = tStr;
        }
        if (msg.typefile == forFileImage) {
            UIImage * img = [baseImageCaches getImageCache:[msg.content md5Hex]];
            if (img == nil) {
                img = [Globals getImageGray];
            }
            cell.imageSize = msg.imageSize;
            cell.conImage = img;
        }
        cell.item = msg;
        cell.state = msg.state;
        cell.playing = NO;
        return cell;
    }
}

#pragma mark - TableViewDelegate
- (UIView *)tableView:(UITableView *)sender viewForHeaderInSection:(NSInteger)section {
    if (inFilter) {
        return nil;
    }
    CGFloat height = 0;
    Message * msg = [inFilter?filterArr:contentArr objectAtIndex:section];
    if (section == 0) {
        height += 28;
    } else {
        Message * msgLast = [inFilter?filterArr:contentArr objectAtIndex:section - 1];
        if (msg.sendTime.doubleValue / 1000 - msgLast.sendTime.doubleValue / 1000 > 60) {
            height += 28;
        }
    }
    UIImageView * clearView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, sender.width, height)];
    clearView.backgroundColor = [UIColor clearColor];
    return clearView;
}

- (CGFloat)tableView:(UITableView *)sender heightForHeaderInSection:(NSInteger)section {
    if (inFilter) {
        return 0;
    }
    CGFloat height = 0;
    if (section == 0) {
        height += 28;
    } else {
        Message * msg = [contentArr objectAtIndex:section];
        Message * msgLast = [contentArr objectAtIndex:section - 1];
        if (msg.sendTime.doubleValue / 1000 - msgLast.sendTime.doubleValue / 1000 > 180) {
            height += 28;
        }
    }
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)sender {
    return inFilter?1:contentArr.count;
}

- (NSInteger)tableView:(UITableView *)sender numberOfRowsInSection:(NSInteger)section {
    if (inFilter) {
        return filterArr.count;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView*)sender heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    if (inFilter) {
        return 60;
    }
    Message * msg = [inFilter?filterArr:contentArr objectAtIndex:indexPath.section];
    CGFloat height = [ChatMessagesCell heightForMessage:msg];
    return height;
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    if (self.searchField.text.length > 0) {
        Message * msg = [filterArr objectAtIndex:indexPath.section];
        TalkingViewController * con = [[TalkingViewController alloc] initWithSession:_session];
        con.isSearchMode = YES;
        con.sinceMsgID = msg.rowID;
        [self pushViewController:con];
    }
}

- (void)tableView:(UITableView *)sender willDisplayCell:(ChatMessagesCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.imageView.image = [Globals getImageUserHeadDefault];
    NSInvocationOperation * opHeadItem = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadHeadImageWithIndexPath:) object:indexPath];
    [baseOperationQueue addOperation:opHeadItem];
    if (!inFilter) {
        NSInvocationOperation * opItem = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadImageWithIndexPath:) object:indexPath];
        [baseOperationQueue addOperation:opItem];;
    }
}

- (void)loadImageWithIndexPath:(NSIndexPath *)indexPath {
    Message * msg = [inFilter?filterArr:contentArr objectAtIndex:indexPath.section];
    NSString * url = nil;
    if (msg.typefile == forFileAddress) {
        url = [Globals getBaiduAdrPicForTalk:msg.address.lat lng:msg.address.lng];
    } else if (msg.typefile == forFileNameCard) {
        NSDictionary * dic = [JSON objectFromJSONString:msg.content];
        url = [dic getStringValueForKey:@"headsmall" defaultValue:nil];
    }else {
        url = msg.imgUrlS;
    }
    if (url) {
        UIImage * img = [baseImageCaches getImageCache:[url md5Hex]];
        if (!img) {
            ImageProgress * progress = [[ImageProgress alloc] initWithUrl:url delegate:baseImageQueue];
            progress.indexPath = indexPath;
            progress.tag = 0;
            [self performSelectorOnMainThread:@selector(startLoadingWithProgress:) withObject:progress waitUntilDone:YES];
        } else {
            dispatch_async(kQueueMain, ^{
                [self setConImage:img forIndex:indexPath];
            });
        }
    }
}

- (void)setConImage:(UIImage *)image forIndex:(NSIndexPath*)indexPath {
    ChatMessagesCell * cell = (ChatMessagesCell*)[inFilter?filterTableView:tableView cellForRowAtIndexPath:indexPath];
    cell.conImage = image;
}

- (NSString*)baseTableView:(UITableView *)sender imageURLAtIndexPath:(NSIndexPath*)indexPath {
    Message * msg = [inFilter?filterArr:contentArr objectAtIndex:indexPath.section];
    if (msg.isSendByMe) {
        return [[BSEngine currentUser] headsmall];
    }
    return msg.displayImgUrl;
}

- (int)baseTableView:(UITableView *)sender imageTagAtIndexPath:(NSIndexPath*)indexPath {
    return -1;
}

- (void)baseTableView:(NSInteger)tag imageUpdateAtIndexPath:(NSIndexPath*)indexPath image:(UIImage *)image idx:(NSInteger)idx {
    if (tag == -1) {
        [self setHeadImage:image forIndex:indexPath];
    } else {
        [self setConImage:image forIndex:indexPath];
    }
}

- (CGFloat)baseTableView:(UITableView *)sender imageSizeAtIndexPath:(NSIndexPath*)indexPath{
    return 0;
}

#pragma mark - ImageTouchViewDelegate
- (void)imageTouchViewDidSelected:(id)sender {
    [self.view addSubview:bkgView];
    self.searchField.text = @"";
    [self textFieldDidChange:self.searchField];
}


#pragma filter

- (void)filterContentForSearchText:(NSString*)searchText
                             scope:(NSString*)scope {
    searchContent = searchText;
    if (searchContent.length > 0) {
        [bkgView removeFromSuperview];
    } else {
        [self.view addSubview:bkgView];
    }
    for (Message *it in contentArr) {
        if ([it.content rangeOfString:searchText].location <= it.content.length) {
            [filterArr addObject:it];
        }
    }
    
    notFound.hidden = !(filterArr.count == 0);
    
    tableView.userInteractionEnabled = notFound.hidden;
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	搜索时根据输入的字符过滤tableview
 *
 */
- (void)textFieldDidChange:(UITextField*)sender {
    if (sender.markedTextRange != nil) {
        return;
    }
    [filterArr removeAllObjects];
    UITextField *_field = (UITextField *)sender;
    NSString * str = _field.text;
    [self filterContentForSearchText:str scope:nil];
    if (str.length == 0) {
        [filterTableView reloadData];
        [UIView animateWithDuration:0.25 animations:^{
            filterTableView.alpha = 0;
            tableView.alpha = 1;
        } completion:^(BOOL finished) {
            if (finished) {
                inFilter = NO;
                filterTableView.hidden = YES;
            }
        }];
    } else {
        if (!inFilter) {
            filterTableView.alpha = 0;
            filterTableView.hidden = NO;
            inFilter = YES;
            [UIView animateWithDuration:0.25 animations:^{
                tableView.alpha = 0;
                filterTableView.alpha = 1;
            } completion:^(BOOL finished) {
                if (finished) {
                    [filterTableView reloadData];
                }
            }];
        } else {
            [filterTableView reloadData];
        }
        
    }
    
}
@end
