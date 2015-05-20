//
//  UITouchableLabel.h
//  UILabelTouch
//
//  Created by kiwaro Hood on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UITouchableLabel;
@protocol UITouchableLabelDelegate <NSObject>
@required
- (void)touchableLabelLabel:(UITouchableLabel *)_label touchesWtihTag:(NSInteger)tag;
@end

@interface UITouchableLabel : UILabel {
    __unsafe_unretained id <UITouchableLabelDelegate> touchdelegate;
}

@property (nonatomic, assign) IBOutlet id <UITouchableLabelDelegate> touchdelegate;

@end
