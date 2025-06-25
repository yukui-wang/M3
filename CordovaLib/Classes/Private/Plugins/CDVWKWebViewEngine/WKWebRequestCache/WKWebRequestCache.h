//
//  WKWebRequestCache.h
//  CordovaLib
//
//  Created by SeeyonMobileM3MacMini2 on 2021/8/10.
//  Copyright © 2021 crmo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKWebRequestCache : NSObject

@property (nonatomic,copy) NSString *cid;
@property (nonatomic,copy) NSString *url;
@property (nonatomic,copy) NSString *type;
@property (nonatomic,strong) id data;

-(instancetype)initWithBody:(NSDictionary *)body;

@end

NS_ASSUME_NONNULL_END
