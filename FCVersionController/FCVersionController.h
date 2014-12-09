//
//  VersionController.h
//  Wosai
//
//  Created by Harley on 14/11/6.
//  Copyright (c) 2014年 Flycent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FCVersionInfo.h"


/**
 *  搜索版本更新的地址，目前支持AppStore和FIR.im
 */
typedef enum {
    FCVersionSearchingLocation_AppStore,
    FCVersionSearchingLocation_FIR
}FCUpdateSearchingLocation;


/**
 *  版本控制器
 *  提供本地版本校验与缓存、版本更新检查与更新等功能
 */
@interface FCVersionController : NSObject

/**
 *  获取单例对象
 */
+ (instancetype)sharedController;

/**
 *  版本更新的地址，切换版本地址后会重置新版本信息为nil，并默认执行一次新版本搜索
 *  默认为AppStore: FCVersionSearchingLocation_AppStore
 */
@property (assign, nonatomic) FCUpdateSearchingLocation searchingLocation;

/**
 *  AppID，设置AppID后会重置新版本信息为nil，并默认执行一次新版本搜索
 *
 *  @attention AppStore和FIR版本都需要设置AppID，否则无法搜索新版本
 */
@property (strong, nonatomic) NSString *AppID;

/**
 *  当前本地版本，只包含版本号信息，其他为nil
 */
@property (strong, nonatomic, readonly) FCVersionInfo *currentVersion;

/**
 *  上次启动的版本，只包含版本号信息，其他为nil
 */
@property (strong, nonatomic, readonly) FCVersionInfo *lastLaunchedVersion;

/**
 *  最新版本信息，没有新版本时为nil
 */
@property (strong, nonatomic, readonly) FCVersionInfo *latestNewVersion;

/**
 *  是否正在查询更新
 */
@property (assign, nonatomic, readonly) BOOL isSearchingForUpdate;

/**
 *  搜索更新信息，通过block返回新版本内容
 *
 *  @attention 正在查询更新时调用该方法不会重复执行，将等待之前的查询完毕后一同回调callback
 *             通过 isSearchingForUpdate 属性检查是否正在查询更新
 *             调用该方法时＊断言＊已设置AppID
 *
 *  失败或者没有新版本时，block参数为nil
 */
- (void)searchForUpdateFinished:(void(^)(FCVersionInfo* versionInfo))callback;

/**
 *  安装最新版本，没有新版本时不执行任何操作
 *
 *  安装FIR版本时直接下载安装对应版本，请确认该设备具备安装该应用的权限，否则会安装失败。
 *  @attention 对AppStore上的新版本执行该方法，将直接跳转到AppStore的更新界面。
 *             调用该方法时＊断言＊已设置AppID
 */
- (void)installLatestVersion;

@end