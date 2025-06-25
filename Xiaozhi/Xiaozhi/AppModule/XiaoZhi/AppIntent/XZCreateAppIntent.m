//
//  XZCreateAppIntent.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/4/10.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZCreateAppIntent.h"
#import "XZIntentMemberStep.h"
#import "XZDateUtils.h"

@interface XZCreateAppIntent (){
    BOOL _useUnit;
}

@property(nonatomic, assign)long long sourceId;//本地缓存以保证，修改后点击卡片穿透能拿到数据

@end

@implementation XZCreateAppIntent

- (id)initWithIntentName:(NSString *)intentName {
    if (self = [super init]) {
        self.intentName = intentName;
        if (intentName.length > 2) {
            NSString *filePath = [NSString stringWithFormat:@"%@/%@.json",[SPTools localIntentFolderPath],intentName];
            [self setupWithFilePath:filePath];
        }
        _useUnit = YES;
    }
    return self;
}

- (id)initWithBundleFile:(NSString *)fileName {
    if (self = [super init]) {
        NSString *file = XZ_NAME(fileName);
        NSString *filePath = [[NSBundle mainBundle] pathForResource:file ofType:nil];
        [self setupWithFilePath:filePath];
        _useUnit = NO;
    }
    return self;
}

- (void)setupWithFilePath:(NSString *)filePath {
    NSString *jsonStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"create intent:\n%@",jsonStr);
    NSDictionary *data = [SPTools dictionaryWithJsonString:jsonStr];
    self.intentName = [SPTools stringValue:data forKey:@"intentName"];
    self.appId = [SPTools stringValue:data forKey:@"appId"];
    self.appName = [SPTools stringValue:data forKey:@"appName"];
    self.url = [SPTools stringValue:data forKey:@"url"];
    self.urlType = [SPTools stringValue:data forKey:@"urlType"];
    self.extData = [SPTools dicValue:data forKey:@"extData"];
    self.openType = [SPTools stringValue:data forKey:@"openType"];
    self.openApi = [SPTools stringValue:data forKey:@"openApi"];
    self.sourceIdUrl = [SPTools stringValue:data forKey:@"sourceIdUrl"];
    self.sourceIdUrlType = [SPTools stringValue:data forKey:@"sourceIdUrlType"];
    self.epilogue = [SPTools stringValue:data forKey:@"epilogue"];
    self.loadUrl = [SPTools stringValue:data forKey:@"loadUrl"];
    self.sourceIdUrl = [SPTools stringValue:data forKey:@"sourceIdUrl"];
    self.sourceIdUrlType = [SPTools stringValue:data forKey:@"sourceIdUrlType"];
    self.checkParamsUrl = [SPTools stringValue:data forKey:@"checkParamsUrl"];
    self.checkParamsUrlType = [SPTools stringValue:data forKey:@"checkParamsUrlType"];
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    NSTimeInterval timeInterval = [datenow timeIntervalSince1970];
    self.sourceId = timeInterval*1000;

    self.relationParams = [SPTools dicValue:data forKey:@"relationParams"];
    NSArray *param = [SPTools arrayValue:data forKey:@"params"];
    NSMutableArray *paramTemp = [NSMutableArray array];
    for (NSDictionary *dict in param) {
        XZIntentStep *step = [XZIntentStep intentStepWithDic:dict];
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

- (NSString *)request_url {
    NSString *url = [self.urlType isEqualToString:KXZIntentUrlType_Rest] ? [XZCore fullUrlForPath:self.url] : self.url;
    return url;
}

- (NSDictionary *)request_params {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [result addEntriesFromDictionary:self.extData];
    [result addEntriesFromDictionary:self.defaultValue];
    [result addEntriesFromDictionary:self.relationData];
    [result addEntriesFromDictionary:self.tempData];
    [result addEntriesFromDictionary:self.dicVaule];
    [result setObject:[NSNumber numberWithLongLong:self.sourceId] forKey:@"sourceId"];
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
        [params setObject:[NSNumber numberWithLongLong:self.sourceId] forKey:@"sourceId"];
        [params setObject:@"view" forKey:@"option"];
        result = [NSDictionary dictionaryWithObjectsAndKeys:self.openApi,@"openApi",self.appId,@"appId",params,@"params", nil];
    }
    return result;
}

- (NSString *)relation_url {
    NSString *url = [self.sourceIdUrlType isEqualToString:KXZIntentUrlType_Rest] ? [XZCore fullUrlForPath:self.sourceIdUrl] : self.sourceIdUrl;
    return url;
}

- (NSDictionary *)relation_params {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [result addEntriesFromDictionary:self.extData];
    [result setObject:[NSNumber numberWithLongLong:self.sourceId] forKey:@"sourceId"];
    return result;
}
- (NSString *)checkParams_url {
    if ([NSString isNull:self.checkParamsUrl]) {
        return nil;
    }
    NSString *url = [self.checkParamsUrlType isEqualToString:KXZIntentUrlType_Rest] ? [XZCore fullUrlForPath:self.checkParamsUrl] : self.checkParamsUrl;
    return url;
}

- (NSDictionary *)checkParams_params {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [result addEntriesFromDictionary:self.extData];
    [result addEntriesFromDictionary:self.defaultValue];
    [result addEntriesFromDictionary:self.relationData];
    [result addEntriesFromDictionary:self.tempData];
    [result addEntriesFromDictionary:self.dicVaule];
    [result setObject:[NSNumber numberWithLongLong:self.sourceId] forKey:@"sourceId"];
    return result;
}

- (NSArray *)card_params {
    NSMutableArray *result = [NSMutableArray array];
    for (XZIntentStep *step in self.params) {
        NSArray *array = [NSArray arrayWithObjects:step.displayName,step.displayValue?:@"-", nil];
        [result addObject:array];
    }
    return result;
}

- (BOOL)handleCookies {
    return ![self.url isEqualToString:KXZIntentUrlType_Remote];
}

- (void)next {
    if ([self canNext]) {
        self.currentStep = self.currentStep.nextStep;
        [self next];
        return;
    }
    if (!self.currentStep) {
        [XZCore sharedInstance].textLenghtLimit = 0;
        if (self.showGuideBlock) {
            self.showGuideBlock(self.epilogue);
        }
    }
    else {
        [XZCore sharedInstance].textLenghtLimit = self.currentStep.limit;
        if (self.showGuideBlock) {
            self.showGuideBlock(self.currentStep.guideWord);
        }
    }
    SpeechRecognizeType type =  SpeechRecognizeShortText;
    if (self.currentStep.isChooseMember) {
        type = SpeechRecognizeMember;
    }
//    else if (self.currentStep.isLongText) {
//        type = SpeechRecognizeLongText;
//    }
    if (self.spRecognizeTypeBlock) {
        self.spRecognizeTypeBlock(type);
    }
    if (![self.currentStep isKindOfClass:NSClassFromString(@"XZObtainOptionStep")]) {
        [self showCard];
    }
}

- (void)handleNativeResult:(NSString *)result {
    if (self.currentStep) {
        __weak typeof(self) weakSelf = self;
        [self.currentStep handleNativeResult:result complete:^{
            [weakSelf handlePairValue];
            [weakSelf next];
        }];
    }
    else {
        [self next];
    }
}

- (void)handleUnitResult:(BUnitResult *)bResult {
    NSDictionary *dic = bResult.infoListDict;
    if (bResult.isEnd) {
        _useUnit = NO;
    }
    if (dic && dic.allKeys.count > 0) {
        XZIntentStep *memberStep = nil;
        for (XZIntentStep *step in self.params) {
            NSString *key = step.slot;
            if (dic[key]) {
                if ([step isChooseMember]) {
                    if (![step normalizedValue]) {
                        //选人 且不是text 跳过，最后单独处理,  如果有值了也不处理（防止重复处理）
                        memberStep = step;
                    }
                    continue;
                }
                [step handleUnitResult:dic[key] complete:nil];
            }
        }
        [self handlePairValue];
        if (memberStep) {
            NSArray *members = dic[memberStep.slot];
            if ([bResult.currentText rangeOfString:[members firstObject]].location != NSNotFound) {
                if(self.currentStep != memberStep) {
                    //memberStep放在首位
                    memberStep.parentStep.nextStep = memberStep.nextStep;
                    memberStep.nextStep = self.currentStep;
                    self.currentStep = memberStep;
                }
                __weak typeof(self) weakSelf = self;
                [memberStep handleUnitResult:dic[memberStep.slot] complete:^{
                    [weakSelf next];
                }];
                return;
            }
        }
    }
     [self next];
}

- (void)handleMembers:(NSArray *)array target:(NSString *)target next:(BOOL)next{
    NSString *key = target? target:self.intentStepTarget;
    XZIntentStep *step = target ? [self stepForKey:key]:nil;
    step = step? :self.currentStep;
    [step handleMembers:array];
    self.intentStepTarget = nil;
    if (next) {
        [self next];
    }
}

- (BOOL)canNext {
    if (!self.currentStep) {
        return NO;
    }
    return [self.currentStep canNextForCreate];
}

- (BOOL)isMultiSelectMember {
    return [self.currentStep isMultiSelectMember];
}

- (BOOL)useUnit {
    BOOL result = self.currentStep ? [self.currentStep useUnit] : YES;
    return result;
}

- (BOOL)canHandleSendWords {
    if ([self checkParams_url]) {
        self.checkParamsBlock(self);
    }
    else {
        self.createBlock(self);
    }
    return YES;
}

- (void)showCard {
    if (self.showCardBlock) {
        self.showCardBlock(self);
    }
}

- (BOOL)isCreateIntent {
    return YES;
}


- (void)handleRelatePreIntent:(CMPOfflineContactMember *)member {
    if (!member) {
        return;
    }
    for (XZIntentStep *step in self.params) {
        if (step.relatePreIntent) {
            [step handleMembers:@[member]];
            if(self.currentStep != step) {
                //memberStep放在首位
                step.parentStep.nextStep = step.nextStep;
                step.nextStep = self.currentStep;
                self.currentStep = step;
            }
            break;
        }
    }
}

@end
