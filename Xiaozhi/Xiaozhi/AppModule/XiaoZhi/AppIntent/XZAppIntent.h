//
//  XZLocalIntent.h
//  M3
//
//  Created by wujiansheng on 2019/3/7.
//

#import <Foundation/Foundation.h>
#import "SPConstant.h"
#import "SPTools.h"
#import "XZIntentStep.h"
#import "XZCore.h"
#import "BUnitResult.h"

typedef void(^XZIntentBlock)(id intent);
typedef void(^XZIntentShowGuideBlock)(NSString *guideWord);
typedef void(^XZIntentStepClarifyMembersBlock)(XZIntentStepClarifyMemberParam *param);
typedef void(^XZIntentRecognizeTypeBlock)(SpeechRecognizeType type);
typedef void(^XZObtainOptionBlock)(XZObtainOptionConfig *config,NSDictionary *params,id intentStep);


@interface XZAppIntent : NSObject<XZIntentStepDelegate>

@property(nonatomic, strong)NSString *intentName;
@property(nonatomic, strong)NSString *appId;
@property(nonatomic, strong)NSString *appName;
@property(nonatomic, strong)NSArray *params;//意图步骤
@property(nonatomic, strong)NSDictionary *extData;//额外参数
@property(nonatomic, strong)NSString *openType;
@property(nonatomic, strong)NSString *openApi;
@property(nonatomic, strong)NSString *loadUrl;//H5渲染卡片的路径地址 xx
@property(nonatomic, strong)NSString *renderType;//penetrate:穿透 （使用openType+openApi） card:卡片渲染，先请求，再渲染卡片（使用loadUrl）  nesting:嵌套，在小致界面渲染（使用loadUrl）
@property(nonatomic, strong)NSDictionary *relationParams;


@property(nonatomic, copy)XZIntentShowGuideBlock showGuideBlock;
@property(nonatomic, copy)XZIntentBlock searchBlock;
@property(nonatomic, copy)XZIntentBlock createBlock;
@property(nonatomic, copy)XZIntentBlock openBlock;
@property(nonatomic, copy)XZIntentBlock cancelBlock;
@property(nonatomic, copy)XZIntentBlock checkParamsBlock;
@property(nonatomic, copy)XZIntentBlock nestingBlock;//nesting:嵌套，在小致界面渲染（使用loadUrl）
@property(nonatomic, copy)XZIntentBlock showCardBlock;

@property(nonatomic, copy)XZIntentStepClarifyMembersBlock clarifyMembersBlock;
@property(nonatomic, copy)XZIntentRecognizeTypeBlock spRecognizeTypeBlock;

@property(nonatomic, copy)XZObtainOptionBlock obtainOptionBlock;

@property(nonatomic, strong)NSString *intentStepTarget;
@property(nonatomic, strong)NSDictionary *relationData;//解析后的关联数据
@property(nonatomic, weak)XZIntentStep *currentStep;
@property(nonatomic, strong)NSDictionary *tempData;//缓存nextIntent  optionValue插件的值


+ (BOOL)isAppIntent:(NSString *)intentName;
+ (BOOL)isUnavailableAppIntent:(NSString *)intentName;

- (id)initWithIntentName:(NSString *)intentName;
+ (XZAppIntent *)IntentWithName:(NSString *)intentName;
- (id)initWithBundleFile:(NSString *)fileName;
+ (XZAppIntent *)IntentWithBundleFile:(NSString *)fileName;

- (NSString *)paramUrlWithUrl:(NSString *)url;
- (NSDictionary *)dicVaule;
- (NSDictionary *)defaultValue;
- (void)handlePairValue;//关联时间时间段参数

- (NSString *)request_url;
- (NSDictionary *)request_params;
- (NSString *)open_url;
- (NSDictionary *)open_params;

- (NSString *)relation_url;
- (NSDictionary *)relation_params;
- (NSString *)checkParams_url;
- (NSDictionary *)checkParams_params;

- (NSArray *)card_params;

- (BOOL)handleCookies;
- (void)next;
- (BOOL)canNext;
- (BOOL)isEnd;//意图完成
- (BOOL)isRequiredEnd;//意图必填完成

- (void)handleUnitResult:(BUnitResult *)bResult;
- (void)handleNativeResult:(NSString *)result;
- (void)handleMembers:(NSArray *)array target:(NSString *)target next:(BOOL)next;
- (BOOL)useUnit;
- (BOOL)currentIsLongText;
- (BOOL)isMultiSelectMember;
- (BOOL)canHandleSendWords;
- (XZIntentStep *)stepForKey:(NSString *)key;
- (BOOL)isCreateIntent;

- (void)handleRelatePreIntent:(CMPOfflineContactMember *)member;

- (void)handlePreIntentData:(NSDictionary *)data;

@end

