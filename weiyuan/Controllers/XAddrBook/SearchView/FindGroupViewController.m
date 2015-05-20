//
//  FindGroupViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "FindGroupViewController.h"
#import "TextInput.h"
#import "Room.h"
#import "SearchResultViewController.h"

@interface FindGroupViewController () {
    KTextField * textField;
}

@end

@implementation FindGroupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setEdgesNone];
    self.navigationItem.title = @"查找群";
    textField = [[KTextField alloc] initWithFrame:CGRectMake(10, 14, self.view.width - 20, 42)];
    
    [self.view addSubview:textField];
    textField.placeholder = @"请输入群名称";
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn commonStyle];
    btn.frame = CGRectMake(80, 80, self.view.width - 160, 40);
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn addTarget:self action:@selector(foundIt) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"查找" forState:UIControlStateNormal];
    [self.view addSubview:btn];
}

- (void)foundIt {
    if (textField.text.length == 0) {
        [self showText:@"名字不能为空"];
    }
    if ([super startRequest]) {
        [client groupSearch:textField.text page:currentPage];
    }
}

- (BOOL)requestDidFinish:(id)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        NSMutableArray * itemArray = [NSMutableArray array];
        NSArray * array = [obj getArrayForKey:@"data"];
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Room * room = [Room objWithJsonDic:obj];
            [itemArray addObject:room];
        }];
    }
    return YES;
}

@end
