//
//  XZCreateFormModel.h
//  M3
//
//  Created by wujiansheng on 2018/8/10.
//

#import "XZCreateModel.h"
#import "XZOptionMemberParam.h"
@interface XZCreateFormModel : XZCreateModel
@property(nonatomic, copy) void (^needSayBlock)(NSString *say);
@property(nonatomic, copy) void (^needUnitBlock)(BOOL unit);
@property(nonatomic, copy) void (^needLongTextBlock)(NSString *say);
@property(nonatomic, copy) void (^needShortTextBlock)(NSString *say);
@property(nonatomic, copy) void (^needMembersBlock)(NSString *say);
@property(nonatomic, copy) void (^needChooseFormOptionMembersBlock)(XZOptionMemberParam *param);
@property(nonatomic, copy) void (^needChooseMembersFinishBlock)(NSString *allNames);

@property(nonatomic, copy) void (^needCreateFormBlock)(NSDictionary *param);
@property(nonatomic, copy) void (^needShowFormBlock)(NSDictionary *param);
@property(nonatomic, copy) void (^needCancelBlock)(NSString *say);
@property(nonatomic, copy) void (^needShowChoosedMembersBlock)(NSString *names);
@property(nonatomic, copy) void (^needSleepBlock)(void);
@property(nonatomic, copy) void (^needContinueRecognizeBlock)(void);

@end
