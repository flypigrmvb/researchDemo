//
//  EmotionInputView.h
//  CarPool
//
//  Created by kiwi on 6/8/13.
//  Copyright (c) 2013 Kiwaro. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EmotionInputViewDelegate <NSObject>

- (void)emotionInputView:(id)sender output:(NSString*)str;
- (void)emotionInputView:(id)sender otherOutput:(NSString*)str;

@end

@interface EmotionInputView : UIView <UIScrollViewDelegate> {
    UIScrollView * keyPad0;
    //Released
    UIButton * btnEnmotionKey0;
    UIPageControl * pageCtrl0;
}

@property (nonatomic, assign) id <EmotionInputViewDelegate> delegate;

- (id)initWithOrigin:(CGPoint)point del:(id)del;
+ (void)emojiMapping;
+ (NSString*)encodeMessageEmoji:(NSString*)msg;

+ (NSString*)decodeMessageEmoji:(NSString*)msg;

+ (NSString *)emojiText5To4:(NSString *)text;

+ (NSString *)emojiText4To5:(NSString *)text;

@end
