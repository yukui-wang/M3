//
//  CMPBaseDataProvider.h
//  CMPLib
//
//  Created by SeeyonMobileM3MacMini2 on 2022/9/9.
//  Copyright © 2022 crmo. All rights reserved.
//

#import <CMPLib/CMPDataProvider.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^CommonResultBlk)(id respData,NSError *error,id ext);

@interface CMPBaseDataProvider : CMPObject<CMPDataProviderDelegate>

@end

NS_ASSUME_NONNULL_END
