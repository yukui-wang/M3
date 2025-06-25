//
//  CMPOcrItemManager.m
//  CMPCore
//
//  Created by Shoujian Rao on 2021/12/9.
//

#import "CMPOcrItemManager.h"
#import "CMPOcrItemDBManager.h"
#import <CMPLib/CMPFileManager.h>
#import "CMPOcrCreateInvoiceDataProvider.h"
#import "CMPOcrDeleteInvoiceDataProvider.h"
#import "CMPOcrValidateManageDataProvider.h"
#import <CMPLib/CMPUploadFileTool.h>
@interface CMPOcrItemManager()

//异步队列
@property (nonatomic, strong) dispatch_queue_t ocr_queue;
@property (nonatomic, strong) NSMutableArray *pendingTaskArr;//挂起的ocrItem
@property (nonatomic, strong) CMPOcrCreateInvoiceDataProvider *createInvoiceProvider;
@property (nonatomic, strong) CMPOcrDeleteInvoiceDataProvider *deleteInvoiceProvider;
@property (nonatomic, strong) CMPOcrValidateManageDataProvider *checkInvoiceProvider;
@property (nonatomic, strong) CMPOcrItemDBManager *dbManager;
@end

@implementation CMPOcrItemManager
+ (instancetype)sharedInstance{
    static CMPOcrItemManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CMPOcrItemManager alloc] init];
    });
    return instance;
}

- (instancetype)init{
    if (self = [super init]) {
        _ocr_queue = dispatch_queue_create("ocr_queue",DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

//同步保存到db和本地路径（如果是我的收藏，则只需要保存到数据库）
- (BOOL)saveFileToLocalAndDb:(CMPOcrFileModel *)obj withPackageId:(NSString *)packageId{
    CMPOcrFileModel *originalFile = obj;
    CMPOcrItemModel *item = [[CMPOcrItemModel alloc]init];
    item.serviceId = kCMP_ServerID;
    item.userId = CMP_USERID;
    item.packageId = packageId;
    item.fileType = originalFile.fileType;
    BOOL success = NO;
    if (originalFile.image) {//相册、拍照图片，均为jpg格式
        CMPFile *file = [CMPFileManager saveImageFileToLocal:originalFile.image type:originalFile.fileType];
        if (file) {
            NSLog(@"ocr-item-拷贝图片成功");
            item.fileId = file.fileID;//本地文件唯一id
            item.filePath = file.filePath;
            item.image = originalFile.image;
            item.taskStatus = CMPOcrItemStateNotUpload;
            item.filename = originalFile.originalName;
            BOOL addSuccess = [self.dbManager addItem:item];
            if (addSuccess) {
                success = YES;
                NSLog(@"ocr-item-相册、拍照图片添加到数据库成功");
            }else{
                NSLog(@"ocr-item-相册、拍照图片添加到数据库失败");
                BOOL delete = [[NSFileManager defaultManager] removeItemAtPath:file.filePath error:nil];
                NSLog(@"ocr-item-delete相册、拍照图片:%d",delete);
            }
        }else{
            NSLog(@"ocr-item-相册、拍照图片拷贝图片失败");
        }
    }else if (originalFile.localUrl.length>0){//手机文件（pdf和图片）
        CMPFile *file = [CMPFileManager copyFileToLocal:originalFile.localUrl type:originalFile.fileType];
        if (file) {
            NSLog(@"ocr-item-拷贝手机文件成功");
            item.fileId = file.fileID;
            item.filePath = file.filePath;//Documents/File/Localfile/17F86884-9786-4226-920B-7D9CE8A90557.jpg
            item.filename = originalFile.localUrl.lastPathComponent;
            item.taskStatus = CMPOcrItemStateNotUpload;
            BOOL addSuccess = [self.dbManager addItem:item];
            if (addSuccess) {
                success = YES;
                NSLog(@"ocr-item-添加手机文件到数据库成功");
            }else{
                NSLog(@"ocr-item-添加手机文件到数据库失败");
                BOOL delete = [[NSFileManager defaultManager] removeItemAtPath:file.filePath error:nil];
                NSLog(@"ocr-item-delete手机文件:%d",delete);
            }
        }else{
            NSLog(@"ocr-item-拷贝手机文件失败");
        }
    }else if (originalFile.fileId.length){//我的收藏
        item.fileId = originalFile.fileId;//jpeg、jpg、png、pdf 有fileId
        item.filename = originalFile.originalName;
        item.taskStatus = CMPOcrItemStateUploadSuccess;
        BOOL addSuccess = [self.dbManager addItem:item];
        if (addSuccess) {
            success = YES;
            NSLog(@"ocr-item-添加我的收藏到数据库成功");
        }else{
            NSLog(@"ocr-item-添加我的收藏到数据库失败");
        }
    }
    return success;
}

//获取数据库本地数据
- (NSArray<CMPOcrItemModel *> *)getAllLocalItemByPackageId:(NSString *)packageId{
    NSArray *arr = [self.dbManager getAllItemWithServerId:kCMP_ServerID andUserId:CMP_USERID andPackageId:packageId];
    NSLog(@"ocr-item获取本地数据：%ld",arr.count);
    return arr;
}

//开启单个任务
- (void)beginTaskWithItem:(CMPOcrItemModel *)ocrItem callBack:(void(^)(CMPOcrItemModel *item,NSError *err))callBack{
    BOOL isPending = NO;
    for (CMPOcrItemModel *pendingItem in self.pendingTaskArr) {
        if ([ocrItem.fileId isEqual:pendingItem.fileId]) {
            isPending = YES;
            break;
        }
    }
    if (!isPending) {
        [self.pendingTaskArr addObject:ocrItem];
        dispatch_async(_ocr_queue, ^{//后端执行
            [self executeTask:ocrItem callBack:^(NSError *err) {
                [self.pendingTaskArr removeObject:ocrItem];
                if (callBack) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        callBack(ocrItem,err);
                    });
                }
            }];
        });
    }
    
}
//执行任务
- (void)executeTask:(CMPOcrItemModel *)ocrItem callBack:(void(^)(NSError *err))callBack{
    NSLog(@"ocr-item-executeTask-%@",ocrItem.fileId);
    if (ocrItem.taskStatus == CMPOcrItemStateUploadSuccess) {
        //提交任务
        [self submitTask:ocrItem completion:^(NSError *error) {
            if (callBack) {
                callBack(error);
            }
        }];
    }else{
        //上传
        [self upload:ocrItem Completion:^(NSError *error) {
            if (!error) {
                //提交任务
                [self submitTask:ocrItem completion:^(NSError *error) {
                    if (callBack) {
                        callBack(error);
                    }
                }];
            }else{
                if (callBack) {
                    callBack(error);
                }
            }
        }];
    }
}
//提交任务
- (void)submitTask:(CMPOcrItemModel *)ocrItem completion:(void(^)(NSError *))completion{
    
    __weak typeof(self) weakSelf = self;
    [self.createInvoiceProvider requestToSubmitFileWithId:ocrItem.fileId
                                        andPackageId:ocrItem.packageId
                                        successBlock:^(NSString *taskId) {
        NSLog(@"ocr-item-submitTask成功-%@",ocrItem.fileId);
        ocrItem.taskStatus = CMPOcrItemStateSubmitSuccess;//提交服务器成功
        ocrItem.taskId = taskId;
        [weakSelf.dbManager deleteItem:ocrItem];
        if (completion) {
            completion(nil);
        }
    } failedBlock:^(NSError *error) {
        NSLog(@"ocr-item-submitTask失败-%@",ocrItem.fileId);
        ocrItem.taskStatus = CMPOcrItemStateSubmitFail;//提交服务器失败
        [weakSelf.dbManager updateItemTaskStatus:ocrItem];
        if (completion) {
            completion(error);
        }
    }];
}
//上传
- (void)upload:(CMPOcrItemModel *)ocrItem Completion:(void(^)(NSError *))completion{
    if (ocrItem.filePath.length <= 0) {
        [self.dbManager deleteItem:ocrItem];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [CMPUploadFileTool.sharedTool uploadFileWithPath:ocrItem.filePath startBlock:^(NSString * requestId) {
        ocrItem.uploadRequestId = requestId;
    } successBlock:^(NSString * fileId) {
        if (fileId.length>0) {
            //上传成功后删除文件
            [CMPFileManager removeFileWithPath:ocrItem.filePath];
            NSLog(@"ocr-item-upload成功-%@",ocrItem.fileId);
            //并修改数据库状态
            ocrItem.fileId = fileId;
            ocrItem.filePath = @"";
            ocrItem.taskStatus = CMPOcrItemStateUploadSuccess;
            [weakSelf.dbManager updateItem:ocrItem];
            if (completion) {
                completion(nil);
            }
        }else{
            ocrItem.taskStatus = CMPOcrItemStateUploadError;
            [weakSelf.dbManager updateItemTaskStatus:ocrItem];
            NSError *error = [NSError errorWithDomain:@"上传文件失败" code:1 userInfo:@{@"message":@"上传文件失败"}];
            if (completion) {
                completion(error);
            }
        }
    } failedBlock:^(NSError * _Nonnull error) {
        NSLog(@"ocr-item-upload失败-%@",ocrItem.fileId);
        ocrItem.taskStatus = CMPOcrItemStateUploadError;
        [weakSelf.dbManager updateItemTaskStatus:ocrItem];
        if (completion) {
            completion(error);
        }
    }];
}
//重新上传
- (void)reUpload:(CMPOcrItemModel *)ocrItem callBack:(void(^)(NSError *err))callBack{
    [self upload:ocrItem Completion:^(NSError *error) {
        if (!error) {
            //提交任务
            [self submitTask:ocrItem completion:^(NSError *error) {
                if (callBack) {
                    callBack(error);
                }
            }];
        }else{
            if (callBack) {
                callBack(error);
            }
        }
    }];
}
//重新提交
- (void)reSubmitTask:(CMPOcrItemModel *)ocrItem completion:(void(^)(NSError *))completion{
    __weak typeof(self) weakSelf = self;
    [self.createInvoiceProvider requestToSubmitFileWithId:ocrItem.fileId
                                        andPackageId:ocrItem.packageId
                                        successBlock:^(NSString *taskId) {
        NSLog(@"ocr-item提交任务成功");
        ocrItem.taskStatus = CMPOcrItemStateSubmitSuccess;//提交服务器成功
        ocrItem.taskId = taskId;
        [weakSelf.dbManager deleteItem:ocrItem];
        if (completion) {
            completion(nil);
        }
    } failedBlock:^(NSError *error) {
        NSLog(@"ocr-item提交任务失败");
        ocrItem.taskStatus = CMPOcrItemStateSubmitFail;//提交服务器失败
        [weakSelf.dbManager updateItemTaskStatus:ocrItem];
        if (completion) {
            completion(error);
        }
    }];
}
//重试
- (void)retryTask:(CMPOcrItemModel *)ocrItem completion:(void(^)(NSError *))completion{
    [self.createInvoiceProvider retryToSubmitWithId:ocrItem.ID
                                        successBlock:^(NSString *taskId) {
        ocrItem.taskStatus = CMPOcrItemStateCheckProcessing;//提交服务器成功
        if (completion) {
            completion(nil);
        }
    } failedBlock:^(NSError *error) {
        ocrItem.taskStatus = CMPOcrItemStateCheckProcessing;//提交服务器失败
        if (completion) {
            completion(error);
        }
    }];
}

//重新发起识别
- (void)reCheckTask:(CMPOcrItemModel *)ocrItem completion:(void (^)(NSError *))completion{
    [self retryTask:ocrItem completion:completion];//ks fix -- 后端人员说换成这个接口
//    [self.deleteInvoiceProvider updateTaskStatusByTaskId:ocrItem.taskId taskStatus:@(ocrItem.taskStatus) completion:^(NSError *error) {
//        if (completion) {
//            completion(error);
//        }
//    }];
}
//取消上传
- (void)cancelUpload:(CMPOcrItemModel *)ocrItem callBack:(void(^)(void))callBack{
    if (ocrItem.uploadRequestId.length) {
        [CMPUploadFileTool.sharedTool cancelRequestById:ocrItem.uploadRequestId];
        ocrItem.taskStatus = CMPOcrItemStateUploadPause;
        [self.dbManager updateItemTaskStatus:ocrItem];
        NSLog(@"ocr-item-已取消上传-%@",ocrItem.fileId);
        if (callBack) {
            callBack();
        }
    }
}
//删除
- (void)deleteOcrItem:(CMPOcrItemModel *)ocrItem callBack:(void(^)(NSError *error))callBack{
    if (ocrItem.invoiceId) {
        [self.deleteInvoiceProvider deleteInvoiceById:ocrItem.invoiceId completion:^(NSError *error) {
            if (callBack) {
                callBack(error);
            }
        }];
    }else{
        [self.dbManager deleteItem:ocrItem];
        NSError *err;
        if ([[NSFileManager defaultManager] fileExistsAtPath:ocrItem.filePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:ocrItem.filePath error:&err];
        }
        if (callBack) {
            callBack(nil);
        }
    }
}

- (void)deleteRemoteOcrItemArr:(NSArray *)ocrItemArr callBack:(void(^)(NSError *error))callBack{
    NSMutableArray *invoiceIdArr = [NSMutableArray new];
    for (CMPOcrItemModel *item in ocrItemArr) {
        if (item.invoiceId) {
            [invoiceIdArr addObject:item.invoiceId];
        }
    }
    if (invoiceIdArr.count) {
        [self.deleteInvoiceProvider deleteInvoiceByIdArr:invoiceIdArr completion:^(NSError *error) {
            if (callBack) {
                callBack(error);
            }
        }];
    }
}

- (void)deleteLocalOcrItemArr:(NSArray *)ocrItemArr callBack:(void(^)(NSError *error))callBack{
    for (CMPOcrItemModel *item in ocrItemArr) {
        [self.dbManager deleteItem:item];
        [[NSFileManager defaultManager] removeItemAtPath:item.filePath error:nil];
    }
}

#pragma mark - lazy
- (CMPOcrItemDBManager *)dbManager{
    if (!_dbManager) {
        _dbManager = [[CMPOcrItemDBManager alloc]init];
    }
    return _dbManager;
}
- (CMPOcrCreateInvoiceDataProvider *)createInvoiceProvider{
    if (!_createInvoiceProvider) {
        _createInvoiceProvider = [[CMPOcrCreateInvoiceDataProvider alloc]init];
    }
    return _createInvoiceProvider;
}
- (CMPOcrDeleteInvoiceDataProvider *)deleteInvoiceProvider{
    if (!_deleteInvoiceProvider) {
        _deleteInvoiceProvider = [[CMPOcrDeleteInvoiceDataProvider alloc]init];
    }
    return _deleteInvoiceProvider;
}
- (CMPOcrValidateManageDataProvider *)checkInvoiceProvider{
    if (!_checkInvoiceProvider) {
        _checkInvoiceProvider = [[CMPOcrValidateManageDataProvider alloc]init];
    }
    return _checkInvoiceProvider;
}
 - (NSMutableArray *)pendingTaskArr{
    if(!_pendingTaskArr){
        _pendingTaskArr = [NSMutableArray new];
    }
    return _pendingTaskArr;
}

@end
