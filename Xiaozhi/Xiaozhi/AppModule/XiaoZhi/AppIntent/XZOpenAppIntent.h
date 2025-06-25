//
//  XZOpenAppIntent.h
//  M3
//
//  Created by wujiansheng on 2019/3/13.
//

#import "XZAppIntent.h"

@interface XZOpenAppIntent : XZAppIntent
@property(nonatomic, strong)NSDictionary *paramsDic;

- (id)initWithJsonStr:(NSString *)jsonStr;

@end
