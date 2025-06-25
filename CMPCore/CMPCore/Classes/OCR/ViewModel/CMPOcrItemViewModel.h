//
//  CMPOcrItemViewModel.h
//  M3
//
//  Created by Shoujian Rao on 2021/12/9.
//

#import <CMPLib/CMPBaseViewModel.h>
#import "CMPOcrItemModel.h"
@interface CMPOcrItemViewModel : CMPBaseViewModel

@property (nonatomic, strong) NSMutableArray *ocrItemArray;
@property (nonatomic, strong) NSArray *originalFileArray;
@property (nonatomic, copy) NSString *packageId;

//处理本地数据库、上传、提交识别任务
//- (void)handleOcrItemCallRefresh:(void(^)(void))refreshBlock;
//识别任务
//- (void)checkInvoiceCallRefresh:(void(^)(void))refreshBlock errorBlock:(void(^)(NSError *))errorBlock;
//
////重新上传
//- (void)reUpload:(CMPOcrItemModel *)item callRefresh:(void(^)(void))refreshBlock;
////取消上传/暂停上传
//- (void)cancelUpload:(CMPOcrItemModel *)itemModel callRefresh:(void(^)(void))refreshBlock;
////重新提交
//- (void)reSubmit:(CMPOcrItemModel *)itemModel callRefresh:(void(^)(void))refreshBlock;
//
////删除发票
//- (void)deleteModel:(NSInteger)idx callRefresh:(void(^)(NSError *error))refreshBlock;

- (void)checkInvoiceWithPackageId:(NSString *)packageId successBlock:(void(^)(NSArray <CMPOcrItemModel *>*arr))successBlock errorBlock:(void(^)(NSError *error))errorBlock;

@end

