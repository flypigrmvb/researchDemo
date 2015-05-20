//
//  BasicNavigationController.h
//  SpartaEducation
//
//  Created by Kiwaro on 14-5-17.
//  Copyright (c) 2014年 Kiwaro. All rights reserved.
//
#import "RegViewController.h"
#import "Globals.h"
#import "HelpViewController.h"
#import "UITextField+Shake.h"
#import "TextInput.h"

@interface RegViewController () {
    IBOutlet KTextField     * nameLabel;
    IBOutlet KTextField     * passwordLabel;
    IBOutlet KTextField     * repasswordLabel;
    IBOutlet KTextField     * codeLabel;
    IBOutlet UIButton       * btnAgreeMent;
    IBOutlet UIButton       * btnAgree;
    IBOutlet UIButton       * btngetCode;
    IBOutlet UIButton       * btnReg;
    NSTimer                 * timer;
}
@property (nonatomic, assign) int time;
@property (nonatomic, strong) NSString * regPhone;
@end

@implementation RegViewController
@synthesize regPhone;

- (id)init {
    if (self = [super initWithNibName:@"RegViewController" bundle:nil]) {
        // Custom initialization
        _time = 60;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"注册";
    [btnReg infoStyle];
    [self setEdgesNone];
    currentInputView = nameLabel;
    [nameLabel infoStyle];
    [passwordLabel infoStyle];
    [repasswordLabel infoStyle];
    [codeLabel infoStyle];
    
    [btngetCode infoStyle];
    btngetCode.titleLabel.font = [UIFont systemFontOfSize:13];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (timer) {
        // 强制停止计时器
        [timer invalidate];
        timer = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    __block BaseViewController *blockSelf = self;
    [blockSelf.view addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView, BOOL opening, BOOL closing) {
        if (opening) {
            if (currentInputView.tag >3) {
                // 有必要的时候 适应键盘
                CGFloat oy = keyboardFrameInView.origin.y;
                if (currentInputView.bottom>oy) {
                    self.view.top -= abs(currentInputView.bottom-oy)*2;
                }
            }
        }
        if (closing) {
            self.view.top = 0;
        }
    }];
}

- (IBAction)btnArgee:(UIButton*)sender {
    sender.selected = !sender.selected;
}

- (IBAction)btnGetCode:(UIButton*)sender {
    if (nameLabel.text.length != 11) {
        [self showText:@"请输入正确的手机号"];
    } else {
        if (client) {
            return;
        }
        [self setLoading:YES content:@"正在发送验证码"];
        client = [[BSClient alloc] initWithDelegate:self action:@selector(requestDidCodeFinish:obj:)];
        [client getPhoneCode:nameLabel.text];
        [self resignAllKeyboard:self.view];
    }
}

- (BOOL)requestDidCodeFinish:(id)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        NSDictionary * data = [obj getDictionaryForKey:@"data"];
        NSString * code = [data getStringValueForKey:@"code" defaultValue:@""];
//        [self showAlert:@"验证码已经发送到你的手机，请注意查收！" isNeedCancel:NO];
        codeLabel.text = code;
        btngetCode.enabled = NO;
        if (timer) {
            [timer invalidate];
            timer = nil;
        }
        _time = 60;
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(repeat:) userInfo:nil repeats:YES];
        [self repeat:nil];
    }
    return YES;
}
/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	刷新[获取验证码] 按钮的计数
 *
 *	@param 	tr 	计时器对象
 */
- (void)repeat:(NSTimer*)tr
 {
    if (_time <= 0) {
        btngetCode.enabled = YES;
        [btngetCode setTitle:@"获取验证码" forState:UIControlStateNormal];
        if (timer) {
            [timer invalidate];
            timer = nil;
        }
    } else {
        [btngetCode setTitle:[NSString stringWithFormat:@"剩余%d秒", _time] forState:UIControlStateDisabled];
        _time -= 1;
    }
}

- (IBAction)btnRegister:(id)sender {
    [self resignAllKeyboard:self.view];
    if (!nameLabel.text || nameLabel.text.length == 0) {
        [self showText:@"请输入手机号"];
        [nameLabel shakeAlert];
    } else if (!passwordLabel.text && passwordLabel.text.length == 0) {
        [self showText:@"请输入密码"];
        [passwordLabel shakeAlert];
    } else if (!repasswordLabel.text && repasswordLabel.text.length == 0) {
        [self showText:@"请输入确认密码"];
        [passwordLabel shakeAlert];
    } else if (![repasswordLabel.text isEqual:passwordLabel.text]) {
        [self showText:@"请输入正确的确认密码"];
        [repasswordLabel shakeAlert];
    } else if (!codeLabel.text || codeLabel.text.length == 0) {
        [self showText:@"请输入验证码"];
        [codeLabel shakeAlert];
    } else if (!btnAgree.selected) {
        [self showText:@"请阅读并同意注册协议！"];
    } else {
        [self startRequest];
        return;
    }
    //    [currentInputView resignFirstResponder];
}

- (BOOL)startRequest {
    [super startRequest];
    [client regWithPhone:nameLabel.text password:passwordLabel.text code:codeLabel.text];
    return YES;
}

- (BOOL)requestDidFinish:(id)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        NSDictionary *dic = [obj getDictionaryForKey:@"data"];
        User * user = [User objWithJsonDic:dic];
        // 注册成功后 自动登录－保存账户信息
        [[BSEngine currentEngine] setCurrentUser:user password:passwordLabel.text];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:nameLabel.text forKey:KBSLoginUserName];
        [defaults setObject:passwordLabel.text forKey:KBSLoginPassWord];
        [defaults synchronize];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    return NO;
}

- (IBAction)btnAgreement:(id)sender {
    HelpViewController* controller = [[HelpViewController alloc] init];
    controller.type = 1;
    [self pushViewController:controller];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self resignAllKeyboard:self.view];
}

@end
