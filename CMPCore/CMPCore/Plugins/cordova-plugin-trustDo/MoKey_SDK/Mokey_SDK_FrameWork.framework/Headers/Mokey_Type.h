#ifndef _DEFINED_GM_TYPE_H
#define _DEFINED_GM_TYPE_H

/** 注册激活结果函数 */
typedef void(^OnActivateResult)(int errorCode);
/** 快速重置结果函数 */
typedef void(^OnFastResetResult)(int errorCode);
/** 登录结果回调函数 */
typedef void(^OnUserLoginResult)(int errorCode, NSString *accToken);
/** 签名结果回调函数 */
typedef void(^OnUserSignResult)(int errorCode, NSString *signValue);
/** 签章结果回调函数 */
typedef void(^OnUserStampResult)(int errorCode,NSString *signValue);
/** PDF签章结果回调函数 */
typedef void(^OnUserPDFStampResult)(int errorCode,NSString *accToken);
/** PDF签章结果回调函数(根据Hash计算P7) */
typedef void(^OnUserPDFStampP7Result)(int errorCode,NSString *signValue);
/** 签批结果回调函数 */
typedef void(^OnUserCommentResult)(int errorCode,NSString *signValue);
/** 设置签章图片结果回调函数 */
typedef void(^OnSetStampImgResult)(int errorCode,NSData *stampImg);
/** 重置密钥结果回调函数 */
typedef void(^OnUserResetResult)(int errorCode);
/** 切换设备-获取切换二维码结果回调函数 */
typedef void(^OnGenChangeImgResult)(int errorCode,NSData *changeImg);
/** 切换结果回调函数 */
typedef void(^OnUserChangeResult)(int errorCode);
/** 解析签名值 返回对应类型的数据 */
typedef void(^OnGetSignInfoResult)(int errorCode , id data);
/** 修改口令结果回调函数 */
typedef void(^OnModifyResult)(int errorCode);
/** 密钥／更新证书 */
typedef void(^OnUserUpdateResult)(int errorCode);
/** 获取错误描述 */
typedef void(^OnGetErrMsgResult)(NSString *errMsg);
/** 获取设备信息接口 */
typedef void(^OnGetDeviceIDResult)(NSString *deviceId);
/** 获取用户状态接口 */
typedef void(^OnGetUserStateResult)(int errorCode, id state);
/** 个人批量P7签 */
typedef void(^OnUserBatchStampResult)(int errorCode,NSString *signValue);
/** 个人批量P7签 */
typedef void(^OnUserBatchP1StampResult)(int errorCode,NSString *signValue);



/** 企业账户登录结果函数 */
typedef void(^OnCompanyLoginResult)(int errorCode, NSString *accToken);
/** 企业账户签名结果回调函数 */
typedef void(^OnCompanySignResult)(int errorCode, NSString *signValue);
/** 企业账户签章结果回调函数 */
typedef void(^OnCompanyStampResult)(int errorCode,NSString *signValue);
/** 企业账户PDF签章结果回调函数 */
typedef void(^OnCompanyPDFStampResult)(int errorCode,NSString *accToken);
/** 企业账户PDF签章结果回调函数(根据Hash计算P7) */
typedef void(^OnCompanyPDFStampP7Result)(int errorCode,NSString *signValue);
/** 企业批量P7签 */
typedef void(^OnCompanyBatchStampResult)(int errorCode,NSString *signValue);
/** 企业批量P1签 */
typedef void(^OnCompanyBatchP1StampResult)(int errorCode,NSString *signValue);
/** 企业账户解密结果回调函数 */
typedef void(^OnCompanyDecryptResult)(int errorCode, NSString *signValue);

/** 开启静默签名 */
typedef void(^OnUserAuthQuickResult)(int errorCode, NSString *silentToken);
/** 静默签名 */
typedef void(^OnUserQuickResult)(int errorCode, NSString *signValue);
/** 关闭静默签名 */
typedef void(^OnUserQuickStopResult)(int errorCode);

/** 登录并开启静默签名回调函数 */
typedef void(^OnUserSilentLoginResult)(int errorCode, NSString *accToken);
/** 开启静默签名回调函数 */
typedef void(^OnUserSilentSignStartResult)(int errorCode, NSString *silentToken);

#endif
