//
//  TalkingRecordView.h
//  CarPool
//
//  Created by kiwi on 6/20/13.
//  Copyright (c) 2013 xizue. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TalkingRecordView;

@protocol TalkingRecordViewDelegate <NSObject>
@optional
- (void)recordView:(TalkingRecordView*)sender didFinish:(NSString*)path duration:(NSTimeInterval)du;
@end

@interface TalkingRecordView : UIView

@property (nonatomic, assign) id <TalkingRecordViewDelegate> delegate;
@property (nonatomic, assign) int state;
@property (nonatomic, retain) NSString * audioFileSavePath;

- (id)initWithFrame:(CGRect)frame del:(id)del;
- (void)recordCancel;
- (void)recordEnd;

@end
