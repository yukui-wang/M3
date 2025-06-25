//
//  CMPWiFiClockInView.h
//  M3
//
//  Created by CRMO on 2019/1/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CMPWiFiClockInButtonState) {
    CMPWiFiClockInButtonStateInit,
    CMPWiFiClockInButtonStateLoading,
    CMPWiFiClockInButtonStateSuccess,
};

@interface CMPWiFiClockInButton : UIButton
- (void)updateState:(CMPWiFiClockInButtonState)state;
@end

@interface CMPWiFiClockInView : UIView

/** 日期 **/
@property (strong, nonatomic) UILabel *dateLabel;
/** 当前时间 **/
@property (strong, nonatomic) UILabel *timeLabel;
/** 上班时间 **/
@property (strong, nonatomic) UILabel *workTimeLabel;
/** WiFi名 **/
@property (strong, nonatomic) UILabel *wifiNameLabel;
/** 打卡按钮 **/
@property (strong, nonatomic) CMPWiFiClockInButton *clockInButton;
/** 关闭按钮 **/
@property (strong, nonatomic) UIButton *closeButton;

@end

NS_ASSUME_NONNULL_END
