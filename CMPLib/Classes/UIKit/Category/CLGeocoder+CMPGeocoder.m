//
//  CLGeocoder+CMPGeocoder.m
//  CMPLib
//
//  Created by MacBook on 2020/2/20.
//  Copyright © 2020 crmo. All rights reserved.
//

#import "CLGeocoder+CMPGeocoder.h"


@implementation CLGeocoder (CMPGeocoder)

- (void)cmp_reverseGeocodeWithCLLocation:(CLLocation *)location Block:(void (^)(BOOL isError, BOOL isInCHINA))block {
    
    if (!block) {
        return;
    }
    
    [self reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error || placemarks.count == 0) {
            block(YES,NO);//苹果自带的CLGeocoder在国外逆地理编码时候并不好用，经常解析失败。
        } else {
            CLPlacemark *placemark = [placemarks firstObject];
            if ([placemark.ISOcountryCode isEqualToString:@"CN"]) {
                block(NO,YES);
            } else {
                block(NO,NO);
            }
        }
    }];
}

@end
