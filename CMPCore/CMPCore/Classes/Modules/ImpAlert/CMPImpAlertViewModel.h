//
//  CMPImpAlertViewModel.h
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2023/8/29.
//

#import <CMPLib/CMPBaseViewModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPImpAlertViewModel : CMPBaseViewModel
@property (nonatomic,copy) NSString *greetingId;
-(void)fetchImpMsgs:(void(^)(NSArray *datas, NSError *err))completion;
-(void)fetchImpMsgDetailByGid:(NSString *)gid completion:(void(^)(NSDictionary *datas, NSError *err))completion;
-(void)fetchImpMsgShareImageByGid:(NSString *)gid completion:(void(^)(NSData *data,NSString *localPath, NSError *err))completion;
+(NSString *)shareImageLocalPathWithGreetingId:(NSString *)greetingId;
@end

NS_ASSUME_NONNULL_END
