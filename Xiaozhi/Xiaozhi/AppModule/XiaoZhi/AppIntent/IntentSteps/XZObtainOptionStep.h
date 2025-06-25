//
//  XZObtainOptionStep.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/10/24.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZIntentStep.h"
#import "XZObtainOptionConfig.h"

@interface XZObtainOptionStep : XZIntentStep
@property(nonatomic,strong)XZObtainOptionConfig *obtainConfig;
- (void)handleTempValue;
@end
