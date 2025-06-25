//
//  CMPVerifyCodeViewController.h
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2023/9/19.
//

#import <CMPLib/CMPBaseViewController.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPVerifyCodeViewController : CMPBaseViewController

@property(nonatomic,copy) void(^fetchCodeAction)(void);
@property(nonatomic,copy) void(^smsInputCompletion)(id resp,NSError *err,id ext);
@property(nonatomic,copy) void(^completion)(BOOL success,NSError *err,id ext);
@property(nonatomic,copy) BOOL(^cancelBlk)( NSError * _Nullable err,id _Nullable ext);

-(instancetype)initWithNumber:(NSString *)number
                          ext:(_Nullable id)ext;

@end

NS_ASSUME_NONNULL_END
