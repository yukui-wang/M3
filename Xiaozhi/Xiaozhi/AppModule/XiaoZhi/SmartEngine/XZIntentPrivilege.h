//
//  XZIntentPrivilege.h
//  M3
//
//  Created by wujiansheng on 2018/12/27.
//

#import <CMPLib/CMPObject.h>


@interface XZIntentPrivilege : CMPObject
@property(nonatomic, strong) NSDictionary *intentDic;
@property(nonatomic, strong) NSString *showStr;
@property(nonatomic, strong) NSString *showAllStr;
@property(nonatomic, assign) BOOL showMore;

- (id)initWithResult:(NSArray *)array;
- (id)initWithIntentNameArray:(NSArray *)array;

- (BOOL)isAvailableIntentName:(NSString *)intentName;
@end

