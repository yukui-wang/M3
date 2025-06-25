//
//  SignMapPlugin.h
//  CMPCore
//
//  Created by wujiansheng on 16/8/4.
//
//

#import <CordovaLib/CDVPlugin.h>

@interface CMPLocationMarkPlugin : CDVPlugin

/**
 打开地图标记控件
 参数：
    showMap "1"-返回地图图片 "0"-不返回地图图片
    zoom 默认 "16"
    scale 默认 "2"
    size 默认 "408*240"
 返回：
    [{"lbsAddr":"四川省成都市武侯区成都精诺企业管理集团有限公司","category":"2","lbsProvince":"四川省","lbsTown":"武侯区","createDate":null,"lbsComment":null,"lbsStreet":"科园二路10号2栋2单元3楼","lbsLatitude":"30.572269","lbsCountry":"中国","lbsContinent":null,"lbsLongitude":"104.066541","lbsCity":"成都市", "mapImagePath":""}]

 */
- (void)markLocation:(CDVInvokedUrlCommand*)command;

@end
