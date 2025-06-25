//
//  SFMobileSecurityTypes.h
//  Pods
//  定义枚举类型
//  Created by SANGFOR on 2019/10/28.
//

#ifndef SFMobileSecurityTypes_h
#define SFMobileSecurityTypes_h

#import <Foundation/Foundation.h>
#import "SFSecurityTypes.h"
#import "SFSecurityObject.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSString *SFAuthKeyName NS_EXTENSIBLE_STRING_ENUM;
typedef NSString *SFOptionsName NS_EXTENSIBLE_STRING_ENUM;
typedef NSString *SFCommandName NS_EXTENSIBLE_STRING_ENUM;
typedef NSString *SFAuthValueName NS_EXTENSIBLE_STRING_ENUM;

/** 认证对应的key */
FOUNDATION_EXPORT SFAuthKeyName const kAuthKeyPassUsername;       // 用户名密码认证用户名信息
FOUNDATION_EXPORT SFAuthKeyName const kAuthKeyPassPassword;       // 用户名密码认证密码信息
FOUNDATION_EXPORT SFAuthKeyName const kAuthKeyCertPath;           // 证书认证路径信息
FOUNDATION_EXPORT SFAuthKeyName const kAuthKeyCertPassword;       // 证书认证密码信息
FOUNDATION_EXPORT SFAuthKeyName const kAuthKeyRandCode;           // 图形校验认证码
FOUNDATION_EXPORT SFAuthKeyName const kAuthKeySMS;                // 短信验证码
FOUNDATION_EXPORT SFAuthKeyName const kAuthKeyToken;              // 动态令牌认证码
FOUNDATION_EXPORT SFAuthKeyName const kAuthKeyRadiusCode;         // Radius认证码
FOUNDATION_EXPORT SFAuthKeyName const kAuthKeyRenewOldPassword;   // 更新密码认证旧密码
FOUNDATION_EXPORT SFAuthKeyName const kAuthKeyRenewNewPassword;   // 更新密码认证新密码
FOUNDATION_EXPORT SFAuthKeyName const kAuthKeyUserContentData;    // 用户透传数据
FOUNDATION_EXPORT SFAuthKeyName const kAuthKeySecondAuthId;       // 辅助认证唯一标识
FOUNDATION_EXPORT SFAuthKeyName const kAuthKeyAuthType;           // 认证类型钉钉/企业微信/政务微信
FOUNDATION_EXPORT SFAuthKeyName const kAuthKeyAuthInfo;           // 认证信息
FOUNDATION_EXPORT SFAuthKeyName const kAuthKeyAuthReason;         // 授信终端申请绑定信息
FOUNDATION_EXPORT SFAuthKeyName const kAuthKeyAuthUnBindList;     // 授信终端申请解绑列表
FOUNDATION_EXPORT SFAuthKeyName const kAuthKeyPrimarySmsAuthCode; // 短信主认证短信验证码

/** kAuthKeyAuthType 对应的value */
FOUNDATION_EXPORT SFAuthValueName const kAuthValueDingTalk;     // 钉钉
FOUNDATION_EXPORT SFAuthValueName const kAuthValueQyWechat;     // 企业微信
FOUNDATION_EXPORT SFAuthValueName const kAuthValueZwWechat;     // 政务微信

/** 初始化SDK额外配置的key */
FOUNDATION_EXPORT NSString * const kExtraFileIsolation; // 文件隔离额外配置

/** SDK高级配置选项的key */
FOUNDATION_EXPORT SFOptionsName const kOptionsAuthTimeOut;       // 设置认证连接超时时间
FOUNDATION_EXPORT SFOptionsName const kOptionsAuthLanguage;      // 设置认证提示语言
FOUNDATION_EXPORT SFOptionsName const kOptionsLogReport;         // 设置日志提交选项
FOUNDATION_EXPORT SFOptionsName const kOptionsCapturePackage;    // 设置开启抓包
FOUNDATION_EXPORT SFOptionsName const kOptionsSdkRandCodeUI;     // 设置使用SDK图形验证码UI
FOUNDATION_EXPORT SFOptionsName const kOptionsSdkTrustDeviceUI;  // 设置使用SDK授信终端展示UI

/// SDK Option选项
typedef NS_ENUM(NSInteger, SFSDKOption)
{
    SFSDKOptionAuthTimeOut               = 0,            //设置认证连接超时时间
    SFSDKOptionLanguage                  = 1,            //设置语言环境
    SFSDKOptionsLogReport                = 2,            //设置日志提交选项
    SFSDKOptionsCapturePackage           = 3,            //设置开启抓包
    SFSDKOptionAworkDisplayName          = 4,            //awork的名称
    SFSDKOptionUsingSdkRandCodeUI        = 5,            //设置使用SDK图形验证码UI
    SFSDKOptionUsingSdkTrustDeviceUI     = 6,            //设置使用SDK授信终端展示页面
};

/// SDK Extras选项
typedef NS_ENUM(NSInteger, SFSDKExtras)
{
    SFSDKExtrasAworkCurrentVersion       = 0,            //awork版本号
    SFSDKExtraSsoId                      = 1,            //增强沙箱的ssoid
    SFSDKExtrasEnableAppStore            = 2,            //启用应用商店
};

/// 错误码
typedef NS_ENUM(NSInteger, SF_ERROR_CODE)
{
    /** 成功的标记 */
    SF_ERROR_CODE_NONE                        = 1000,       //成功
    
    /** 认证服务端返回的错误  */
    SF_ERROR_SERVER_BUSY                      = 1001,       //操作失败，可能服务器太忙
    SF_ERROR_TIME_DENY                        = 1002,       //非允许时间段，禁止登录
    SF_ERROR_AUTH_TYPE_DISABLE                = 1003,       //未启用此认证，访问被拒绝
    SF_ERROR_NOT_SAME_USER                    = 1004,       //登录失败，前一认证与当前认证非同一用户
    SF_ERROR_AUTH_COMBINATION_INVALID         = 1005,       //不支持此种认证组合方式
    SF_ERROR_LICENSED_USER_LIMIT              = 1006,       //系统已到达最大授权用户限制
    SF_ERROR_GROUP_USER_LIMIT                 = 1007,       //您所在用户组已达到最大在线用户限制
    SF_ERROR_ACCOUNT_LOCKED                   = 1008,       //用户尝试暴破登录，已被系统锁定
    SF_ERROR_IP_LOCKED                        = 1009,       //ip地址尝试暴破登录，已被系统锁定
    SF_ERROR_IP_NEED_WORD_VERIFICATION        = 1010,       //ip地址尝试暴破登录，启用图形校验码
    SF_ERROR_SESSION_TIMEOUT                  = 1011,       //session timeout
    
    /**用户名认证*/
    SF_ERROR_PASSWOR_INVALID                  = 1101,        //用户名或者密码错误
    SF_ERROR_USER_EXPIRE                      = 1102,        //用户已过期
    SF_ERROR_USER_DISABLE                     = 1103,        //用户被禁用
    SF_ERROR_USER_TIMEOUT                     = 1104,        //用户已超时或注销
    SF_ERROR_CHARACTERS_INCORRECT             = 1105,        //校验码错误或校验码已过期
    SF_ERROR_USER_NEED_WORD_VERIFICATION      = 1106,        //用户名或密码错误，启用图形校验码
    SF_ERROR_LDAP_SERVER_FAILED               = 1107,        //LDAP连接服务器失败
    /**证书认证*/
    SF_ERROR_CERTIFICATE_INVALID              = 1201,        //证书不合法
    SF_ERROR_CERTIFICATE_AUTH_DISABLE         = 1202,        //证书认证被禁用
    SF_ERROR_CERTIFICATE_REVOKED              = 1203,        //证书已经被撤消
    SF_ERROR_CERTIFICATE_CODE_ERR             = 1204,        //证书编码设置有误，请联系管理员
    SF_ERROR_CERTIFICATE_SIGN_INVALID         = 1205,        //证书签名无效
    SF_ERROR_CERTIFICATE_NOT_EFFECT           = 1206,        //证书还未生效
    SF_ERROR_CERTIFICATE_EXPIRE               = 1207,        //证书已经过期
    SF_ERROR_CERTIFICATE_NO_PERMISSION        = 1208,        //证书读取失败，请检查证书文件权限
    
    /**免密认证*/
    SF_ERROR_TICKET_MOBID_INVALID             = 1301,        //免密认证无效的手机ID
    SF_ERROR_TICKET_CODEID_INVALID            = 1302,        //免密认证无效的code
    SF_ERROR_TICKET_PASS_CLOSE                = 1303,        //免密认证功能未开启
    SF_ERROR_TICKET_UNKOWN                    = 1304,        //未知错误
    
    /**短信校验码认证*/
    SF_ERROR_SEND_SMS_MESSAGE                 = 1401,        //发送短信失败
    SF_ERROR_SMS_PASSWORD_INVALID             = 1402,        //短信验证码错误
    SF_ERROR_NOT_SET_PHONE_NUMBER             = 1403,        //用户未设置手机号码，无法进行短信认证
    SF_ERROR_PHONE_NUMBER_INCORRECT           = 1404,        //提交的手机号码错误，无法进行短信认证
    SF_ERROR_SMS_PASSWORD_EXPIRE              = 1405,        //短信验证码已过期
    
    /**EMM授权认证*/
    SF_ERROR_EMM_NOT_AUTHORZATION             = 1501,        //EMM授权不通过，请联系管理员更新授权
    SF_ERROR_EMM_DEVICE_LIMIT                 = 1502,        //EMM授权达到最大数
    SF_ERROR_EMM_DEVICE_FROZEN                = 1503,        //EMM授权被冻结
    SF_ERROR_EMM_FAILED                       = 1504,        //EMM授权认证失败
    SF_ERROR_EMM_NETWORK_ERROR                = 1505,        //EMM授权网络链接错误
    SF_ERROR_EMM_CRYPTO_KEY                   = 1506,        //EMM授权加密key错误
    
    /**硬件特征码认证*/
    SF_ERROR_HID_VERIFY_FAILED                = 1601,        //硬件特征码验证失败
    SF_ERROR_HID_EXIST_NOTPASSED              = 1602,        //存在未审批的硬件特征码,等待管理员审批
    SF_ERROR_HID_INVALID                      = 1603,        //用户超时或硬件特征码无效输入
    SF_ERROR_HID_LIMIT                        = 1604,        //硬件特征数达到最大值
    SF_ERROR_HID_UPDATE_FAILED                = 1605,        //更新硬件特征码失败
    SF_ERROR_HID_GROUP_LIMIT                  = 1606,        //硬件特征码达到组用户最大限制
    SF_ERROR_HID_SN_LIMIT                     = 1607,        //硬件特征码达到授权限制
    SF_ERROR_HID_FAILED                       = 1608,        //当前终端未经过硬件特征码验证，请等待管理员审批
    SF_ERROR_HID_SUBMIT_FAILED                = 1609,        //提交硬件特征码失败
    SF_ERRPR_HID_CELLNUM_INVALID              = 1610,        //硬件特征码短信审批，用户未设置手机号码
    SF_ERROR_HID_COLLECT_FAILED               = 1611,        //硬件特征码收集失败
    
    /**外部认证等*/
    SF_ERROR_NO_EXTERNAL_SERVER               = 1701,        //没有对应的外部认证服务器，认证失败
    SF_ERROR_TOKEN_PASSWORD_INCORRECT         = 1702,        //动态令牌密码错误，认证失败
    SF_ERROR_CHALLENGE_FAILED                 = 1703,        //挑战认证失败
    SF_ERROR_CHALLENGE_TIMEOUT                = 1704,        //radius挑战超时
    
    /** 本地认证的错误 */
    SF_ERROR_CONNECT_VPN_FAILED               = 2001,        //连接VPN服务器错误，请检查网络
    SF_ERROR_URL_INVALID                      = 2002,        //VPN的URL为空
    SF_ERROR_DOMAN_RESOLVE_FAILED             = 2003,        //域名解析失败
    SF_ERROR_CRACKED_PHONE                    = 2004,        //越狱手机禁止登录
    SF_ERROR_SELECT_LINE_FAILED               = 2005,        //VPN选路失败
    SF_ERROR_NET_INVALID                      = 2006,        //网络不可用
    SF_ERROR_ADDRESS_FORMAT                   = 2007,        //vpn地址格式有误
    SF_ERROR_CONN_TIMEOUT                     = 2008,        //连接服务器超时
    
    SF_ERROR_AUTH_PARAM_EMPTY                 = 2101,        //认证参数为空
    SF_ERROR_AUTH_TYPE_INVALID                = 2102,        //调用的方法与当前认证方式不一致
    SF_ERROR_CERTIFICATE_NOT_EXIST            = 2103,        //证书不存在
    SF_ERROR_CERTIFICATE_TYPE_ERROR           = 2104,        //证书类型获取失败
    SF_ERROR_TICKET_AUTH_DISABLE              = 2105,        //免密认证不可用
    SF_ERROR_BUILD_REQUEST                    = 2106,        //构建请求失败
    SF_ERROR_SESSION_INVALID                  = 2107,        //session无效
    SF_ERROR_AUTH_TYPE_UNSPPORT               = 2108,        //认证类型不支持
    SF_ERROR_STATUS_ERROR                     = 2109,        //登录VPN状态错误，注销后再进行登录
    SF_ERROR_HID_GET_ERROR                    = 2110,        //读取硬件特征码失败
    SF_ERROR_AUTH_INIT_ERROR                  = 2111,        //VPN初始化失败
    SF_ERROR_AUTH_PARAM_ERROR                 = 2112,        //认证参数错误
    SF_ERROR_CERTIFICATE_WRONG_PWD            = 2113,
    
    SF_ERROR_START_L3VPN_FAILED               = 2201,        //启动L3VPN失败
    
    /** 非认证产生的错误 */
    SF_ERROR_CHPWD_TIMEOUT                    = 3001,        //用户超时
    SF_ERROR_CHPWD_NO_PERMISSION              = 3002,        //不属于本地密码认证用户
    SF_ERROR_CHPWD_GETINFO_FAIL               = 3003,        //获取用户信息失败
    SF_ERROR_CHPWD_WRONG_PWD                  = 3004,        //密码输入错误
    SF_ERROR_CHPWD_SYSTEM_BUSY                = 3005,        //更新用户信息失败,可能服务器忙!
    SF_ERROR_CHPWD_FORBID_CHGPWD              = 3006,        //您的帐号没有通过密码认证,不能修改密码
    SF_ERROR_VPN_NOT_LOGIN                    = 3007,        //VPN未登录导致修改密码失败
    SF_ERROR_NEW_PASSWORD_SAME_AS_OLD         = 3008,        //新密码与原密码相同
    SF_ERROR_CHPWD_SAFE_POLICY                = 3009,        //不符合密码策略
    SF_ERROR_CHPWD_FAILED                     = 3010,       //修改密码失败
    SF_ERROR_CHPWD_RIGHT_CHGPWD               = 3013,        //对不起，您不具有更改密码的权限，请与管理员联系
    SF_ERROR_CHPWD_RIGHT_CHGNOTE              = 3014,        //对不起,您不具有更改用户描述的权限,请与管理员联系
    SF_ERROR_CHPWD_NEWPWD_TOO_LONG            = 3015,        //密码的长度最长不能超过48个字符
    SF_ERROR_UPLAOD_DEVICE_INFO_FAILED        = 3016,        //上报设备信息失败
    SF_ERROR_IPV6_TO_TPV4_ONLY                = 3017,        //本地是纯ipv6场景不能对接ipv4的服务端
    SF_ERROR_IPV4_TO_TPV6_ONLY                = 3018,        //本地是纯ipv4场景不能对接ipv6的服务端
    
    SF_ERROR_FORWARD_FAILED                   = 3101,        //转发线程启动失败
    SF_ERROR_OUT_OF_MEMORY                    = 3201,        //内存不足
    
    /** 其它错误 */
    SF_ERROR_OTHER_ERROR                      = 4001,        //其它错误
    
    /** 注销错误 **/
    SF_ERROR_IP                             = 5001,         //ip错误注销
    SF_ERROR_IP_CONFLIC                     = 5005,         //虚拟ip冲突
    SF_ERROR_IP_SHORTAGE                    = 5006,         //虚拟ip短缺
    SF_ERROR_IP_KICK                        = 5007,         //虚拟ip被高权限用户踢掉
    SF_ERROR_IP_OTHER                       = 5008,         //虚拟ip其他错误
    SF_ERROR_IP_QUIT                        = 5009,         //服务端命令客户端退出
    SF_ERROR_IP_RECV                        = 5010,         //接收到服务端下发的ip
    SF_ERROR_IP_RESET                       = 5011,         //ip服务服务端重置了
    SF_ERROR_IP_RECONNECT                   = 5012,         //ip服务读、写隧道重连成功
} ;

/**
 * 定义更新策略返回值类型
 */
typedef NS_ENUM(NSInteger, SFUpdatePolicyCode)
{
    SFUpdatePolicySuccess            = 0,    //更新成功
    SFUpdatePolicyFormatError        = 1,    //策略格式错误
    SFUpdatePolicyNotAuth            = 2,    //未通过认证
    SFUpdatePolicyInnerError         = 3,    //内部错误
} ;

/*! @brief 获取修改密码的密码规则block
 *
 * @param displayMessage 修改密码的密码规则展示信息
 * @param detailRuleJson 修改密码的密码规则的详细json
 */ //
typedef void (^ SFGetPswStrategyBlock)(NSString *__nullable displayMessage, NSString *__nullable detailRuleJson);

/*! @brief 重置密码的block
 * 如果为nil则修改成功;否则修改密码错误,读取NSError的domain
 * @param error 重置密码错误
 */
typedef void (^ SFResetPasswordBlock)(NSError *__nullable error);

/*! @brief 重新获取短信校验码的block
 * 如果为nil则获取短信验证码成功；否则获取短信验证码失败
 * @param message 短信验证码信息
 * @param error 重新获取短信校验码错误
 */
typedef void (^ SFRegetSmsCodeBlock)(SFSmsMessage *__nullable message, NSError *__nullable error);

/*! @brief 重新获取图形校验码的block
 *
 * @param randcode 短信验证码信息
 * @param error 重新获取图形校验码错误
 */
typedef void (^ SFRegetRandCodeBlock)(NSData *__nullable randcode, NSError *__nullable error);

/*! @brief 选路block
 *
 * @param error 选路结果错误
 */
typedef void (^ SFSelectLineBlock)(NSError *__nullable error);

/*! @brief 设置SPA的结果回调
 *
 * @param result 对SPA配置解析到的结果, 登录的URL地址
 * @param error 如果error有值,代表设置配置遇到了错误
 */
typedef void (^ SFSetSpaConfigBlock)(NSString *__nullable result, NSError *__nullable error);

NS_ASSUME_NONNULL_END

#endif /* SFMobileSecurityTypes_h */
