//
//  CMPInvoiceWechatHelper.h
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2022/1/11.
//

#import <CMPLib/CMPObject.h>
#import "CMPShareToOtherAppKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface CMPInvoiceWechatHelper : CMPObject<WXApiDelegate>

+(instancetype)shareInstance;
-(BOOL)config:(NSDictionary *)config;
-(void)getWXInvoiceWithCompletion:(void(^)(id respData,NSError *error,id ext) )completion;
-(void)updateWXInvoiceStateWithParams:(NSDictionary *)params completion:(void(^)(id respData,NSError *error,id ext))completion;

@end

NS_ASSUME_NONNULL_END
