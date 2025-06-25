//
//  CMPVpnConfigModel.h
//  CMPVpn
//
//  Created by SeeyonMobileM3MacMini2 on 2022/4/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPVpnConfigModel : NSObject

@property (nonatomic, copy) NSString *vpnUrl;
@property (nonatomic, copy) NSString *vpnLoginName;
@property (nonatomic, copy) NSString *vpnLoginPwd;

@end

NS_ASSUME_NONNULL_END
