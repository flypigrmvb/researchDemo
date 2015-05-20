//
//  SessionActionBar.h
//
//  AppDelegate.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum ActionBarState {
    ActionBarStateText = 0,
    ActionBarStateTalk = 1,
    ActionBarStateMap = 2,
    ActionBarStateEmotion = 3,
    ActionBarStateInsert = 4,
    ActionBarStateReInsert = 5,
    ActionBarStateNameCard = 6,
    ActionBarStateMyFav = 7,
    ActionBarStateCamera = 8,
    ActionBarStatePhoto = 9,
}ActionBarState;


typedef enum TalkState {
    TalkStateNone = 0,
    TalkStateTalking = 1,
    TalkStateCanceling = 2
}TalkState;

typedef void(^SessionActionBlock)(ActionBarState sts, TalkState talkState);

@protocol SessionActionBarDelegate <NSObject>
@optional
- (void)actionBarDidChangeState:(ActionBarState)sts;
- (void)actionBarTalkStateChanged:(TalkState)sts;
- (void)actionBarTalkFinished;
- (BOOL)actionBarSendMessage:(NSString*)msgStr;
@end

@interface SessionActionBar : UIView

@property (nonatomic, strong) UITextView * textView;
@property (nonatomic, assign) IBOutlet id <SessionActionBarDelegate> sessionDelegate;
@property (nonatomic, assign) BOOL talkingState;
@property (nonatomic, assign) TalkState talkState;
@property (nonatomic, assign) ActionBarState state;
@property (nonatomic, strong) UIView * inputView;

- (id)initWithOrigin:(CGPoint)origin;
@end
