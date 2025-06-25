//
//  NSDate+CMPDate.h
//  CMPLib
//
//  Created by CRMO on 2018/10/18.
//  Copyright © 2018 CMPCore. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (CMPDate)

/**
 获取毫秒
 */
- (NSString *)cmp_millisecondStr;

/**
 获取秒
 */
- (NSString *)cmp_secondStr;

/**
 是否为今天
 */
- (BOOL)cmp_isToday;

/**
返回日期
*/
- (NSString *)formatDateDayString;

@end

NS_ASSUME_NONNULL_END
