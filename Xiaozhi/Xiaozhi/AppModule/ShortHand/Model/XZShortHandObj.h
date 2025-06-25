//
//  XZShortHandObj.h
//  M3
//
//  Created by wujiansheng on 2019/1/7.
//

#import <CMPLib/CMPObject.h>

@interface XZShortHandObj : CMPObject

@property(nonatomic, assign) long long shId;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *content;
@property(nonatomic, copy) NSString *createDate;
@property(nonatomic, retain) NSArray *forwardApps;

- (id)initWithDic:(NSDictionary *)dic;

@end

