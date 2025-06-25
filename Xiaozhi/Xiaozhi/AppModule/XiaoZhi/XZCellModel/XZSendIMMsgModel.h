//
//  XZSendIMMsgModel.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/6/22.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZCellModel.h"
#import <CMPLib/CMPOfflineContactMember.h>
NS_ASSUME_NONNULL_BEGIN

@interface XZSendIMMsgModel : XZCellModel
@property(nonatomic, strong)CMPOfflineContactMember *targetMember;
@property(nonatomic, strong)NSString *content;
@property(nonatomic, assign)CGSize contentSize;

@end

NS_ASSUME_NONNULL_END
