//
//  TextInput.h
//  FamiliarMen
//
//  Created by kiwi on 14-1-17.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITextField+Shake.h"

@interface KTextField : UITextField
@property (nonatomic, assign) NSInteger  index;
- (void)infoStyle;
- (void)enableBorder;
@end


@interface KTextView : UITextView {
    UILabel * labPlaceholder;
    UILabel * labCount;
    UIImageView * backgroundView;
}

@property (nonatomic, strong) NSString * placeholder;
@property (nonatomic, assign) NSInteger  maxCount;

- (void)setupBackgroundView;

@end
