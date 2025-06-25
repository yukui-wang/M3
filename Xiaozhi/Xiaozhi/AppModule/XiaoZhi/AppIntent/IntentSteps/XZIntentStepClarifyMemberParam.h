//
//  XZIntentStepClarifyMemberParam.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/9/18.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import <CMPLib/CMPObject.h>

@interface XZIntentStepClarifyMemberParam : CMPObject
@property(nonatomic,retain)NSArray *members;
@property(nonatomic,copy)NSString *name;
@property(nonatomic,copy)NSString *target;
@property(nonatomic,assign)BOOL isMultipleSelection;//是否是多选
@property(nonatomic,retain)NSArray *defaultSelectArray;//默认勾选
@end
