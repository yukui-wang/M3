//
//  XZCore.h
//  M3
//
//  Created by wujiansheng on 2019/2/20.
//

#import <Foundation/Foundation.h>
#import "CMPSpeechRobotConfig.h"
#import "SPBaiduSpeechInfo.h"
#import "SPBaiduUnitInfo.h"
#import "BaiduFaceIdApp.h"
#import "BaiduNlpApp.h"
#import "BaiduImageClassifyApp.h"

#import "XZMsgSwitchInfo.h"
#import "XZMsgRemindRule.h"
#import "XZIntentPrivilege.h"
#import "XZPrivilege.h"
#import "XZGuidePage.h"
#import "SPConstant.h"

@interface XZCore : NSObject {
    NSString *_intentMd5;
    NSString *_spErrorCorrectionMd5;
    NSString *_pinyinRegularMd5;
}

//小致设置
@property (nonatomic, retain) CMPSpeechRobotConfig *robotConfig;
@property (nonatomic, assign) BOOL showInSetting;//小致是否在设置界面显示
@property (nonatomic, assign) long long outTime;
@property (nonatomic, assign) NSInteger xiaozhiCode;
//百度信息
@property (nonatomic, retain) SPBaiduSpeechInfo *baiduSpeechInfo;//语音
@property (nonatomic, retain) SPBaiduUnitInfo *baiduUnitInfo;//unit
@property (nonatomic, retain) BaiduFaceIdApp *baiduFaceInfo;//人脸识别
@property (nonatomic, retain) BaiduNlpApp *baiduNlpInfo;//nlp
@property (nonatomic, retain) BaiduImageClassifyApp *baiduImageCInfo;//图像识别
//智能消息设置
@property (nonatomic, retain) XZMsgSwitchInfo *msgSwitchInfo;
@property (nonatomic, retain) XZMsgRemindRule *msgRemindRule;
@property (nonatomic, retain) NSArray *shortCutIds;//关联文档权限
//命令（意图）列表     及
@property (nonatomic, retain) XZIntentPrivilege *intentPrivilege;
//QA列表权限
@property (nonatomic, retain) NSArray *qaPermissions;
//权限：新建协同、新建日程。。。的权限
@property (nonatomic, retain) XZPrivilege  *privilege;
@property (nonatomic, retain) NSArray *tabbarIdArray;
@property (nonatomic, retain) NSDictionary *speechInput;//用于h5插件缓存

//intent
@property (nonatomic, assign) XZIntentJsonFileState intentJsonState;//intent json 文件 更新状态

@property (nonatomic, copy) NSString *intentMd5;//intent json 文件Md5
@property (nonatomic, copy) NSString *spErrorCorrectionMd5;//百度语音矫正
@property (nonatomic, retain) NSDictionary *spErrorCorrectionDic;//百度语音矫正

@property (nonatomic, copy) NSString *pinyinRegularMd5;//拼音正则下载MD5
@property (nonatomic, retain) NSString *pinyinRegular;//拼音正则

@property (nonatomic, strong) UIImage *userProfileImage;//小致用户当前头像
@property (nonatomic, assign) NSInteger textLenghtLimit;//小致文本长度限制

@property (nonatomic, strong) XZGuidePage *guidePage;//新版本引导页，类似siri

@property (nonatomic, assign) XiaozhiMessageRequestStatus xzMsgRequestStatus;//获取小致登录信息接口状态


@property (nonatomic, copy) NSString *intentMd5Temp;//临时文件Md5
@property (nonatomic, assign)BOOL downloadIntent;//
@property (nonatomic, copy) NSString *spErrorCorrectionMd5Temp;//临时百度语音矫正
@property (nonatomic, assign)BOOL downloadSpeechError;//
@property (nonatomic, copy) NSString *pinyinRegularMd5Temp;//临时拼音正则下载MD5
@property (nonatomic, assign)BOOL downloadRosterPinyin;//


+ (XZCore *)sharedInstance;
- (void)clearData;
- (void)setupBaiduInfo:(NSDictionary *)dic;
+ (void)setCurrentUserRobotConfig:(CMPSpeechRobotConfig *)config;
- (void)saveAppListId;
- (NSDictionary *)formJson;
- (void)setupMsgSwitchInfo:(NSDictionary *)dic;
- (void)setupMsgSwitchInfoWithMainSwitch:(BOOL)mainSwitch;
- (BOOL)msgIsFirst;
- (BOOL)msgViewCanSpeak;
- (void)setupMsgViewCanSpeak:(BOOL)speak;
- (NSString *)msgRemindPreTime;
- (void)updateMsgRemindPreTime:(NSString *)time;

- (BOOL)xiaozAvailable;//小致是否可用
//是否是unit2.0
- (BOOL)isUnitLater2;
//小致版本号判断
- (BOOL)isXiaozVersionLater2_2;
- (BOOL)isXiaozVersionLater3_1;
- (BOOL)isM3ServerIsLater8;

+ (NSString *)userID;
+ (NSString *)userName;
+ (NSString *)departmentName;
+ (NSString *)postID;
+ (NSString *)postName;
+ (NSString *)accountID;
+ (NSString *)serverurl;
+ (NSString *)fullUrlForPath:(NSString *)path;
+ (NSString *)fullUrlForPathFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2);
+ (NSString *)serverID;
+ (BOOL)allowRotation;


@end
