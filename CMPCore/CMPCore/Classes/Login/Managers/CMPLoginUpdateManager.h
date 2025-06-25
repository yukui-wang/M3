//
//  CMPLoginUpdateManager.h
//  M3
//
//  Created by CRMO on 2017/11/15.
//

#import <CMPLib/CMPObject.h>

@class CMPAppListModel;

@interface CMPLoginUpdateManager : CMPObject

/**
 新建3个库
 */
- (BOOL)createTables;

/**
 将AppList写入H5需要的数据库，兼容老版本
 */
- (BOOL)insertApps:(CMPAppListModel *)appList;

@end
