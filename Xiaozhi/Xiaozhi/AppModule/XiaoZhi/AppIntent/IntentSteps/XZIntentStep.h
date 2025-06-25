//
//  XZIntentStep.h
//  M3
//
//  Created by wujiansheng on 2019/3/7.
//


#import <Foundation/Foundation.h>
#import "SPConstant.h"
#import "SPTools.h"
#import <CMPLib/CMPOfflineContactMember.h>
#import "XZDateUtils.h"
#import "XZIntentStepClarifyMemberParam.h"
#import "XZObtainOptionConfig.h"
@protocol XZIntentStepDelegate <NSObject>

- (void)intentStepShpuldClarifyMembers:(XZIntentStepClarifyMemberParam *)param;
- (NSDictionary *)obtainOptionConfigParam;
- (void)needRequestObtainOption:(XZObtainOptionConfig *)config param:(NSDictionary *)params intentStep:(id)intentStep;
- (id)pairStepForKey:(NSString *)pairKey;
@end

@interface XZIntentStep : NSObject {
    NSString *_guideWord;
}
@property(nonatomic, strong)NSString *key;
@property(nonatomic, strong)NSString *type;
@property(nonatomic, strong)NSString *slot;
@property(nonatomic, strong)NSString *guideWord;
@property(nonatomic, assign)BOOL required;
@property(nonatomic, assign)NSInteger limit;
@property(nonatomic, strong)NSString *displayName;//当前填空的对象
@property(nonatomic, assign)BOOL relatePreIntent;//关联上个意图，如显示人员卡片后发协同，人员需要带入x发协同中默认已选该人员
@property(nonatomic, assign)BOOL native;
@property(nonatomic, strong)NSString *pairKey;//新增字段pairKey:成对的关联字段, currentLoc：关联字段所在的位置
@property(nonatomic, strong)NSString *currentLoc;

@property(nonatomic, strong)NSString *displayValue;//显示卡片的内容

@property(nonatomic, strong)id pairValue;//显示卡片的内容
@property(nonatomic, assign)XZIntentStep *nextStep;
@property(nonatomic, assign)XZIntentStep *parentStep;

@property(nonatomic, assign)id<XZIntentStepDelegate> delegate;

@property(nonatomic, assign)BOOL isSearchStep;


- (id)initWithDic:(NSDictionary *)dic;
- (void)handleNativeResult:(NSString *)result complete:(void(^)(void))complete;
- (void)handleUnitResult:(NSArray *)result complete:(void(^)(void))complete;
- (void)handleMembers:(NSArray *)array;

- (void)handlePairValue:(NSString *)pairVaule;

- (NSString *)stringValue;
- (id)normalizedValue;//处理后的结果，标准化值
- (id)normalizeDefauleValue;

- (BOOL)canNext;
- (BOOL)canNextForCreate;
- (BOOL)isMultiSelectMember;
- (BOOL)isChooseMember;
- (BOOL)isLongText;
- (BOOL)useUnit;
- (long long)numberValue;//relationParams相关参数
- (CMPOfflineContactMember *)currentUser;

- (void)handleOptionValue:(NSDictionary *)params;

+ (XZIntentStep *)intentStepWithDic:(NSDictionary *)dic;
- (void)handleNormalizedValue:(id)value;
@end
