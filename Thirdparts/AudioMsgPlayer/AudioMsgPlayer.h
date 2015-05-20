//
//  AudioMsgPlayer.h
//  CarPool
//
//  Created by kiwi on 14-1-26.
//  Copyright (c) 2013年 Kiwaro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@class AudioMsgPlayer;
@protocol AudioMsgPlayerDelegate <NSObject>

-(void)audioMsgPlayerDidFinishPlaying:(AudioMsgPlayer*)sender;

@end
@interface AudioMsgPlayer : NSObject <AVAudioPlayerDelegate>
@property (nonatomic, assign) id<AudioMsgPlayerDelegate> audioMsgPlayerDelegate;
+ (void)playWithURL:(NSString*)url delegate:(id)del;
+ (void)cancel;

@end
