//
//  XZGuidePageSubItem.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/5/13.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XZGuidePageSubItem : NSObject
@property(nonatomic, strong)NSString *title;
@property(nonatomic, strong)NSArray *words;
- (id)initWithDic:(NSDictionary *)result;
@end

NS_ASSUME_NONNULL_END
