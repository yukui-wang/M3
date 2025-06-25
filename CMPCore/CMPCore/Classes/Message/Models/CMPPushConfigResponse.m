//
//  CMPNotificationSettingObjct.m
//  M3
//
//  Created by CRMO on 2017/9/20.
//

#import "CMPPushConfigResponse.h"

@implementation CMPPushConfigResponse

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"main" : @"data.mainSwitch",
             @"ring" : @"data.ring",
             @"shake" : @"data.shake",
             @"mute" : @"data.mute",
             @"startDate" : @"data.startDate",
             @"endDate" : @"data.endDate",
             @"settingContent" : @"data.settingContent"};
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    if ([CMPCore sharedInstance].serverIsLaterV1_8_0) {
        return YES;
    }
    
    NSString *settingContent = self.settingContent;
    NSDictionary *settingContentDic = [settingContent JSONValue];
    
    if (!settingContentDic || ![settingContentDic isKindOfClass:[NSDictionary class]]) {
        return YES;
    }
    
    NSDictionary *mainDic = settingContentDic[@"main"];
    
    _main =  [NSString stringWithFormat:@"%@", mainDic[@"mainSwitch"]];
    _ring = [NSString stringWithFormat:@"%@", mainDic[@"ring"]];
    _shake = [NSString stringWithFormat:@"%@", mainDic[@"shake"]];
    
    return YES;
}

#pragma mark-
#pragma mark Getter & Setter

- (NSString *)startDate {
    if (!_startDate) {
        _startDate = @"00:00:00";
    }
    return _startDate;
}

- (NSString *)endDate {
    if (!_endDate) {
        _endDate = @"23:59:00";
    }
    return _endDate;
}

- (NSString *)main {
    if (!_main) {
        _main = @"1";
    }
    return _main;
}

- (NSString *)ring {
    if (!_ring) {
        _ring = @"1";
    }
    return _ring;
}

- (NSString *)shake {
    if (!_shake) {
        _shake = @"1";
    }
    return _shake;
}

- (NSString *)mute {
    if (!_mute) {
        CMPCore *core = [CMPCore sharedInstance];
        NSString *pushConfig = core.pushConfig;
        CMPPushConfigResponse *pushConfigResponse = [CMPPushConfigResponse yy_modelWithJSON:pushConfig];
        if (pushConfigResponse) {
            _mute = [pushConfigResponse getMute];
        } else {
            _mute = @"0";
        }
    }
    return _mute;
}

- (NSString *)getMute {
    if (!_mute) {
        _mute = @"0";
    }
    return _mute;
}

- (BOOL)mainSwitch {
    if ([self.main isEqualToString:@"0"]) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)ringSwitch {
    if ([self.ring isEqualToString:@"0"]) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)shakeSwitch {
    if ([self.shake isEqualToString:@"0"]) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)multiLoginReceivesMessageState {
    if ([self.mute isEqualToString:@"1"]) {
        return NO;
    } else {
        return YES;
    }
}

@end
