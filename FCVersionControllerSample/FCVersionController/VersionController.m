//
//  VersionController.m
//  Wosai
//
//  Created by Harley on 14/11/6.
//  Copyright (c) 2014年 Flycent. All rights reserved.
//

#import "VersionController.h"
#import "FCAppSystemData.h"

#if defined Enterprise
    #define VERSION_INFO_URL    @"http://fir.im/api/v2/app/version/5451b2ace8c5b1e519001116"
    #define VERSION_INSTALL_URL @"itms-services://?action=download-manifest&url=https://fir.im/api/v2/app/install/5451b2ace8c5b1e519001116"
#else
//    #define VERSION_INFO_URL    @"http://itunes.apple.com/lookup?id=924340295"  // Wosai AppID
    #define VERSION_INFO_URL    @"http://itunes.apple.com/lookup?id=924340295"  // 云享AppID，测试用
    #define VERSION_INSTALL_URL @"itms-apps://itunes.apple.com/app/id924340295"
#endif



@implementation VersionInfo

+ (instancetype)currentVersion
{
    FCAppSystemData *systemData = [FCAppSystemData sharedInstance];
    VersionInfo *currentVersion = [VersionInfo new];
    currentVersion.fullCode = [systemData versionString];
    currentVersion.shortCode = [systemData versionStringShort];
    return currentVersion;
}

- (instancetype)initWihtResponseJsonData:(NSDictionary*)jsonData
{
    self = [super init];
    
#if defined Enterprise
    self.fullCode = [jsonData stringForKey:@"version"];
    self.shortCode = [jsonData stringForKey:@"versionShort"];
    self.releaseNotes = [jsonData stringForKey:@"changelog"];
    self.releaseURL = [jsonData stringForKey:@"update_url"];
#else
    
    NSArray *results = [jsonData objectForKey:@"results"];
    if (results.count <= 0) {
        self = [VersionInfo currentVersion];
    }
    jsonData = [results firstObject];
    self.fullCode = [jsonData stringForKey:@"version"];
    self.shortCode = [jsonData stringForKey:@"version"];
    self.releaseNotes = [jsonData stringForKey:@"releaseNotes"];
    self.releaseURL = [jsonData stringForKey:@"trackViewUrl"];
#endif
    return self;
}

- (BOOL)sameAs:(VersionInfo*)info
{
    if (self.fullCode.length > 0 && info
        .fullCode.length > 0) {
        return [self.fullCode isEqualToString:info.fullCode];
    }
    return [self.shortCode isEqualToString:info.shortCode];
}

@end

@implementation VersionController

+ (instancetype)sharedController
{
    static VersionController *instanceSharedController;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instanceSharedController = [VersionController new];
    });
    return instanceSharedController;
}

- (void)searchForUpdate:(void(^)(VersionInfo* versionInfo))finished
{
    NSString *updateUrl = VERSION_INFO_URL;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:updateUrl]];
    [request setHTTPMethod:@"GET"];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
    
        if (connectionError || data == nil) {
            finished(nil);
            return;
        }
        
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        VersionInfo *version = [[VersionInfo alloc] initWihtResponseJsonData:jsonData];
        VersionInfo *currentVersion = [VersionInfo currentVersion];
        if (finished) {
            if (version == nil || [version sameAs:currentVersion]) {
                finished(nil);
            }else {
                self.newVersion = version;
                finished(version);
            }
        }
    }];
}

- (void)installLatestVersion
{
    NSString *url = VERSION_INSTALL_URL;
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

@end
