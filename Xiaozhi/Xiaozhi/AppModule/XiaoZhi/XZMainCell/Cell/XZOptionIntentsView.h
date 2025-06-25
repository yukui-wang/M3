//
//  XZOptionIntentsView.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/7/3.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZBaseView.h"
#import "XZAppIntent.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZOptionIntentsView : XZBaseView

- (void)setupData:(NSArray *)intents;
+ (CGFloat)viewHeight:(NSInteger)count;

@end

NS_ASSUME_NONNULL_END
