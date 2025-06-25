//
//  XZScheduleMsgItem.h
//  M3
//
//  Created by wujiansheng on 2018/9/12.
//

#import <Foundation/Foundation.h>
#import "XZBaseMsgData.h"

@interface XZScheduleMsgItem : NSObject
@property(nonatomic, copy)NSString *type;
@property(nonatomic, retain)NSArray<XZBaseMsgData *> *items;
@property(nonatomic, copy)NSString *showInfo;
@property(nonatomic, retain)UIColor *color;

- (id)initWithMsg:(NSDictionary *)msg;

@end
