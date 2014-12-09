//
//  FCVersionInfo.m
//  FCVersionController
//
//  Created by Harley on 14/12/9.
//  Copyright (c) 2014年 Flycent. All rights reserved.
//

#import "FCVersionInfo.h"
#import "FCVersionController.h"


@implementation FCVersionInfo

- (instancetype)initWihtResponseDataJsonData:(NSDictionary*)jsonData searchingLocation:(FCUpdateSearchingLocation)location
{
    self = [super init];
    
    if (location == FCVersionSearchingLocation_FIR)
    {
        self.fullCode = [jsonData objectForKey:@"version"];
        self.shortCode = [jsonData objectForKey:@"versionShort"];
        self.releaseNotes = [jsonData objectForKey:@"changelog"];
        self.releaseURL = [jsonData objectForKey:@"update_url"];
    }
    else if (location == FCVersionSearchingLocation_AppStore)
    {
        NSArray *results = [jsonData objectForKey:@"results"];
        if (results.count <= 0) {
            return nil;
        }
        jsonData = [results firstObject];
        self.fullCode = [jsonData objectForKey:@"version"];
        self.shortCode = [jsonData objectForKey:@"version"];
        self.releaseNotes = [jsonData objectForKey:@"releaseNotes"];
        self.releaseURL = [jsonData objectForKey:@"trackViewUrl"];
    }
    else
    {
        return nil;
    }
    return self;
}

- (BOOL)sameAs:(FCVersionInfo*)info
{
    if (self.fullCode.length > 0 && info
        .fullCode.length > 0) {
        return [self.fullCode isEqualToString:info.fullCode];
    }
    return [self.shortCode isEqualToString:info.shortCode];
}

@end
