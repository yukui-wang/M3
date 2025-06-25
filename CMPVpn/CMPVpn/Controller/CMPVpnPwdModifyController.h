//
//  CMPVpnPwdModifyController.h
//  CMPVpn
//
//  Created by SeeyonMobileM3MacMini2 on 2023/10/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPVpnPwdModifyController : UIViewController
@property(nonatomic,copy) BOOL(^cancelBlk)( NSError * _Nullable err,id _Nullable ext);
@end

NS_ASSUME_NONNULL_END
