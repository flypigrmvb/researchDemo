//
//  Favorite.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "Favorite.h"
#import "Address.h"
#import "JSON.h"
#import "Globals.h"
#import "EmotionInputView.h"

@implementation Favorite
@synthesize content, fid, nickname, createtime, headsmall, imgUrl, otherid, typefile, uid, value, voiceTime, voiceUrl, address;

+ (CGFloat)HeightOfFavorite:(Favorite*)item {
    CGFloat height = 10 + 16;// 边距＋名字
    if (item.typefile == forFileText) {
        CGSize size = [item.content sizeWithFont:[UIFont systemFontOfSize:14] maxWidth:Main_Screen_Width - 70 maxNumberLines:0];
        height += size.height;
    } else if (item.typefile == forFileImage) {
        height += 50 + 10;
    } else if (item.typefile == forFileVoice) {
        height += 50;
    } else if (item.typefile == forFileAddress) {
        height += 128;
    }
    return height>60?height:60;
}

- (void) updateWithJsonDic:(NSDictionary *)dic {
    isInitSuccuss = NO;
    if (dic != nil && [dic isKindOfClass:[NSDictionary class]]) {
        isInitSuccuss = YES;
    }
    if (isInitSuccuss) {
        fid = [dic getStringValueForKey:@"id" defaultValue:@""];
        createtime = [dic getStringValueForKey:@"createtime" defaultValue:@""];
        uid = [dic getStringValueForKey:@"uid" defaultValue:@""];
        headsmall = [dic getStringValueForKey:@"headsmall" defaultValue:@""];
        nickname = [dic getStringValueForKey:@"nickname" defaultValue:@""];
        nickname = [EmotionInputView decodeMessageEmoji:nickname];
        
        otherid = [dic getStringValueForKey:@"otherid" defaultValue:@""];
        NSString * str = [dic getStringValueForKey:@"content" defaultValue:@""];
        NSDictionary * info = [str mutableObjectFromJSONString];
        typefile = [info getIntValueForKey:@"typefile" defaultValue:0];
        content = [info getStringValueForKey:@"content" defaultValue:@""];
        content = [EmotionInputView decodeMessageEmoji:content];
        if (typefile == forFileImage) {
            imgUrl = [info getStringValueForKey:@"urllarge" defaultValue:@""];
        } else if (typefile == forFileVoice) {
            voiceUrl = [info getStringValueForKey:@"url" defaultValue:@""];
            voiceTime = [info getStringValueForKey:@"time" defaultValue:@""];
        } else if (typefile == forFileAddress) {
            self.address = [[Address alloc] init];
            address.address = [info getStringValueForKey:@"address" defaultValue:@""];
            address.lat = [info getFloatValueForKey:@"lat" defaultValue:0.0];
            address.lng = [info getFloatValueForKey:@"lng" defaultValue:0.0];
            imgUrl = [Globals getBaiduAdrPicForTalk:address.lat lng:address.lng];
        }
        
    }
}
@end
