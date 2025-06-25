//
//  CMPConstant_Ext.h
//  CMPCore
//  
//  Created by youlin on 2017/7/4.
//
//

#ifndef CMPConstant_Ext_h
#define CMPConstant_Ext_h

//App ID
#define kM3AppIDInHouse @"com.seeyon.m3.inhouse.dis"    // 企业版本App ID
#define kM3AppIDInAppStore @"com.seeyon.m3.appstore.new.phone" // App store版本 APP ID

// 生成设备唯一标志
#define kM3PrefixAppIDInHouse @"5U3B39Y6Z9.com.seeyon.m3.inhouse.dis"  // 企业版本App ID prefix
#define kM3PrefixAppIDInAppStore @"LMTR39G5GC.com.seeyon.m3.appstore.new.phone" // App store版本 APP ID prefix

/* 使用高德地图API，请注册Key，注册地址：http://lbs.amap.com/console/key */
//#define kLBSAPIKeyM3InHouse @"0d61ba031c6cf00e28204f74efb65503" // 原企业版本高德地图key
#define kLBSAPIKeyM3InHouse @"29a46e3ed958e7af8a1213ed93506ca5" // 企业版本高德地图key（海外版）
#define kLBSAPIKeyM3InAppStore @"ecaf271a6890b98e35395cac340c98d1" // App Store地图key
#define kLBSWebAPIKeyM3 @"7400bedef5cb309ea767340c3b67c828" // 高德地图Web api key

/* 使用谷歌地图API，默认Key*/
#define kLBSGoogleAPIKey @"AIzaSyBHtDLGM_Nbv6tyFCfL6bkle2oL_ZX_Mio"

/*百度推送key*/
#define kBaiDuPushKeyM3InHouse  @"VXhjYR2fCblbXA997FjtfUIY"  // 企业版本离线消息推送key
#define kBaiDuPushKeyM3InAppStore  @"MyRcsxpiXU3lvTKfC8xksKoW" // App Store版本离线消息推送key

/*乐播投屏AppID 及 AppKey*/
#define kLeboHpPlayKeyM3InHouse     @"110ef1a857717d4bbd78a2ac8978d65b"  // 企业版本离线消息推送key
#define kLeboHpPlayKeyM3InAppStore  @"290026c3e57943b7b9f64e20fc2c4eb0" // App Store版本离线消息推送key
#define kLeboHpPlayIDM3InHouse      @"11425"  // 企业版本离线消息推送AppID
#define kLeboHpPlayIDM3InAppStore   @"11424" // App Store版本离线消息推送AppID

// 离线消息推送类型
#define kC_iMessageClientProtocolType_Android @"android"
#define kC_iMessageClientProtocolType_IPad @"iPad" // ipad 99美元证书
#define kC_iMessageClientProtocolType_IPadInHouse @"iPadInHouse" // ipad 299美元证书
#define kC_iMessageClientProtocolType_IPhone @"iPhone" //iphone 99美元证书
#define kC_iMessageClientProtocolType_IPhoneInHouse @"iPhoneInHouse" //iphone 299美元证书

// 检查客户端更新参数
#define kAccountType_AppStore @"1"
#define kAccountType_InHouse @"2"
#define kAccountType_Undefined @"undefined"

// 检测M3更新url参数
#define kCheckVersionUrl_M3_Param @"%@/validateversion?clienttype=iphone&clientversion=%@&serverversion=%@&accountType=%@"

#if DEBUG
#define kMplusGetServerInfoUrl  @"https://mplus.test.seeyon.com/open/ip" // 云联测试服务器
//#define kMplusGetServerInfoUrl  @"https://mplus.seeyon.com/open/ip" // 云联正式服务器
#endif

#if RELEASE
#define kMplusGetServerInfoUrl  @"https://mplus.seeyon.com/open/ip" // 云联正式服务器
#endif

#if APPSTORE
#define kMplusGetServerInfoUrl  @"https://mplus.seeyon.com/open/ip" // 云联正式服务器
#endif

#if CUSTOM
#define kMplusGetServerInfoUrl  @"https://mplus.seeyon.com/open/ip" // 云联正式服务器
#endif

//云租户组织码获取server接口
#define kCloudLoginServiceUrl @"https://a6cloud.cn/loginservice/resource/obtainUrl"


#endif /* CMPConstant_Ext_h */
