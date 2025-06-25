//
//  XZIntentMemberStep.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/4/29.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZIntentStep.h"


@interface XZIntentMemberStep : XZIntentStep

@property(nonatomic, strong)NSString *originalValue;//原始数据 防止多次冲通讯录选择人员
@property(nonatomic,assign)BOOL skip;// 直接 “下一步”
@property(nonatomic,strong)NSString *errorMsg;// 直接 “下一步”
@property(nonatomic, strong)NSArray *tempValue;//重名人员缓存

- (NSString *)memberToIdStr:(CMPOfflineContactMember *)member;
- (NSDictionary *)memberToDictionary:(CMPOfflineContactMember *)member;
- (NSString *)errorMsgWithName:(NSString *)name;
@end

