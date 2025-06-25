//
//  XZCultureMsg.h
//  M3
//
//  Created by wujiansheng on 2018/9/7.
//  文件建设消息 生日等

#import "XZBaseMsg.h"

@interface XZCultureMsg : XZBaseMsg
@property(nonatomic, copy)NSString *imgUrl;
@property(nonatomic, copy)NSString *content;
@property(nonatomic, retain)NSDictionary *gotoParams;

@end
