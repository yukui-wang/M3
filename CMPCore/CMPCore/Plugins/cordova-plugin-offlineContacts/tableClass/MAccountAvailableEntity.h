//
//  MAccountAvailableEntity.h
//  CMPCore
//
//  Created by wujiansheng on 2017/1/11.
//
//

#import <CMPLib/CMPObject.h>
#import "MAccountSetting.h"
@interface MAccountAvailableEntity : CMPObject

@property(nonatomic, assign)long long accountId;
@property(nonatomic, assign)int accessable;//0  不能访问，1可以  为0时 前台直接删掉
@property(nonatomic, assign)int change; // 0  没有改变， 1  改变了 为0时 不做更新，  1时更新
@property(nonatomic, copy)NSString *md5;
@property(nonatomic, retain)MAccountSetting *setting;
@end
