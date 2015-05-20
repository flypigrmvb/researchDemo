//
//  TextSeeViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "TextSeeViewController.h"
#import "BaseTableViewCell.h"
#import "UILabelAdditions.h"
#import "CircleMessage.h"
@interface TextSeeViewController ()

@property (nonatomic, retain) User *user;
@property (nonatomic, retain) CircleMessage *it;
@end

@implementation TextSeeViewController
@synthesize user, it;

- (id)initWithUser:(User*)_user circleMessage:(CircleMessage*)_it
{
    self = [super initWithNibName:@"TextSeeViewController" bundle:NULL];
    if (self) {
        // Custom initialization
        self.user = _user;
        self.it = _it;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"详情";
    CGFloat tableViewCellHeight = 8;
    UIFont *font = [UIFont systemFontOfSize:20];
    CGSize size = [user.nickname sizeWithFont:font maxWidth:tableView.width - 80 maxNumberLines:0];
    tableViewCellHeight += size.height+4;
    
    font = [UIFont systemFontOfSize:14];
    size = [it.content sizeWithFont:font maxWidth:tableView.width - 80 maxNumberLines:0];
    tableViewCellHeight += size.height+4;
    
    font = [UIFont systemFontOfSize:12];
    size = [it.createtime sizeWithFont:font maxWidth:tableView.width - 80 maxNumberLines:0];
    tableViewCellHeight += size.height+12;
    if (tableViewCellHeight < 68) {
        tableViewCellHeight = 68;
    }
    self.tableViewCellHeight = tableViewCellHeight;
    tableView.allowsSelection = NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)sender
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)sender numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"UIBaseTableViewCell";
    BaseTableViewCell *cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    cell.topLine =
    cell.bottomLine = NO;
    UILabel *lab = (UILabel *)[tableView viewWithTag:10];
    CGFloat oy = 6;
    if (!lab) {
        lab = [UILabel multLinesText:user.nickname font:[UIFont systemFontOfSize:20] wid:tableView.width - 80];
        lab.origin = CGPointMake(75, oy);
        lab.tag = 10;
        lab.text = user.nickname;
        [cell.contentView addSubview:lab];
       
        oy +=lab.height + 4;
        
        lab = [UILabel defaultLabel:it.content font:[UIFont systemFontOfSize:14] maxWid:tableView.width - 80];
        lab.origin = CGPointMake(75, oy);
        lab.textAlignment = NSTextAlignmentLeft;
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(72, oy, lab.width + 2, lab.height)];
        imgView.userInteractionEnabled = YES;
        imgView.image = [[UIImage imageNamed:@"bkg_login_input.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
        [cell.contentView addSubview:imgView];
        [cell.contentView addSubview:lab];
        
        oy +=lab.height + 4;
        
        lab = [UILabel multLinesText:it.createtime font:[UIFont systemFontOfSize:12] wid:tableView.width - 80 color:[UIColor grayColor]];
        lab.origin = CGPointMake(75, oy);
        [cell.contentView addSubview:lab];
    }
    cell.bottomLine = cell.topLine = YES;
    return cell;
}

- (NSString*)baseTableView:(UITableView *)sender imageURLAtIndexPath:(NSIndexPath *)indexPath
{
    return user.headsmall;
}

@end

