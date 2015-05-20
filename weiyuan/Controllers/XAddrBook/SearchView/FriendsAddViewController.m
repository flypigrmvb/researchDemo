//
//  FriendsAddViewController.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "FriendsAddViewController.h"
#import "ChooseContactsViewController.h"
#import "Globals.h"
#import "BaseTableViewCell.h"
#import "FindGroupViewController.h"
#import "SearchResultViewController.h"

@implementation FriendsAddViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"添加朋友";
    self.tableViewCellHeight = 36;
    tableView.tableHeaderView = self.searchBar;
    self.searchBar.placeholder = @"昵称/手机号";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[self searchBar] becomeFirstResponder];
}

#pragma mark - UISearchDisplayController delegate methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)sender {
    [sender resignFirstResponder];
    if (sender.text.length == 0) {
        [self showText:@"请输入正确的昵称/手机号"];
    } else {
        SearchResultViewController * con = [[SearchResultViewController alloc] init];
        con.showType = 0;
        con.keyword = sender.text;
        [self pushViewController: con];
    }
}

#pragma mark - UITableViewDataSource

- (UIView *)tableView:(UITableView *)sender viewForHeaderInSection:(NSInteger)section {
    UIImageView * clearView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, sender.width, 10)];
    clearView.backgroundColor = [UIColor clearColor];
    return clearView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UIView *)tableView:(UITableView *)sender viewForFooterInSection:(NSInteger)section {
    UIImageView *clearView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, sender.width, 10)];
    clearView.backgroundColor = [UIColor clearColor];
    return clearView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

#define titleArray @[@"添加手机联系人"]
- (UITableViewCell *)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"BaseTableViewCell";
    BaseTableViewCell* cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [cell addArrowRight];
    cell.textLabel.text = titleArray[indexPath.row];
    [cell update:^(NSString *name) {
        cell.imageView.frame = CGRectMake(10, (cell.height - 23)/2, 23, 23);
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        cell.textLabel.left = 40;
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.textLabel.font = [UIFont systemFontOfSize:18];
    }];
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)sender willDisplayCell:(BaseTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.imageView.image = LOADIMAGE(cell.textLabel.text);
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    ChooseContactsViewController * con = [[ChooseContactsViewController alloc] init];
    con.findNewFriend = NO;
    [self pushViewController:con];
}

@end
