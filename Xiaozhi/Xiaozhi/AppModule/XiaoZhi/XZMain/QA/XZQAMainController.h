//
//  XZQAMainController.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/12/11.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XZQAMainController : NSObject
+ (instancetype)sharedInstance;
- (void)openQAPage:(NSDictionary *)params;
//消息界面打开QA
- (id)showIntelligentPage;

@end

NS_ASSUME_NONNULL_END
