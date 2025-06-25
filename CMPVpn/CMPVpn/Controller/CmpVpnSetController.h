//
//  CmpVpnSetController.h
//  CMPVpn
//
//  Created by Shoujian Rao on 2022/4/8.
//

#import <UIKit/UIKit.h>

@interface CmpVpnSetController : UIViewController

- (instancetype)initWithVpnUrl:(NSString *)vpnUrl vpnLoginName:(NSString *)vpnLoginName vpnLoginPwd:(NSString *)vpnLoginPwd spa:(NSString *)spa;

//提交返回填写的vpn信息
@property (nonatomic, copy) void(^SubmitBlock)(NSString *vpnUrl,NSString *vpnLoginName,NSString *vpnLoginPwd,id ext);

@end
