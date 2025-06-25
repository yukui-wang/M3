//
//  XZOptionMemberParam.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/9/18.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import <CMPLib/CMPObject.h>

typedef void(^SmartMembersBlock)(NSArray *members, BOOL cancel,NSString *extData);

@interface XZOptionMemberParam : CMPObject
@property(nonatomic,copy)NSString *speakContent;
@property(nonatomic,copy)NSString *showContent;
@property(nonatomic,retain)NSArray *members;
@property(nonatomic,copy)NSString *extData;
@property(nonatomic,assign)BOOL isMultipleSelection;//是否是多选
@property(nonatomic,retain)NSArray *defaultSelectArray;//默认勾选
@property(nonatomic,copy)SmartMembersBlock  membersChoosedBlock;

@end


