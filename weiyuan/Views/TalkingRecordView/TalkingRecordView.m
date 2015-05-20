//
//  TalkingRecordView.m
//  CarPool
//
//  Created by kiwi on 6/20/13.
//  Copyright (c) 2013 xizue. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TalkingRecordView.h"
#import <AVFoundation/AVFoundation.h>
#import "lame.h"
#import "AudioMsgPlayer.h"

@interface TalkingRecordView () <AVAudioRecorderDelegate> {
    UIImageView * iconView;
    UIImageView * powerView;
    UILabel    * labText;
    
    NSTimeInterval duration;
    
    BOOL recording;
}
@property (nonatomic, strong) AVAudioRecorder * recorder;
@property (nonatomic, strong) NSString * audioTemporarySavePath;
@property (nonatomic, strong) NSTimer * timer;
@end

@implementation TalkingRecordView
@synthesize delegate, state, audioFileSavePath;
@synthesize recorder, audioTemporarySavePath, timer;

- (id)initWithFrame:(CGRect)frame del:(id)del {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.delegate = del;
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.9];
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 0;
        self.layer.cornerRadius = 8;
        iconView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 120, 100)];
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:iconView];
        
        powerView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 20, 30, 100)];
        [self addSubview:powerView];
        
        labText = [[UILabel alloc] initWithFrame:CGRectMake(20, 125, 120, 20)];
        labText.backgroundColor = [UIColor clearColor];
        labText.font = [UIFont boldSystemFontOfSize:15];
        labText.textColor = [UIColor whiteColor];
        labText.textAlignment = NSTextAlignmentCenter;
        [self addSubview:labText];
        
        self.audioTemporarySavePath = [NSString stringWithFormat:@"%@/tmp/temporary.dat", NSHomeDirectory()];
        recording = NO;
    }
    return self;
}

- (void)dealloc {
    iconView = nil;
    labText = nil;
    self.timer = nil;
    self.recorder = nil;
    self.audioTemporarySavePath = nil;
    self.audioFileSavePath = nil;
}

- (void)setState:(int)sts {
    if (state != sts) {
        if (sts == 1) {
            powerView.hidden = NO;
            iconView.frame = CGRectMake(20, 20, 120, 100);
            iconView.image = [UIImage imageNamed:@"talk_icon_recoder.png"];
            labText.text = @"录制中...";
            if (!recording) {
                [self recordStart];
            }
        } else if (sts == 2) {
            powerView.hidden = YES;
            iconView.frame = CGRectMake(20, 50, 120, 40);
            iconView.image = [UIImage imageNamed:@"KAlertError.png"];
            labText.text = @"放开手指取消";
        } else {
            iconView.image = nil;
            [self recordCancel];
        }
        state = sts;
    }
}

- (void)recordStart {
    [AudioMsgPlayer cancel];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    
    recording = YES;
    self.audioFileSavePath = [NSString stringWithFormat:@"%@/tmp/%.0f.mp3", NSHomeDirectory(), [NSDate timeIntervalSinceReferenceDate] * 1000];
    if (recorder == nil) {
        NSMutableDictionary *recSet = [[NSMutableDictionary alloc] init];
        [recSet setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey: AVFormatIDKey];
        [recSet setValue :[NSNumber numberWithFloat:8000.f] forKey: AVSampleRateKey];//44100.0
        [recSet setValue :[NSNumber numberWithInt:2] forKey: AVNumberOfChannelsKey];
        //[recSet setValue :[NSNumber numberWithInt:16] forKey: AVLinearPCMBitDepthKey];
        [recSet setValue:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
        NSURL * pathU = nil;
#if TARGET_IPHONE_SIMULATOR
        pathU = [NSURL fileURLWithPath:audioTemporarySavePath isDirectory:NO];
#else
        pathU = [NSURL URLWithString:audioTemporarySavePath];
#endif
        self.recorder = [[AVAudioRecorder alloc] initWithURL:pathU settings:recSet error:nil];
    }
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    if ([recorder prepareToRecord]) {
        powerView.hidden = NO;
        [recorder record];
        [timer invalidate];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.33 target:self selector:@selector(detectionVoice) userInfo:nil repeats:YES];
    }
}

- (void)recordCancel {
    powerView.hidden = YES;
    [timer invalidate];
    self.timer = nil;
    recording = NO;
    recorder.delegate = nil;
    [recorder stop];
    self.recorder = nil;
    state = 0;
}

- (void)recordEnd {
    self.hidden = YES;
    duration = recorder.currentTime;
    powerView.hidden = YES;
    [timer invalidate];
    self.timer = nil;
    recording = NO;
    [recorder stop];
    state = 0;
}

- (void)detectionVoice {
    [recorder updateMeters];//刷新音量数据
    double lowPassResults = pow(10, (0.05 * [recorder peakPowerForChannel:0]));
    //    DLog(@"%lf",lowPassResults);
    //最大50  0
    //图片 小-》大
    if (lowPassResults<=0.10) {
        [powerView setImage:[UIImage imageNamed:@"talk_sound_p1.png"]];
    } else if (lowPassResults<=0.20) {
        [powerView setImage:[UIImage imageNamed:@"talk_sound_p2.png"]];
    } else if (lowPassResults<=0.30) {
        [powerView setImage:[UIImage imageNamed:@"talk_sound_p3.png"]];
    } else if (lowPassResults<=0.40) {
        [powerView setImage:[UIImage imageNamed:@"talk_sound_p4.png"]];
    } else if (lowPassResults<=0.50) {
        [powerView setImage:[UIImage imageNamed:@"talk_sound_p5.png"]];
    } else if (lowPassResults<=0.60) {
        [powerView setImage:[UIImage imageNamed:@"talk_sound_p6.png"]];
    } else {
        [powerView setImage:[UIImage imageNamed:@"talk_sound_p7.png"]];
    }
    if (recorder.currentTime >= 59.5) {
        [self recordEnd];
        [self audio_PCMtoMP3];
        if ([delegate respondsToSelector:@selector(recordView:didFinish:duration:)]) {
            [delegate recordView:self didFinish:audioFileSavePath duration:duration];
        }
        recorder.delegate = nil;
        self.recorder = nil;
    }
}

#pragma mark
#pragma mark - AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)sender successfully:(BOOL)flag {
    if (flag) {
        [self audio_PCMtoMP3];
        if ([delegate respondsToSelector:@selector(recordView:didFinish:duration:)]) {
            [delegate recordView:self didFinish:audioFileSavePath duration:duration];
        }
        recorder.delegate = nil;
        self.recorder = nil;
    }
}

#pragma mark
#pragma mark - Lame

- (void)audio_PCMtoMP3 {
    NSString * mp3FilePath = audioFileSavePath;
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([audioTemporarySavePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 8000.f);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = (int)fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        DLog(@"%@",[exception description]);
    }
    @finally {
        DLog(@"MP3 file generated successfully: %@",audioFileSavePath);
    }
    
}

@end
