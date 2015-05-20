//
//  KPickerView.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kPickViewHeight 260         // 216+44
#define kPickViewNavBarHeight 44

typedef enum {
    forPickViewCustom = 1,      // 自定义的 picker
    forPickViewDate = 2,        // 日期
    forPickViewDateAndTime = 3, // 日期 + 时间
    forPickViewTime = 4,        // 时间
}kPickerViewType;

@class KPickerView;

@protocol KPickerViewDelegate <NSObject>

@optional

- (void)kPickerViewWillDismiss:(KPickerView*)sender;
- (void)kPickerViewDidDismiss:(KPickerView*)sender;
- (void)kPickerViewDidCancel:(KPickerView*)sender;

@end

@interface KPickerView : UIView

@property (nonatomic, assign) id <KPickerViewDelegate>  delegate;
@property (nonatomic, strong) NSMutableArray*           content;
@property (nonatomic, strong) NSMutableArray*           selections;
@property (nonatomic, strong) NSDate*                   selectedDate;

@property (nonatomic, assign) id                        picker;
@property (nonatomic, assign) kPickerViewType           type;
@property (nonatomic, assign) BOOL                      timeDoNotInvaild;

- (id)initWithType:(kPickerViewType)theType delegate:(id)del;
- (void)showInView:(UIView*)sup;

@end

@interface KNumber : NSObject

@property (nonatomic, assign) NSInteger value;

+ (KNumber*)numberWithValue:(int)val;

@end
