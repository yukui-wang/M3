//
//  Target_Xiaozhi.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/4/2.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "Target_Xiaozhi.h"
#import "CMPSpeechRobotManager.h"
#import "XZCore.h"
#import "XZTransWebViewController.h"
#import "SPTools.h"
#import "SPSpeechEngine.h"
#import <CMPLib/CMPNavigationController.h>
#import "XZQAMainController.h"
#import "XZMainController.h"

@implementation Target_Xiaozhi

- (void)Action_openSpeechRobot:(NSDictionary *)params {
    [[CMPSpeechRobotManager sharedInstance] openSpeechRobot];
}

- (void)Action_reloadSpeechRobot:(NSDictionary *)params {
    [[CMPSpeechRobotManager sharedInstance] reloadSpeechRobot];
}

- (void)Action_updateSpeechRobotConfig:(NSDictionary *)params {
    CMPSpeechRobotConfig *config = [[XZCore sharedInstance] robotConfig];
    BOOL changeValue = NO;
    NSArray *allkeys = [params allKeys];
    NSString *key = @"isOnOff";
    if ([allkeys containsObject:key]) {
        BOOL isOnOff = [params[key] boolValue];
        if (isOnOff != config.isOnOff) {
            config.isOnOff = isOnOff;
            changeValue = YES;
        }
    }
    key = @"isOnShow";
    if ([allkeys containsObject:key]) {
        BOOL isOnShow = [params[key] boolValue];
        if (isOnShow != config.isOnShow) {
            config.isOnShow = isOnShow;
            changeValue = YES;
        }
    }
    key = @"isAutoAwake";
    if ([allkeys containsObject:key]) {
        BOOL isAutoAwake = [params[key] boolValue];
        if (isAutoAwake != config.isAutoAwake) {
            config.isAutoAwake = isAutoAwake;
            changeValue = YES;
        }
    }
    key = @"startTime";
    if ([allkeys containsObject:key]) {
        NSString *startTime = params[key];
        if (![startTime isEqualToString:config.startTime]) {
            config.startTime = startTime;
            changeValue = YES;
        }
    }
    key = @"endTime";
    if ([allkeys containsObject:key]) {
        NSString *endTime = params[key];
        if (![endTime isEqualToString:config.endTime]) {
            config.endTime = endTime;
            changeValue = YES;
        }
    }
    if (changeValue) {
         [XZCore setCurrentUserRobotConfig:config];
    }
    key = @"showOrNot";
    if ([allkeys containsObject:key]) {
        BOOL showOrNot = [params[key] boolValue];
       [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_RobotToggleShowAssistiveTouchOnPageSwitch object:[NSNumber numberWithBool:showOrNot]];
    }
}

- (NSDictionary *)Action_obtainSpeechRobotConfig:(NSDictionary *)params {
    NSArray *keys = params[@"keys"];
    CMPSpeechRobotConfig *config = [[XZCore sharedInstance] robotConfig];
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSString *key = @"isOnOff";
    if ([keys containsObject:key]) {
        NSNumber *value = [NSNumber numberWithBool:config.isOnOff];
        [result setObject:value forKey:key];
    }
    key = @"isOnShow";
    if ([keys containsObject:key]) {
        NSNumber *value = [NSNumber numberWithBool:config.isOnShow];
        [result setObject:value forKey:key];
    }
    key = @"isAutoAwake";
    if ([keys containsObject:key]) {
        NSNumber *value = [NSNumber numberWithBool:config.isAutoAwake];
        [result setObject:value forKey:key];
    }
    key = @"startTime";
    if ([keys containsObject:key]) {
        [result setObject:config.startTime forKey:key];
    }
    key = @"endTime";
    if ([keys containsObject:key]) {
        [result setObject:config.endTime forKey:key];
    }

    XZCore *core = [XZCore sharedInstance];
    key = @"showInSetting";
    if ([keys containsObject:key]) {
        NSNumber *value = [NSNumber numberWithBool:core.showInSetting];
        [result setObject:value forKey:key];
    }
    key = @"hasVoicePermission";
    if ([keys containsObject:key]) {
        //如果云联配置了小致，还需判断智能助手界面中小致是否打开
        NSNumber *value = [NSNumber numberWithBool:[core xiaozAvailable] ? config.isOnOff : NO];
        [result setObject:value forKey:key];
    }
    key = @"shortCutIds";
    if ([keys containsObject:key]) {
        NSArray *array = core.shortCutIds?:[NSArray array];
        [result setObject:array forKey:key];
    }
    key = @"intentNames";
    if ([keys containsObject:key]) {
        NSArray *array = core.intentPrivilege.intentDic.allKeys?:[NSArray array];
        [result setObject:array forKey:key];
    }
    return result;
}

- (NSDictionary *)Action_obtainXiaozhiSettings:(NSDictionary *)params {
    NSNumber *outTime = [NSNumber numberWithLongLong:[[XZCore sharedInstance] outTime]];
    /*outTime 超期时间  单位ms  */
    NSNumber *status = [NSNumber numberWithInteger:[[XZCore sharedInstance] xiaozhiCode]];
    /*status 小致状态: //是1000:正常/2001:未开通/2002:已停用 /2003:已过期*/
    CMPSpeechRobotConfig *config = [[XZCore sharedInstance] robotConfig];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:[NSNumber numberWithBool:config.isOnOff] forKey:@"isOnOff"];
    [dic setObject:[NSNumber numberWithBool:config.isOnShow] forKey:@"isOnShow"];
    [dic setObject:[NSNumber numberWithBool:config.isAutoAwake] forKey:@"isAutoAwake"];
    [dic setObject:config.startTime?config.startTime:@"" forKey:@"startTime"];
    [dic setObject:config.endTime?config.endTime:@""  forKey:@"endTime"];
    [dic setObject:outTime forKey:@"outTime"];
    [dic setObject:status  forKey:@"status"];
    
    XZMsgSwitchInfo *info = [[XZCore sharedInstance] msgSwitchInfo];
    [dic setObject:[NSNumber numberWithBool:info.mainSwitch] forKey:@"mainSwitch"];
    [dic setObject:[NSNumber numberWithBool:info.cultureSwitch] forKey:@"cultureSwitch"];
    [dic setObject:[NSNumber numberWithBool:info.statisticsSwitch] forKey:@"statisticsSwitch"];
    [dic setObject:[NSNumber numberWithBool:info.arrangeSwitch] forKey:@"arrangeSwitch"];
    [dic setObject:[NSNumber numberWithBool:info.chartSwitch] forKey:@"chartSwitch"];
    return dic;
}

- (NSDictionary *)Action_obtainSpeechInput:(NSDictionary *)params {
    UIViewController *viewController = params[@"viewController"];
    if ([viewController isKindOfClass:[XZTransWebViewController class]]) {
        XZTransWebViewController *controller = (XZTransWebViewController *)viewController;
        return controller.gotoParams;
    }
    return [XZCore sharedInstance].speechInput;
}

- (SPSpeechEngine *)speechEngine {
    if (![[XZCore sharedInstance] xiaozAvailable]) {
        return nil;
    }
    SPSpeechEngine *speechEngine = [SPSpeechEngine sharedInstance:SPSpeechEngineBaidu];
    return speechEngine;
}

//语音播报（小致平台中H5卡片语音播报）
- (void)Action_broadcast:(NSDictionary *)params{
    [[self speechEngine] broadcast:params[@"text"]
                           success:params[@"success"]
                              fail:params[@"fail"]];
}

//语音播报文本
- (void)Action_broadcastText:(NSDictionary *)params {
    [[self speechEngine] broadcastText:params[@"text"]
                               success:params[@"success"]
                                  fail:params[@"fail"]];
}
//停止语音播报文本
- (void)Action_stopBroadcastText:(NSDictionary *)params {
    [[self speechEngine] stopBroadcastText];
}
//清空语音合成block
- (void)Action_clearBroadcastTextBlock:(NSDictionary *)params {
    [[self speechEngine] clearBroadcastTextBlock];
}

- (void)Action_updateMsgSwitchInfo:(NSDictionary *)params {
    [[XZCore sharedInstance] setupMsgSwitchInfo:params];
}

- (void)Action_showQAWithIntentId:(NSDictionary *)params {
    NSString *intentId = params[@"intentId"];
    [[CMPSpeechRobotManager sharedInstance] showQAWithIntentId:intentId];
}

- (void)Action_showWebViewWithParam:(NSDictionary *)params {
    XZTransWebViewController *transVC = [[XZTransWebViewController alloc] init];
    NSDictionary *paramsObj = params[@"params"];
    NSString *url = [paramsObj objectForKey:@"accessUrl"]?:@"http://xiaoz.v5.cmp/v/html/xiaoz-app-access.html";
    transVC.loadUrl = url;
    transVC.gotoParams = paramsObj;
    UIViewController *vc = params[@"viewController"];
    if (vc.navigationController) {
        [vc.navigationController pushViewController:transVC animated:YES];
    }
    else {
        CMPNavigationController *nav = [[CMPNavigationController alloc] initWithRootViewController:transVC];
        [[SPTools currentViewController] presentViewController:nav animated:YES completion:nil];
    }
}

- (void)Action_openQAPage:(NSDictionary *)params{
    [[XZQAMainController sharedInstance]openQAPage:params];
}

- (UIViewController *)Action_showIntelligentPage:(NSDictionary *)params {
   return [[XZQAMainController sharedInstance] showIntelligentPage];
}
- (void)Action_openXiaoz:(NSDictionary *)params{
    [[XZMainController sharedInstance]openXiaoz:params];
}
- (void)Action_openAllSearchPage:(NSDictionary *)params {
    [[XZMainController sharedInstance]openAllSearchPage:params];
}
- (void)Action_callXiaozMethod:(NSDictionary *)xzParams {
    NSString *method = xzParams[@"method"];
    NSString *params = xzParams[@"params"];
    SEL sel = NSSelectorFromString(method);
    if ([self respondsToSelector:sel]) {
        [self performSelector:sel withObject:params];
    }
}


- (void)xiaozOpenQAPage:(NSDictionary *)params{
    [[XZMainController sharedInstance]openQAPage:params];
}
@end
