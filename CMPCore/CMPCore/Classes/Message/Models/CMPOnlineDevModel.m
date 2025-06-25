//
//  CMPOnlineDevModel.m
//  M3
//
//  Created by CRMO on 2019/5/24.
//

#import "CMPOnlineDevModel.h"

@implementation CMPOnlineDevModel

+ (instancetype)modelWithString:(NSString *)str {
    CMPOnlineDevModel *model = [[CMPOnlineDevModel alloc] init];
    
    if ([NSString isNull:str]) {
        return model;
    }
    
    NSArray *arr = [str componentsSeparatedByString:@"|"];
    
    for (NSString *s in arr) {
        if ([s isEqualToString:@"1"]) {
            model.pcOnline = YES;
        }
        if ([s isEqualToString:@"4"]) {
            model.ucOnline = YES;
        }
        if ([s isEqualToString:@"8"]) {
            model.weChatOnline = YES;
        }
        if ([s isEqualToString:@"2048"]) {
            model.padOnline = YES;
        }
        if ([s isEqualToString:@"2"]) {
            model.phoneOnline = YES;
        }
    }
    
    UIUserInterfaceIdiom dom = [[UIDevice currentDevice] userInterfaceIdiom];
    if (dom == UIUserInterfaceIdiomPad) {
        if (model.padOnline) model.padOnline = NO;
    }else{
        if (model.phoneOnline) model.phoneOnline = NO;
    }
    
    model.isMultiOnline = model.pcOnline || model.ucOnline || model.weChatOnline || model.padOnline || model.phoneOnline;
    
    if (!model.phoneOnline && !model.padOnline) {
        if (model.pcOnline && !model.ucOnline && !model.weChatOnline) {
            model.onlineDevState = CMPOnlineDevPC;
        } else if (!model.pcOnline && model.ucOnline && !model.weChatOnline) {
            model.onlineDevState = CMPOnlineDevUC;
        } else if (!model.pcOnline && !model.ucOnline && model.weChatOnline) {
            model.onlineDevState = CMPOnlineDevWeChat;
        } else if (model.pcOnline && model.ucOnline && !model.weChatOnline) {
            model.onlineDevState = CMPOnlineDevPCAndUC;
        } else if (model.pcOnline && !model.ucOnline && model.weChatOnline) {
            model.onlineDevState = CMPOnlineDevPCAndWeChat;
        } else if (!model.pcOnline && model.ucOnline && model.weChatOnline) {
            model.onlineDevState = CMPOnlineDevUCAndWeChat;
        } else if (model.pcOnline && model.ucOnline && model.weChatOnline) {
            model.onlineDevState = CMPOnlineDevPCAndUCAndWeChat;
        }
    }else{
        model.onlineDevState = CMPOnlineDevUnknown;
    }
    
    return model;
}

-(BOOL)isOnlyPadOnline{
    return self.padOnline && !self.pcOnline && !self.ucOnline && !self.weChatOnline && !self.phoneOnline;
}

-(BOOL)isOnlyPhoneOnline{
    if (self.phoneOnline) {
        return !self.pcOnline && !self.ucOnline && !self.weChatOnline && !self.padOnline;
    }
    if (self.weChatOnline) {
        return !self.pcOnline && !self.ucOnline && !self.phoneOnline && !self.padOnline;
    }
    return NO;
}

-(BOOL)isOnlyPcOnline{
    if (self.pcOnline){
        return !self.padOnline && !self.ucOnline && !self.weChatOnline && !self.phoneOnline;
    }
    if (self.ucOnline){
        return !self.padOnline && !self.pcOnline && !self.weChatOnline && !self.phoneOnline;
    }
    return NO;
}


- (NSString *)tip {
    NSString *tip = nil;
    
//    if (self.padOnline || self.phoneOnline) {//全部采用新逻辑
        tip = @"";
        if (self.pcOnline){
            tip = [tip stringByAppendingFormat:@"%@、",SY_STRING(@"mu_login_type_web")];
        }
        if (self.ucOnline){
            tip = [tip stringByAppendingFormat:@"%@、",SY_STRING(@"mu_login_type_pc")];
        }
        if (self.weChatOnline){
            tip = [tip stringByAppendingFormat:@"%@、",SY_STRING(@"mu_login_type_wechat")];
        }
        if (self.phoneOnline){
            tip = [tip stringByAppendingFormat:@"%@、",SY_STRING(@"mu_login_type_phone")];
        }
        if (self.padOnline){
            tip = [tip stringByAppendingFormat:@"%@、",SY_STRING(@"mu_login_type_pad")];
        }
        if (tip.length && [tip hasSuffix:@"、"]){
            tip = [tip stringByReplacingCharactersInRange:NSMakeRange(tip.length-1, 1) withString:@""];
            tip = [tip stringByAppendingString:SY_STRING(@"mu_login_type_logined")];
        }
        return tip;
//    }
    
    switch (self.onlineDevState) {
        case CMPOnlineDevPC: {
            tip = SY_STRING(@"mu_login_web");
        }
        break;
            
        case CMPOnlineDevUC: {
            tip = SY_STRING(@"mu_login_zhixin");
        }
        break;
            
        case CMPOnlineDevWeChat: {
            tip = SY_STRING(@"mu_login_weChat");
        }
        break;
            
        case CMPOnlineDevPCAndUC: {
            tip = SY_STRING(@"mu_login_web_zhixin");
        }
        break;
            
        case CMPOnlineDevPCAndWeChat: {
            tip = SY_STRING(@"mu_login_web_weChat");
        }
        break;
            
        case CMPOnlineDevUCAndWeChat: {
            tip = SY_STRING(@"mu_login_zhixin_weChat");
        }
        break;
            
        case CMPOnlineDevPCAndUCAndWeChat: {
           tip = SY_STRING(@"mu_login_web_zhixin_weChat");
        }
        break;
    }
    
    return tip;
}

- (NSString *)messagePageTip {
    NSMutableString *tip = [NSMutableString stringWithString:self.tip];
    
//    if (![CMPCore sharedInstance].multiLoginReceivesMessageState) {
//           [tip appendString:@"，"];
//           [tip appendString:SY_STRING(@"mu_login_alreadyMute")];
//    }
    
    return [tip copy];
}

@end
