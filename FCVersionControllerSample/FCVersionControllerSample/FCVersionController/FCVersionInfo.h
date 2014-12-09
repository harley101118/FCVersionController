//
//  FCVersionInfo.h
//  FCVersionController
//
//  Created by Harley on 14/12/9.
//  Copyright (c) 2014年 Flycent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FCVersionController.h"

/**
 *  版本信息
 *  版本信息的数据结构类，保存版本号、更新内容等
 */
@interface FCVersionInfo : NSObject

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

/**
 *  比较两个版本信息是否代表同一个版本
 */
- (BOOL)sameAs:(FCVersionInfo*)info;

@end
