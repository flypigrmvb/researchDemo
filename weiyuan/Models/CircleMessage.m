//
//  Message.m
//  BusinessMate
//
//  Created by keen on 13-6-8.
//  Copyright (c) 2013年 xizue. All rights reserved.
//

#import "CircleMessage.h"
#import "EmotionInputView.h"
#import "BSEngine.h"
#import "Globals.h"
#import "SharePicture.h"

@implementation CircleComment

- (void) updateWithJsonDic:(NSDictionary *)dic {
    [super updateWithJsonDic:dic];
    _content = [EmotionInputView decodeMessageEmoji:_content];
}
@end;

@implementation CircleZan

@end;

@interface CircleMessage ()

@end

@implementation CircleMessage

- (void)updateWithJsonDic:(NSDictionary *)dic {
    isInitSuccuss = NO;
    if (dic != nil && [dic isKindOfClass:[NSDictionary class]]) {
        isInitSuccuss = YES;
    }
    if (isInitSuccuss) {
        self.fid = [dic getStringValueForKey:@"id" defaultValue:nil];
        self.uid = [dic getStringValueForKey:@"uid" defaultValue:nil];
        self.name = [dic getStringValueForKey:@"nickname" defaultValue:nil];
        self.name = [EmotionInputView decodeMessageEmoji:_name];
        
        self.imgHeadUrl = [dic getStringValueForKey:@"headsmall" defaultValue:nil];
        
        self.replys = [dic getIntValueForKey:@"replys" defaultValue:0];
        self.praises = [dic getIntValueForKey:@"praises" defaultValue:0];
        
        self.time = [dic getDoubleValueForKey:@"createtime" defaultValue:0.f];
        self.createtime = [Globals timeStringForListWith:self.time];
        
        NSString *str = [dic getStringValueForKey:@"content" defaultValue:nil];
        self.content = [EmotionInputView decodeMessageEmoji:str];
        
        self.address = [Address objWithJsonDic:dic];
        NSArray *arr = [dic getArrayForKey:@"picture"];
        self.picsArray = [NSMutableArray array];
        if (arr && arr.count > 0) {
            [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                SharePicture * item = [SharePicture objWithJsonDic:obj];
                [self.picsArray insertObject:item atIndex:0];
            }];
            self.cmType = forMessageType2;
        }
        arr = [dic getArrayForKey:@"replylist"];
        self.replylist = [NSMutableArray array];
        [arr enumerateObjectsUsingBlock:^(id commentObj, NSUInteger idx, BOOL *stop) {
            CircleComment *commentItem = [CircleComment objWithJsonDic:commentObj];
            [self.replylist insertObject:commentItem atIndex:0];
        }];
    
        arr = [dic getArrayForKey:@"praiselist"];
        self.praiselist = [NSMutableArray array];
        [arr enumerateObjectsUsingBlock:^(id praiseObj, NSUInteger idx, BOOL *stop) {
            CircleZan * zanItem = [CircleZan objWithJsonDic:praiseObj];
            [self.praiselist insertObject:zanItem atIndex:0];
        }];
        
        self.ispraise = [dic getIntValueForKey:@"ispraise" defaultValue:0];
    }
}
@end
