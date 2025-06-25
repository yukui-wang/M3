//
//  XZGuidePageItem.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/5/13.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XZGuidePageSubItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZGuidePageItem : NSObject

@property(nonatomic, strong)NSString *title;
@property(nonatomic, strong)NSString *subTitle;
@property(nonatomic, strong)NSArray *subheads;
@property(nonatomic, strong)NSString *themeIcon;
- (id)initWithDic:(NSDictionary *)result;
@end

NS_ASSUME_NONNULL_END
