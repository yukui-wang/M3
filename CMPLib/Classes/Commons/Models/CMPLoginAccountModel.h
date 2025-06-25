//
//  CMPLoginAccountModel.h
//  M3
//
//  Created by CRMO on 2017/12/6.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CMPLoginAccountModelGesture) {
    CMPLoginAccountModelGestureUninit = 2,
    CMPLoginAccountModelGestureOpen = 1,
    CMPLoginAccountModelGestureClose = 0,
};

typedef NS_ENUM(NSUInteger, CMPLoginAccountModelLoginType) {
    CMPLoginAccountModelLoginTypeLegacy, // 企业账号登录，默认值
    CMPLoginAccountModelLoginTypePhone, // 手机号登录
    CMPLoginAccountModelLoginTypeMokey,  // 手机盾登录
    CMPLoginAccountModelLoginTypeSMS  // 手机盾登录
};

typedef NS_ENUM(NSInteger, CMPLoginModeSubType) {
    CMPLoginModeSubType_None = 0,
    CMPLoginModeSubType_MutilVerify = 1, // 双因子等需要短信验证码
};

@class CMPLoginAccountExtraDataModel;

@interface CMPLoginAccountModel : NSObject

@property (strong, nonatomic) NSString *serverID;
@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSString *loginName;
@property (strong, nonatomic) NSString *loginPassword;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *gesturePassword;
@property (assign, nonatomic) CMPLoginAccountModelGesture gestureMode;
@property (assign, nonatomic) BOOL inUsed;
@property (strong, nonatomic) NSString *loginResult;
@property (strong, nonatomic) NSString *appList;
@property (strong, nonatomic) NSString *configInfo;

@property (nonatomic, copy)NSString *accountID;  // 单位id
@property (nonatomic, copy)NSString *departmentID;  // 部门id
@property (nonatomic, copy)NSString *levelID;  // 职务级别id
@property (nonatomic, copy)NSString *postID;  // 岗位id
@property (nonatomic, copy)NSString *iconUrl; // 用户头像url,用于手势密码显示人员头像，但不会及时更新，只有登录的时候才会更新
@property (nonatomic, copy)NSString *pushConfig; // 新消息推送设置
@property (nonatomic, copy)NSString *ucConfig; // 致信配置

@property (nonatomic ,copy)NSString * departmentName;//部门
@property (nonatomic ,copy)NSString * postName;//岗位

@property (strong, nonatomic) NSString *extend1; // 企业简称
@property (strong, nonatomic) NSString *extend2; // 密码（用于关联账号，在切换账号时不清空）
@property (strong, nonatomic) NSString *extend3; // 企业名
@property (strong, nonatomic) NSString *extend4; // 登录方式
@property (strong, nonatomic) NSString *extend5; // 手机号
@property (strong, nonatomic) NSString *extend6; // token
@property (strong, nonatomic) NSString *extend7; // token过期时间
@property (strong, nonatomic) NSString *extend8; // areaCode手机号区号
@property (strong, nonatomic) NSString *extend9;
@property (strong, nonatomic) NSString *extend10;

// 数据存储在extend4
@property (assign, nonatomic) CMPLoginAccountModelLoginType loginType;

// 数据存储在extend10 中
@property (strong, nonatomic, readonly) CMPLoginAccountExtraDataModel *extraDataModel;

@end

@interface CMPLoginAccountExtraDataModel : NSObject

@property (nonatomic) BOOL isAlreadyShowPrivacyAgreement; //是否已经显示过隐私协议,老用户默认已经显示过
@property (assign, nonatomic) CMPLoginModeSubType loginModeSubType;
@property (copy, nonatomic) NSString *loginInfoLegency;

@end
