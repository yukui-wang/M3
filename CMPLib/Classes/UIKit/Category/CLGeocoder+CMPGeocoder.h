//
//  CLGeocoder+CMPGeocoder.h
//  CMPLib
//
//  Created by MacBook on 2020/2/20.
//  Copyright © 2020 crmo. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CLGeocoder (CMPGeocoder)

/**
 *  反编译GPS坐标点 判断坐标点位置是否在中国境内
 *
 *  @param location GPS坐标点
 *  @param block    isError 是否出错 /  isINCHINA 是否在中国境内
 */
- (void)cmp_reverseGeocodeWithCLLocation:(CLLocation *)location Block:(void (^)(BOOL isError, BOOL isInCHINA))block;

@end

NS_ASSUME_NONNULL_END
