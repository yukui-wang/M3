//
//  CMPPicListViewController.h
//  CMPLib
//
//  Created by MacBook on 2019/12/17.
//  Copyright © 2019 crmo. All rights reserved.
//

#import <CMPLib/CMPBannerViewController.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPPicListViewController : CMPBannerViewController

/* 是否允许保存 */
@property (assign, nonatomic) BOOL canSave;
/* dataArray */
@property (copy, nonatomic) NSMutableArray *dataArray;
/* originalDataArray */
@property (copy, nonatomic) NSMutableArray *originalDataArray;
/* 融云消息数组 */
@property (copy, nonatomic) NSMutableArray *rcImgModels;

+ (NSArray *)groupDataArray:(NSArray *)dataSourceArray;

@end

NS_ASSUME_NONNULL_END
