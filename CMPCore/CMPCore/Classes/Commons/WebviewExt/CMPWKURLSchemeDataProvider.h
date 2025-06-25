//
//  CMPWKURLSchemeDataProvider.h
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2023/5/24.
//

#import <Foundation/Foundation.h>
#import <CMPLib/CMPWKURLSchemeHandler.h>
NS_ASSUME_NONNULL_BEGIN

@interface CMPWKURLSchemeDataProvider : NSObject<CMPWKURLSchemeHandlerDelegate>
+(instancetype)shareInstance;
@end

NS_ASSUME_NONNULL_END
