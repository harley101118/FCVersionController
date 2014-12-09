//
//  VersionController.h
//  Wosai
//
//  Created by Harley on 14/11/6.
//  Copyright (c) 2014年 Flycent. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VersionInfo;

@interface VersionController : NSObject

+ (instancetype)sharedController;

/**
 *  新版本信息，没有新版本时为nil
 */
@property (strong, nonatomic,getter = getNewVersion) VersionInfo *newVersion;

- (void)searchForUpdate:(void(^)(VersionInfo* versionInfo))finished;
- (void)installLatestVersion;

@end


@interface VersionInfo : NSObject
+ (instancetype)currentVersion;
/**
 *  完整版本号
 */
@property (strong, nonatomic) NSString *fullCode;

/**
 *  短版本号
 */
@property (strong, nonatomic) NSString *shortCode;

/**
 *  更新信息
 */
@property (strong, nonatomic) NSString *releaseNotes;

/**
 *  更新信息地址
 */
@property (strong, nonatomic) NSString *releaseURL;


@end
