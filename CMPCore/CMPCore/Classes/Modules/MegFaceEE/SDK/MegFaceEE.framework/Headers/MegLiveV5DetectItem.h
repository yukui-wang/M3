//
//  MegLiveV5DetectItem.h
//  MegLiveV5Detect
//
//  Created by MegviiDev on 2021/10/15.
//

#import <UIKit/UIKit.h>
#if __has_include(<MegLiveV5Detect/MegLiveV5DetectConfig.h>)
#import <MegLiveV5Detect/MegLiveV5DetectConfig.h>
#else
#import "MegLiveV5DetectConfig.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface MegLiveV5DetectUIConfigItem : NSObject

@property (nonatomic, strong) UIColor *livenessHomeContourLineColor;                    //  检测成功中间人形线条色
@property (nonatomic, strong) UIColor *livenessHomeFailContourLineColor;                //  检测失败中间人形线条色
@property (nonatomic, strong) UIColor *livenessHomeFlashContourLineColor;               //  炫彩活体检测过程中间人形线条色
@property (nonatomic, strong) UIColor *livenessHomeProcessBarColor;                     //  活体进度条颜色(动作和静默活体)
@property (nonatomic, strong) UIColor *livenessHomeFlashProcessBarColor;                //  炫彩活体进度条颜色
@property (nonatomic, strong) UIColor *livenessHomeLoadingLineColor;                    //  loading蛇形线颜色
@property (nonatomic, strong) UIColor *livenessHomeFlashRemindTextColor;                //  炫彩阶段提示文字颜色
@property (nonatomic, strong) UIColor *livenessHomeNormalRemindTextColor;               //  正常状态提示文字颜色
@property (nonatomic, strong) UIColor *livenessHomeFailedRemindTextColor;               //  失败状态提示文字颜色
@property (nonatomic, strong) UIColor *livenessHomeActionRemindTextColor;               //  动作提示字体颜色
@property (nonatomic, strong) UIColor *livenessHomeBackgroundColor1;                    //  主题圆圈颜色1
@property (nonatomic, strong) UIColor *livenessHomeBackgroundColor2;                    //  主题圆圈颜色2
@property (nonatomic, strong) UIColor *livenessHomeActionHatColor;                      //  动作活体过程中小帽子颜色
@property (nonatomic, strong) UIColor *livenessHomeDeviceVerticalRemindColor;           //  手机竖向垂直提示字体颜色
@property (nonatomic, strong) UIColor *livenessHomeLoadingTextColor;                    //  验证中提示字体颜色
@property (nonatomic, strong) UIColor *livenessHomeNormalContourLineColor;              //  第一次完成照镜子之前人形线条颜色
@property (nonatomic, strong) UIColor *livenessHomeBeforeLookMirrorRemindTextColor;     //  第一次完成照镜子之前提示文字颜色

@property (nonatomic, strong) UIColor *livenessHomeCustomPromptBackgroundColor;         //  活体界面提示背景颜色
@property (nonatomic, strong) UIColor *livenessHomeCustomPromptTextColor;               //  活体界面提示字体颜色

@property (nonatomic, assign) CGFloat livenessHomeRemindTextSize;                       //  提示文字大小
@property (nonatomic, assign) CGFloat livenessHomeActionRemindTextSize;                 //  动作活体提示文字大小
@property (nonatomic, assign) CGFloat livenessHomeLoadingTextSize;                      //  验证中提示文字大小
@property (nonatomic, assign) CGFloat livenessHomeDeviceVerticalRemindSize;             //  手机竖向垂直提示字体大小

//退出提示框
@property (nonatomic, assign) CGFloat livenessHomeExitPopupwindowTextSize;              //  退出弹窗标题字号
@property (nonatomic, assign) CGFloat livenessHomeExitPopupwindowBodySize;              //  退出弹窗正文字号
@property (nonatomic, strong) UIColor *livenessHomeConfirmButtonColor;                  //  确认按钮颜色
@property (nonatomic, strong) UIColor *livenessHomeCancelButtonColor;                   //  取消按钮颜色

//  协议页面
@property (nonatomic, assign) CGFloat livenessHomeAgreementpageTitleTextSize;                    //  协议页面顶部标题字体大小
@property (nonatomic, assign) CGFloat livenessHomeAgreementpageBottomTitleTextSize;              //  协议页面底部提示字体大小
@property (nonatomic, strong) UIColor *livenessHomeAgreementpageBottomButtonBeforeClickColor;                  //  协议页面按钮正常态
@property (nonatomic, strong) UIColor *livenessHomeAgreementpageBottomButtonAfterClickColor;                   //  协议页面按钮高亮态度

//  动作活体倒计时
@property (nonatomic, assign) CGFloat livenessHomeActionTimeTextSize;              //  动作活体倒计时文字大小
@property (nonatomic, strong) UIColor *livenessHomeActionTimeTextColor;            //  动作活体倒计时提示颜色
@end

@interface MegLiveV5DetectInitConfigItem : NSObject

//  指定活体V5语言类型，关于SDK语言资源加载的方式，详情见文档。必需
@property (nonatomic, assign) MegLiveV5DetectLanguageType languageType;
//  指定活体V5拉取配置的HOST地址。默认为"https://api.megvii.com"。非必需
@property (nonatomic, strong) NSString* hostURL;
//  指定活体V5SDK资源绝对路径，以'bundle'为结尾。如果该值为nil或者""，则从MainBundle中读取资源。关于资源加载的方式，详情见文档。非必需
@property (nonatomic, strong) NSString* bundleFilePath;

//  指定活体检测过程中设备垂直检测类型。默认为`MegLiveV5DetectPhoneVerticalTypeFront2`
@property (nonatomic, assign) MegLiveV5DetectPhoneVerticalType phoneVertical;
//  是否进行音量调节。其中YES为开启，NO为不开启。开启后，会将当前设备音量调节到`maxPhoneVolume`。默认为NO。非必需
@property (nonatomic, assign) BOOL isAdjustPhoneVolume;
//  音量调节后最大音量。阈值范围为[0, 100]，默认为0。该参数仅在`isAdjustPhoneVolume`值为YES时生效。非必需
@property (nonatomic, assign) int adjustPhoneVolume;
//  指定是否显示活体检测页面底部powerby图片。默认值为NO，不显示。非必需
@property (nonatomic, assign) BOOL showPoweryby;
//  指定活体V5的UI样式。非必需
@property (nonatomic, strong) MegLiveV5DetectUIConfigItem* customUI;
//  是否私有化版本。默认为NO，非私有化版本。非必需
@property (nonatomic, assign) BOOL isOffline;

@property (nonatomic, strong) NSString *encryptKey;

@property (nonatomic, strong) NSString *privateConfigPath;

@end

NS_ASSUME_NONNULL_END
