//
//  XZQAGuidePageView.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/6/12.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZGuidePageView.h"
#import "XZQAGuideInfo.h"
#import "XZQAGuideSubPageView.h"

@interface XZQAGuidePageView : XZGuidePageView
@property (nonatomic, strong) XZQAGuideInfo *guideInfo;
@property (nonatomic,strong)XZQAGuideSubPageView *subPage;

- (id)initWithQAInfo:(XZQAGuideInfo *)guideInfo;
@end

