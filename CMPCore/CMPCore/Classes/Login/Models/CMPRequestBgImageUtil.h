//
//  CMPRequestBgImageUtil.h
//  M3
//
//  Created by MacBook on 2020/1/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class CMPLoginViewStyle;

typedef void(^RequestStart)(void);
typedef void(^RequestProgressUpdateWithExt)(float progress,NSInteger recieveBytes,NSInteger totalBytes);
typedef void(^RequestSuccess)(CMPLoginViewStyle *style);
typedef void(^RequestFail)(NSError *error);


@interface CMPRequestBgImageUtil : NSObject

- (void)requestBackgroundWithStart:(RequestStart)start
progressUpdateWithExt:(RequestProgressUpdateWithExt)update
              success:(RequestSuccess)success
                 fail:(RequestFail)fail;

- (CMPLoginViewStyle *)currentLoginViewStyle;

@end

NS_ASSUME_NONNULL_END
