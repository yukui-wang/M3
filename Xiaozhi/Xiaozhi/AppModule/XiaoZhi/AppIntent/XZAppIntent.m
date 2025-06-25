//
//  XZLocalIntent.m
//  M3
//
//  Created by wujiansheng on 2019/3/7.
//

#import "XZAppIntent.h"
#import "XZSearchAppIntent.h"
#import "XZCreateAppIntent.h"
#import "XZFormAppIntent.h"
#import "XZSearchAppIntent_70_1.h"
#import <CMPLib/NSString+CMPString.h>
#import "XZIntentNumberStep.h"
#import "XZIntentDateStep.h"
#import "XZIntentTimestampStep.h"
#import "XZIntentDateTimeStep.h"

@interface XZAppIntent ()
@end

@implementation XZAppIntent

+ (BOOL)isAppIntent:(NSString *)intentName {
    if (intentName.length < 4) {
        return NO;
    }
    NSString *subStr = [intentName substringToIndex:4];
    if ([subStr isEqualToString:@"APP_"]) {
        NSString *path = [NSString stringWithFormat:@"%@/%@.json",[SPTools localIntentFolderPath],intentName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            return YES;
        }
    }
    return NO;
}


+ (BOOL)isUnavailableAppIntent:(NSString *)intentName {
    if (intentName.length < 4 ) {
        return NO;
    }
    NSString *subStr = [intentName substringToIndex:4];
    if ([subStr isEqualToString:@"APP_"]) {
        NSString *path = [NSString stringWithFormat:@"%@/%@.json",[SPTools localIntentFolderPath],intentName];
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            //找不到对应的json文件
            return YES;
        }
    }
    return NO;
}

+ (XZAppIntent *)IntentWithName:(NSString *)intentName {
    
    if ([intentName isEqualToString:@"APP_70_1_S"]) {
        //特殊处理，该意图词槽要取list，
        XZSearchAppIntent_70_1 *intent = [[XZSearchAppIntent_70_1 alloc] initWithIntentName:intentName];
        return intent;
    }
    NSString *subStr = [intentName.lowercaseString substringFromIndex:intentName.length-2];
    if ([subStr isEqualToString:@"_s"]) {
        //搜索
        XZSearchAppIntent *intent = [[XZSearchAppIntent alloc] initWithIntentName:intentName];
        return intent;
    }
    if ([subStr isEqualToString:@"_c"]) {
        //创建
        XZCreateAppIntent *intent = [[XZCreateAppIntent alloc] initWithIntentName:intentName];
        return intent;
    }
    if ([subStr isEqualToString:@"_f"]) {
        //表单 高级计算
        XZFormAppIntent *intent = [[XZFormAppIntent alloc] initWithIntentName:intentName];
        return intent;
    }
    //_o 打开，对话意图（FAQ）直接处理 
    return nil;
}

+ (XZAppIntent *)IntentWithBundleFile:(NSString *)fileName {
    XZCreateAppIntent *intent = [[XZCreateAppIntent alloc] initWithBundleFile:fileName];
    return intent;
}

- (void)dealloc {
    self.intentName = nil;
    self.extData = nil;
    self.params = nil;
   
    self.currentStep = nil;
  
    self.showGuideBlock = nil;
    self.searchBlock = nil;
    self.createBlock = nil;
    self.openBlock = nil;
    self.cancelBlock = nil;
    self.checkParamsBlock = nil;
    self.nestingBlock = nil;
    self.showCardBlock = nil;
   
    self.clarifyMembersBlock = nil;
    self.spRecognizeTypeBlock = nil;

    self.intentStepTarget = nil;
}

- (id)initWithIntentName:(NSString *)intentName {
    if (self = [super init]) {
        self.intentName = intentName;
    }
    return self;
}

- (id)initWithBundleFile:(NSString *)fileName {
    if (self = [super init]) {
    }
    return self;
}

- (void)intentStepShpuldClarifyMembers:(XZIntentStepClarifyMemberParam *)param {
    if (self.clarifyMembersBlock) {
        self.clarifyMembersBlock(param);
    }
}

- (NSDictionary *)obtainOptionConfigParam {
    return [self dicVaule];
}
- (void)needRequestObtainOption:(XZObtainOptionConfig *)config param:(NSDictionary *)params intentStep:(id)intentStep{
    if (self.obtainOptionBlock) {
        self.obtainOptionBlock(config, params,intentStep);
    }
}
- (id)pairStepForKey:(NSString *)pairKey {
    id result = nil;
    for (XZIntentStep *step in self.params) {
        if ([step.key isEqualToString:pairKey]) {
            result = step;
            break;
        }
    }
    return result;
}

//意图完成
- (BOOL)isEnd {
    if (!self.currentStep) {
        return YES;
    }
    return NO;
}
//意图必填完成
- (BOOL)isRequiredEnd {
    if (self.currentStep) {
        return !self.currentStep.required;
    }
    return YES;
}


- (NSDictionary *)dicVaule {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (XZIntentStep *step in self.params) {
        id value = step.normalizedValue;
        if (value) {
            [dic setObject:value forKey:step.key];
        }
    }
    return dic;
}

- (NSDictionary *)defaultValue {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (XZIntentStep *step in self.params) {
        id value = [step normalizeDefauleValue];
        if (value) {
            [dic setObject:value forKey:step.key];
        }
    }
    [self handlePairValue];
    return dic;
}

- (void)handlePairValue {
    NSMutableDictionary *secondStepDic = [NSMutableDictionary dictionary];
    NSMutableArray *firstLocArray = [NSMutableArray array];
    for (XZIntentStep *step in self.params) {
        if (step.pairKey ) { //1-2
            if ([step.currentLoc isEqualToString:@"1"]) {
                [firstLocArray addObject:step];
            }
            else {
                [secondStepDic setObject:step forKey:step.key];
            }
        }
    }
    for (XZIntentStep *step in firstLocArray) {
        XZIntentStep *secondStep = secondStepDic[step.pairKey];
        if (step.pairValue && ![secondStep normalizedValue]) {
            [secondStep handlePairValue:step.pairValue];
        }
        else if (secondStep.pairValue && ![step normalizedValue]) {
            [step handlePairValue:secondStep.pairValue];
        }
    }
}

- (NSString *)stringValue {
    NSMutableString *string = [NSMutableString string];
    for (XZIntentStep *step in self.params) {
       
        NSString *strVaule = [step stringValue];
        if (![NSString isNull:strVaule]) {
            if (string.length > 0) {
                [string appendString:@"&"];
            }
            [string appendFormat:@"%@=%@",step.key,strVaule];
        }
    }
    return string;
}
- (NSString *)paramUrlWithUrl:(NSString *)url {
    NSString *result = url;
    for (XZIntentStep *step in self.params) {
        NSString *strVaule = [step stringValue];
        if (![NSString isNull:strVaule]) {
            result = [result appendHtmlUrlParam:step.key value:strVaule];
        }
    }
    return result;
}

- (NSString *)request_url {
    return nil;
}

- (NSDictionary *)request_params {
    return nil;
}

- (NSString *)open_url {
    return nil;
}

- (NSDictionary *)open_params {
    return nil;
}

- (NSString *)relation_url {
    return nil;
}

- (NSDictionary *)relation_params {
    return nil;
}

- (NSString *)checkParams_url {
    return nil;
}

- (NSDictionary *)checkParams_params {
    return nil;
}

- (NSArray *)card_params {
    return nil;
}

- (BOOL)handleCookies {
    return NO;
}

- (void)next {
   
}

- (void)handleNativeResult:(NSString *)result {
    if (self.currentStep) {
        [self.currentStep handleNativeResult:result complete:nil];
        [self next];
    }
    else {
        [self next];
    }
}

- (void)handleUnitResult:(BUnitResult *)bResult {
    
}

- (void)handleMembers:(NSArray *)array target:(NSString *)target next:(BOOL)next{
}

- (BOOL)canNext {
    return NO;
}

- (BOOL)useUnit {
    return YES;
}

- (BOOL)currentIsLongText {
    return NO;
}

- (BOOL)isMultiSelectMember {
    return NO;
}

- (BOOL)canHandleSendWords {
    return NO;
}

- (NSDictionary *)relationData {
    if (!_relationData) {
        NSArray *allkey = self.relationParams.allKeys;
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        NSMutableDictionary *stepDic = [NSMutableDictionary dictionary];
        for (XZIntentStep *step in self.params) {
            if (![NSString isNull:step.key]) {
                [stepDic setObject:step forKey:step.key];
            }
        }
        
        for (NSString *key in allkey) {
            NSDictionary *relationDic = self.relationParams[key];
            NSString *relationKey = relationDic[@"relationKey"];
            NSInteger relationValue = [relationDic[@"relationValue"] integerValue];
            NSString *expressionSymbol = relationDic[@"expressionSymbol"];
            XZIntentStep *step = stepDic[key];
            XZIntentStep *relationStep = stepDic[relationKey];
            if (![relationStep normalizedValue] || [step normalizedValue]) {
                //关联对象没有值   该对象本来就有值 ，就不处理了
                continue;
            }
            long long number = [relationStep numberValue];
            
            if ([expressionSymbol.lowercaseString isEqualToString:@"plus"]) {
                number += relationValue;
            }
            if ([step isKindOfClass:[XZIntentNumberStep class]]) {
                [dic setObject:[NSString stringWithLongLong:number] forKey:key];
            }
            else  if ([step isKindOfClass:[XZIntentDateStep class]]) {
                NSString *value = [XZDateUtils dateStrFormTimestamp:number dateFormat:kDateFormate_YYYY_MM_DD];
                [dic setObject:value forKey:key];
            }
            else  if ([step isKindOfClass:[XZIntentTimestampStep class]]) {
                [dic setObject:[NSString stringWithLongLong:number] forKey:key];
            }
            else  if ([step isKindOfClass:[XZIntentDateTimeStep class]]) {
                NSString *value = [XZDateUtils dateStrFormTimestamp:number dateFormat:kDateFormate_YYYY_MM_DD_HHMM];
                [dic setObject:value forKey:key];
            }
            else {
                [dic setObject:relationStep.stringValue forKey:key];
            }
        }
        _relationData = [[NSDictionary alloc] initWithDictionary:dic];
    }
    return _relationData;
}

- (XZIntentStep *)stepForKey:(NSString *)key {
    if ([NSString isNull:key]) {
        return nil;
    }
    for (XZIntentStep *step in self.params) {
        if ([key isEqualToString:step.key]) {
            return step;
        }
    }
    return nil;
}

- (BOOL)isCreateIntent {
    return NO;
}

- (void)handleRelatePreIntent:(CMPOfflineContactMember *)member {
    
}

- (void)handlePreIntentData:(NSDictionary *)data {
   self.tempData = data;
      for (XZIntentStep *step in self.params) {
          id value = data[step.key];
          if (value) {
              [step handleNormalizedValue:value];
          }
      }
      [self next];
}

@end
