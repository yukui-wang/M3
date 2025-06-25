//
//  SyDataUtil.h
//  M1Core
//
//  Created by xiang fei on 11-7-24.
//  Copyright 2011年 Seeyon. All rights reserved.
//
//  数据操作工具类

#import <Foundation/Foundation.h>

@interface CMPDataUtil : NSObject

/**
 * 解压数据
 */
+ (NSMutableData *)uncompressZippedData:(NSMutableData *)compressedData;
+ (NSString *)getANSIString:(NSData *)ansiData;
+ (NSString *)textEncodingName:(NSData *)ansiData;
+ (NSString *)unZipDataforSeeyon:(NSString *)responseString;

@end
