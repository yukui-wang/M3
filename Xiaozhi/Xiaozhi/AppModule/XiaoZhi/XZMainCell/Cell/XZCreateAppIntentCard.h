//
//  XZCreateAppIntentCard.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/5/24.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZCreateAppIntentCard : XZBaseView

- (void)setupWithAppName:(NSString *)name infoList:(NSArray *)infoList;

- (CGFloat)viewHeightForWidth:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
