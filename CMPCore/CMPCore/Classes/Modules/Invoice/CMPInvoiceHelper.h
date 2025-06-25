//
//  CMPInvoiceHelper.h
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2022/1/14.
//

#import <CMPLib/CMPObject.h>
#import "CMPInvoiceWechatHelper.h"
//#import "CMPInvoiceAlipayHelper.h"

NS_ASSUME_NONNULL_BEGIN

@interface CMPInvoiceHelper : CMPObject

+(NSDictionary *)fetchCmpNewAccessTokenByParams:(NSDictionary *)params;
+(BOOL)fetchOtherPlatformInvoiceList:(NSDictionary *)params result:(void(^)(id data, NSError *error))result;
+(BOOL)decodeCmpInvoiceDataByParams:(NSDictionary *)invoiceData result:(void(^)(id data, NSError *error))result;

@end

NS_ASSUME_NONNULL_END
