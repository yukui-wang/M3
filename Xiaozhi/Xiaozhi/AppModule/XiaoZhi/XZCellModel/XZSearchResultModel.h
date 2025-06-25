//
//  XZSearchResultModel.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/7/4.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZSearchResultModel : XZCellModel
@property(nonatomic, strong)NSString *title;
@property(nonatomic, strong)NSArray *items;
@property(nonatomic, copy) void (^moreBtnClickAction)(XZSearchResultModel *model);
@property(nonatomic, copy) void (^clickBlock)(NSObject *clickedObj);
@property(nonatomic, copy) void (^stopSpeakBlock)(void);
@property(nonatomic, assign)BOOL showMoreBtn;
@property(nonatomic, assign)NSInteger itemHeight;
@property(nonatomic, strong)NSArray *itemHeightArray;


@end

NS_ASSUME_NONNULL_END
