//
//  KPickerView.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "KPickerView.h"

@interface KPickerView () <UIPickerViewDelegate> {
    UIView * blankView;
}

@end

@implementation KPickerView

@synthesize delegate, content, selections, selectedDate;
@synthesize type;
@synthesize picker;

- (id)initWithType:(kPickerViewType)theType delegate:(id)del {
    CGRect rect = [UIScreen mainScreen].bounds;
    if (self = [super initWithFrame:CGRectMake(0, 0, rect.size.width, kPickViewHeight)]) {
        self.delegate = del;
        self.type = theType;
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        imgView.backgroundColor = kbColor;
        [self addSubview:imgView];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(10, 0, 44, 44);
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitle:@"取消" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnCancel:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(270, 0, 44, 44);
        [btn setImage:[UIImage imageNamed:@"OK"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnDone:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        CGRect framePicker = CGRectMake(0, kPickViewNavBarHeight, rect.size.width, kPickViewHeight - kPickViewNavBarHeight);
        if (type == forPickViewCustom) {
            UIPickerView* tmpPicker = [[UIPickerView alloc] initWithFrame:framePicker];
            tmpPicker.backgroundColor = RGBCOLOR(224, 224, 221);
            tmpPicker.delegate = self;
            tmpPicker.showsSelectionIndicator = YES;
            [self insertSubview:tmpPicker atIndex:0];
            self.picker = tmpPicker;
            
            self.content = [NSMutableArray array];
            self.selections = [NSMutableArray array];
        } else {
            UIDatePicker* tmpPicker = [[UIDatePicker alloc] initWithFrame:framePicker];
            tmpPicker.backgroundColor = RGBCOLOR(224, 224, 221);
            NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];//设置为中文显示
            tmpPicker.locale = locale;
            if (type == forPickViewDate) {
                tmpPicker.datePickerMode = UIDatePickerModeDate;
                //定义最小日期
                NSDateFormatter *formatter_minDate = [[NSDateFormatter alloc] init];
                [formatter_minDate setDateFormat:@"yyyy-MM-dd"];
                NSDate *minDate = [formatter_minDate dateFromString:@"1970-01-01"];
                formatter_minDate = nil;
                //最大日期是今天
                NSDate *maxDate = [NSDate date];
                
                [tmpPicker setMinimumDate:minDate];
                [tmpPicker setMaximumDate:maxDate];
            } else if (type == forPickViewDateAndTime) {
                tmpPicker.datePickerMode = UIDatePickerModeDateAndTime;
            } else if (type == forPickViewTime) {
                tmpPicker.datePickerMode = UIDatePickerModeTime;
            }
            if (_timeDoNotInvaild) {
                tmpPicker.minimumDate = [NSDate date];
            }
            [self insertSubview:tmpPicker atIndex:0];
            self.picker = tmpPicker;
        }
    }
    return self;
}

- (void)dealloc {
    self.content = nil;
    self.selections = nil;
    self.selectedDate = nil;
}

- (void)showInView:(UIView*)superView {
    superView.userInteractionEnabled = NO;
    for (int i = 0; i < content.count; i ++) {
        KNumber * num = [KNumber numberWithValue:0];
        [selections addObject:num];
    }
    blankView = [[UIView alloc] initWithFrame:superView.bounds];
    blankView.backgroundColor = [UIColor blackColor];
    blankView.alpha = 0;
    [superView addSubview:blankView];
    CGRect frame = self.frame;
    frame.origin.y = superView.frame.size.height;
    self.frame = frame;
    [superView addSubview:self];
    [UIView beginAnimations:@"SHOW" context:nil];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationEnd:finished:context:)];
    frame.origin.y = superView.frame.size.height - kPickViewHeight;
    self.frame = frame;
    blankView.alpha = 0.3;
    [UIView commitAnimations];
}

- (void)hide:(NSString*)anID {
    UIView * superView = self.superview;
    superView.userInteractionEnabled = NO;
    CGRect frame = self.frame;
    [UIView beginAnimations:anID context:nil];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationEnd:finished:context:)];
    frame.origin.y = superView.frame.size.height;
    self.frame = frame;
    blankView.alpha = 0;
    [UIView commitAnimations];
}

- (void)setTimeDoNotInvaild:(BOOL)doNotInvaild {
    _timeDoNotInvaild = doNotInvaild;
    UIDatePicker * tmpPicker = picker;
    if (doNotInvaild) {
        tmpPicker.minimumDate = [NSDate date];
    } else {
        tmpPicker.minimumDate = nil;
    }
}

- (void)btnCancel:(id)sender {
    if ([delegate respondsToSelector:@selector(kPickerViewWillDismiss:)]) {
        [delegate kPickerViewWillDismiss:self];
    }
    [self hide:@"HIDE"];
}

- (void)btnDone:(id)sender {
    if (type != forPickViewCustom) {
        self.selectedDate = ((UIDatePicker*)picker).date;
    }
    if ([delegate respondsToSelector:@selector(kPickerViewWillDismiss:)]) {
        [delegate kPickerViewWillDismiss:self];
    }
    [self hide:@"DONE"];
}

- (void)animationEnd:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
    UIView * superView = self.superview;
    superView.userInteractionEnabled = YES;
    if ([animationID isEqualToString:@"HIDE"]) {
        if ([delegate respondsToSelector:@selector(kPickerViewDidCancel:)]) {
            [delegate kPickerViewDidCancel:self];
        }
        [blankView removeFromSuperview];
        [self removeFromSuperview];
    } else if ([animationID isEqualToString:@"DONE"]) {
        if ([delegate respondsToSelector:@selector(kPickerViewDidDismiss:)]) {
            [delegate kPickerViewDidDismiss:self];
        }
        [blankView removeFromSuperview];
        [self removeFromSuperview];
    }
}

#pragma mark - UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)sender {
    return content.count;
}

- (NSInteger)pickerView:(UIPickerView *)sender numberOfRowsInComponent:(NSInteger)component {
    NSArray * arr = [content objectAtIndex:component];
    return arr.count;
}

- (NSString *)pickerView:(UIPickerView *)sender titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSArray * arr = [content objectAtIndex:component];
    return [arr objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)sender didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSArray * arr = [content objectAtIndex:component];
    NSString *result = nil;
    result = [arr objectAtIndex:row];
    DLog(@"result: %@",result);
    KNumber * sel = [selections objectAtIndex:component];
    sel.value = row;
}

@end

@implementation KNumber

+ (KNumber*)numberWithValue:(int)val {
    KNumber * num = [[KNumber alloc] init];
    num.value = val;
    return num;
}

@end
