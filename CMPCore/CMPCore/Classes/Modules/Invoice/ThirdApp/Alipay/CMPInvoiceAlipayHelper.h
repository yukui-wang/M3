//
//  CMPInvoiceAlipayHelper.h
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2022/1/14.
//

#import <CMPLib/CMPObject.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPInvoiceAlipayHelper : CMPObject

+(BOOL)handleOpenURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
