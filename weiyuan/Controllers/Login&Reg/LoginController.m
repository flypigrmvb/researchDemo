//
//  LoginController.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "LoginController.h"
#import "RegViewController.h"
#import "ResetPasswordViewController.h"
#import "TextInput.h"

@interface LoginController () {
    IBOutlet KTextField     *   tfUserName;
    IBOutlet KTextField     *   tfPassWord;
    IBOutlet UIButton       *   btnLogin;
    IBOutlet UIButton       *   btnReg;
    IBOutlet UIButton       *   btnForget;
}

@end

@implementation LoginController

- (id)init {
    self = [super initWithNibName:@"LoginController" bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    Release(tfUserName);
    Release(tfPassWord);
    Release(btnLogin);
    Release(btnReg);
    Release(btnForget);
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.title = @"登录";
    // 配置按钮的默认外观
    [btnLogin infoStyle];
    [tfUserName infoStyle];
    [tfPassWord infoStyle];
    [self setEdgesNone];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (isFirstAppear) {
        [self readLoginInfo];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    if ([[BSEngine currentEngine] isLoggedIn]) {
        [self dismissModalController:YES];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [tfPassWord resignFirstResponder];
    [tfUserName resignFirstResponder];
}

- (void)popViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnItemPressed:(UIButton*)sender {
    [tfPassWord resignFirstResponder];
    [tfUserName resignFirstResponder];
    if (sender == btnLogin) {
        if (tfUserName.text.length == 0) {
            // please input account, or play go ...
            [tfUserName shakeAlert];
        } else if (tfPassWord.text.length == 0) {
            // please input password, play go again...
            [tfPassWord shakeAlert];
        } else {
            [self startRequest];
        }
    } else if (sender == btnReg) {
        // regist ..
        RegViewController *con = [[RegViewController alloc] init];
        [self pushViewController:con];
    } else if (sender == btnForget) {
        // forget ..
        ResetPasswordViewController * con = [[ResetPasswordViewController alloc] init];
        [self pushViewController:con];
    }
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	读取保存在本地的账号信息，成功读取则免登录
 */
- (void)readLoginInfo {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    tfUserName.text = [defaults objectForKey:KBSLoginUserName];
    tfPassWord.text = [defaults objectForKey:KBSLoginPassWord];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	登录成功后保存账号信息到本地，方便下次免登录
 */
- (void)saveLoginInfo {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // save
    [defaults setObject:tfUserName.text forKey:KBSLoginUserName];
    [defaults setObject:tfPassWord.text forKey:KBSLoginPassWord];
    [defaults synchronize];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	注销成功后删除保存在本地的账号信息
 */
- (void)deleteLoginInfo {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:KBSLoginUserName];
    [defaults removeObjectForKey:KBSLoginPassWord];
	[defaults synchronize];
}

#pragma mark - Request

/** 开始登陆到服务器*/
- (BOOL)startRequest {
    if ([super startRequest]) {
        [client loginWithUserPhone:tfUserName.text password:tfPassWord.text];
    }
    return YES;
}

/***/
- (BOOL)requestDidFinish:(BSClient*)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        id data = [obj getDictionaryForKey:@"data"];
        if (data && [data isKindOfClass:[NSDictionary class]]) {
            User * item = [User objWithJsonDic:data];
            if (item) {
                // 登录成功 保存账号数据
                [self saveLoginInfo];
                [[BSEngine currentEngine] setCurrentUser:item password:tfPassWord.text];
                // check config 检查用户的配置参数， 不存在则创建默认参数
                [item checkConfig];
                // 返回登陆前页面
                [self popViewController];
            } else {
                // 登录失败
                sender.errorMessage = @"无法获取登录用户信息";
                [sender showAlert];
            }
        }
    }
    return YES;
}

#pragma mark - UITextFieldDelegate
/***/
- (BOOL)textFieldShouldReturn:(UITextField *)sender {
    if (sender == tfUserName) {
        [tfPassWord becomeFirstResponder];
    } else if (sender == tfPassWord) {
        [self btnItemPressed:btnLogin];
    }
    return YES;
}

@end


