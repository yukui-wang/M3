//
//  XZScheduleModel.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/6/6.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZScheduleModel : XZCellModel
@property(nonatomic, strong)NSString *content;
@property(nonatomic, strong)NSArray *showItems;
@property(nonatomic, copy) void (^clickBlock)(NSObject *clickedObj);
@property(nonatomic, assign)CGFloat viewHeight;
@end

NS_ASSUME_NONNULL_END



