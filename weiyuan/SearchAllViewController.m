//
//  SearchAllViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "SearchAllViewController.h"
#import "TalkingViewController.h"
#import "ImageTouchView.h"
#import "Message.h"
#import "User.h"
#import "JSON.h"
#import "SessionCell.h"
#import "Room.h"
#import "Session.h"
#import "UserCell.h"
#import "TalkingViewController.h"
#import "TextInput.h"

@interface SearchAllViewController ()<ImageTouchViewDelegate>{
    NSMutableArray * sessionArr;
}

@end

@implementation SearchAllViewController

- (void)viewDidLoad {
    sessionArr = [NSMutableArray array];
    enablefilter = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setEdgesNone];
    self.navigationItem.titleView = self.titleView;
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchAnyWhere)];
    [recognizer setNumberOfTapsRequired:1];
    [tableView addGestureRecognizer:recognizer];
    tableView.backgroundColor = RGBACOLOR(100, 100, 100, 0.7);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.searchField performSelectorOnMainThread:@selector(becomeFirstResponder) withObject:nil waitUntilDone:YES];
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

- (void)touchAnyWhere {
    [self popViewController];
}

#pragma mark - TableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString* CellIdentifier = @"UserCell";
        UserCell * cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UserCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            [cell setlabTimeHide:YES];
        }
        
        User * user = [contentArr objectAtIndex:indexPath.row];
        if (searchContent) {
            NSString * str = nil;
            
            NSRange range = [user.displayName rangeOfString:searchContent];
            if ([user.displayName rangeOfString:searchContent].location <= user.displayName.length) {
                str = user.displayName;
            } else {
                range = [user.nickname rangeOfString:searchContent];
                str = user.nickname;
            }
            NSMutableAttributedString * attrString = [[NSMutableAttributedString alloc] initWithString:str];
            [attrString addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(75, 163, 0) range:range];
            cell.textLabel.attributedText = attrString;
        }

        cell.detailTextLabel.text = user.sign;
        [cell setBottomLine:NO];
        if (indexPath.row == contentArr.count - 1) {
            [cell setBottomLine:YES];
        }
        [cell update:^(NSString *name) {
            [cell autoAdjustText];
        }];
        return cell;
    }
    static NSString* CellIdentifier = @"SessionCell";
    SessionCell * cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[SessionCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.superTableView = sender;
    }
    [cell setNumberOfGroupHead:0];
    [cell setBottomLine:NO];
    if (indexPath.row == sessionArr.count - 1) {
        [cell setBottomLine:YES];
    }
    
    Session * session = [sessionArr objectAtIndex:indexPath.row];
    cell.textLabel.text = session.message.displayName;
    NSString * str = session.content;
    
    if (searchContent) {
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:str];
        NSRange range = [str rangeOfString:searchContent];
        if (range.location > 10 && range.location != NSNotFound) {
            // 最大18个字
            str = [session.content substringFromIndex:range.location];
            if ((str.length < 10 && session.content.length > 10) || str.length > 10) {
                str = [session.content substringFromIndex:range.location - 9];
            }
            session.content = str;
            attrString = [[NSMutableAttributedString alloc] initWithString:str];
            range = [str rangeOfString:searchContent];
        }
        [attrString addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(75, 163, 0) range:[str rangeOfString:searchContent]];
        cell.detailTextLabel.attributedText = attrString;
    }
    [cell update:^(NSString *name) {
        [cell autoAdjustText];
    }];
    return cell;
}

#pragma mark - TableViewDelegate
- (UIView *)tableView:(UITableView *)sender viewForHeaderInSection:(NSInteger)section {
    CGFloat height = 0;
    if (section == 0) {
        height = contentArr.count>0?19:0;
    } else {
        height = sessionArr.count>0?19:0;
    }
    UIImageView * clearView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, sender.width, height)];
    if (height > 0) {
        clearView.backgroundColor = RGBCOLOR(229, 228, 226);
        UILabel *tLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, 120, 15)];
        tLabel.textColor=[UIColor blackColor];
        tLabel.backgroundColor = [UIColor clearColor];
        tLabel.font = [UIFont systemFontOfSize:14];
        if (section == 0) {
            tLabel.text = @"联系人";
        } else {
            tLabel.text = @"聊天记录";
        }
        [clearView addSubview:tLabel];
    } else {
        clearView.backgroundColor = [UIColor clearColor];
    }
    return clearView;
}

- (CGFloat)tableView:(UITableView *)sender heightForHeaderInSection:(NSInteger)section {
    CGFloat height = 0;
    if (section == 0) {
        height = contentArr.count>0?19:0;
    } else {
        height = sessionArr.count>0?19:0;
    }
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)sender {
    return 2;
}

- (NSInteger)tableView:(UITableView *)sender numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return contentArr.count;
    }
    return sessionArr.count;
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        User * item = [contentArr objectAtIndex:indexPath.row];
        Session * session = [Session getSessionWithID:item.uid];
        if (!session) {
            session = [Session sessionWithUser:item];
        }
        TalkingViewController * con = [[TalkingViewController alloc] initWithSession:session];
        [self pushViewController:con];
    } else {
        Session * session = [sessionArr objectAtIndex:indexPath.row];
        NSInteger rowid = session.message.rowID;
        session = [Session valueForKeyFromeDB:session.uid
                                      keyname:@"uid"];
        TalkingViewController * con = [[TalkingViewController alloc] initWithSession:session];
        con.sinceMsgID = rowid;
        [self pushViewController:con];
    }
}

- (NSString*)baseTableView:(UITableView *)sender imageURLAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        User * item = [contentArr objectAtIndex:indexPath.row];
        return item.headsmall;
    }
    Session * item = [sessionArr objectAtIndex:indexPath.row];
    if (item.isRoom) {
        return item.value;
    } else {
        if (item.message.isSendByMe) {
            return item.message.tohead;
        }
        return item.message.displayImgUrl;
    }
}

- (int)baseTableView:(UITableView *)sender imageTagAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.section == 0) {
        return -1;
    }
    Session * item = [sessionArr objectAtIndex:indexPath.row];
    if (item.isRoom) {
        return -2;
    } else {
        return -1;
    }
}

- (void)baseTableView:(NSInteger)tag imageUpdateAtIndexPath:(NSIndexPath*)indexPath image:(UIImage *)image idx:(NSInteger)idx {
    if (tag == -1) {
        [self setHeadImage:image forIndex:indexPath];
    } else {
        [self setGroupHeadImage:image forIndex:indexPath forPos:idx];
    }
}

#pragma mark - ImageTouchViewDelegate
- (void)imageTouchViewDidSelected:(id)sender {
    searchContent = nil;
    [sessionArr removeAllObjects];
    [contentArr removeAllObjects];
    self.searchField.text = @"";
    [self textFieldDidChange:self.searchField];
}

#pragma filter

- (void)filterContentForSearchText:(NSString*)searchText
                             scope:(NSString*)scope {
    searchContent = searchText;
    [sessionArr removeAllObjects];
    [contentArr removeAllObjects];
    NSArray * array = [User friendlistFromeDB];
    [array enumerateObjectsUsingBlock:^(User * user, NSUInteger idx, BOOL *stop) {
        if ([user.remark rangeOfString:searchText].location <= user.remark.length) {
            [contentArr addObject:user];
        } else if ([user.nickname rangeOfString:searchText].location <= user.nickname.length) {
            [contentArr addObject:user];
        }
    }];
    NSArray * contentArray = [Message valuelistForKeyFromeDB:searchText keyname:@"content"];
    [contentArray enumerateObjectsUsingBlock:^(Message * obj, NSUInteger idx, BOOL *stop) {
        Session * item = [Session valueForKeyFromeDB:obj.withID keyname:@"uid"];
        if (item) {
            item.content = obj.content;
            item.message.rowID = obj.rowID;
            [sessionArr addObject:item];
        }
    }];
}

@end
