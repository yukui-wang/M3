//
//  CMPServerUtils.h
//  CMPLib
//
//  Created by youlin on 2019/8/2.
//  Copyright © 2019年 crmo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMPObject.h"

@interface CMPServerUtils : CMPObject

/**
 判断传入URL是否是当前设置服务器的请求
 */
+ (BOOL)isCurrentServer:(NSURL *)url;

@end
