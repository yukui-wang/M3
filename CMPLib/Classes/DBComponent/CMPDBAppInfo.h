//
//  CMPDBAppItem.h
//  CMPLib
//
//  Created by youlin on 16/6/6.
//  Copyright © 2016年 CMPCore. All rights reserved.
//

#import "CMPObject.h"

@interface CMPDBAppInfo : CMPObject

@property(nonatomic, copy)NSString    *appId;      // 应用id
@property(nonatomic, copy)NSString    *bundle_identifier; // 包唯一id
@property(nonatomic, copy)NSString    *bundle_name;
@property(nonatomic, copy)NSString    *bundle_display_name;
@property(nonatomic, copy)NSString    *version;
@property(nonatomic, copy)NSString    *team;
@property(nonatomic, copy)NSString    *path;
@property(nonatomic, copy)NSString    *bundle_type;
@property(nonatomic, copy)NSString    *desc;
@property(nonatomic, copy)NSString    *deployment_target;
@property(nonatomic, copy)NSString    *compatible_version;
@property(nonatomic, copy)NSString    *icon_files;
@property(nonatomic, copy)NSString    *supported_platforms;
@property(nonatomic, copy)NSString    *url_schemes;

@property(nonatomic, copy)NSString    *serverID;
@property(nonatomic, copy)NSString    *owerID;
@property(nonatomic, copy)NSString    *downloadTime;

@property(nonatomic, copy)NSString    *extend1;  // 已经被占用，for md5 code
@property(nonatomic, copy)NSString    *extend2;  // 已经被占用，js注入后的文件夹路径
@property(nonatomic, copy)NSString    *extend3;
@property(nonatomic, copy)NSString    *extend4;
@property(nonatomic, copy)NSString    *extend5;
@property(nonatomic, copy)NSString    *extend6;
@property(nonatomic, copy)NSString    *extend7;
@property(nonatomic, copy)NSString    *extend8;
@property(nonatomic, copy)NSString    *extend9;
@property(nonatomic, copy)NSString    *extend10;
@property(nonatomic, copy)NSString    *extend11;
@property(nonatomic, copy)NSString    *extend12;
@property(nonatomic, copy)NSString    *extend13;
@property(nonatomic, copy)NSString    *extend14;
@property(nonatomic, copy)NSString    *extend15;

- (id)initWithManifestDict:(NSDictionary *)aDict;
//获取应用的最终路径，应为js合并后是extend2，不是path
- (NSString *)finalPath;
@end
