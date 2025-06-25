//
//  BFParameterConfig.h
//  CMPCore
//
//  Created by wujiansheng on 2018/12/12.
//

#ifndef BFParameterConfig_h
#define BFParameterConfig_h

// 如果在后台选择自动配置授权信息，下面的三个LICENSE相关的参数已经配置好了
// 只需配置FACE_API_KEY和FACE_SECRET_KEY两个参数即可

// 人脸license文件名
#define BFACE_LICENSE_NAME_DEV    @"dev-idl-license"//开发模式299$证书对应
#define BFACE_LICENSE_NAME_DIS    @"release-idl-license"//发布模式99$证书对应(Appstore)


// 人脸license后缀
#define BFACE_LICENSE_SUFFIX  @"face-ios"

// （你申请的应用名称(appname)+「-face-ios」后缀，如申请的应用名称(appname)为test123，则此处填写test123-face-ios）
// 在后台 -> 产品服务 -> 人脸识别 -> 客户端SDK管理查看，如果没有的话就新建一个
#define BFACE_LICENSE_ID_DEV        @"cs-face-ios"//开发模式299$证书对应
#define BFACE_LICENSE_ID_DIS        @"M3Release-face-ios"//发布模式99$证书对应(Appstore)

// 以下两个在后台 -> 产品服务 -> 人脸识别 -> 应用列表下面查看，如果没有的话就新建一个

#define BFACE_API_ID @"11034185"
#define BFACE_API_KEY @"oopux74bQXlUeKNGR2Kqy2cO" // 你的API Key
#define BFACE_SECRET_KEY @"3gse8c4gDgiz4y3p1NGe3oChukzDXHNn" // 你的Secret Key

#define  BFConditionTimeout_Liveness  60
#define  BFConditionTimeout_Unliveness  1000


#endif /* BFParameterConfig_h */
