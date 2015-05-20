//
//  AboutViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "AboutViewController.h"

@interface AboutViewController () {
    IBOutlet UIImageView * bkgView;
    IBOutlet UILabel     * labVersion;
    IBOutlet UILabel     * labName;
    IBOutlet UILabel     * labYear;
    IBOutlet UIImageView * iconView;
}
@end

@implementation AboutViewController

- (id)init {
    if (self = [super initWithNibName:@"AboutViewController" bundle:nil]) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    Release(bkgView);
    Release(labVersion);
    Release(iconView);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setEdgesNone];
    self.navigationItem.title = @"关于我们";
    
    labName.text = AppDisplayName;
    labYear.text = [NSString stringWithFormat:@"@2014 %@版权所有", AppDisplayName];
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    if (height > 500) {
        bkgView.image = [UIImage imageNamed:@"bkg_about-568"];
    }
    
   NSString * ver = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    labVersion.text = [NSString stringWithFormat:@"版本 : V%@", ver];
}

@end
