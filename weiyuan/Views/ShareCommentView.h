//
//  ShareCommentView.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShareCommentDelegate;

@interface ShareCommentView : UIView

@property (nonatomic, strong) UITableView * tableView;
/**评论数据*/
@property (nonatomic, strong) NSMutableArray * contentArr;
/**赞数据*/
@property (nonatomic, strong) NSMutableArray * praiseArr;
@property (nonatomic, assign) id <ShareCommentDelegate> delegate;
+ (CGFloat)getHeightWithItemArray:(NSArray*)arr;
- (id)initWithContentArr:(NSArray *)contentArr praiseArr:(NSArray*)praiseArr withDelegate:(id)del height:(CGFloat)height;
@end

@protocol ShareCommentDelegate <NSObject>
@optional
- (void)didTapHeadAtIndexPath:(id)path;
@end
