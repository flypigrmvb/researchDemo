//
//  BasicNavigationController.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "ResetPasswordViewController.h"
#import "KWAlertView.h"
#import "TextInput.h"
#import "UITextField+Shake.h"

@interface ResetPasswordViewController () {
    IBOutlet KTextField         * phoneField;
    IBOutlet UIButton           * btnSend;
}

@end

@implementation ResetPasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"找回密码";

    [self setEdgesNone];
    [btnSend infoStyle];
    currentInputView = phoneField;
    [phoneField infoStyle];
    
}

- (IBAction)send:(id)sender {
    [phoneField resignFirstResponder];
    if (phoneField.text.length != 11 ) {
        [self showText:@"请输入正确的手机号"];
        [phoneField shakeAlert];
    } else {
        // 提供接口后 请取消注释
//        [super startRequest];
//        [client findPassword:phoneField.text];
    }
}

- (BOOL)requestDidFinish:(id)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        [self showAlert:@"验证码已发送到你的手机上，请注意查收！" isNeedCancel:NO];
    }
    return YES;
}

- (void)kwAlertView:(KWAlertView*)sender didDismissWithButtonIndex:(NSInteger)index {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [phoneField resignFirstResponder];
}


@end
