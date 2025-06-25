//
//  BUnitManager.m
//  BUnitManager
//
//  Created by 阿凡树 on 2017/7/27.
//  Copyright © 2017年 Baidu. All rights reserved.
//

#import "BUnitManager.h"
#import "SPConstant.h"
#import <CMPLib/NSString+CMPString.h>

@interface BUnitManager ()
@property (nonatomic, readwrite, assign) NSInteger scene_id;
@property (nonatomic, retain) NSURLSessionTask *sessionTask;
@end

@implementation BUnitManager

+ (instancetype)sharedInstance {
    static BUnitManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BUnitManager alloc] init];
    });
    return instance;
}

- (void)setSceneID:(NSInteger)sceneID {
    self.scene_id = sceneID;
    [self resetDialogueState];
}

- (void)resetDialogueState {
    self.session = @"";
}

- (NSDictionary *)dataToDic:(NSData *)data {
    NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    return dict;
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSString * responseString;
    responseString = [jsonString stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    responseString = [responseString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    responseString = [responseString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    responseString = [responseString stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
    responseString = [responseString stringByReplacingOccurrencesOfString:@"</br>" withString:@""];
    NSData *jsonData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSObject *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:NSJSONReadingMutableContainers
                                                      error:&err];
    if ([dic isKindOfClass:[NSArray class]]) {
        return [(NSArray *)dic firstObject];
    }
    return (NSDictionary *)dic;
}

- (NSString *)stringValueInDic:(NSDictionary *)dic key:(NSString *)key {
    id value = dic[key];
    if (value) {
        if ([value isKindOfClass:[NSString class]]) {
            return value;
        }
        if ([value isKindOfClass:[NSNumber class]]) {
            NSNumber *number = (NSNumber *)value;
            return [number stringValue];
        }
    }
    return nil;
}


- (void)getAccessTokenWithAK:(NSString *)ak SK:(NSString *)sk
                  completion:(void (^)(NSError *error, NSString* token))completionBlock {
    __weak typeof(self) weakSelf = self;
    NSString* url = [NSString stringWithFormat:@"https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials&client_id=%@&client_secret=%@",ak,sk];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLSessionTask * task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
        if (error == nil) {
            NSDictionary* dict = [self dataToDic:data];
            weakSelf.accessToken = dict[@"access_token"];
            if (completionBlock) {
                completionBlock(nil, dict[@"access_token"]);
            }
        } else {
            if (completionBlock) {
                completionBlock(error, nil);
            }
        }
    }];
    [task resume];
}


- (BOOL)isVersionLater2 {
    if ([self.version isKindOfClass:[NSString class]] && self.version.length > 0) {
        NSArray *array = [self.version componentsSeparatedByString:@"."];
        NSInteger first = [array[0] integerValue];
        if (first > 1) {
            return YES;
        }
    }
    return NO;
}

- (void)askWord:(NSString *)word completion:(void (^)(NSError *error, BUnitResult *resultObject))completionBlock {
    if ([self isVersionLater2]) {
        //2.0版本
        [self askWordV2:word completion:completionBlock];
    }
    else {
        //1.0版本
        [self askWordV1:word completion:completionBlock];
    }
}
/*********************************** unit 1.0 start ***************************************/
- (void)askWordV1:(NSString *)word completion:(void (^)(NSError *error, BUnitResult *resultObject))completionBlock {
    NSString* url = [NSString stringWithFormat:@"https://aip.baidubce.com/rpc/2.0/solution/v1/unit_utterance?access_token=%@",self.accessToken];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    request.HTTPShouldHandleCookies = false;
    NSDictionary* parm = @{@"scene_id":@(self.scene_id),
                           @"query":word ?: @"",
                           @"session_id":self.session ?: @""};
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:parm options:NSJSONWritingPrettyPrinted error:nil];
    request.HTTPBody = jsonData;
    __weak typeof(self) weakSelf = self;
    NSURLSessionTask * task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
        if (error == nil) {
            NSDictionary* result = [self dataToDic:data];
            if (result[@"error"] == nil) {
                NSDictionary* dict = result[@"result"];
                if (dict != nil) {
                    weakSelf.session = dict[@"session_id"];
                    if (completionBlock) {
                        BUnitResult *resultDic = [self handleV1Result:dict original:word];
                        completionBlock(nil,resultDic);
                    }
                } else {
                    if (completionBlock) {
                        completionBlock([NSError errorWithDomain:@"com.baidu.ai.unit.error" code:[result[@"error_code"] integerValue] userInfo:@{@"error":result[@"error_msg"]}],nil);
                    }
                }
            } else {
                if (completionBlock) {
                    completionBlock([NSError errorWithDomain:@"com.baidu.ai.unit.error" code:-1 userInfo:@{@"error":result[@"error"]}],nil);
                }
            }
        } else {
            if (completionBlock) {
                completionBlock(error,nil);
            }
        }
    }];
    [task resume];
}
//处理unit 1.0
- (BUnitResult *)handleV1Result:(NSDictionary *)result original:(NSString *)original {
    
    NSArray *action_list = result[@"action_list"];
    NSString *action_id = @""; //意图id
    NSString *say = @"";
    NSString *actionDetail = @"";
    NSString *actionType = @"";//satisfy---代表成功 or clarify---需要澄清
    
    for (NSDictionary *actionDic in action_list) {
        NSString *say_temp = actionDic[@"say"];
        if (![NSString isNull:say_temp]) {
            say = say_temp;
        }
        NSString *action_id_temp =  actionDic[@"action_id"];//_satisfy 代表成功  _clarify 需要澄清
        if (![NSString isNull:action_id_temp]) {
            action_id = action_id_temp;
        }
        NSDictionary *actionTypeDic = actionDic[@"action_type"];
        NSString *actionDetailTemp =  actionTypeDic[@"act_target_detail"];
        if (![NSString isNull:actionDetailTemp]) {
            actionDetail = actionDetailTemp;
        }
        NSString *actionTypeTemp =  actionTypeDic[@"act_type"];
        if (![NSString isNull:actionTypeTemp]) {
            actionType = actionTypeTemp;
        }
    }
    //概要
    NSDictionary *schema = result[@"schema"];
    //意图
    NSString *action = schema[@"current_qu_intent"];
    NSArray *bot_merged_slots = schema[@"bot_merged_slots"];
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    for (NSDictionary *dict in bot_merged_slots) {
        NSString *type = dict[@"type"];//参数类型
        NSString *original_word = dict[@"original_word"];
        NSString *normalized_word = dict[@"normalized_word"];
        if (![NSString isNull:normalized_word]) {
            [info setObject:normalized_word forKey:type];
        }
        else if(![NSString isNull:original_word]){
            [info setObject:original_word forKey:type];
        }
    }
    BUnitResult *unitResult = [[BUnitResult alloc] init];
    unitResult.say = say;
    unitResult.intentName = action;
    unitResult.intentTarget = actionDetail;
    unitResult.intentType = actionType;
    unitResult.intentId = action_id;
    unitResult.currentText = original;
    unitResult.infoDict = info;
    return unitResult;
    
}

/*********************************** unit 1.0 end ***************************************/

/*********************************** unit 2.0 start ***************************************/


- (void)askWordV2:(NSString *)word completion:(void (^)(NSError *error, BUnitResult *resultObject))completionBlock {
    if (self.sessionTask) {
        [self.sessionTask cancel];
        self.sessionTask = nil;
    }
    NSString* url = [NSString stringWithFormat:@"https://aip.baidubce.com/rpc/2.0/unit/bot/chat?access_token=%@",self.accessToken];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    request.HTTPShouldHandleCookies = false;
   
    NSDictionary *parm = [self parameterForV2WithWord:word];
    
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:parm options:NSJSONWritingPrettyPrinted error:nil];
    request.HTTPBody = jsonData;
    __weak typeof(self) weakSelf = self;
    NSURLSessionTask * task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
        weakSelf.sessionTask = nil;
        if (error == nil) {
            NSDictionary* result = [self dataToDic:data];
            NSInteger errorCode = 0;
            NSArray *allKeys = result.allKeys;
            if ([allKeys containsObject:@"error_code"]) {
                errorCode = [result[@"error_code"] integerValue];
            }
            if (errorCode == 0 ) {
                NSDictionary* dict = result[@"result"];
                if (dict != nil) {
                    NSString *bot_session =  dict[@"bot_session"];
                    NSData *bot_data = [bot_session dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *bot_sessionDic = [self dataToDic:bot_data];
                    weakSelf.session =  bot_sessionDic[@"session_id"];
                    if (completionBlock) {
                        BUnitResult *resultDic = [self handleV2Result:result original:word];
                        completionBlock(nil,resultDic);
                    }
                } else {
                    if (completionBlock) {
                        completionBlock([NSError errorWithDomain:@"com.baidu.ai.unit.error" code:errorCode userInfo:@{@"error":result[@"error_msg"]}],nil);
                    }
                }
            } else {
                if (completionBlock) {
                    completionBlock([NSError errorWithDomain:@"com.baidu.ai.unit.error" code:errorCode userInfo:@{@"error":result[@"error_msg"]}],nil);
                }
            }
        } else {
            if (completionBlock) {
                completionBlock(error,nil);
            }
        }
    }];
    [task resume];
    self.sessionTask = task;
}

//unit 2.0 参数
- (NSDictionary *)parameterForV2WithWord:(NSString *)word {
    NSMutableDictionary *parm = [NSMutableDictionary dictionary];
    //版本号
    [parm setObject:@"2.0" forKey:@"version"];
    //场景id
    [parm setObject:[NSString stringWithFormat:@"%ld",(long)self.scene_id] forKey:@"bot_id"];
    //开发者需要在客户端生成的唯一id，用来定位请求，响应中会返回该字段。对话中每轮请求都需要一个log_id
    [parm setObject:self.logId forKey:@"log_id"];
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    //与BOT对话的用户id（如果BOT客户端是用户未登录状态情况下对话的，也需要尽量通过其他标识（比如设备id）来唯一区分用户），方便今后在平台的日志分析模块定位分析问题、从用户维度统计分析相关对话情况。
    [requestDic setObject:self.userId forKey:@"user_id"];
    //本轮请求query（用户说的话），详情见【参数详细说明】
    [requestDic setObject:word?word:@"" forKey:@"query"];
    //本轮请求query的附加信息。
    NSMutableDictionary *query_info = [NSMutableDictionary dictionary];
    [query_info setObject:@"TEXT" forKey:@"type"];
    //请求信息来源，可选值："ASR","KEYBOARD"。ASR为语音输入，KEYBOARD为键盘文本输入，ASR输入的UNIT平台内置了异常信息纠错机制，尝试解决语音输入中的一些常见错误。
    [query_info setObject:@"ASR" forKey:@"source"];
    
    [requestDic setObject:query_info forKey:@"query_info"];
    [requestDic setObject:@"{\"client_results\":\"\", \"candidate_options\":[]}" forKey:@"client_session"];
    //系统自动发现不置信意图/词槽，并据此主动发起澄清确认的敏感程度。取值范围：0(关闭)、1(中敏感度)、2(高敏感度)。取值越高BOT主动发起澄清的频率就越高，建议值为1。
    [requestDic setObject:[NSNumber numberWithInteger:0] forKey:@"bernard_level"];
    [parm setObject:requestDic forKey:@"request"];
    
    NSString *bot_session = @"";
    if (![NSString isNull:self.session]) {
//        NSString *botId = [NSString stringWithFormat:@"%ld",self.scene_id];
//        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.session,@"session_id",botId,@"bot_id", nil];
//        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
//        bot_session = [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease];
        bot_session = [NSString stringWithFormat:@"{\"session_id\":\"%@\"}",self.session];
    }
    
    [parm setObject:bot_session forKey:@"bot_session"];
    return parm;
}


//处理unit 2.0
- (BUnitResult *)handleV2Result:(NSDictionary *)result original:(NSString *)original {
    NSDictionary* dict = result[@"result"];
    NSDictionary *response = dict[@"response"];
    /*****以下 获取action action Id 及 say *****/
    NSArray *action_list = response[@"action_list"];
    NSString *action_id = @""; //意图id
    NSString *say = @"";
    NSString *actionDetail = @"";
    NSString *actionType = @"";//satisfy---代表成功 or clarify---需要澄清
    
    for (NSDictionary *actionDic in action_list) {
        NSString *say_temp = actionDic[@"say"];
        if (![NSString isNull:say_temp]) {
            say = say_temp;
        }
        NSString *action_id_temp =  actionDic[@"action_id"];//_satisfy 代表成功  _clarify 需要澄清
        if (![NSString isNull:action_id_temp]) {
            action_id = action_id_temp;
        }
        NSString *actionTypeTemp =  actionDic[@"type"];
        if (![NSString isNull:actionTypeTemp]) {
            actionType = actionTypeTemp;
        }
        NSDictionary *refine_detail = actionDic[@"refine_detail"];
        NSArray *option_list =  refine_detail[@"option_list"];
        NSDictionary *option_list_1 = [option_list firstObject];
        if (option_list_1) {
            NSDictionary *info = option_list_1[@"info"];
            NSString *actionDetailTemp = info[@"name"];
            if (![NSString isNull:actionDetailTemp]) {
                actionDetail = actionDetailTemp;
            }
        }
    }
    //概要
    NSDictionary *schema = response[@"schema"];
    //意图
    NSString *action = schema[@"intent"];
    
    /*****以下 获取 关键词 词槽 *****/
    NSArray *bot_merged_slots = schema[@"slots"];
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    NSMutableDictionary *infoList = [NSMutableDictionary dictionary];
    for (NSDictionary *dict in bot_merged_slots) {
        NSString *type = dict[@"name"];//参数类型
        NSString *value = [self stringValueInDic:dict key:@"normalized_word"];
        if (!value) {
           value = [self stringValueInDic:dict key:@"original_word"];
        }
        if (value && value.length > 0) {
            if (!info[type]) {
                //去重，只取第一个
                [info setObject:value forKey:type];
            }
            //所有的都要获取
            NSMutableArray *array = infoList[type];
            if (!array) {
                array = [NSMutableArray array];
            }
            [array addObject:value];
            [infoList setObject:array forKey:type];
        }
    }

    BUnitResult *unitResult = [[BUnitResult alloc] init];
    unitResult.say = say;
    unitResult.intentName = action;
    unitResult.intentTarget = actionDetail;
    unitResult.intentType = actionType;
    unitResult.intentId = action_id;
    unitResult.currentText = original;
    unitResult.infoDict = info;
    unitResult.infoListDict = infoList;
    if ([action_id isEqualToString:kBUnitFAQGuide]) {
        if ([action isEqualToString:kFAQ_OPEN]) {
            NSDictionary *openDic1 = action_list[0];
            NSArray *optionList = openDic1[@"refine_detail"][@"option_list"];
            NSArray *slots = schema[@"slots"];
            NSInteger max = MIN(optionList.count, slots.count);
            NSMutableArray *optionalOpenIntentList = [[NSMutableArray alloc] init];
            for (NSInteger t = 0; t <max; t++) {
                NSDictionary *nameDic = optionList[t];
                NSString *name = nameDic[@"option"];
                NSDictionary *sayDic = slots[t];
                NSString *say = sayDic[@"normalized_word"];
                BUnitOptionalOpenIntent *openIntent = [[BUnitOptionalOpenIntent alloc] init];
                openIntent.displayName = name;
                openIntent.say = say;
                [optionalOpenIntentList addObject:openIntent];
            }
            unitResult.optionalOpenIntentList = optionalOpenIntentList;
        }
        else {
            unitResult.say = info[kBUnitFAQResultKey];
        }
    }
    /*****以下 QA 获取可能的列表 *****/

    if (![NSString isNull:action] && [action rangeOfString:kFAQ_KB].location !=NSNotFound ) {
        NSDictionary *qu_res = response[@"qu_res"];
        NSArray *candidates = qu_res[@"candidates"];
        NSMutableArray *QAArray = [NSMutableArray array];
        for (NSDictionary *candidateDic in candidates) {
            NSString *confidence = candidateDic[@"confidence"];
            NSString *eAction = candidateDic[@"intent"];
            if ([NSString isNull:eAction] || [eAction rangeOfString:kFAQ_KB].location ==NSNotFound) {
                //eAction = nil 或者 不是智能QA kFAQ_KB
                continue;
            }
            NSArray *eSlots = candidateDic[@"slots"];
            NSDictionary *slotDic = [eSlots firstObject];
            NSString *e_normalized_word = slotDic[@"normalized_word"];
            if (![NSString isNull:e_normalized_word]) {
                BUnitQAExtra *QAExtra = [[BUnitQAExtra alloc] init];
                QAExtra.confidence = confidence;
                QAExtra.intentName = eAction;
                QAExtra.say = e_normalized_word;
                [QAArray addObject:QAExtra];
            }
        }
        unitResult.QAExtra = QAArray;
    }
    return unitResult;
}

/*********************************** unit 2.0 end ***************************************/

/*********************************** unit 2.0 机器人 start ***************************************/
//token 获取方式与原先的一致

- (void)askWordInRobot:(NSString *)word completion:(void (^)(NSError *error, BUnitResult *resultObject))completionBlock {
    
    if (self.sessionTask) {
        [self.sessionTask cancel];
        self.sessionTask = nil;
    }
    NSString* url = [NSString stringWithFormat:@"https://aip.baidubce.com/rpc/2.0/unit/service/chat?access_token=%@",self.accessToken];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    request.HTTPShouldHandleCookies = false;
    
    NSDictionary *parm = [self parameterForRobotWithWord:word];
    
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:parm options:NSJSONWritingPrettyPrinted error:nil];
    request.HTTPBody = jsonData;
    __weak typeof(self) weakSelf = self;
    NSURLSessionTask * task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
        weakSelf.sessionTask = nil;
        if (error == nil) {
            NSDictionary* result = [self dataToDic:data];
            NSInteger errorCode = 0;
            NSArray *allKeys = result.allKeys;
            if ([allKeys containsObject:@"error_code"]) {
                errorCode = [result[@"error_code"] integerValue];
            }
            if (errorCode == 0 ) {
                NSDictionary* dict = result[@"result"];
                if (dict != nil) {
                    NSString *bot_session =  dict[@"bot_session"];
                    NSData *bot_data = [bot_session dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *bot_sessionDic =  [self dataToDic:bot_data];
                    weakSelf.session =  bot_sessionDic[@"session_id"];
                    if (completionBlock) {
                        BUnitResult *resultDic = [self handleV2Result:result original:word];
                        completionBlock(nil,resultDic);
                    }
                } else {
                    if (completionBlock) {
                        completionBlock([NSError errorWithDomain:@"com.baidu.ai.unit.error" code:errorCode userInfo:@{@"error":result[@"error_msg"]}],nil);
                    }
                }
            } else {
                if (completionBlock) {
                    completionBlock([NSError errorWithDomain:@"com.baidu.ai.unit.error" code:errorCode userInfo:@{@"error":result[@"error_msg"]}],nil);
                }
            }
        } else {
            if (completionBlock) {
                completionBlock(error,nil);
            }
        }
    }];
    [task resume];
    self.sessionTask = task;
}

- (NSDictionary *)parameterForRobotWithWord:(NSString *)word {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [result setValue:@"2.0" forKey:@"version"];//当前api版本对应协议版本号为2.0，固定值
    //机器人ID，service_id 与skill_ids不能同时缺失，至少一个有值。
    [result setValue:@"" forKey:@"service_id"];
    [result setValue:@"" forKey:@"skill_ids"];//list<string>
    
    [result setObject:self.logId forKey:@"log_id"];
    
    [result setObject:self.session ?: @"" forKey:@"session_id"];
    
    
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    [request setObject:self.userId forKey:@"user_id"];
    [request setObject:word forKey:@"query"];
   
    NSMutableDictionary *query_info = [NSMutableDictionary dictionary];
    [query_info setObject:@"TEXT" forKey:@"type"];
    [query_info setObject:@"KEYBOARD" forKey:@"source"];
    
    NSMutableDictionary *hyper_params = [NSMutableDictionary dictionary];
 //系统自动发现不置信意图/词槽，并据此主动发起澄清确认的敏感程度。取值范围：0(关闭)、1(中敏感度)、2(高敏感度)。取值越高BOT主动发起澄清的频率就越高，建议值为1。
    [hyper_params setObject:[NSNumber numberWithInteger:0] forKey:@"bernard_level"];
    
    [request setObject:query_info forKey:@"query_info"];
    [request setObject:hyper_params forKey:@"hyper_params"];

    [result setObject:request forKey:@"request"];

    return result;
}

- (BUnitResult *)handleRobotResult:(NSDictionary *)result original:(NSString *)original {
    return nil;
}
/*********************************** unit 2.0 机器人 end ***************************************/

@end
