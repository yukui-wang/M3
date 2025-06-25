//
//  XZCreateAppIntent.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/4/10.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZAppIntent.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZCreateAppIntent : XZAppIntent
//intent内部
@property(nonatomic, strong)NSString *url;
@property(nonatomic, strong)NSString *urlType;
@property(nonatomic, strong)NSString *sourceIdUrl;//根据sourceId来获取小致产生的数据，即获取产生的结果后进行渲染
@property(nonatomic, strong)NSString *sourceIdUrlType;//根据sourceId来获取小致产生的数据，即获取产生的结果后进行渲染
@property(nonatomic, strong)NSString *epilogue;
@property(nonatomic, strong)NSString *checkParamsUrl;//参数校验请求地址
@property(nonatomic, strong)NSString *checkParamsUrlType;
@end

NS_ASSUME_NONNULL_END
