//
//  ReportViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "ReportViewController.h"
#import "BaseTableViewCell.h"
#import "TextInput.h"

@interface ReportViewController () {
    IBOutlet KTextView * textView;
}

@property (nonatomic, assign) NSString      * fuid;

@end

@implementation ReportViewController
@synthesize  fuid;

- (id) initWithuid:(NSString*)fd;
{
    self = [super initWithNibName:@"ReportViewController" bundle:NULL];
    if (self) {
        // Custom initialization
        self.fuid = fd;
    }
    return self;
}

- (void) dealloc {
    self.fuid = nil;
    Release(textView);
}

- (void) viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"举报";
    [self setEdgesNone];
    [self setRightBarButton:@"确定" selector:@selector(sendReport)];
    [self setLeftBarButton:@"取消" selector:@selector(popViewController)];
}

- (void) sendReport {
    if (textView.text.length == 0) {
        [self showText:@"举报内容不能为空!"];
        return;
    }
    if ([super startRequest]) {
        [client jubao:textView.text fuid:fuid];
    }
}

- (BOOL) requestDidFinish:(id)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        [self popViewController];
    }
    return YES;
}

- (void) popViewController {
    [self dismissModalController:YES];
}

@end
