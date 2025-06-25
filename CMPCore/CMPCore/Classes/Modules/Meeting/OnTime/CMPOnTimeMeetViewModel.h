//
//  CMPOnTimeMeetViewModel.h
//  M3
//
//  Created by Kaku Songu on 11/26/22.
//

#import <CMPLib/CMPBaseViewModel.h>
#import "CMPOnTimeMeetingPersonalConfigModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CMPOnTimeMeetViewModel : CMPBaseViewModel

@property (nonatomic,assign) __block NSInteger openState;//0 未请求过。1 打开。2 未打开 3 请求报错
@property (nonatomic,assign) __block NSInteger personalConfigState;//0 未请求过。1 已配置。2 未配置 3 请求报错
@property (nonatomic,strong) __block CMPOnTimeMeetingPersonalConfigModel *personalConfigModel;

-(BOOL)ifOpen;
-(BOOL)ifOpenLoaded;
-(BOOL)ifConfig;
-(BOOL)ifConfigLoaded;
-(NSURL *)personalMeetingUrl;
-(void)checkQuickMeetingEnableWithCompletion:(void(^)(BOOL ifEnable,NSError *error, id ext))completion;
-(void)checkQuickMeetingConfigWithCompletion:(void(^)(BOOL ifConfig,NSError *error, id ext))completion;
-(void)createMeetingByMids:(NSArray *)mids completion:(void(^)(NSDictionary *meetInfo,NSError *error, id ext))completion;
-(void)fetchPersonalMeetingConfigInfoWithCompletion:(void(^)(CMPOnTimeMeetingPersonalConfigModel *configInfo,NSError *error, id ext))completion;
-(void)verifyOnTimeMeetingValidWithInfo:(NSDictionary *)meetInfo completion:(void(^)(BOOL validable,NSError *error, id ext))completion;
-(void)zxCreateOnTimeMeetingBySenderId:(NSString *)sid receiverIds:(NSArray *)receiverIds type:(NSString *)type link:(NSString *)link password:(NSString *)pwd completion:(void(^)(NSDictionary *meetInfo,NSError *error, id ext))completion;

@end

NS_ASSUME_NONNULL_END
