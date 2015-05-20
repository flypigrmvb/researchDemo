//
//  KLocatePickView.m
//  SpartaEducation
//
//  Created by kiwaro on 14-3-5.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "KLocatePickView.h"
#import "KLocation.h"

@interface KLocatePickView ()<UIPickerViewDataSource, UIPickerViewDelegate> {
    NSArray *provinces;
    NSArray	*cities;
    IBOutlet UILabel *titleLabel;
    IBOutlet UIPickerView *locatePicker;
    UIView * blankView;
}

@end

@implementation KLocatePickView

+ (NSString *)convertProvincesCode:(int)code {
    KLocatePickView *k = [KLocatePickView new];
    [k loadData];
    return [k getPCode:code];
}

+ (NSString *)convertCitiesCode:(int)code {
    KLocatePickView *k = [KLocatePickView new];
    [k loadData];
    return [k getCCode:code];
}

- (id)initWithTitle:(NSString *)title delegate:(id)delegate
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"KLocatePickView" owner:self options:nil] objectAtIndex:0];
    if (self) {
        self.delegate = delegate;
        titleLabel.text = title;
        locatePicker.dataSource = self;
        locatePicker.delegate = self;
        locatePicker.backgroundColor = RGBCOLOR(245, 241, 247);
        [self loadData];
    }
    return self;
}

- (void)loadData {
    //加载数据
    NSString *path = [[NSBundle mainBundle] pathForResource:@"AreaCode.plist" ofType:nil];
    if (path) {
        provinces = [[NSArray alloc] initWithContentsOfFile:path];
        cities = [[provinces objectAtIndex:0] objectForKey:@"Cities"];
        
        //初始化默认数据
        self.locate = [[KLocation alloc] init];
        self.locate.state = [[provinces objectAtIndex:0] objectForKey:@"State"];
        self.locate.city = [[cities objectAtIndex:0] objectForKey:@"City"];
        
        self.locate.stateCode = [[[provinces objectAtIndex:0] objectForKey:@"id"] intValue];
        self.locate.cityCode = [[[cities objectAtIndex:0] objectForKey:@"id"] intValue];
    }

}
- (void)dealloc
{
    self.locate = nil;
}

- (void)showInView:(UIView *)view
{
    blankView = [[UIView alloc] initWithFrame:view.bounds];
    blankView.backgroundColor = [UIColor blackColor];
    blankView.alpha = 0;
    [view addSubview:blankView];
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = 0.3;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromTop;
    [self setAlpha:1.0f];
    [self.layer addAnimation:animation forKey:@"ShowPickView"];
    
    self.frame = CGRectMake(0, view.frame.size.height - self.frame.size.height, self.frame.size.width, self.frame.size.height);
    blankView.alpha = 0.3;
    [view addSubview:self];
    [UIView commitAnimations];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)sender
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)sender numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return [provinces count];
            break;
        case 1:
            return [cities count];
            break;
        default:
            return 0;
            break;
    }
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)sender titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return [[provinces objectAtIndex:row] objectForKey:@"State"];
            break;
        case 1:
            return [[cities objectAtIndex:row] objectForKey:@"City"];
            break;
        default:
            return nil;
            break;
    }
}

- (void)pickerView:(UIPickerView *)sender didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    switch (component) {
        case 0:
            cities = [[provinces objectAtIndex:row] objectForKey:@"Cities"];
            [locatePicker selectRow:0 inComponent:1 animated:NO];
            [locatePicker reloadComponent:1];
            
            self.locate.state = [[provinces objectAtIndex:row] objectForKey:@"State"];
            self.locate.stateCode = [[[provinces objectAtIndex:row] objectForKey:@"id"] intValue];
            self.locate.city = [[cities objectAtIndex:0] objectForKey:@"City"];
            self.locate.cityCode = [[[cities objectAtIndex:0] objectForKey:@"id"] intValue];
            break;
        case 1:
            self.locate.city = [[cities objectAtIndex:row] objectForKey:@"City"];
            self.locate.cityCode = [[[cities objectAtIndex:row] objectForKey:@"id"] intValue];
            break;
        default:
            break;
    }
}

#pragma mark - IBAction

- (IBAction)cancel:(id)sender {
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = 0.3;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromBottom;
    blankView.alpha = 0;
    [self setAlpha:0.0f];
    [self.layer addAnimation:animation forKey:@"KLocatePickView"];
    [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.3];
    if(self.delegate) {
        [self.delegate actionSheet:self clickedButtonAtIndex:0];
    }
}

- (IBAction)locate:(id)sender {
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = 0.3;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromBottom;
    blankView.alpha = 0;
    [self setAlpha:0.0f];
    [self.layer addAnimation:animation forKey:@"KLocatePickView"];
    [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.3];
    if(self.delegate) {
        [self.delegate actionSheet:self clickedButtonAtIndex:1];
    }
    
}

- (NSString *)getPCode:(int)code {
    NSString * str = @"暂无";
    for (NSDictionary * dic in provinces) {
        NSString *pid = [dic objectForKey:@"id"];
        if (pid.intValue == code) {
            str = [dic objectForKey:@"State"];
            break;
        }
    }
    return str;
}

- (NSString *)getCCode:(int)code {
    NSString * str = @"暂无";
    for (NSDictionary * dic in provinces) {
        NSArray *mcities = [dic objectForKey:@"Cities"];
        for (NSDictionary * dic in mcities) {
            NSString *pid = [dic objectForKey:@"id"];
            if (pid.intValue == code) {
                str = [dic objectForKey:@"City"];
                break;
            }
        }
    }

    return str;
}
@end
