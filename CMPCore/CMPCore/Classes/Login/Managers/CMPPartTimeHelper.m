//
//  CMPPartTimeHelper.m
//  M3
//
//  Created by CRMO on 2018/6/26.
//

#import "CMPPartTimeHelper.h"
#import <CMPLib/CMPLoginDBProvider.h>
#import "CMPPartTimeProvider.h"
#import "M3LoginManager.h"
#import "CMPLoginConfigInfoModel.h"

@interface CMPPartTimeHelper()

@property (strong, nonatomic) CMPLoginDBProvider *dbProvider;
@property (strong, nonatomic) CMPPartTimeProvider *networkProvider;

@end

@implementation CMPPartTimeHelper

- (NSArray<CMPPartTimeModel *> *)partTimeList {
    if (![self supportPartTime]) {
        return nil;
    }
    NSArray *partTimes = [self.dbProvider
                          partTimeListWithServerID:[CMPCore sharedInstance].serverID
                          userID:[CMPCore sharedInstance].userID];
    [self refreshPartTimeList];
    return partTimes;
}

- (NSString *)currentAccountShortName {
    NSString *accountShortName = [CMPCore sharedInstance].currentUser.extend1;
    CMPPartTimeModel *currentParttime = [self currentPartTime];
    if (![NSString isNull:currentParttime.accountShortName]) {
        accountShortName = currentParttime.accountShortName;
    }
    return accountShortName;
}

- (CMPPartTimeModel *)currentPartTime {
    return [self.dbProvider partTimeWithServerID:[CMPCore sharedInstance].serverID
                                          userID:[CMPCore sharedInstance].userID
                                       accountID:[CMPCore sharedInstance].currentUser.accountID];
}

- (void)refreshPartTimeList {
    if (![self supportPartTime]) {
        return;
    }
    [self.networkProvider partTimeListCompletion:^(NSArray<CMPPartTimeModel *> *partTimes, NSError *error) {
        if (error) {
            NSLog(@"zl---refreshPartTimeList失败，error=%@", error);
            return;
        }
        [self.dbProvider
         clearPartTimesWithServerID:[CMPCore sharedInstance].serverID
         userID:[CMPCore sharedInstance].userID];
        [self.dbProvider addPartTimes:partTimes];
    }];
}

- (void)switchPartTime:(CMPPartTimeModel *)partTime
            completion:(CMPPartTimeHelperSwitchDidFinish)completion {
    NSString *currentAccountID = [CMPCore sharedInstance].currentUser.accountID;
    if ([currentAccountID isEqualToString:partTime.accountID]) {
        NSLog(@"zl---不能切换到当前单位");
        NSError *error = [[NSError alloc] initWithDomain:@"不能切换到当前单位" code:0 userInfo:nil];
        if (completion) completion(nil, error);
        return;
    }
    [self.networkProvider
     switchPartTimeWithAccountID:partTime.accountID
     completion:^(CMPPartTimeModel *partTime, NSError *error) {
         // 切换兼职单位，将token置为过期，下次登录走登录接口
         [[M3LoginManager sharedInstance] setTokenExpire];
         if (completion) completion(partTime, error);
     }];
}

/**
 是否支持兼职单位切换
 7.0SP1及之后的版本默认支持
 7.0SP1之前的版本从config里面取配置判断是否支持
 */
- (BOOL)supportPartTime {
    BOOL isSupport = NO;
    if ([[CMPCore sharedInstance] serverIsLaterV7_0_SP1]) {
        isSupport = YES;
    } else {
        CMPLoginAccountModel *currentUser = [CMPCore sharedInstance].currentUser;
        NSString *configStr = currentUser.configInfo;
        if ([CMPCore sharedInstance].serverIsLaterV1_8_0) {
            CMPLoginConfigInfoModel_2 *model = [CMPLoginConfigInfoModel_2 yy_modelWithJSON:configStr];
            isSupport = model.config.hasParttimeSwitch;
        } else {
            CMPLoginConfigInfoModel *model = [CMPLoginConfigInfoModel yy_modelWithJSON:configStr];
            isSupport = model.data.hasParttimeSwitch;
        }
    }
    return isSupport;
}

#pragma mark-
#pragma mark Getter & Setter

- (CMPLoginDBProvider *)dbProvider {
    if (!_dbProvider) {
        _dbProvider = [CMPCore sharedInstance].loginDBProvider;
    }
    return _dbProvider;
}

- (CMPPartTimeProvider *)networkProvider {
    if (!_networkProvider) {
        _networkProvider = [[CMPPartTimeProvider alloc] init];
    }
    return _networkProvider;
}

@end
