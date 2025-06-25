// SDK2.3.9 手机盾对外发布版本
// 2020-8-6
// 1、新增个人批量P7签和企业批量P7签接口(2.3.1新增)
// 2、修改网络请求时间为20秒(2.3.1新增)
// 3、新增个人批量P1签和企业批量P1签接口(2.3.2新增 2019-6-21)
// 4、新增个人批量P1签和企业批量P1签的数据签(2.3.3新增 2019-7-12)
// 5、新增个人批量P1签在数据签时加结构(2.3.3新增 2019-7-12)
// 6、新增获取用户状态接口(2.3.4新增 2019-7-29)
// 7、修改设置签章图片时隐藏状态栏的操作(2.3.4新增 2019-8-13)
// 8、修改错误码提示语和新增错误码(2.3.5新增 2019-9-12)
// 9、新增网络通信时是否显示等待框的配置(2.3.5新增 2019-9-12)
// 10、增加开启静默签名、静默签名、关闭静默签名接口(2.3.5新增 2019-9-12)
// 11、适配iPhone 11、iPhone11 Pro、iPhone11 Pro Max 并对判断逻辑进行修改(2.3.6新增 2019-10-11)
// 12、修改原静默功能为免密，并新增开启静默、登录并开启静默功能(2.3.6新增 2019-10-18)
// 13、修改HTTPS使用SSL证书发起请求在XCode11及之后版本验证不通过报网络通信异常的问题 (2.3.6新增 2019-12-4)
// 14、修改自定义口令框显示字符串高度逻辑 (2.3.7新增 2020-1-8)
// 15、整理错误码 (2.3.7新增 2020-1-8)
// 16、修改自定义口令框显示html的控件，使用WKWebView进行了替换并适配 (2.3.9新增 2020-7-13)
// 17、新增企业解密接口(2.3.9新增 2020-8-6)

#import <Foundation/Foundation.h>
#import "Mokey_Type.h"
#import <UIKit/UIKit.h>

/*! @brief 解析签名值的类型
 *
 */
typedef enum {
    TYPE_ORIGINAL,  /**< 原文    */
    TYPE_IMAGE,     /**< 图片    */
    TYPE_CERT,      /**< 证书    */
    TYPE_SIGNVALUE  /**< 签名值    */
}InfoType;

/*! @brief 手写框横竖屏类型
 *
 */
typedef enum {
    SCREEN_Orientation_Right,   /**< 横屏    */
    SCREEN_Orientation_Down     /**< 竖屏    */
}ScreenOrientationType;

@interface MoKey_SDK : NSObject

/** 生成切换二维码时 设置返回二维码图片或二维码数据
 * YES为返回二维码（默认）
 * NO为返回二维码数据
 */
@property (nonatomic, assign) BOOL isQRCode;


/*
 * 手写框的设置项
 * 包括手写框的横竖屏、手写框的大小、画笔的颜色
 */

/**
 *  手写框横竖屏设置 默认横屏
 */
@property (nonatomic, assign) ScreenOrientationType isScreenOrientationType;

/**
 *  手写框的大小(width和height) 默认全屏
 */
@property (nonatomic, assign) CGSize isScreenSize;

/**
 *  画笔的颜色 默认黑色
 */
@property (nonatomic, strong) NSString *isBrushColor;

/** 网络请求时 是否显示加载框
 * YES为显示（默认）
 * NO为不显示
 */
@property (nonatomic, assign) BOOL isShowMKLoading;


/*
 * 每次调用接口时必须先调用initWithRootPath方法 进行SDK的初始化
 * 网络请求时如果报错：460101网络连接不可用 请检测网络地址和证书是否正确
 * 注：获取错误描述接口、获取设备信息接口、解析签名值接口可不用初始化直接调用
 */

// 初始化
- (id)initWithRootPath:(NSString *)rootPath httpsCert:(NSData *)httpsCert;

// 注册激活
- (void)MK_activateWithMKKeyId:(NSString *)keyId ActivateResult:(OnActivateResult)activateResult;

// 重置密钥-快速重置
- (void)MK_fastResetWithMKKeyId:(NSString *)keyId EventData:(NSString *)eventData FastResetResult:(OnFastResetResult)fastResetResult;

// 登录认证
- (void)MK_doUserLoginWithMKKeyId:(NSString *)keyId EventData:(NSString *)eventData UserLoginResult:(OnUserLoginResult)userLoginResult;

// 签名认证
- (void)MK_doUserSignWithMKKeyId:(NSString *)keyId EventData:(NSString *)eventData UserSignResult:(OnUserSignResult)userSignResult;

// 签章认证
- (void)MK_doUserStampWithMKKeyId:(NSString *)keyId EventData:(NSString *)eventData UserStampResult:(OnUserStampResult)userStampResult;

// 签批认证
- (void)MK_doUserCommentWithMKKeyId:(NSString *)keyId EventData:(NSString *)eventData UserCommentResult:(OnUserCommentResult)userCommentResult;

// PDF签章认证
- (void)MK_doUserPDFStampWithMKKeyId:(NSString *)keyId EventData:(NSString *)eventData UserPDFStampResult:(OnUserPDFStampResult)userPDFStampResult;

// PDF签章认证(根据Hash计算P7)
- (void)MK_doUserPDFStampP7WithMKKeyId:(NSString *)keyId EventData:(NSString *)eventData UserPDFStampP7Result:(OnUserPDFStampP7Result)userPDFStampP7Result;

// 个人批量P7签（2.3.1版本新增）
- (void)MK_doUserBatchStampWithMKKeyId:(NSString *)keyId EventData:(NSString *)eventData UserBatchStampResult:(OnUserBatchStampResult)userBatchStampResult;

// 个人批量P1签（2.3.2版本新增）
- (void)MK_doUserBatchP1StampWithMKKeyId:(NSString *)keyId EventData:(NSString *)eventData UserBatchP1StampResult:(OnUserBatchP1StampResult)userBatchP1StampResult;

// 设置签章图片
- (void)MK_setStampImgWithMKKeyId:(NSString *)keyId SetStampImgResult:(OnSetStampImgResult)setStampImgResult;

// 获取签章图片
- (void)MK_getStampImgWithMKKeyId:(NSString *)keyId SetStampImgResult:(OnSetStampImgResult)setStampImgResult;

// 重置密钥
- (void)MK_doUserResetWithMKKeyId:(NSString *)keyId EventData:(NSString *)eventData UserResetResult:(OnUserResetResult)userResetResult;

// 切换设备-获取切换二维码
- (void)MK_genChangeImgWithMKKeyId:(NSString *)keyId EventData:(NSString *)eventData GenChangeImgResult:(OnGenChangeImgResult)genChangeImgResult;

// 切换设备-新设备切换
- (void)MK_doUserChangeWithMKChangeData:(NSString *)changeData UserChangeResult:(OnUserChangeResult)userChangeResult;

// 切换设备-新设备切换（传keyId 只有同一用户可以切换）
- (void)MK_doUserChangeWithMKChangeData:(NSString *)changeData KeyId:(NSString *)keyId UserChangeResult:(OnUserChangeResult)userChangeResult;

// 修改密钥口令
/*
 * 修改密钥口令 因为iOS系统的原因
 * 当设备系统版本小于9.0或者不支持指纹功能时，才能调用该接口进行口令修改，大于9.0并且支持指纹功能时调用无效！
 * 错误码：400130 表示当前使用机器系统版本大于9.0 并且设备支持指纹功能
 */
- (void)MK_modifyPinWithMKKeyId:(NSString *)keyId ModifyResult:(OnModifyResult)modifyResult;

// 密钥／证书更新
- (void)MK_doUserUpdateWithKeyId:(NSString *)keyId EventData:(NSString *)eventData UserUpdateResult:(OnUserUpdateResult)userUpdateResult;

// 获取用户状态（0:未激活(未设置) 1:已激活(已设置) 2:已失效(密钥丢失、换设备) 3、已停用 4、已锁定 5、证书过期）（2.3.4版本增加 2.3.5版本修改）
- (void)MK_getUserStateWithMKKeyId:(NSString *)keyId GetUserStateResult:(OnGetUserStateResult)getUserStateResult;

// 开启免密签名（2.3.5版本新增） (原本地客户端开启静默功能改的名称)
- (void)MK_doUserAuthQuickWithMKKeyId:(NSString *)keyId ExpTime:(NSInteger)expTime UserAuthQuickResult:(OnUserAuthQuickResult)userAuthQuickResult;

// 免密签名（2.3.5版本新增）(原本地客户端静默签名功能改的名称)
- (void)MK_doUserQuickWithMKKeyId:(NSString *)keyId EventData:(NSString *)eventData SilentToken:(NSString *)silentToken UserQuickResult:(OnUserQuickResult)userQuickResult;

// 关闭免密签名（2.3.5版本新增）(原本地客户端关闭静默功能改的名称)
- (void)MK_doUserQuicktStopWithMKKeyId:(NSString *)keyId UserQuickStopResult:(OnUserQuickStopResult)userQuickStopResult;

// 开启静默签名（2.3.6版本新增）
- (void)MK_doUserAuthSilentWithMKKeyId:(NSString *)keyId EventData:(NSString *)eventData UserAuthSilentResult:(OnUserSilentSignStartResult)userAuthSilentResult;

// 登录并开启静默签名（2.3.6版本新增）
- (void)MK_doUserAuthSilentLoginWithMKKeyId:(NSString *)keyId EventData:(NSString *)eventData UserSilentLoginResult:(OnUserSilentLoginResult)userSilentLoginResult;

// 解析签名值(返回对应类型的数据)
+ (void)MK_getSignInfoWithMKCType:(InfoType)type SignValue:(NSString *)signValue GetSignInfoResult:(OnGetSignInfoResult)getSignInfoResult;

// 获取设备信息
+ (void)MK_getDeviceID:(OnGetDeviceIDResult)deviceId;

// 获取错误描述
+ (void)MK_getErrMsgWithErrorCode:(int)errorCode ErrMsg:(OnGetErrMsgResult)errMsg;

// 企业账号登录认证
- (void)MK_doCompanyLoginWithMKKeyId:(NSString *)keyId EventData:(NSString *)eventData CompanyLoginResult:(OnCompanyLoginResult)companyLoginResult;

// 企业账号签名认证
- (void)MK_doCompanySignWithMKKeyId:(NSString *)keyId EventData:(NSString *)eventData CompanySignResult:(OnCompanySignResult)companySignResult;

// 企业账户签章认证
- (void)MK_doCompanyStampWithMKKeyId:(NSString *)keyId EventData:(NSString *)eventData CompanyStampResult:(OnCompanyStampResult)companyStampResult;

// 企业PDF签章认证
- (void)MK_doCompanyPDFStampWithMKKeyId:(NSString *)keyId EventData:(NSString *)eventData CompanyPDFStampResult:(OnCompanyPDFStampResult)companyPDFStampResult;

// 企业PDF签章认证(根据Hash计算P7)
- (void)MK_doCompanyPDFStampP7WithMKKeyId:(NSString *)keyId EventData:(NSString *)eventData CompanyPDFStampP7Result:(OnCompanyPDFStampP7Result)companyPDFStampP7Result;

// 企业批量P7签（2.3.1版本新增）
- (void)MK_doCompanyBatchStampWithMKKeyId:(NSString *)keyId EventData:(NSString *)eventData CompanyBatchStampResult:(OnCompanyBatchStampResult)companyBatchStampResult;

// 企业批量P1签（2.3.2版本新增）
- (void)MK_doCompanyBatchP1StampWithMKKeyId:(NSString *)keyId EventData:(NSString *)eventData CompanyBatchP1StampResult:(OnCompanyBatchP1StampResult)companyBatchP1StampResult;

// 企业账号解密认证（2.3.9版本新增）
- (void)MK_doCompanyDecryptWithMKKeyId:(NSString *)keyId EventData:(NSString *)eventData CompanyDecryptResult:(OnCompanyDecryptResult)companyDecryptResult;

@end
