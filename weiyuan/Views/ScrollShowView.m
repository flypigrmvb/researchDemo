//
//  ScrollShowView.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "ScrollShowView.h"

@implementation ScrollShowView
@synthesize delegate, scrollEnabled;
@synthesize selectedIndex;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        // Initialization code
        [self initializeBasic];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self initializeBasic];
    }
    return self;
}

- (void)initializeBasic {
    CGRect frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    UIScrollView * scroll = [[UIScrollView alloc] initWithFrame:frame];
    scroll.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    scroll.delegate = self;
    scroll.pagingEnabled = YES;
    scroll.alwaysBounceHorizontal = YES;
    scroll.backgroundColor = [UIColor blackColor];
    scroll.showsHorizontalScrollIndicator = NO;
    [self addSubview:scroll];
    scrollerHorizontal = scroll;

}

- (void)setScrollEnabled:(BOOL)scroll {
    scrollerHorizontal.scrollEnabled = scroll;
}

- (ScrollShowViewCell*)cellForIndex:(NSInteger)idx {
    ScrollShowViewCell * cell = nil;
    for (ScrollShowViewCell * sub in scrollerHorizontal.subviews) {
        if ([sub isKindOfClass:[ScrollShowViewCell class]] && sub.index == idx) {
            cell = sub;
            break;
        }
    }
    return cell;
}

- (void)addCellAtIndex:(int)idx {
    CGRect frame = self.bounds;
    ScrollShowViewCell * cell = [self.delegate scrollShowView:self cellForIndex:idx];
    frame.origin.x = idx * self.bounds.size.width;
    cell.frame = frame;
    if ([self.delegate respondsToSelector:@selector(scrollShowView:willDisplayCell:forIndex:)]) {
        [self.delegate scrollShowView:self willDisplayCell:cell forIndex:idx];
    }
    [scrollerHorizontal addSubview:cell];
}

- (void)updateWithIndex:(int)idx {
    scrollerHorizontal.contentSize = CGSizeMake([self.delegate scrollShowViewNumberOfIndexes] * self.bounds.size.width, self.bounds.size.height);
    [scrollerHorizontal setContentOffset:CGPointMake(idx*self.bounds.size.width, 0) animated:NO];
    ScrollShowViewCell * cell;
    for (int i = idx-1; i <= idx+1; i++) {
        cell = [self cellForIndex:i];
        if (cell) {
            [cell removeFromSuperview];
        }
    }
    [self addCellAtIndex:idx];
    cell = [self cellForIndex:idx];
    if ([self.delegate respondsToSelector:@selector(scrollShowView:didShowCell:forIndex:)]) {
        [self.delegate scrollShowView:self didShowCell:cell forIndex:idx];
    }
}

- (int)currentIndex {
    int offsetX = scrollerHorizontal.contentOffset.x;
    int width = self.bounds.size.width;
    int idx = offsetX / width;
    return idx;
}

#pragma mark
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    int offsetX = sender.contentOffset.x;
    int width = self.bounds.size.width;
    int idx = offsetX / width;
    
    ScrollShowViewCell * cell = [self cellForIndex:idx];
    if (!cell) {
        [self addCellAtIndex:idx];
    }
    
    if (offsetX % width > 0) {
        if (idx + 1 < [self.delegate scrollShowViewNumberOfIndexes]) {
            cell = [self cellForIndex:idx + 1];
            if (!cell) {
                [self addCellAtIndex:idx + 1];
            }
        }
        
        cell = [self cellForIndex:idx-1];
        if (cell) {
            [cell removeFromSuperview];
        }
        cell = [self cellForIndex:idx+2];
        if (cell) {
            [cell removeFromSuperview];
        }
    }
    
    if (sender.contentSize.width < [self.delegate scrollShowViewNumberOfIndexes] * self.bounds.size.width) {
        sender.contentSize = CGSizeMake([self.delegate scrollShowViewNumberOfIndexes] * self.bounds.size.width, self.bounds.size.height);
    }
    
    if ([self.delegate respondsToSelector:@selector(scrollShowViewDidScroll:)]) {
        [self.delegate scrollShowViewDidScroll:self];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)sender willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        int offsetX = sender.contentOffset.x;
        int width = self.bounds.size.width;
        int idx = offsetX / width;
        selectedIndex = idx;
        ScrollShowViewCell * cell = [self cellForIndex:idx];
        if (cell) {
            if ([self.delegate respondsToSelector:@selector(scrollShowView:didShowCell:forIndex:)]) {
                [self.delegate scrollShowView:self didShowCell:cell forIndex:idx];
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender {
    int offsetX = sender.contentOffset.x;
    int width = self.bounds.size.width;
    int idx = offsetX / width;
    selectedIndex = idx;
    ScrollShowViewCell * cell = [self cellForIndex:idx];
    if (cell) {
        if ([self.delegate respondsToSelector:@selector(scrollShowView:didShowCell:forIndex:)]) {
            [self.delegate scrollShowView:self didShowCell:cell forIndex:idx];
        }
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self updateWithIndex:selectedIndex];
    for (ScrollShowViewCell * sub in scrollerHorizontal.subviews) {
        CGRect fra = sub.frame;
        fra.size = self.bounds.size;
        sub.frame = fra;
    }
}

@end



@implementation ScrollShowViewCell
@synthesize delegate, index;

- (id)initWithIndex:(NSInteger)idx frame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        index = idx;
    }
    return self;
}

@end
