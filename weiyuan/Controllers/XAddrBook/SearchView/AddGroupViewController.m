//
//  AddGroupViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "AddGroupViewController.h"
#import "ImageGridInView.h"
#import "Room.h"
#import "TalkingViewController.h"
#import "Session.h"
#import "ViewController.h"

@interface AddGroupViewController () {
    IBOutlet UILabel            * nameLabel;
    IBOutlet UILabel            * countLabel;
    IBOutlet UIButton           * addBtn;
    IBOutlet ImageGridInView    * headView;
}

@end

@implementation AddGroupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setEdgesNone];
    [addBtn navStyle];
    headView.isHead = YES;
    headView.bkgImageView.image = LOADIMAGE(@"roomHeadImage");
    nameLabel.text = _room.name;
    countLabel.text = [NSString stringWithFormat:@"(共%d人)", _room.usercount];
    headView.numberOfItems = [_room.value count];
    [_room.value enumerateObjectsUsingBlock:^(NSString * url, NSUInteger idx, BOOL *stop) {
        ImageProgress * progress = [[ImageProgress alloc] initWithUrl:url delegate:baseImageQueue];
        if (progress.loaded) {
            [headView setImage:progress.image forIndex:idx];
        } else {
            progress.tag = idx;
            [baseImageQueue addOperation:progress];
        }
    }];
}

#pragma mark - imageProgress

- (void)imageProgressCompleted:(UIImage*)img indexPath:(NSIndexPath*)indexPath idx:(NSInteger)_idx url:(NSString *)url tag:(NSInteger)_tag{
    //to be impletemented in sub-class
    [headView setImage:img forIndex:_tag];
}

- (IBAction)addGroup {
    [super startRequest];
    [client addtogroup:_room.uid];
}

- (BOOL)requestDidFinish:(id)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        NSDictionary * dic = [obj getDictionaryForKey:@"data"];
        _room = [Room objWithJsonDic:dic];
        Session * item = [Session sessionWithRoom:_room];
        id con = [[TalkingViewController alloc] initWithSession:item];
        [self pushViewControllerAfterPop:con];
    }
    return YES;
}
@end
