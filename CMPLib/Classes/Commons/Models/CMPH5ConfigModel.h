//
//  CMPH5ConfigModel.h
//  CMPLib
//
//  Created by CRMO on 2019/1/3.
//  Copyright © 2019 CMPCore. All rights reserved.
//

#import "CMPObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface CMPH5ConfigModel : CMPObject

/** 不展示常用应用入口的应用列表 **/
@property (strong, nonatomic) NSArray *commonAppBlackList;

@end

NS_ASSUME_NONNULL_END
