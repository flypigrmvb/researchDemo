//
//  PasswordViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "PasswordViewController.h"
#import "AppDelegate.h"
#import "TextInput.h"

@interface PasswordViewController ()
{
    IBOutlet KTextField *oldField;
    IBOutlet KTextField *newField;
    IBOutlet KTextField *confirmField;
    IBOutlet UIButton   *confirmButton;
}
@end

@implementation PasswordViewController

- (id)init
{
    self = [super initWithNibName:@"PasswordViewController" bundle:NULL];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    Release(oldField);
    Release(newField);
    Release(confirmField);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setEdgesNone];
    
    [confirmButton infoStyle];
    
    [oldField infoStyle];
    [newField infoStyle];
    [confirmField infoStyle];
    [oldField enableBorder];
    [newField enableBorder];
    [confirmField enableBorder];
    self.navigationItem.title = @"修改密码";
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [oldField resignFirstResponder];
    [newField resignFirstResponder];
    [confirmField resignFirstResponder];
}

- (IBAction)reSetPassword:(id)sender
{
    [(KTextField*)currentInputView resignFirstResponder];
    if (oldField.text.length == 0) {
        [self showText:@"请输入原来的密码！"];
        [oldField shakeAlert];
        return;
    }
    if (newField.text.length == 0) {
        [self showText:@"请输入新的密码！"];
        [newField shakeAlert];
        return;
    }
    if (confirmField.text.length == 0) {
        [self showText:@"请输入确认密码！"];
        [confirmField shakeAlert];
        return;
    }
    if (![confirmField.text isEqualToString:newField.text]) {
        [self showText:@"确认密码和新的密码不一致！"];
        [confirmField shakeAlert];
        return;
    }
    
    [super startRequest];
    [client changePassword:oldField.text new:newField.text];
}

- (BOOL)requestDidFinish:(BSClient*)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        [self showText:sender.errorMessage];
        [self popViewController];
    }
    return NO;
}

- (void)kwAlertView:(id)sender didDismissWithButtonIndex:(NSInteger)index {
    [[AppDelegate instance] signOut];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)sender {
    currentInputView = sender;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)sender {
    if (sender == oldField) {
        [newField becomeFirstResponder];
    } else if (sender == newField) {
        [confirmField becomeFirstResponder];
    } else {
        [sender resignFirstResponder];
        [self reSetPassword:nil];
    }
    return YES;
}
@end
