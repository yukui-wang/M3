//
//  XZMemberCard.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/5/23.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZBaseView.h"
#import "XZMemberModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface XZMemberDetailView : XZBaseView
- (void)setupInfo:(XZMemberModel *)info;
+ (CGFloat)viewHeight:(BOOL)enable;

@end

NS_ASSUME_NONNULL_END
