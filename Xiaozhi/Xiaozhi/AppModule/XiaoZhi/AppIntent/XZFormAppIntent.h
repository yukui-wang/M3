//
//  XZFormAppIntent.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/4/13.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZAppIntent.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZFormAppIntent : XZAppIntent

@property(nonatomic, strong)NSString *accountId;
@property(nonatomic, strong)NSString *url;
@property(nonatomic, strong)NSString *urlType;
@property(nonatomic, strong)NSString *callParamsUrl;
@property(nonatomic, strong)NSString *callParamsUrlType;
@end

NS_ASSUME_NONNULL_END
