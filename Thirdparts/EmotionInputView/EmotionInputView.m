//
//  EmotionInputView.m
//  CarPool
//
//  Created by kiwi on 6/8/13.
//  Copyright (c) 2013 Kiwaro. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "EmotionInputView.h"

#define EPreviewW 50
#define EPreviewH 70

@implementation EmotionInputView
@synthesize delegate;

- (id)initWithOrigin:(CGPoint)point del:(id)del {
    if (self = [super initWithFrame:CGRectMake(point.x, point.y, 320.0f, 145)]) {
        self.delegate = del;
        [self initDefault];
    }
    return self;
}

- (void)initDefault {
    // Initialization code
    self.backgroundColor = RGBCOLOR(255, 255, 255);
    [self generateInputView];
}

- (NSString*)emoji:(int)emj {
    return [NSString stringWithFormat:@"[emoji_%d]", emj];
}

- (void)generateInputView {
    keyPad0 = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, self.frame.size.height - 38)];
    keyPad0.backgroundColor = [UIColor clearColor];
    keyPad0.delegate = self;
    keyPad0.tag = 0;
    keyPad0.showsHorizontalScrollIndicator = NO;
    keyPad0.clipsToBounds = NO;
    [self addKeysOnPad0];
    [self addSubview:keyPad0];
}

- (void)addKeysOnPad0 {
    NSArray * keys = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"emoji2text" ofType:@"plist"]];
    int pages = 1;
    int height = 0;
	
	UIButton * key0;
    int pointX = 6;
	int m = 0;
	for (int n = 0; n < keys.count; n++) {
		if (n != 0 && n%7 == 0) {
			height += 41;
			m = 0;
            if (height >= 123) {
                height = 0;
                pointX += 320;
                pages ++;
            }
		}
        NSString * imgName = [keys objectAtIndex:n];
		key0 = [UIButton buttonWithType:UIButtonTypeCustom];
		[key0 setFrame:CGRectMake(pointX+(m*44), height, 40, 40)];
		[key0 setTitle:imgName forState:UIControlStateNormal];
		[key0 addTarget:self action:@selector(keyEmotionClick:) forControlEvents:UIControlEventTouchUpInside];
		[keyPad0 addSubview:key0];
		m++;
	}
    
    keyPad0.contentSize = CGSizeMake(pages*320, 0);
    keyPad0.pagingEnabled = YES;
    
    UIPageControl * pageC = [[UIPageControl alloc] init];
    pageC.width = keyPad0.width - 20;
    if (Sys_Version >= 6) {
        pageC.pageIndicatorTintColor = [UIColor grayColor];
        pageC.currentPageIndicatorTintColor = [UIColor redColor];
    }
    pageC.numberOfPages = pages;
    pageC.center = CGPointMake(self.width/2, self.height - 20);
    [self addSubview:pageC];
    pageCtrl0 = pageC;
}

#pragma mark - Key Actions
- (void)btnKey0:(UIButton*)sender {
    btnEnmotionKey0.selected = NO;
    keyPad0.hidden = YES;
    pageCtrl0.hidden = YES;

}

- (void)keyEmotionClick:(UIButton*)sender {
    if ([delegate respondsToSelector:@selector(emotionInputView:output:)]) {
        [delegate emotionInputView:self output:sender.titleLabel.text];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    CGFloat offsetX = sender.contentOffset.x;
    pageCtrl0.currentPage = (offsetX+160)/320;
}

#pragma mark - Static Actions
+ (NSString*)encodeMessageEmoji:(NSString*)text {
    NSString * msg = [self emojiText5To4:text];
    NSMutableString * res = [NSMutableString string];
    for (int i = 0; i < msg.length; i ++) {
        NSRange ran = NSMakeRange(i, 1);
        NSString * str = [msg substringWithRange:ran];
        str = [EmotionInputView emojiCodeToEMJ:str];
        [res appendString:str];
    }
    return res;
}

+ (NSString*)emojiCodeToEMJ:(NSString*)acode {
    unsigned short * utfString = (unsigned short*)[acode cStringUsingEncoding:NSUTF16StringEncoding];
    unsigned short val = *utfString;
    if ((0xE001<= val <= 0xE05A) || (0xE101<= val <= 0xE15A) || (0xE201<= val <= 0xE253) || (0xE301<= val <= 0xE34D) || (0xE401<= val <= 0xE44C) || (0xE501<= val <= 0xE537)) {
        int emj = (val & 0x00FF) - 1;

        switch (val & 0x0F00) {
            case 0x0000:
                break;
            case 0x0100:
                emj += 90;
                break;
            case 0x0200:
                emj += (90 + 90);
                break;
            case 0x0300:
                emj += (90 + 90 + 83);
                break;
            case 0x0400:
                emj += (90 + 90 + 83 + 77);
                break;
            case 0x0500:
                emj += (90 + 90 + 83 + 77 + 76);
                break;
            default:
                return nil;
                break;
        }
        return [NSString stringWithFormat:@"[emoji_%d]", emj];
    } else {
        return acode;
    }
}

+ (NSString*)decodeMessageEmoji:(NSString*)msg {
    NSMutableString * res = [NSMutableString string];
    NSString *text = [NSString stringWithFormat:@"%@",msg];
    NSInteger stringIndex = 0;
    for (;stringIndex < msg.length;) {
        NSRange range = [text rangeOfString:@"[emoji_"];
         NSRange range1 = [text rangeOfString:@"]"];
        if (range.length == 0 || range1.length == 0) {
            [res appendString:text];
            break;
        } else {
            if (range.location > 0) {
                [res appendString:[text substringWithRange:NSMakeRange(0, range.location)]];
            }
            NSString * emojiString = [text substringWithRange:NSMakeRange(range.location,range1.location-range.location+1)];
            NSString * num = [emojiString substringWithRange:NSMakeRange(7, emojiString.length-8)];
            unsigned short emj = [num intValue];
            if (emj >= 0 || emj <= 470) {
                if (emj < 90) {
                    [res appendFormat:@"%C", (unsigned short)(emj + 0xE001)];
                } else if (emj < 90 + 90) {
                    emj -= 90;
                    [res appendFormat:@"%C", (unsigned short)(emj + 0xE101)];
                } else if (emj < 90 + 90 + 83) {
                    emj -= (90 + 90);
                    [res appendFormat:@"%C", (unsigned short)(emj + 0xE201)];
                } else if (emj < 90 + 90 + 83 + 77) {
                    emj -= (90 + 90 + 83);
                    [res appendFormat:@"%C", (unsigned short)(emj + 0xE301)];
                } else if (emj < 90 + 90 + 83 + 77 + 76) {
                    emj -= (90 + 90 + 83 + 77);
                    [res appendFormat:@"%C", (unsigned short)(emj + 0xE401)];
                } else if (emj < 90 + 90 + 83 + 77 + 76 + 55) {
                    emj -= (90 + 90 + 83 + 77 + 76);
                    [res appendFormat:@"%C", (unsigned short)(emj + 0xE501)];
                }
            } else {
                [res appendString:emojiString];
            }
            text = [text substringWithRange:NSMakeRange(range1.location+1, text.length-range1.location-1)];
        }
    }
    return [self emojiText4To5:res];
}



static NSArray * _map5 = nil;
static NSArray * _map4 = nil;

+ (void)emojiMapping {
    if (_map5 == nil) {
        _map5 = [NSArray arrayWithObjects:
                  @"\u2196",
                  @"\u2197",
                  @"\u2198",
                  @"\u2199",
                  @"\u23E9",
                  @"\u23EA",
                  @"\u25B6",
                  @"\u25C0",
                  @"\u2600",
                  @"\u2601",
                  @"\u260E",
                  @"\u2614",
                  @"\u2615",
                  @"\u261D",
                  @"\u263A",
                  @"\u2648",
                  @"\u2649",
                  @"\u264A",
                  @"\u264B",
                  @"\u264C",
                  @"\u264D",
                  @"\u264E",
                  @"\u264F",
                  @"\u2650",
                  @"\u2651",
                  @"\u2652",
                  @"\u2653",
                  @"\u2660",
                  @"\u2663",
                  @"\u2665",
                  @"\u2666",
                  @"\u2668",
                  @"\u267F",
                  @"\u26A0",
                  @"\u26A1",
                  @"\u26BD",
                  @"\u26BE",
                  @"\u26C4",
                  @"\u26CE",
                  @"\u26EA",
                  @"\u26F2",
                  @"\u26F3",
                  @"\u26F5",
                  @"\u26FA",
                  @"\u26FD",
                  @"\u2702",
                  @"\u2708",
                  @"\u270A",
                  @"\u270B",
                  @"\u270C",
                  @"\u2728",
                  @"\u2733",
                  @"\u2734",
                  @"\u274C",
                  @"\u2753",
                  @"\u2754",
                  @"\u2755",
                  @"\u2757",
                  @"\u2764",
                  @"\u27A1",
                  @"\u27BF",
                  @"\u2B05",
                  @"\u2B06",
                  @"\u2B07",
                  @"\u2B50",
                  @"\u2B55",
                  @"\u303D",
                  @"\u3297",
                  @"\u3299",
                  @"\U0001F004",
                  @"\U0001F170",
                  @"\U0001F171",
                  @"\U0001F17E",
                  @"\U0001F17F",
                  @"\U0001F18E",
                  @"\U0001F192",
                  @"\U0001F194",
                  @"\U0001F195",
                  @"\U0001F197",
                  @"\U0001F199",
                  @"\U0001F19A",
                  @"\U0001F1E8\U0001F1F3",
                  @"\U0001F1E9\U0001F1EA",
                  @"\U0001F1EA\U0001F1F8",
                  @"\U0001F1EB\U0001F1F7",
                  @"\U0001F1EC\U0001F1E7",
                  @"\U0001F1EE\U0001F1F9",
                  @"\U0001F1EF\U0001F1F5",
                  @"\U0001F1F0\U0001F1F7",
                  @"\U0001F1F7\U0001F1FA",
                  @"\U0001F1FA\U0001F1F8",
                  @"\U0001F201",
                  @"\U0001F202",
                  @"\U0001F21A",
                  @"\U0001F22F",
                  @"\U0001F233",
                  @"\U0001F235",
                  @"\U0001F236",
                  @"\U0001F237",
                  @"\U0001F238",
                  @"\U0001F239",
                  @"\U0001F23A",
                  @"\U0001F250",
                  @"\U0001F300",
                  @"\U0001F302",
                  @"\U0001F303",
                  @"\U0001F304",
                  @"\U0001F305",
                  @"\U0001F306",
                  @"\U0001F307",
                  @"\U0001F308",
                  @"\U0001F30A",
                  @"\U0001F319",
                  @"\U0001F31F",
                  @"\U0001F334",
                  @"\U0001F335",
                  @"\U0001F337",
                  @"\U0001F338",
                  @"\U0001F339",
                  @"\U0001F33A",
                  @"\U0001F33B",
                  @"\U0001F33E",
                  @"\U0001F340",
                  @"\U0001F341",
                  @"\U0001F342",
                  @"\U0001F343",
                  @"\U0001F345",
                  @"\U0001F346",
                  @"\U0001F349",
                  @"\U0001F34A",
                  @"\U0001F34E",
                  @"\U0001F353",
                  @"\U0001F354",
                  @"\U0001F358",
                  @"\U0001F359",
                  @"\U0001F35A",
                  @"\U0001F35B",
                  @"\U0001F35C",
                  @"\U0001F35D",
                  @"\U0001F35E",
                  @"\U0001F35F",
                  @"\U0001F361",
                  @"\U0001F362",
                  @"\U0001F363",
                  @"\U0001F366",
                  @"\U0001F367",
                  @"\U0001F370",
                  @"\U0001F371",
                  @"\U0001F372",
                  @"\U0001F373",
                  @"\U0001F374",
                  @"\U0001F375",
                  @"\U0001F376",
                  @"\U0001F378",
                  @"\U0001F37A",
                  @"\U0001F37B",
                  @"\U0001F380",
                  @"\U0001F381",
                  @"\U0001F382",
                  @"\U0001F383",
                  @"\U0001F384",
                  @"\U0001F385",
                  @"\U0001F386",
                  @"\U0001F387",
                  @"\U0001F388",
                  @"\U0001F389",
                  @"\U0001F38C",
                  @"\U0001F38D",
                  @"\U0001F38E",
                  @"\U0001F38F",
                  @"\U0001F390",
                  @"\U0001F391",
                  @"\U0001F392",
                  @"\U0001F393",
                  @"\U0001F3A1",
                  @"\U0001F3A2",
                  @"\U0001F3A4",
                  @"\U0001F3A5",
                  @"\U0001F3A6",
                  @"\U0001F3A7",
                  @"\U0001F3A8",
                  @"\U0001F3A9",
                  @"\U0001F3AB",
                  @"\U0001F3AC",
                  @"\U0001F3AF",
                  @"\U0001F3B0",
                  @"\U0001F3B1",
                  @"\U0001F3B5",
                  @"\U0001F3B6",
                  @"\U0001F3B7",
                  @"\U0001F3B8",
                  @"\U0001F3BA",
                  @"\U0001F3BE",
                  @"\U0001F3BF",
                  @"\U0001F3C0",
                  @"\U0001F3C1",
                  @"\U0001F3C3",
                  @"\U0001F3C4",
                  @"\U0001F3C6",
                  @"\U0001F3C8",
                  @"\U0001F3CA",
                  @"\U0001F3E0",
                  @"\U0001F3E2",
                  @"\U0001F3E3",
                  @"\U0001F3E5",
                  @"\U0001F3E6",
                  @"\U0001F3E7",
                  @"\U0001F3E8",
                  @"\U0001F3E9",
                  @"\U0001F3EA",
                  @"\U0001F3EB",
                  @"\U0001F3EC",
                  @"\U0001F3ED",
                  @"\U0001F3EF",
                  @"\U0001F3F0",
                  @"\U0001F40D",
                  @"\U0001F40E",
                  @"\U0001F411",
                  @"\U0001F412",
                  @"\U0001F414",
                  @"\U0001F417",
                  @"\U0001F418",
                  @"\U0001F419",
                  @"\U0001F41A",
                  @"\U0001F41B",
                  @"\U0001F41F",
                  @"\U0001F420",
                  @"\U0001F424",
                  @"\U0001F426",
                  @"\U0001F427",
                  @"\U0001F428",
                  @"\U0001F42B",
                  @"\U0001F42C",
                  @"\U0001F42D",
                  @"\U0001F42E",
                  @"\U0001F42F",
                  @"\U0001F430",
                  @"\U0001F431",
                  @"\U0001F433",
                  @"\U0001F434",
                  @"\U0001F435",
                  @"\U0001F436",
                  @"\U0001F437",
                  @"\U0001F438",
                  @"\U0001F439",
                  @"\U0001F43A",
                  @"\U0001F43B",
                  @"\U0001F440",
                  @"\U0001F442",
                  @"\U0001F443",
                  @"\U0001F444",
                  @"\U0001F446",
                  @"\U0001F447",
                  @"\U0001F448",
                  @"\U0001F449",
                  @"\U0001F44A",
                  @"\U0001F44B",
                  @"\U0001F44C",
                  @"\U0001F44D",
                  @"\U0001F44E",
                  @"\U0001F44F",
                  @"\U0001F450",
                  @"\U0001F451",
                  @"\U0001F452",
                  @"\U0001F454",
                  @"\U0001F455",
                  @"\U0001F457",
                  @"\U0001F458",
                  @"\U0001F459",
                  @"\U0001F45C",
                  @"\U0001F45F",
                  @"\U0001F460",
                  @"\U0001F461",
                  @"\U0001F462",
                  @"\U0001F463",
                  @"\U0001F466",
                  @"\U0001F467",
                  @"\U0001F468",
                  @"\U0001F469",
                  @"\U0001F46B",
                  @"\U0001F46E",
                  @"\U0001F46F",
                  @"\U0001F471",
                  @"\U0001F472",
                  @"\U0001F473",
                  @"\U0001F474",
                  @"\U0001F475",
                  @"\U0001F476",
                  @"\U0001F477",
                  @"\U0001F478",
                  @"\U0001F47B",
                  @"\U0001F47C",
                  @"\U0001F47D",
                  @"\U0001F47E",
                  @"\U0001F47F",
                  @"\U0001F480",
                  @"\U0001F481",
                  @"\U0001F482",
                  @"\U0001F483",
                  @"\U0001F484",
                  @"\U0001F485",
                  @"\U0001F486",
                  @"\U0001F487",
                  @"\U0001F488",
                  @"\U0001F489",
                  @"\U0001F48A",
                  @"\U0001F48B",
                  @"\U0001F48D",
                  @"\U0001F48E",
                  @"\U0001F48F",
                  @"\U0001F490",
                  @"\U0001F491",
                  @"\U0001F492",
                  @"\U0001F493",
                  @"\U0001F494",
                  @"\U0001F497",
                  @"\U0001F498",
                  @"\U0001F499",
                  @"\U0001F49A",
                  @"\U0001F49B",
                  @"\U0001F49C",
                  @"\U0001F49D",
                  @"\U0001F49F",
                  @"\U0001F4A1",
                  @"\U0001F4A2",
                  @"\U0001F4A3",
                  @"\U0001F4A4",
                  @"\U0001F4A6",
                  @"\U0001F4A8",
                  @"\U0001F4A9",
                  @"\U0001F4AA",
                  @"\U0001F4B0",
                  @"\U0001F4B1",
                  @"\U0001F4B9",
                  @"\U0001F4BA",
                  @"\U0001F4BB",
                  @"\U0001F4BC",
                  @"\U0001F4BD",
                  @"\U0001F4BF",
                  @"\U0001F4C0",
                  @"\U0001F4D6",
                  @"\U0001F4DD",
                  @"\U0001F4E0",
                  @"\U0001F4E1",
                  @"\U0001F4E2",
                  @"\U0001F4E3",
                  @"\U0001F4E9",
                  @"\U0001F4EB",
                  @"\U0001F4EE",
                  @"\U0001F4F1",
                  @"\U0001F4F2",
                  @"\U0001F4F3",
                  @"\U0001F4F4",
                  @"\U0001F4F6",
                  @"\U0001F4F7",
                  @"\U0001F4FA",
                  @"\U0001F4FB",
                  @"\U0001F4FC",
                  @"\U0001F50A",
                  @"\U0001F50D",
                  @"\U0001F511",
                  @"\U0001F512",
                  @"\U0001F513",
                  @"\U0001F514",
                  @"\U0001F51D",
                  @"\U0001F51E",
                  @"\U0001F525",
                  @"\U0001F528",
                  @"\U0001F52B",
                  @"\U0001F52F",
                  @"\U0001F530",
                  @"\U0001F531",
                  @"\U0001F532",
                  @"\U0001F533",
                  @"\U0001F534",
                  @"\U0001F550",
                  @"\U0001F551",
                  @"\U0001F552",
                  @"\U0001F553",
                  @"\U0001F554",
                  @"\U0001F555",
                  @"\U0001F556",
                  @"\U0001F557",
                  @"\U0001F558",
                  @"\U0001F559",
                  @"\U0001F55A",
                  @"\U0001F55B",
                  @"\U0001F5FB",
                  @"\U0001F5FC",
                  @"\U0001F5FD",
                  @"\U0001F601",
                  @"\U0001F602",
                  @"\U0001F603",
                  @"\U0001F604",
                  @"\U0001F609",
                  @"\U0001F60A",
                  @"\U0001F60C",
                  @"\U0001F60D",
                  @"\U0001F60F",
                  @"\U0001F612",
                  @"\U0001F613",
                  @"\U0001F614",
                  @"\U0001F616",
                  @"\U0001F618",
                  @"\U0001F61A",
                  @"\U0001F61C",
                  @"\U0001F61D",
                  @"\U0001F61E",
                  @"\U0001F620",
                  @"\U0001F621",
                  @"\U0001F622",
                  @"\U0001F623",
                  @"\U0001F625",
                  @"\U0001F628",
                  @"\U0001F62A",
                  @"\U0001F62D",
                  @"\U0001F630",
                  @"\U0001F631",
                  @"\U0001F632",
                  @"\U0001F633",
                  @"\U0001F637",
                  @"\U0001F645",
                  @"\U0001F646",
                  @"\U0001F647",
                  @"\U0001F64C",
                  @"\U0001F64F",
                  @"\U0001F680",
                  @"\U0001F683",
                  @"\U0001F684",
                  @"\U0001F685",
                  @"\U0001F687",
                  @"\U0001F689",
                  @"\U0001F68C",
                  @"\U0001F68F",
                  @"\U0001F691",
                  @"\U0001F692",
                  @"\U0001F693",
                  @"\U0001F695",
                  @"\U0001F697",
                  @"\U0001F699",
                  @"\U0001F69A",
                  @"\U0001F6A2",
                  @"\U0001F6A4",
                  @"\U0001F6A5",
                  @"\U0001F6A7",
                  @"\U0001F6AC",
                  @"\U0001F6AD",
                  @"\U0001F6B2",
                  @"\U0001F6B6",
                  @"\U0001F6B9",
                  @"\U0001F6BA",
                  @"\U0001F6BB",
                  @"\U0001F6BC",
                  @"\U0001F6BD",
                  @"\U0001F6BE",
                  @"\U0001F6C0",
                  @"\u2122",
                  @"\u00A9",
                  @"\u00AE",
                  [NSString stringWithFormat:@"%C%C", (short)0x0023, (short)0x20E3],
                  [NSString stringWithFormat:@"%C%C", (short)0x0030, (short)0x20E3],
                  [NSString stringWithFormat:@"%C%C", (short)0x0031, (short)0x20E3],
                  [NSString stringWithFormat:@"%C%C", (short)0x0032, (short)0x20E3],
                  [NSString stringWithFormat:@"%C%C", (short)0x0033, (short)0x20E3],
                  [NSString stringWithFormat:@"%C%C", (short)0x0034, (short)0x20E3],
                  [NSString stringWithFormat:@"%C%C", (short)0x0035, (short)0x20E3],
                  [NSString stringWithFormat:@"%C%C", (short)0x0036, (short)0x20E3],
                  [NSString stringWithFormat:@"%C%C", (short)0x0037, (short)0x20E3],
                  [NSString stringWithFormat:@"%C%C", (short)0x0038, (short)0x20E3],
                  [NSString stringWithFormat:@"%C%C", (short)0x0039, (short)0x20E3],
                  [NSString stringWithFormat:@"%C%C", (short)0xD83D, (short)0xDEA1],
                 nil];
    }
    if (_map4 == nil) {
        _map4 = [NSArray arrayWithObjects:
                  @"\uE237",
                  @"\uE236",
                  @"\uE238",
                  @"\uE239",
                  @"\uE23C",
                  @"\uE23D",
                  @"\uE23A",
                  @"\uE23B",
                  @"\uE04A",
                  @"\uE049",
                  @"\uE009",
                  @"\uE04B",
                  @"\uE045",
                  @"\uE00F",
                  @"\uE414",
                  @"\uE23F",
                  @"\uE240",
                  @"\uE241",
                  @"\uE242",
                  @"\uE243",
                  @"\uE244",
                  @"\uE245",
                  @"\uE246",
                  @"\uE247",
                  @"\uE248",
                  @"\uE249",
                  @"\uE24A",
                  @"\uE20E",
                  @"\uE20F",
                  @"\uE20C",
                  @"\uE20D",
                  @"\uE123",
                  @"\uE20A",
                  @"\uE252",
                  @"\uE13D",
                  @"\uE018",
                  @"\uE016",
                  @"\uE048",
                  @"\uE24B",
                  @"\uE037",
                  @"\uE121",
                  @"\uE014",
                  @"\uE01C",
                  @"\uE122",
                  @"\uE03A",
                  @"\uE313",
                  @"\uE01D",
                  @"\uE010",
                  @"\uE012",
                  @"\uE011",
                  @"\uE32E",
                  @"\uE206",
                  @"\uE205",
                  @"\uE333",
                  @"\uE020",
                  @"\uE336",
                  @"\uE337",
                  @"\uE021",
                  @"\uE022",
                  @"\uE234",
                  @"\uE211",
                  @"\uE235",
                  @"\uE232",
                  @"\uE233",
                  @"\uE32F",
                  @"\uE332",
                  @"\uE12C",
                  @"\uE30D",
                  @"\uE315",
                  @"\uE12D",
                  @"\uE532",
                  @"\uE533",
                  @"\uE535",
                  @"\uE14F",
                  @"\uE534",
                  @"\uE214",
                  @"\uE229",
                  @"\uE212",
                  @"\uE24D",
                  @"\uE213",
                  @"\uE12E",
                  @"\uE513",
                  @"\uE50E",
                  @"\uE511",
                  @"\uE50D",
                  @"\uE510",
                  @"\uE50F",
                  @"\uE50B",
                  @"\uE514",
                  @"\uE512",
                  @"\uE50C",
                  @"\uE203",
                  @"\uE228",
                  @"\uE216",
                  @"\uE22C",
                  @"\uE22B",
                  @"\uE22A",
                  @"\uE215",
                  @"\uE217",
                  @"\uE218",
                  @"\uE227",
                  @"\uE22D",
                  @"\uE226",
                  @"\uE443",
                  @"\uE43C",
                  @"\uE44B",
                  @"\uE04D",
                  @"\uE449",
                  @"\uE146",
                  @"\uE44A",
                  @"\uE44C",
                  @"\uE43E",
                  @"\uE04C",
                  @"\uE335",
                  @"\uE307",
                  @"\uE308",
                  @"\uE304",
                  @"\uE030",
                  @"\uE032",
                  @"\uE303",
                  @"\uE305",
                  @"\uE444",
                  @"\uE110",
                  @"\uE118",
                  @"\uE119",
                  @"\uE447",
                  @"\uE349",
                  @"\uE34A",
                  @"\uE348",
                  @"\uE346",
                  @"\uE345",
                  @"\uE347",
                  @"\uE120",
                  @"\uE33D",
                  @"\uE342",
                  @"\uE33E",
                  @"\uE341",
                  @"\uE340",
                  @"\uE33F",
                  @"\uE339",
                  @"\uE33B",
                  @"\uE33C",
                  @"\uE343",
                  @"\uE344",
                  @"\uE33A",
                  @"\uE43F",
                  @"\uE046",
                  @"\uE34C",
                  @"\uE34D",
                  @"\uE147",
                  @"\uE043",
                  @"\uE338",
                  @"\uE30B",
                  @"\uE044",
                  @"\uE047",
                  @"\uE30C",
                  @"\uE314",
                  @"\uE112",
                  @"\uE34B",
                  @"\uE445",
                  @"\uE033",
                  @"\uE448",
                  @"\uE117",
                  @"\uE440",
                  @"\uE310",
                  @"\uE312",
                  @"\uE143",
                  @"\uE436",
                  @"\uE438",
                  @"\uE43B",
                  @"\uE442",
                  @"\uE446",
                  @"\uE43A",
                  @"\uE439",
                  @"\uE124",
                  @"\uE433",
                  @"\uE03C",
                  @"\uE03D",
                  @"\uE507",
                  @"\uE30A",
                  @"\uE502",
                  @"\uE503",
                  @"\uE125",
                  @"\uE324",
                  @"\uE130",
                  @"\uE133",
                  @"\uE42C",
                  @"\uE03E",
                  @"\uE326",
                  @"\uE040",
                  @"\uE041",
                  @"\uE042",
                  @"\uE015",
                  @"\uE013",
                  @"\uE42A",
                  @"\uE132",
                  @"\uE115",
                  @"\uE017",
                  @"\uE131",
                  @"\uE42B",
                  @"\uE42D",
                  @"\uE036",
                  @"\uE038",
                  @"\uE153",
                  @"\uE155",
                  @"\uE14D",
                  @"\uE154",
                  @"\uE158",
                  @"\uE501",
                  @"\uE156",
                  @"\uE157",
                  @"\uE504",
                  @"\uE508",
                  @"\uE505",
                  @"\uE506",
                  @"\uE52D",
                  @"\uE134",
                  @"\uE529",
                  @"\uE528",
                  @"\uE52E",
                  @"\uE52F",
                  @"\uE526",
                  @"\uE10A",
                  @"\uE441",
                  @"\uE525",
                  @"\uE019",
                  @"\uE522",
                  @"\uE523",
                  @"\uE521",
                  @"\uE055",
                  @"\uE527",
                  @"\uE530",
                  @"\uE520",
                  @"\uE053",
                  @"\uE52B",
                  @"\uE050",
                  @"\uE52C",
                  @"\uE04F",
                  @"\uE054",
                  @"\uE01A",
                  @"\uE109",
                  @"\uE052",
                  @"\uE10B",
                  @"\uE531",
                  @"\uE524",
                  @"\uE52A",
                  @"\uE051",
                  @"\uE419",
                  @"\uE41B",
                  @"\uE41A",
                  @"\uE41C",
                  @"\uE22E",
                  @"\uE22F",
                  @"\uE230",
                  @"\uE231",
                  @"\uE00D",
                  @"\uE41E",
                  @"\uE420",
                  @"\uE00E",
                  @"\uE421",
                  @"\uE41F",
                  @"\uE422",
                  @"\uE10E",
                  @"\uE318",
                  @"\uE302",
                  @"\uE006",
                  @"\uE319",
                  @"\uE321",
                  @"\uE322",
                  @"\uE323",
                  @"\uE007",
                  @"\uE13E",
                  @"\uE31A",
                  @"\uE31B",
                  @"\uE536",
                  @"\uE001",
                  @"\uE002",
                  @"\uE004",
                  @"\uE005",
                  @"\uE428",
                  @"\uE152",
                  @"\uE429",
                  @"\uE515",
                  @"\uE516",
                  @"\uE517",
                  @"\uE518",
                  @"\uE519",
                  @"\uE51A",
                  @"\uE51B",
                  @"\uE51C",
                  @"\uE11B",
                  @"\uE04E",
                  @"\uE10C",
                  @"\uE12B",
                  @"\uE11A",
                  @"\uE11C",
                  @"\uE253",
                  @"\uE51E",
                  @"\uE51F",
                  @"\uE31C",
                  @"\uE31D",
                  @"\uE31E",
                  @"\uE31F",
                  @"\uE320",
                  @"\uE13B",
                  @"\uE30F",
                  @"\uE003",
                  @"\uE034",
                  @"\uE035",
                  @"\uE111",
                  @"\uE306",
                  @"\uE425",
                  @"\uE43D",
                  @"\uE327",
                  @"\uE023",
                  @"\uE328",
                  @"\uE329",
                  @"\uE32A",
                  @"\uE32B",
                  @"\uE32C",
                  @"\uE32D",
                  @"\uE437",
                  @"\uE204",
                  @"\uE10F",
                  @"\uE334",
                  @"\uE311",
                  @"\uE13C",
                  @"\uE331",
                  @"\uE330",
                  @"\uE05A",
                  @"\uE14C",
                  @"\uE12F",
                  @"\uE149",
                  @"\uE14A",
                  @"\uE11F",
                  @"\uE00C",
                  @"\uE11E",
                  @"\uE316",
                  @"\uE126",
                  @"\uE127",
                  @"\uE148",
                  @"\uE301",
                  @"\uE00B",
                  @"\uE14B",
                  @"\uE142",
                  @"\uE317",
                  @"\uE103",
                  @"\uE101",
                  @"\uE102",
                  @"\uE00A",
                  @"\uE104",
                  @"\uE250",
                  @"\uE251",
                  @"\uE20B",
                  @"\uE008",
                  @"\uE12A",
                  @"\uE128",
                  @"\uE129",
                  @"\uE141",
                  @"\uE114",
                  @"\uE03F",
                  @"\uE144",
                  @"\uE145",
                  @"\uE325",
                  @"\uE24C",
                  @"\uE207",
                  @"\uE11D",
                  @"\uE116",
                  @"\uE113",
                  @"\uE23E",
                  @"\uE209",
                  @"\uE031",
                  @"\uE21A",
                  @"\uE21B",
                  @"\uE219",
                  @"\uE024",
                  @"\uE025",
                  @"\uE026",
                  @"\uE027",
                  @"\uE028",
                  @"\uE029",
                  @"\uE02A",
                  @"\uE02B",
                  @"\uE02C",
                  @"\uE02D",
                  @"\uE02E",
                  @"\uE02F",
                  @"\uE03B",
                  @"\uE509",
                  @"\uE51D",
                  @"\uE404",
                  @"\uE412",
                  @"\uE057",
                  @"\uE415",
                  @"\uE405",
                  @"\uE056",
                  @"\uE40A",
                  @"\uE106",
                  @"\uE402",
                  @"\uE40E",
                  @"\uE108",
                  @"\uE403",
                  @"\uE407",
                  @"\uE418",
                  @"\uE417",
                  @"\uE105",
                  @"\uE409",
                  @"\uE058",
                  @"\uE059",
                  @"\uE416",
                  @"\uE413",
                  @"\uE406",
                  @"\uE401",
                  @"\uE40B",
                  @"\uE408",
                  @"\uE411",
                  @"\uE40F",
                  @"\uE107",
                  @"\uE410",
                  @"\uE40D",
                  @"\uE40C",
                  @"\uE423",
                  @"\uE424",
                  @"\uE426",
                  @"\uE427",
                  @"\uE41D",
                  @"\uE10D",
                  @"\uE01E",
                  @"\uE435",
                  @"\uE01F",
                  @"\uE434",
                  @"\uE039",
                  @"\uE159",
                  @"\uE150",
                  @"\uE431",
                  @"\uE430",
                  @"\uE432",
                  @"\uE15A",
                  @"\uE01B",
                  @"\uE42E",
                  @"\uE42F",
                  @"\uE202",
                  @"\uE135",
                  @"\uE14E",
                  @"\uE137",
                  @"\uE30E",
                  @"\uE208",
                  @"\uE136",
                  @"\uE201",
                  @"\uE138",
                  @"\uE139",
                  @"\uE151",
                  @"\uE13A",
                  @"\uE140",
                  @"\uE309",
                  @"\uE13F",
                  @"\uE537",
                  @"\uE24E",
                  @"\uE24F",
                  @"\uE210",
                  @"\uE225",
                  @"\uE21C",
                  @"\uE21D",
                  @"\uE21E",
                  @"\uE21F",
                  @"\uE220",
                  @"\uE221",
                  @"\uE222",
                  @"\uE223",
                  @"\uE224",
                  @"\uE50A",
                 nil];
    }
}

+ (NSString *)emojiChar5To4:(NSString *)text {
    [self emojiMapping];
    NSString * res = text;
    for (int i = 0; i < _map5.count; i ++) {
        NSString * chr = [_map5 objectAtIndex:i];
        if ([chr isEqualToString:text]) {
            res = [_map4 objectAtIndex:i];
            break;
        }
    }
    return res;
}

+ (NSString *)emojiChar4To5:(NSString *)text {
    [self emojiMapping];
    NSString * res = text;
    for (int i = 0; i < _map4.count; i ++) {
        NSString * chr = [_map4 objectAtIndex:i];
        if ([chr isEqualToString:text]) {
            res = [_map5 objectAtIndex:i];
            break;
        }
    }
    return res;
}

+ (NSString *)emojiText5To4:(NSString *)text {
    [self emojiMapping];
    NSString *ios4 = nil, *ios5 = nil;
    for (int i = 0; i < _map4.count; i ++) {
        ios5 = [_map5 objectAtIndex:i];
        ios4 = [_map4 objectAtIndex:i];
        text = [text stringByReplacingOccurrencesOfString:ios5 withString:ios4];
    }
    return text;
}

+ (NSString *)emojiText4To5:(NSString *)text {
    [self emojiMapping];
    NSString *ios4 = nil, *ios5 = nil;
    for (int i = 0; i < _map4.count; i ++) {
        ios5 = [_map5 objectAtIndex:i];
        ios4 = [_map4 objectAtIndex:i];
        text = [text stringByReplacingOccurrencesOfString:ios4 withString:ios5];
    }
    return text;
}

@end
