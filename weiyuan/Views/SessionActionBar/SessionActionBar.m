//
//  SessionActionBar.m
//
//  AppDelegate.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "SessionActionBar.h"
#import "EmotionInputView.h"
#import "UIColor+FlatUI.h"
@import QuartzCore.QuartzCore;

@implementation SessionActionBar {
    UIButton * btnKeyboard;
    UIButton * btnKeyboardTalk;
    UIButton * btnMore;
    UIButton * btnTalk;
    UIButton * btnEmo;
    EmotionInputView    * emojiView;
}

@synthesize textView;
@synthesize talkingState;
@synthesize state;
@synthesize talkState;
@synthesize sessionDelegate;
@synthesize inputView;

- (id)initWithOrigin:(CGPoint)origin {
    self = [super initWithFrame:CGRectMake(origin.x, origin.y, Main_Screen_Width, 44)];
    if (self) {
        // Initialization code
        CGFloat originX = 6.f;
        CGFloat originY = 7;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(originX, originY, 30, 30);
        [btn setImage:LOADIMAGE(@"talk_btn_key_s") forState:UIControlStateNormal];
        [btn setImage:LOADIMAGE(@"talk_btn_key_d") forState:UIControlStateHighlighted];
        [btn setImage:LOADIMAGE(@"talk_btn_keyboard") forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(btnKeyboardPress:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        btnKeyboard = btn;
        btn = nil;
        
        originX += 35.f;
        
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(originX, originY, 30, 30);
        [btn setImage:LOADIMAGE(@"talk_btn_key_more") forState:UIControlStateNormal];
        [btn setImage:LOADIMAGE(@"talk_btn_key_minus") forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(btnMoreViewPress:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        btnMore = btn;
        btn = nil;
        
        originX += 35.f;
        UITextView * kTextView = [[UITextView alloc] initWithFrame:CGRectMake(originX,
                                                                              originY,
                                                                              Main_Screen_Width -  (originX + 60),
                                                                              30)];
        kTextView.returnKeyType = UIReturnKeyDone;
        kTextView.font = [UIFont systemFontOfSize:14];
        kTextView.layer.cornerRadius = 4;
        kTextView.layer.borderWidth = 1;
        kTextView.layer.borderColor = RGBCOLOR(206, 206, 206).CGColor;
        [self addSubview:kTextView];
        self.textView = kTextView;
        originX += kTextView.width + 5;
        
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn navBlackStyle];
        btn.frame = CGRectMake(originX, originY, 47, 29);
        [btn setTitle:@"发送" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];

        self.backgroundColor = RGBCOLOR(243, 243, 243);
        
        // keyboardInputView
        self.inputView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 150)];
        originY = 20;
        originX = 25;
        for (int i=0; i<6;i++) {
            btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(originX, originY, 45, 45);
            btn.tag = i;
            NSString *str = [NSString stringWithFormat:@"SessionBarIcon%d",i];
            [btn setImage:LOADIMAGE(str) forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(btnItemPressed:) forControlEvents:UIControlEventTouchUpInside];
            [inputView addSubview:btn];
            btn = nil;
            if (i == 3) {
                originY += 65;
                originX = 25;
            } else {
                originX += 75;
            }
        }
        self.inputView.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void) dealloc {
    self.textView = nil;
    self.sessionDelegate = nil;
    self.inputView = nil;
    Release(btnKeyboard);
    Release(btnMore);
    Release(btnKeyboardTalk);
    Release(btnTalk);
    Release(emojiView);
}

- (void)sendMessage {
    if (textView.text.length > 0) {
//        [self setClose:YES];
        if ([sessionDelegate respondsToSelector:@selector(actionBarSendMessage:)]) {
            [sessionDelegate actionBarSendMessage:textView.text];
        }
    }
}

- (void)setText:(NSString*)t {
    if (textView.text && textView.text.length > 0) {
        textView.text = [NSString stringWithFormat:@"%@%@", textView.text, t];
    } else {
        textView.text = t;
    }
}

- (void)setTalkingState:(BOOL)sts {
    if (talkingState != sts) {
        talkingState = sts;
        btnKeyboardTalk.hidden = sts;
    }
}

- (void)setTalkState:(TalkState)ts {
    talkState = ts;
    if (ts == TalkStateNone) {
        [self setClose:YES];
    }
}

- (void)setState:(ActionBarState)sts {
    if (state != sts) {
        state = sts;
    }
    if (sts == ActionBarStateReInsert) {
        self.textView.inputView = nil;
        [self.textView resignFirstResponder];
    } else if (sts == ActionBarStateInsert){
        self.textView.inputView = self.inputView;
        [self.textView becomeFirstResponder];
    } else if (sts == ActionBarStateEmotion){
        if (emojiView == nil) {
            emojiView = [[EmotionInputView alloc] initWithOrigin:CGPointMake(0, 44) del:self];
        }
        self.textView.inputView = emojiView;
        [self.textView becomeFirstResponder];
    }
}

- (void)btnMoreViewPress:(UIButton*)sender {
    btnMore.selected = !btnMore.selected;
    self.talkingState = NO;
    textView.hidden = talkingState;
    btnTalk.hidden = !talkingState;
    btnKeyboard.selected = NO;
    
    [self.textView resignFirstResponder];
    self.state = btnMore.selected?ActionBarStateInsert:ActionBarStateReInsert;
    if ([sessionDelegate respondsToSelector:@selector(actionBarDidChangeState:)]) {
        [sessionDelegate actionBarDidChangeState:state];
    }
}

- (void)btnItemPressed:(UIButton *)sender {
    if (sender.tag == 0) {
        [self.textView resignFirstResponder];
        btnMore.selected = YES;
        self.state = ActionBarStateEmotion;
    } else if (sender.tag == 1) {
        state = ActionBarStateCamera;
        [self.textView resignFirstResponder];
    } else if (sender.tag == 2) {
        state = ActionBarStatePhoto;
        [self.textView resignFirstResponder];
    } else if (sender.tag == 3) {
        state = ActionBarStateMap;
        [self.textView resignFirstResponder];
    } else if (sender.tag == 4) {
        [self.textView resignFirstResponder];
        state = ActionBarStateNameCard;
    } else if (sender.tag == 5) {
        [self.textView resignFirstResponder];
        state = ActionBarStateMyFav;
    }
    if ([sessionDelegate respondsToSelector:@selector(actionBarDidChangeState:)]) {
        [sessionDelegate actionBarDidChangeState:state];
    }
}

- (void)setClose:(BOOL)close {
    btnMore.selected = NO;
    self.state = ActionBarStateReInsert;
}

- (void)btnKeyboardPress:(UIButton*)sender {
    sender.selected = !sender.selected;
    self.talkingState = !talkingState;
    textView.hidden = talkingState;
    if (!btnTalk) {
        btnTalk = [UIButton buttonWithType:UIButtonTypeCustom];
        btnTalk.frame = textView.frame;
        [btnTalk setTitle:@"按住说话" forState:UIControlStateNormal];
        [btnTalk commonStyle];
        [btnTalk setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [self addSubview:btnTalk];
        [btnTalk addTarget:self action:@selector(btnRecordDragInside:) forControlEvents:UIControlEventTouchDragInside];
        [btnTalk addTarget:self action:@selector(btnRecordDragOutside:) forControlEvents:UIControlEventTouchDragOutside];
        [btnTalk addTarget:self action:@selector(btnRecordTouchCancel:) forControlEvents:UIControlEventTouchUpOutside];
        [btnTalk addTarget:self action:@selector(btnRecordTouchDown:) forControlEvents:UIControlEventTouchDown];
        [btnTalk addTarget:self action:@selector(btnRecordTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    }
    btnTalk.hidden = !talkingState;
    self.state = (talkingState) ? 1 : 0;
    if ([sessionDelegate respondsToSelector:@selector(actionBarDidChangeState:)]) {
        [sessionDelegate actionBarDidChangeState:state];
    }
    if (talkingState) {
        [textView resignFirstResponder];
        btnMore.selected = NO;
    }
}

- (void)btnInsertPress:(id)sender {
    self.talkingState = NO;
    textView.hidden = NO;
    btnTalk.hidden = YES;
    self.state = 2;
    if ([sessionDelegate respondsToSelector:@selector(actionBarDidChangeState:)]) {
        [sessionDelegate actionBarDidChangeState:state];
    }
}

- (void)btnRecordTouchDown:(id)sender {
    self.talkingState = TalkStateTalking;
    if ([sessionDelegate respondsToSelector:@selector(actionBarTalkStateChanged:)]) {
        [sessionDelegate actionBarTalkStateChanged:TalkStateTalking];
    }
}
- (void)btnRecordTouchUp:(id)sender {
    if ([sessionDelegate respondsToSelector:@selector(actionBarTalkFinished)]) {
        [sessionDelegate actionBarTalkFinished];
    }
}

- (void)btnRecordTouchCancel:(id)sender {
    if ([sessionDelegate respondsToSelector:@selector(actionBarTalkStateChanged:)]) {
        [sessionDelegate actionBarTalkStateChanged:TalkStateNone];
    }
}

- (void)btnRecordDragInside:(id)sender {
    if ([sessionDelegate respondsToSelector:@selector(actionBarTalkStateChanged:)]) {
        [sessionDelegate actionBarTalkStateChanged:TalkStateTalking];
    }
}

- (void)btnRecordDragOutside:(id)sender {
    if ([sessionDelegate respondsToSelector:@selector(actionBarTalkStateChanged:)]) {
        [sessionDelegate actionBarTalkStateChanged:TalkStateCanceling];
    }
}

#pragma mark - EmotionInputViewDelegate
- (void)emotionInputView:(id)sender output:(NSString*)str {
    if ([textView.text isKindOfClass:[NSString class]] && textView.text.length > 0) {
        textView.text = [NSString stringWithFormat:@"%@%@", textView.text, [EmotionInputView emojiText4To5:str]];
    } else {
        textView.text = [EmotionInputView emojiText4To5:str];
    }
}

- (void)emotionInputView:(id)sender otherOutput:(NSString*)str {
    self.state = ActionBarStateEmotion;
    if ([sessionDelegate respondsToSelector:@selector(actionBarDidChangeState:)]) {
        [sessionDelegate actionBarDidChangeState:state];
    }
}

@end
