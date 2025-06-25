//
//  CMPOnlineDevModel.h
//  M3
//
//  Created by CRMO on 2019/5/24.
//

typedef NS_ENUM(NSInteger, CMPOnlineDev) {
    CMPOnlineDevPC,
    CMPOnlineDevUC,
    CMPOnlineDevWeChat,
    CMPOnlineDevPCAndUC,
    CMPOnlineDevPCAndWeChat,
    CMPOnlineDevUCAndWeChat,
    CMPOnlineDevPCAndUCAndWeChat,
    CMPOnlineDevUnknown
};

#import <CMPLib/CMPObject.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPOnlineDevModel : CMPObject

@property (assign, nonatomic) BOOL pcOnline;
@property (assign, nonatomic) BOOL ucOnline;
@property (assign, nonatomic) BOOL weChatOnline;
@property (assign, nonatomic) BOOL padOnline;
@property (assign, nonatomic) BOOL phoneOnline;

@property (assign, nonatomic) BOOL isMultiOnline;
@property (assign, nonatomic) CMPOnlineDev onlineDevState;//8.3多端登录后不要用此参数，不准(判断太多，废弃，以前逻辑不变)

+ (instancetype)modelWithString:(NSString *)str;
- (NSString *)tip;
- (NSString *)messagePageTip;

-(BOOL)isOnlyPadOnline;
-(BOOL)isOnlyPhoneOnline;//(phone and wechat)
-(BOOL)isOnlyPcOnline;//(web and zhixin)

@end

NS_ASSUME_NONNULL_END
