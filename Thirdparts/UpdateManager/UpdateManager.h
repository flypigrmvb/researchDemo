//
//  UpdateManager.h
//  guphoto
//
//  Created by kiwi on 4/1/13.
//  Copyright (c) 2013 Kiwaro. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UpdateManager;

typedef enum VersionType {
    VersionTypeLower = 1,
    VersionTypeEqual = 2,
    VersionTypeGreater = 3
}VersionType;

@protocol UpdateManagerDelegate <NSObject>
- (void)updateManagerDidCheck:(UpdateManager*)sender update:(BOOL)up;
@end

@interface UpdateManager : NSObject {
    NSURLConnection * connection;
    NSMutableData   * buf;
    NSInteger       statusCode;
}

@property (nonatomic, assign) id <UpdateManagerDelegate> delegate;
@property (nonatomic, strong) NSString * updates;
@property (nonatomic, assign) BOOL updateExists;
@property (nonatomic, assign) VersionType versionType;
@property (nonatomic, assign) BOOL hasError;
@property (nonatomic, strong) NSString * releaseNotes;

- (id)initCheckNow:(BOOL)bl del:(id)del;
- (void)runCheck;
- (void)cancel;
- (void)showAlert;

@end
