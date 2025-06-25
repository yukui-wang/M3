//
//  NSURL+CMPURL.h
//  CMPLib
//
//  Created by 程昆 on 2019/8/2.
//  Copyright © 2019 crmo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSURL (CMPURL)

/**
 传入路径字符串,返回URL,支持http,https,file协议,及不带flie协议头的的本地绝对路径

 @param pathString 路径字符串
 @return NSURL实例
 */
+ (instancetype)URLWithPathString:(NSString *)pathString;

@end

