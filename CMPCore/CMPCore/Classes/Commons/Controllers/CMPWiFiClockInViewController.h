//
//  CMPWiFiClockInViewController.h
//  M3
//
//  Created by CRMO on 2019/1/21.
//

#import <UIKit/UIKit.h>
#import "CMPWiFiClockInView.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^CMPWiFiClockInViewControllerDismiss)(void);

@class CMPWiFiClockInSettingResponse;
@class CMPWiFiClockInProvider;
@interface CMPWiFiClockInViewController : UIViewController

@property (strong, nonatomic) CMPWiFiClockInSettingResponse *clockInSetting;
@property (strong, nonatomic) CMPWiFiClockInProvider *provider;
@property (copy, nonatomic) __nullable CMPWiFiClockInViewControllerDismiss didDismiss;

@property (strong, nonatomic) CMPWiFiClockInView *clockInView;
- (void)_refreshWifiName;

@end

NS_ASSUME_NONNULL_END
