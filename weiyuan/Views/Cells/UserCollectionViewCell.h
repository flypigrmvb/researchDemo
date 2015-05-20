//
//  UserCollectionViewCell.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UserCollectionViewCellDelegate <NSObject>
- (void)handleTableviewCellLongPressed:(NSIndexPath*)indexPath;
@end

@interface UserCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UIImageView  * imageViewDelete;
@property (nonatomic, assign) UIImage   * image;
@property (nonatomic, assign) NSString  * title;
@property (nonatomic, assign, readonly) NSIndexPath * indexPath;
@property (nonatomic, strong) UICollectionView * superCollectionView;
@property (nonatomic, assign) BOOL edit;
- (void)enableLongPress;

@end
