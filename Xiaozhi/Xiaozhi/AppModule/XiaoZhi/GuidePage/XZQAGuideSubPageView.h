//
//  XZQAGuideSubPageView.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/6/12.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZGuideSubPageView.h"
#import "XZQAGuideTips.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZQAGuideSubPageView : XZGuideSubPageView
@property (nonatomic, strong) XZQAGuideTips *guideTips;
@property (nonatomic, copy)void(^clickTextBlock)(NSString *text);

@end

NS_ASSUME_NONNULL_END
