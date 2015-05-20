//
//  TextEditController.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//
#import "BaseViewController.h"

typedef enum {
    TextEditTypeDefault = 0,
    TextEditTypeNumber = 1,
    TextEditTypeMultipleLines = 2
}TextEditType;

@protocol TextEditControllerDelegate <NSObject>
@optional
- (void)textEditControllerDidEdit:(NSString*)text idx:(NSIndexPath*)idx;
@end

@interface TextEditController : BaseViewController
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) id <TextEditControllerDelegate> delegate;
@property (nonatomic, assign) int maxTextCount;
@property (nonatomic, assign) int minTextCount;
@property (nonatomic, assign) BOOL showPicture;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * defaultValue;
@property (nonatomic, assign) TextEditType editType;

- (id)initWithDel:(id)del type:(TextEditType)type title:(NSString*)tit value:(NSString*)value;

@end
