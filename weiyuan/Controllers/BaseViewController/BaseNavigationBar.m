//
//  BaseNavigationBar
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "BaseNavigationBar.h"
#import "UIImage+FlatUI.h"

@interface BaseNavigationBar ()
@property (nonatomic, strong) CALayer *colorLayer;
@end

@implementation BaseNavigationBar

static CGFloat const kDefaultColorLayerOpacity = 0.4f;
static CGFloat const kSpaceToCoverStatusBars = 20.0f;

- (id) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = NO;
        if ([[UIDevice currentDevice].systemVersion doubleValue] < 7.0) {
            [self configureFlatNavigationBarWithColor:kbColor];
        } else {
            [self setTintColor:[UIColor whiteColor]];
            if ([self respondsToSelector:@selector(setBarTintColor:)]) {
                [self setBarTintColor:kbColor];
            }
        }
        
        NSMutableDictionary * textDic = [NSMutableDictionary dictionaryWithCapacity:4];
        [textDic setObject:[UIFont boldSystemFontOfSize:20] forKey:UITextAttributeFont];
        [textDic setObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
        self.titleTextAttributes = textDic;
    }
    return self;
}

- (void)configureFlatNavigationBarWithColor:(UIColor *)color {
    [self setBackgroundImage:[UIImage imageWithColor:color cornerRadius:0]
               forBarMetrics:UIBarMetricsDefault & UIBarMetricsLandscapePhone];
    NSMutableDictionary *titleTextAttributes = [[self titleTextAttributes] mutableCopy];
    if (!titleTextAttributes) {
        titleTextAttributes = [[NSMutableDictionary alloc] init];
    }
    [titleTextAttributes setValue:[UIColor clearColor] forKey:UITextAttributeTextShadowColor];
    [titleTextAttributes setValue:[NSValue valueWithUIOffset:UIOffsetMake(0, 0)] forKey:UITextAttributeTextShadowOffset];
    [self setTitleTextAttributes:titleTextAttributes];
    if([self respondsToSelector:@selector(setShadowImage:)]) {
        [self setShadowImage:[UIImage imageWithColor:[UIColor clearColor] cornerRadius:0]];
    }
}

- (void)setBarTintColor:(UIColor *)barTintColor {
    [super setBarTintColor:barTintColor];
    
    if (self.colorLayer == nil) {
        self.colorLayer = [CALayer layer];
        self.colorLayer.opacity = kDefaultColorLayerOpacity;
        [self.layer addSublayer:self.colorLayer];
    }
    
    CGFloat red, green, blue, alpha;
    [barTintColor getRed:&red green:&green blue:&blue alpha:&alpha];
    
    CGFloat opacity = kDefaultColorLayerOpacity;
    
    CGFloat minVal = MIN(MIN(red, green), blue);
    
    if ([self convertValue:minVal withOpacity:opacity] < 0) {
        opacity = [self minOpacityForValue:minVal];
    }
    
    self.colorLayer.opacity = opacity;
    
    red = [self convertValue:red withOpacity:opacity];
    green = [self convertValue:green withOpacity:opacity];
    blue = [self convertValue:blue withOpacity:opacity];
    
    red = MAX(MIN(1.0, red), 0);
    green = MAX(MIN(1.0, green), 0);
    blue = MAX(MIN(1.0, blue), 0);
    
    self.colorLayer.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha].CGColor;
}

- (CGFloat)minOpacityForValue:(CGFloat)value {
    return (0.4 - 0.4 * value) / (0.6 * value + 0.4);
}

- (CGFloat)convertValue:(CGFloat)value withOpacity:(CGFloat)opacity {
    return 0.4 * value / opacity + 0.6 * value - 0.4 / opacity + 0.4;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.colorLayer != nil) {
        self.colorLayer.frame = CGRectMake(0, 0 - kSpaceToCoverStatusBars, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) + kSpaceToCoverStatusBars);
        
        [self.layer insertSublayer:self.colorLayer atIndex:1];
    }
}

- (void)displayColorLayer:(BOOL)display {
    self.colorLayer.hidden = !display;
}

@end
