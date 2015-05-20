//
//  ScrollShowView.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ScrollShowView, ScrollShowViewCell;

@protocol ScrollShowViewDelegate <NSObject>
@required
- (ScrollShowViewCell*)scrollShowView:(ScrollShowView*)sender cellForIndex:(int)idx;
- (NSInteger)scrollShowViewNumberOfIndexes;
@optional
- (void)scrollShowView:(ScrollShowView*)sender willDisplayCell:(ScrollShowViewCell*)cell forIndex:(int)idx;
- (void)scrollShowView:(ScrollShowView*)sender didShowCell:(ScrollShowViewCell*)cell forIndex:(int)idx;
- (void)scrollShowViewDidScroll:(ScrollShowView*)sender;
@end

@interface ScrollShowView : UIView <UIScrollViewDelegate> {
    //released
    UIScrollView * scrollerHorizontal;
}
@property (nonatomic, assign) IBOutlet id <ScrollShowViewDelegate> delegate;
@property (nonatomic, assign) BOOL scrollEnabled;
@property (nonatomic, assign) int selectedIndex;

- (void)updateWithIndex:(int)idx;
- (ScrollShowViewCell*)cellForIndex:(NSInteger)idx;
- (int)currentIndex;

@end

@interface ScrollShowViewCell : UIView {
    
}
@property (nonatomic, assign) id delegate;
@property (readonly, assign) NSInteger index;

- (id)initWithIndex:(NSInteger)idx frame:(CGRect)frame;

@end