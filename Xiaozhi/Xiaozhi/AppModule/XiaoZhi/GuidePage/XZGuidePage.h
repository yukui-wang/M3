//
//  XZGuidePage.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/5/13.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XZGuidePageItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZGuidePage : NSObject
@property(nonatomic, strong)NSArray *pages;
+ (XZGuidePage *)guidePageWithArray:(NSArray *)result;
@end

NS_ASSUME_NONNULL_END
