//
//  CMPLoginConfigInfoModel.h
//  M3
//
//  Created by CRMO on 2017/11/6.
//

#import "CMPBaseResponse.h"
#import "CMPTabBarAttribute.h"
#import "CMPTabBarItemAttribute.h"

@interface CMPLoginConfigMapKey : CMPObject
@property (nonatomic,copy) NSString *googleMapKey;
@property (nonatomic,copy) NSString *gaodeMapKey;
@end

@interface CMPLoginConfigInfo : CMPObject
@property (nonatomic , assign) BOOL              hasAddressBook;
/** 水印总开关 **/
@property (nonatomic , copy) NSString              * materMarkEnable;
/** 7.1及之后版本新增参数，通讯录水印开关 **/
@property (nonatomic , copy) NSString              * materMarkAddressBookEnable;
/** 7.1及之后版本新增参数，致信水印开关 **/
@property (nonatomic , copy) NSString              * materMarkZxEnable;
@property (nonatomic , copy) NSArray<NSNumber *>              * messageClassification;
@property (nonatomic , copy) NSString              * indexClassification;
@property (nonatomic , assign) BOOL              hasSentList;
@property (nonatomic , copy) NSString              * materMarkDeptEnable;
@property (nonatomic , assign) BOOL              hasIndexPlugin;
@property (nonatomic , copy) NSString              * configPwdStrong;
@property (nonatomic , copy) NSString              * materMarkNameEnable;
@property (nonatomic , copy) NSString              * materMarkTimeEnable;
@property (nonatomic , assign) BOOL              hasWaitSendList;
@property (nonatomic , assign) BOOL              hasPendingList;
@property (nonatomic , assign) BOOL              hasDoneList;
@property (nonatomic , assign) BOOL              hasAIPlugin;
@property (nonatomic , assign) BOOL              internal;
@property (nonatomic , assign) BOOL              isGroup;
@property (nonatomic , assign) BOOL              canLocation;
// 隐藏领导消息（V7.1新增字段，如果该人员没有领导返回true）
@property (nonatomic , assign) BOOL              hideLeaderMessage;
// 是否支持通讯录录在线搜索
@property (assign, nonatomic) BOOL hasAddressBookIndex;
// 是否支持兼职单位切换
@property (assign, nonatomic) BOOL hasParttimeSwitch;
@property (assign, nonatomic) BOOL hasBusinessorganization;
/* 是否支持显示t无线投屏按钮 */
@property (copy, nonatomic) NSString *allow_ScreenCast;

/** 7.1及之后版本新增参数，打印开关 **/
@property (assign, nonatomic) BOOL printIsOpen;
/** 8.0及之后版本新增参数，mapkey **/
@property (strong, nonatomic) CMPLoginConfigMapKey *mapKey;

/** 8.0及之后版本新增参数,ocip插件是否开启，hasOcip **/
@property (assign, nonatomic) BOOL hasOcip;

@end

@interface CMPLoginConfigTabBarModel : CMPObject
@property (nonatomic , strong) CMPTabBarAttribute *tabbarAttribute;
@property (nonatomic , strong) NSArray<CMPTabBarItemAttribute *> *tabbarList;
/** V8.0新增,navBarAttribute字段变为数组,包含了所有风格的底导航信息  **/
@property (nonatomic , strong) NSArray<CMPTabBarAttribute *> *tabbarAttributes;
/** 快捷菜单是否在底导航 **/
@property (assign, nonatomic) BOOL hasShortCut;

- (BOOL)needOnlyReloadTabbarItem:(CMPLoginConfigTabBarModel *)aObject;

@end

/** V7.1新增 **/
@interface CMPLoginConfigPortalModel : CMPObject
/** 管理员设置的首页 **/
@property (copy, nonatomic) NSString *indexAppKey;
/** 门户ID **/
@property (copy, nonatomic) NSString *portalID;
/** 右上角是否展示常用应用入口 **/
@property (assign, nonatomic) BOOL isShowCommonApp;
/** 模板名称 **/
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *sortNum;
@property (copy, nonatomic) NSString *createDate;
@property (copy, nonatomic) NSString *updateDate;
@property (assign, nonatomic) NSInteger canModify;
@property (strong, nonatomic) CMPLoginConfigTabBarModel *navBar;
@property (strong, nonatomic) CMPLoginConfigTabBarModel *expandNavBar;

@property (nonatomic, assign) BOOL openExpandNavBar;
@end

@interface CMPLoginConfigInfoModel : CMPBaseResponse

@property (nonatomic, strong) CMPLoginConfigInfo *data;

@end

// 1.8.0版本Server合并config、tabbar接口
@interface CMPLoginConfigInfoModel_2 : CMPBaseResponse

@property (nonatomic, strong) CMPLoginConfigInfo *config;
/** 人员部门显示顺序 **/
@property (copy, nonatomic) NSString *firstShow;
/** 人员卡片展示信息开关 **/
@property (strong, nonatomic) NSDictionary *fieldViewSet;
/** 底部导航配置信息 **/
@property (strong, nonatomic) CMPLoginConfigTabBarModel *tabBar;
/** V7.1新增字段，门户列表 **/
@property (nonatomic , strong) NSArray *portals;
/** V7.1新增字段，当前门户 **/
@property (strong, nonatomic) CMPLoginConfigPortalModel *portal;

@property (assign, nonatomic) BOOL hasUcMsgServerDel;//YES为支持删除远程致信消息

/**
 转化为1.8.0之前版本config的返回报文，用于写入H5缓存
 */
- (NSString *)getH5CacheStr;

@end
