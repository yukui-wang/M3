//
//  CMPOcrItemManager.h
//  CMPCore
//
//  Created by Shoujian Rao on 2021/12/9.
//

#import <CMPLib/CMPObject.h>
#import "CMPOcrFileModel.h"
#import "CMPOcrItemModel.h"
@interface CMPOcrItemManager : CMPObject

+ (instancetype)sharedInstance;
//保存原始file到db和local文件
- (BOOL)saveFileToLocalAndDb:(CMPOcrFileModel *)obj withPackageId:(NSString *)packageId;
//开启单个任务
- (void)beginTaskWithItem:(CMPOcrItemModel *)ocrItem callBack:(void(^)(CMPOcrItemModel *item,NSError *err))callBack;
//重新上传
- (void)reUpload:(CMPOcrItemModel *)ocrItem callBack:(void(^)(NSError *err))callBack;
//重新提交任务
- (void)reSubmitTask:(CMPOcrItemModel *)ocrItem completion:(void(^)(NSError *))completion;
//重试 taskStatus=11的情况
- (void)retryTask:(CMPOcrItemModel *)ocrItem completion:(void(^)(NSError *))completion;
//重新开启识别
- (void)reCheckTask:(CMPOcrItemModel *)ocrItem completion:(void(^)(NSError *))completion;
//取消上传、停止上传
- (void)cancelUpload:(CMPOcrItemModel *)ocrItem callBack:(void(^)(void))callBack;
//删除某项(已经提交任务)
- (void)deleteOcrItem:(CMPOcrItemModel *)ocrItem callBack:(void(^)(NSError *error))callBack;

//只删除远程数据(批量)
- (void)deleteRemoteOcrItemArr:(NSArray *)ocrItemArr callBack:(void(^)(NSError *error))callBack;
//只删除本地数据(批量)
- (void)deleteLocalOcrItemArr:(NSArray *)ocrItemArr callBack:(void(^)(NSError *error))callBack;
- (NSArray<CMPOcrItemModel *> *)getAllLocalItemByPackageId:(NSString *)packageId;
@end

