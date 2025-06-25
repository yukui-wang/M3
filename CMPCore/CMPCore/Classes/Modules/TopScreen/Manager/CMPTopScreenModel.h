//
//  CMPTopScreenModel.h
//  M3
//
//  Created by Shoujian Rao on 2023/12/28.
//

#import <Foundation/Foundation.h>
typedef enum {
    CMPTopScreenOpenTypeLoadApp = 1,
    CMPTopScreenOpenTypePushPage,
    CMPTopScreenOpenTypeNative,
    CMPTopScreenOpenTypeOther,
} CMPTopScreenOpenType;

@interface CMPTopScreenModel : NSObject

@property (nonatomic, copy) NSString *uniqueId;//拼凑的id，决定唯一性

@property (nonatomic, copy) NSString *appId;//62
@property (nonatomic, copy) NSString *appType;//default\biz
@property (nonatomic, copy) NSString *bundleName;//addressbook
@property (nonatomic, copy) NSString *bizMenuId;//业务应用biz类型才使用(pushPage中param["param"]["menuId"])
@property (nonatomic, copy) NSString *m3from;//workbench (param["param"]["entrance"])
@property (nonatomic, copy) NSString *iconUrl;
@property (nonatomic, copy) NSString *iconUrlParsed;
@property (nonatomic, copy) NSString *appName;//例如：通讯录

@property (nonatomic, assign) CMPTopScreenOpenType openType;//类型：loadApp=1\pushPage=2\原生=3\其他

@property (nonatomic, copy) NSString *goToParam;//跳转参数
@property (nonatomic, assign) NSInteger click;//点击次数
@property (nonatomic, assign) BOOL isSecondFloor;//是否是我的二楼model
//数据库标准字段
@property (nonatomic, copy) NSString *serverVersion;//服务器版本
@property (nonatomic, copy) NSString *modelId;
@property (nonatomic, copy) NSString *userId; //用户id
@property (nonatomic, copy) NSString *serverId; //服务器id
@property (nonatomic, assign) NSTimeInterval createTime;//创建时间
@property (nonatomic, assign) NSTimeInterval updateTime;//修改时间
@property (nonatomic, copy) NSString *ext1;
@property (nonatomic, copy) NSString *ext2;
@property (nonatomic, copy) NSString *ext3;

@end


