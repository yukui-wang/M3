//
//  CMPOnTimeMeetViewModel.m
//  M3
//
//  Created by Kaku Songu on 11/26/22.
//

#import "CMPOnTimeMeetViewModel.h"
#import "CMPMeetingDataProvider.h"

@interface CMPOnTimeMeetViewModel()

@property (nonatomic,strong) CMPMeetingDataProvider *dataProvider;

@end

@implementation CMPOnTimeMeetViewModel

-(BOOL)ifOpen
{
    return self.openState == 1;
}

-(BOOL)ifOpenLoaded
{
    return self.openState == 0;
}

-(BOOL)ifConfig
{
    return self.personalConfigState == 1;
}

-(BOOL)ifConfigLoaded
{
    return self.personalConfigState == 0;
}

-(NSURL *)personalMeetingUrl
{
    NSString *s = @"";
    if (_personalConfigModel){
        s = _personalConfigModel.link;
    }
    return [NSURL URLWithString:s];
}

-(void)checkQuickMeetingEnableWithCompletion:(void(^)(BOOL ifEnable,NSError *error, id ext))completion
{
    __weak typeof(self) wSelf = self;
    [self.dataProvider fetchQuickMeetingEnableStateWithResult:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
        if(!error) {
            wSelf.openState = ([respData boolValue] ? 1 : 2);
        }else{
            wSelf.openState = 3;
        }
        if (completion) completion(respData, error, ext);
    }];
}

-(void)checkQuickMeetingConfigWithCompletion:(void(^)(BOOL ifConfig,NSError *error, id ext))completion
{
    __weak typeof(self) wSelf = self;
    [self.dataProvider checkQuickMeetingConfigWithResult:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
        if(!error) {
            wSelf.personalConfigState = respData ? 1 : 2;
        }else{
            wSelf.personalConfigState = 3;
        }
        if (completion) completion(respData, error, ext);
    }];
}

-(void)createMeetingByMids:(NSArray *)mids completion:(void(^)(NSDictionary *meetInfo,NSError *error, id ext))completion
{
    if (!completion) return;
    [self.dataProvider createOnTimeMeetingByMids:mids result:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
        completion(respData,error,ext);
    }];
}

-(void)fetchPersonalMeetingConfigInfoWithCompletion:(void(^)(CMPOnTimeMeetingPersonalConfigModel *configInfo,NSError *error, id ext))completion
{
    __weak typeof(self) wSelf = self;
    [self.dataProvider fetchPersonalQuickMeetingConfigInfoWithResult:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
        if (!error) {
            CMPOnTimeMeetingPersonalConfigModel *aConfig = [CMPOnTimeMeetingPersonalConfigModel yy_modelWithDictionary:respData];
            wSelf.personalConfigState = aConfig ? 1 : 2;
            if (aConfig){
                wSelf.personalConfigModel = aConfig;
                completion(aConfig,nil,ext);
            }else{
                wSelf.personalConfigModel = nil;
                completion(aConfig,[NSError errorWithDomain:@"json to model error" code:-1101 userInfo:nil],ext);
            }
        }else{
            wSelf.personalConfigModel = nil;
            wSelf.personalConfigState = 3;
            completion(nil,error,ext);
        }
    }];
}

-(void)verifyOnTimeMeetingValidWithInfo:(NSDictionary *)meetInfo completion:(void(^)(BOOL validable,NSError *error, id ext))completion
{
    if (!completion) return;
    [self.dataProvider verifyOnTimeMeetingValidWithInfo:meetInfo result:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
        completion(YES,error,ext);
    }];
}

-(void)zxCreateOnTimeMeetingBySenderId:(NSString *)sid receiverIds:(NSArray *)receiverIds type:(NSString *)type link:(NSString *)link password:(NSString *)pwd completion:(void(^)(NSDictionary *meetInfo,NSError *error, id ext))completion
{
    [self.dataProvider zxCreateOnTimeMeetingBySenderId:sid receiverIds:receiverIds type:type link:(NSString *)link password:(NSString *)pwd result:completion];
}

-(CMPMeetingDataProvider *)dataProvider
{
    if (!_dataProvider) {
        _dataProvider = [[CMPMeetingDataProvider alloc] init];
    }
    return _dataProvider;
}

@end
