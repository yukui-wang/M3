//
//  CMPAppMessagePlugin.m
//  M3
//
//  Created by CRMO on 2018/1/9.
//

#import "CMPAppMessagePlugin.h"
#import "CMPMessageManager.h"

@implementation CMPAppMessagePlugin

- (void)setTopStatus:(CDVInvokedUrlCommand *)command {
    NSDictionary *dic = command.arguments[0];
    NSString *appID = dic[@"appID"];
    NSString *status = dic[@"status"];
    
    if ([NSString isNull:appID] || [NSString isNull:status]) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"参数错误"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    BOOL isTop = YES;
    
    if ([status isEqualToString:@"0"]) {
        isTop = NO;
    }
    
    CMPMessageObject *object = [[CMPMessageObject alloc] init];
    object.cId = appID;
    object.isTop = isTop;
    object.type = CMPMessageTypeApp;
    [[CMPMessageManager sharedManager] topMessage:object];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)batchSetTopStatus:(CDVInvokedUrlCommand *)command {
    NSDictionary *dic = command.arguments[0];
    BOOL isUpdateToServer = [dic[@"isUpdateToServer"] boolValue];
    NSArray *settings = dic[@"settings"];
    for (NSDictionary *setting in settings) {
        NSString *appID = setting[@"appID"];
        NSString *status = setting[@"status"];
        if ([NSString isNull:appID] || [NSString isNull:status]) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"参数错误"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }
        
        BOOL isTop = YES;
        
        if ([status isEqualToString:@"0"]) {
            isTop = NO;
        }
        
        CMPMessageObject *object = [[CMPMessageObject alloc] init];
        object.cId = appID;
        object.isTop = isTop;
        object.type = CMPMessageTypeApp;
        [[CMPMessageManager sharedManager] onlyLocalTopMessage:object];
    }
   
    if (isUpdateToServer) {
        //todo
    }
   
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getTopStatus:(CDVInvokedUrlCommand *)command {
    NSString *appID = command.arguments[0][@"appID"];
    [[CMPMessageManager sharedManager] getTopStatusWithAppID:appID completion:^(BOOL isTop) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[NSString stringWithInt:isTop]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)setRemindStatus:(CDVInvokedUrlCommand *)command {
    NSDictionary *dic = command.arguments[0];
    NSString *appID = dic[@"appID"];
    NSString *status = dic[@"status"];
    
    if ([NSString isNull:appID] || [NSString isNull:status]) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"参数错误"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    if ([status isEqualToString:@"0"]) {
        status = @"1";
    } else {
        status = @"0";
    }
    
    CMPMessageObject *object = [[CMPMessageObject alloc] init];
    object.cId = appID;
    object.extra2 = status;
    [[CMPMessageManager sharedManager] remindMessage:object completion:^(NSError *error) {
        if (error) {
            NSDictionary *errorDic= @{@"code" : @0,
                                      @"message" : @"网络请求失败",
                                      @"detail" : @""};
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        } else {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }];
}

- (void)batchSetRemindStatus:(CDVInvokedUrlCommand *)command {
    NSDictionary *dic = command.arguments[0];
    BOOL isUpdateToServer = [dic[@"isUpdateToServer"] boolValue];
    NSArray *settings = dic[@"settings"];
    NSMutableArray *remindMessageObjects = [NSMutableArray array];
    NSMutableArray *settingArray = [NSMutableArray array];
    
    for (NSDictionary *setting in settings) {
        NSString *appID = setting[@"appID"];
        NSString *status = setting[@"status"];
        if ([NSString isNull:appID] || [NSString isNull:status]) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"参数错误"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }
        
        if ([status isEqualToString:@"0"]) {
            status = @"1";
        } else {
            status = @"0";
        }
        
        NSDictionary *settingDic = @{
            @"appId" : appID,
            @"type" :  @"remind",
            @"value" : status
        };
        [settingArray addObject:settingDic];
        
        CMPMessageObject *object = [[CMPMessageObject alloc] init];
        object.cId = appID;
        object.extra2 = status;
        [remindMessageObjects addObject:object];
     }
    
     void (^block)(void) = ^{
         for (CMPMessageObject *object in remindMessageObjects) {
             [[CMPMessageManager sharedManager] onlyLocalRemindMessage:object];
         }
     };
    
     if (isUpdateToServer) {
         [[CMPMessageManager sharedManager] batchUploadSettingWithSettingArray:settingArray completion:^(NSError *error) {
             if (error) {
                 NSDictionary *errorDic= @{@"code" : @0,
                                           @"message" : @"网络请求失败",
                                           @"detail" : @""};
                 CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
                 [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
             } else {
                 block();
                 CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                 [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
             }
         }];
     } else {
         block();
         CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
         [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
     }
    
}

- (void)getRemindStatus:(CDVInvokedUrlCommand *)command {
    NSString *appID = command.arguments[0][@"appID"];
    BOOL remind = [[CMPMessageManager sharedManager] getRemindWithAppID:appID];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[NSString stringWithInt:!remind]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getRemindsStatus:(CDVInvokedUrlCommand *)command {
    NSArray *appIDs = command.arguments[0][@"appIDs"];
    NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
    [appIDs enumerateObjectsUsingBlock:^(NSString *appID, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL remind = [[CMPMessageManager sharedManager] getRemindWithAppID:appID];
        NSString *remindStr = remind ? @"0" : @"1";
        [resultDic setObject:remindStr forKey:appID];
    }];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[resultDic JSONRepresentation]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setAggregationStatus:(CDVInvokedUrlCommand *)command {
    NSDictionary *dic = command.arguments[0];
    NSString *appID = dic[@"appID"];
    NSString *status = dic[@"status"];
    
    if ([NSString isNull:appID] || [NSString isNull:status] ||
        (![status isEqualToString:@"1"] && ![status isEqualToString:@"0"])) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"参数错误"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    void(^block)(NSError *error) = ^(NSError *error) {
        if (error) {
            NSDictionary *errorDic= @{@"code" : @0,
                                      @"message" : @"网络请求失败",
                                      @"detail" : @""};
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        } else {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
        
        if ([CMPCore sharedInstance].serverIsLaterV7_1_SP1) {
            [[CMPMessageManager sharedManager] refreshMessage];
        }
    };
    
    if ([status isEqualToString:@"1"]) {
        CMPMessageObject *object = [[CMPMessageObject alloc] init];
        object.cId = appID;
        object.isTop = NO;
        object.type = CMPMessageTypeApp;
        if ([CMPCore sharedInstance].serverIsLaterV7_1_SP1) {
            [[CMPMessageManager sharedManager] topMessage:object];
        }
        [[CMPMessageManager sharedManager] aggregationMessageWithType:CMPMessageTypeAggregationApp appID:appID completion:block];
    } else if ([status isEqualToString:@"0"]) {
        [[CMPMessageManager sharedManager] cancelAggregationMessageWithAppID:appID completion:block];
    }
}

- (void)getAggregationStatus:(CDVInvokedUrlCommand *)command {
    NSString *appID = command.arguments[0][@"appID"];
    [[CMPMessageManager sharedManager] getParentWithAppID:appID completion:^(NSString *parent) {
        BOOL isAggregation = NO;
        if (![NSString isNull:parent]) {
            isAggregation = YES;
        }
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[NSString stringWithInt:isAggregation]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

@end
