//
//  CMPSelectMultipleDataProvider.h
//  M3
//
//  Created by Shoujian Rao on 2023/9/4.
//

#import <CMPLib/CMPDataProvider.h>


@interface CMPSelectMultipleDataProvider : CMPDataProvider

//获取全部群组-分页从1开始，固定每页20
- (void)getGroupByPageNo:(NSInteger)pageNo
              completion:(void (^)(NSArray *arr,NSError *err))completion;
//搜索群组-分页从1开始，固定每页20
- (void)searchGroupByKeyword:(NSString *)keyword pageNo:(NSInteger)pageNo
                  completion:(void (^)(NSArray *arr,NSError *err))completion;
@end

