//
//  XZSearchAppIntent.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/4/10.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZSearchAppIntent.h"

@interface XZSearchAppIntent () {
   
}
@property(nonatomic, strong)NSArray *paramsRule;
@end

@implementation XZSearchAppIntent

- (id)initWithIntentName:(NSString *)intentName {
    if (self = [super init]) {
        self.intentName = intentName;
        if (intentName.length > 2) {
            NSString *filePath = [NSString stringWithFormat:@"%@/%@.json",[SPTools localIntentFolderPath],intentName];
            NSString *jsonStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
            NSLog(@"search intent:\n%@",jsonStr);
            NSDictionary *data = [SPTools dictionaryWithJsonString:jsonStr];
            self.intentName = [SPTools stringValue:data forKey:@"intentName"];
            self.appId = [SPTools stringValue:data forKey:@"appId"];
            self.appName = [SPTools stringValue:data forKey:@"appName"];
            self.url = [SPTools stringValue:data forKey:@"url"];
            self.urlType = [SPTools stringValue:data forKey:@"urlType"];
            self.extData = [SPTools dicValue:data forKey:@"extData"];
            self.loadUrl = [SPTools stringValue:data forKey:@"loadUrl"];
            self.openType = [SPTools stringValue:data forKey:@"openType"];
            self.openApi = [SPTools stringValue:data forKey:@"openApi"];
            self.renderType = [SPTools stringValue:data forKey:@"renderType"];
            self.relationParams = [SPTools dicValue:data forKey:@"relationParams"];
            self.paramsRule = [SPTools arrayValue:data forKey:@"paramsRule"];
            NSArray *param = [SPTools arrayValue:data forKey:@"params"];
            
            NSMutableArray *paramTemp = [NSMutableArray array];
            for (NSDictionary *dict in param) {
                XZIntentStep *step = [XZIntentStep intentStepWithDic:dict];
                step.isSearchStep = YES;
                step.delegate = self;
                XZIntentStep *preStep = [paramTemp lastObject];
                preStep.nextStep = step;
                step.parentStep = preStep;
                [paramTemp addObject:step];
                step = nil;
            }
            self.params = paramTemp;
            self.currentStep = self.params.firstObject;
        }
        _useUnit = YES;
    }
    return self;
}

- (NSString *)request_url {
    NSString *url = [self.urlType isEqualToString:KXZIntentUrlType_Rest] ? [XZCore fullUrlForPath:self.url] : self.url;
    return url;
}

- (NSDictionary *)request_params {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [result addEntriesFromDictionary:self.extData];
    NSDictionary *dicVaule = self.dicVaule;
    if(dicVaule.count == 0 ) {
        [result addEntriesFromDictionary:self.defaultValue];
    }
    [result addEntriesFromDictionary:self.relationData];
    [result addEntriesFromDictionary:self.tempData];
    [result addEntriesFromDictionary:self.dicVaule];
    return result;
}

- (NSString *)paramUrlWithUrl:(NSString *)url {
    NSString *result = url;
    NSDictionary *params = [self request_params];
    NSArray *allKeys = params.allKeys;
    for (NSString *key in allKeys) {
        result = [result appendHtmlUrlParam:key value:params[key]];
    }
    return result;
}

- (NSString *)open_url {
    NSString *url = nil;
    if ([self.openType isEqualToString:KXZIntentOpenType_Url]) {
        url = [self paramUrlWithUrl:self.openApi];
    }
    return url;
}

- (NSDictionary *)open_params {
    NSDictionary * result = nil;
    if ([self.openType isEqualToString:KXZIntentOpenType_LoadApp]) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params addEntriesFromDictionary:self.extData];
        [params addEntriesFromDictionary:self.defaultValue];
        [params addEntriesFromDictionary:self.relationData];
        [params addEntriesFromDictionary:self.tempData];
        [params addEntriesFromDictionary:self.dicVaule];
        result = [NSDictionary dictionaryWithObjectsAndKeys:self.openApi,@"openApi",self.appId,@"appId",params,@"params", nil];
    }
    return result;
}

- (BOOL)handleCookies {
    return ![self.url isEqualToString:KXZIntentUrlType_Remote];
}

- (void)next {
    [self next:NO];

}

- (void)handleNativeResult:(NSString *)result {
    if (self.currentStep) {
        [self.currentStep handleNativeResult:result complete:nil];
        [self handlePairValue];
        [self next:NO];
    }
    else {
        [self next:YES];
    }
}

- (void)handleUnitResult:(BUnitResult *)bResult {
    _useUnit = NO;
    NSDictionary *dic = bResult.infoListDict;
    XZIntentStep *memberStep = nil;
    if (dic && dic.allKeys.count > 0) {
        for (XZIntentStep *step in self.params) {
            NSString *key = step.slot;
            if (dic[key]) {
                if ([step isChooseMember]) {
                    //选人 且不是text 跳过，最后单独处理
                    memberStep = step;
                    continue;
                }
                [step handleUnitResult:dic[key] complete:nil];
            }
        }
    }
    [self handlePairValue];
  
    BOOL isEnd = bResult.isEnd;
    if (memberStep) {
        NSArray *members = dic[memberStep.slot];
        if ([bResult.currentText rangeOfString:[members firstObject]].location != NSNotFound) {
            __weak typeof(self) weakSelf = self;
            if (weakSelf.currentStep != memberStep) {
                memberStep.parentStep.nextStep = memberStep.nextStep;
                memberStep.nextStep = weakSelf.currentStep;
                weakSelf.currentStep = memberStep;
            }
            [memberStep handleUnitResult:dic[memberStep.slot] complete:^{
                [weakSelf next:isEnd];
            }];
            return;
        }
    }
    [self next:isEnd];
}

- (void)next:(BOOL)isEnd {
    if (self.currentStep && ![self.currentStep canNext]&& self.showGuideBlock) {
        self.showGuideBlock(self.currentStep.guideWord);
        return;
    }
    self.currentStep = self.currentStep.nextStep;
    XZIntentStep *step = self.currentStep;
    if (step && !isEnd ) {
        if ([step canNext]) {
            [self next:NO];
        }
        else if (self.showGuideBlock) {
            self.showGuideBlock(step.guideWord);
        }
    }
    if (isEnd||!step) {
        if (self.paramsRule.count > 0&&
            [self dicVaule].count == 0 &&
            [self defaultValue].count == 0) {
            //使用 paramsRule
            NSArray *array = self.paramsRule[0];
            XZIntentStep *step = nil;
            XZIntentStep *preStep = nil;
            self.currentStep = nil;
            for (NSString *key in array) {
                step = [self stepForKey:key];
                if (!self.currentStep) {
                    self.currentStep = step;
                }
                if (preStep) {
                    preStep.nextStep = step;
                }
            }
            if (self.currentStep) {
               self.showGuideBlock(self.currentStep.guideWord);
                return;
            }
        }
    
        _useUnit = NO;
        if ([self.renderType isEqualToString:@"penetrate"]) {
            //penetrate:穿透 （使用openType+openApi）
            if (self.openBlock) {
                self.openBlock(self);
            }
        }
        else if ([self.renderType isEqualToString:@"nesting"]) {
            //nesting:嵌套，在小致界面渲染（使用loadUrl）
            if (self.nestingBlock) {
                self.nestingBlock(self);
            }
        }
        else {
            //card:卡片渲染，先请求，再渲染卡片（使用loadUrl）
            if (self.searchBlock) {
                self.searchBlock(self);
            }
        }
    }
}

- (void)handleMembers:(NSArray *)array target:(NSString *)target next:(BOOL)next{
    NSString *key = target? target:self.intentStepTarget;
    XZIntentStep *step = [self stepForKey:key];
    step = step?:self.currentStep;
    [step handleMembers:array];
    if (next) {
        [self next:[self stepForKey:self.intentStepTarget] ? NO:YES];
    }
    self.intentStepTarget = nil;
}

- (BOOL)useUnit {
    return _useUnit;
}

- (BOOL)isRequiredEnd {
    return [self isEnd];
}

@end
