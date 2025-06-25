//
//  XZSearchAppIntent.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/4/10.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZAppIntent.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZSearchAppIntent : XZAppIntent {
     BOOL _useUnit;
}
//intent内部
@property(nonatomic, strong)NSString *url;
@property(nonatomic, strong)NSString *urlType;
@end

NS_ASSUME_NONNULL_END
