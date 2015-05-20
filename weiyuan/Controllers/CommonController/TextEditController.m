//
//  TextEditController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//
#import "TextEditController.h"
#import "TextInput.h"
// 昵称／备注 2-8
// 签名 30
@interface TextEditController () {
    IBOutlet KTextField * textField;
    IBOutlet KTextView * textView;
    IBOutlet UILabel   * labCount;
}
@end

@implementation TextEditController
@synthesize delegate;
@synthesize maxTextCount;
@synthesize minTextCount;
@synthesize title, defaultValue;
@synthesize indexPath;
@synthesize showPicture;

- (id)initWithDel:(id)del type:(TextEditType)type title:(NSString*)tit value:(NSString*)value {
    if (self = [super initWithNibName:@"TextEditController" bundle:nil]) {
        // Custom initialization
        delegate = del;
        _editType = type;
        self.title = tit;
        self.defaultValue = value;
        [self setEdgesNone];
        minTextCount = 0;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    Release(textField);
    Release(textView);
    Release(labCount);
    self.indexPath = nil;
    self.title = nil;
    self.defaultValue = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = title;
    
    [textView setupBackgroundView];
    if (_editType == TextEditTypeMultipleLines) {
        textView.hidden = NO;
        textField.hidden = YES;
        textView.text = defaultValue;
        textView.placeholder = @"";
        labCount.hidden = YES;
//        labCount.hidden = !(maxTextCount > 0);
        if (showPicture) {
            
        }
    } else {
        if (_editType == TextEditTypeNumber)
            textField.keyboardType = UIKeyboardTypeNumberPad;
        textView.hidden = YES;
        textField.hidden = NO;
        textField.text = defaultValue;
        [textField infoStyle];
        labCount.hidden = YES;
    }
    [self setRightBarButton:@"确定" selector:@selector(rightPressd)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_editType == TextEditTypeMultipleLines) {
        [textView becomeFirstResponder];
    } else {
        [textField becomeFirstResponder];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:textView];
    [self textChanged:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:textView];
}

- (void)rightPressd {
    NSString * text = [[self getText] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (text.length < minTextCount) {
        if (minTextCount == 2) {
            [self showText:@"名字限制2-8个字！"];
        } else {
            [self showText:@"抱歉，您输入的文字太短了"];
        }
    } else if (maxTextCount > 0 && text.length > maxTextCount) {
        if (maxTextCount == 8) {
            [self showText:@"名字限制2-8个字！"];
        } else if (maxTextCount == 30) {
            [self showText:@"个性签名限制30个字！"];
        } else if (minTextCount == 0) {
            [self showText:@"备注信息限制8个字！"];
        } else {
            [self showText:@"抱歉，您输入的文字太长了"];
        }
    } else if ([delegate respondsToSelector:@selector(textEditControllerDidEdit:idx:)]) {
        [delegate textEditControllerDidEdit:text idx:self.indexPath];
        [self popViewController];
    }
}

- (NSString*)getText {
    if (_editType == TextEditTypeMultipleLines) {
        return textView.text;
    } else {
        return textField.text;
    }
}

- (void)textChanged:(NSNotification*)notification {
    NSString * text = [self getText];
    NSInteger count = maxTextCount - text.length;
    labCount.textColor = (count >= 0) ? [UIColor lightGrayColor] : RGBCOLOR(200, 0, 0);
    labCount.text = [NSString stringWithFormat:@"%d", (int)count];
}

@end
