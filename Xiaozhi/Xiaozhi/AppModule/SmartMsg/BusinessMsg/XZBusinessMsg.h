//
//  XZBusinessMsg.h
//  M3
//
//  Created by wujiansheng on 2018/9/7.
//  业务消息 图表

#import "XZBaseMsg.h"

@interface XZBusinessMsg : XZBaseMsg

@property(nonatomic, copy)NSString *loadUrl;
@property(nonatomic, copy)NSString *content;
@property(nonatomic, retain)NSDictionary *gotoParams;

@end
