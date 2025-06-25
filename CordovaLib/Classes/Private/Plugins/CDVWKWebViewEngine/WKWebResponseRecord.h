//
//  WKWebResponseRecord.h
//  CordovaLib
//
//  Created by wujiansheng on 2020/7/23.
//  Copyright © 2020 crmo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKWebResponseRecord : NSObject
@property(nonatomic, strong)NSData *data;
@property(nonatomic, strong)NSURLResponse *response;
@end

NS_ASSUME_NONNULL_END
