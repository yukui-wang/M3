//
//  CMPVpnEnterView.h
//  CMPVpn
//
//  Created by Shoujian Rao on 2022/4/7.
//

#import <UIKit/UIKit.h>

@interface CMPVpnEnterView : UIView
@property (nonatomic, copy) NSString *vpnId;
@property (nonatomic, copy) NSString *vpnUrl;
@property (nonatomic, copy) NSString *vpnLoginName;
@property (nonatomic, copy) NSString *vpnLoginPwd;
@property (nonatomic, copy) NSString *vpnSPA;
@property (nonatomic, assign) __block BOOL contentChanged;
//- (instancetype)initWithFromViewController:(UIViewController *)fromVC vpnSetResult:(void(^)(NSString *vpnUrl, NSString *vpnLoginName, NSString *vpnLoginPwd))vpnSetResultBlock;
- (instancetype)initWithFromViewController:(UIViewController *)fromVC;
- (void)setVpnStatus:(BOOL)vpnOn;
- (void)vpnBtnClick:(id)sender;
@end
