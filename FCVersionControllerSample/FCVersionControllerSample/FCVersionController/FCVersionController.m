//
//  VersionController.m
//  Wosai
//
//  Created by Harley on 14/11/6.
//  Copyright (c) 2014年 Flycent. All rights reserved.
//

#import "FCVersionController.h"
#import "FCVersionInfo.h"


#define URL_VERSION_INFO_APPSTORE       @"http://itunes.apple.com/lookup?id="
#define URL_VERSION_INFO_FIR            @"http://fir.im/api/v2/app/version/"

#define URL_VERSION_UPDATE_APPSTORE     @"itms-apps://itunes.apple.com/app/"
#define URL_VERSION_UPDATE_FIR          @"itms-services://?action=download-manifest&url=https://fir.im/api/v2/app/install/"

#define KEY_LASTLAUNCH_VERSION          @"FCAppLastLaunchVersionKey"
#define KEY_LASTLAUNCH_VERSION_SHORT    @"FCAppLastLaunchVersionKey_Short"


@interface FCVersionInfo ()
- (instancetype)initWihtResponseDataJsonData:(NSDictionary*)jsonData searchingLocation:(FCUpdateSearchingLocation)location;
@end

@interface FCVersionController ()

@property (strong, nonatomic) FCVersionInfo *currentVersion;
@property (strong, nonatomic) FCVersionInfo *lastLaunchedVersion;
@property (strong, nonatomic) FCVersionInfo *latestNewVersion;
@property (assign, nonatomic) BOOL isSearchingForUpdate;

@property (strong, nonatomic) NSMutableArray *callbacks;

@end


@implementation FCVersionController

+ (instancetype)sharedController
{
    static FCVersionController *instanceSharedController;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instanceSharedController = [FCVersionController new];
    });
    return instanceSharedController;
}

- (id)init
{
    self = [super init];
    
    // 初始化回调池
    self.callbacks = [NSMutableArray array];
    
    /**
     *  初始化本地版本信息
     */
    // 读取当前启动的版本号
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    self.currentVersion = [FCVersionInfo new];
    self.currentVersion.shortCode = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    self.currentVersion.fullCode = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    // 读取上次启动的版本号
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *lastLaunchVersionString = [userDefaults objectForKey:KEY_LASTLAUNCH_VERSION];
    if (!lastLaunchVersionString)
    {
        self.lastLaunchedVersion = nil;
    }
    else
    {
        NSString *lastLaunchVersionStringShort = [userDefaults objectForKey:KEY_LASTLAUNCH_VERSION_SHORT];
        self.lastLaunchedVersion = [FCVersionInfo new];
        self.lastLaunchedVersion.fullCode = lastLaunchVersionString;
        self.lastLaunchedVersion.shortCode = lastLaunchVersionStringShort;
    }

    // 保存本次启动版本号
    [userDefaults setObject:self.currentVersion.fullCode forKey:KEY_LASTLAUNCH_VERSION];
    [userDefaults setObject:self.currentVersion.shortCode forKey:KEY_LASTLAUNCH_VERSION_SHORT];
    [userDefaults synchronize];
    
    return self;
}

- (void)setAppID:(NSString *)AppID
{
    if ([_AppID isEqualToString:AppID]) {
        return;
    }
    _AppID = AppID;
    _latestNewVersion = nil;
    
    [self searchForUpdateFinished:nil];
}

- (void)setSearchingLocation:(FCUpdateSearchingLocation)searchingLocation
{
    if (_searchingLocation == searchingLocation) {
        return;
    }
    _searchingLocation = searchingLocation;
    _latestNewVersion = nil;

    [self searchForUpdateFinished:nil];
}

- (void)searchForUpdateFinished:(void(^)(FCVersionInfo* versionInfo))finished
{
    NSAssert(_AppID.length > 0, @"FCVersionController:未设置AppID，请设置AppID后再查询更新信息!");
    
    // 缓存回调至回调池
    if (finished) {
        [self.callbacks addObject:finished];
    }
    // 正在搜索则返回，等待搜索结果
    if (self.isSearchingForUpdate) {
        return;
    }
    // 标记为正在搜索状态
    self.isSearchingForUpdate = YES;
    
    // 拼接请求地址
    NSString *searchUrl;
    switch (_searchingLocation) {
        case FCVersionSearchingLocation_AppStore:
            searchUrl = URL_VERSION_INFO_APPSTORE;
            break;
        case FCVersionSearchingLocation_FIR:
            searchUrl = URL_VERSION_INFO_FIR;
            break;
        default:
            break;
    }
    searchUrl = [searchUrl stringByAppendingString:_AppID];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:searchUrl]];
    [request setHTTPMethod:@"GET"];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
    
        if (connectionError || data == nil) {
            [self callbackWithVersion:nil];
            return;
        }
        
        // 标记为搜索结束状态
        self.isSearchingForUpdate = NO;
        
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        FCVersionInfo *version = [[FCVersionInfo alloc] initWihtResponseDataJsonData:jsonData
                                                                   searchingLocation:_searchingLocation];
        
        if (version == nil || [version sameAs:_currentVersion]) {
            [self callbackWithVersion:nil];
        }else {
            self.latestNewVersion = version;
            [self callbackWithVersion:version];
        }
    }];
}

- (void)callbackWithVersion:(FCVersionInfo*)version
{
    for (void(^callback)(FCVersionInfo*) in _callbacks) {
        callback(version);
    }
    // 回调完毕后清空缓存池
    [_callbacks removeAllObjects];
}

- (void)installLatestVersion
{
    NSAssert(_AppID.length > 0, @"FCVersionController:未设置AppID，请设置AppID后再更新应用!");

    // 拼接更新地址
    NSString *updateUrl;
    switch (_searchingLocation) {
        case FCVersionSearchingLocation_AppStore:
            updateUrl = URL_VERSION_UPDATE_APPSTORE;
            break;
        case FCVersionSearchingLocation_FIR:
            updateUrl = URL_VERSION_UPDATE_FIR;
            break;
        default:
            break;
    }
    updateUrl = [updateUrl stringByAppendingString:_AppID];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:updateUrl]];
}

@end
