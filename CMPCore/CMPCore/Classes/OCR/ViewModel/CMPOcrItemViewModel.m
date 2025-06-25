//
//  CMPOcrItemViewModel.m
//  M3
//
//  Created by Shoujian Rao on 2021/12/9.
//

#import "CMPOcrItemViewModel.h"
#import "CMPOcrCreateInvoiceDataProvider.h"
#import "CMPOcrValidateManageDataProvider.h"
#import "CMPOcrDeleteInvoiceDataProvider.h"
#import "CMPOcrItemDBManager.h"
#import <CMPLib/CMPFileManager.h>
#import <CMPLib/CMPUploadFileTool.h>
#import "CMPOcrFileModel.h"
#import <CMPLib/NSObject+CMPHUDView.h>

@interface CMPOcrItemViewModel()

@property (nonatomic, strong) CMPOcrCreateInvoiceDataProvider *createInvoiceProvider;
@property (nonatomic, strong) CMPOcrValidateManageDataProvider *checkInvoiceProvider;
@property (nonatomic, strong) CMPOcrDeleteInvoiceDataProvider *deleteInvoiceProvider;
@property (nonatomic, strong) CMPOcrItemDBManager *dbManager;

@property (nonatomic, assign) BOOL canAddItemToArray;//删除的时候不能添加识别返回的item数据


@end

@implementation CMPOcrItemViewModel

- (void)dealloc{
    NSLog(@"%@-delloc",self.class);
}

- (instancetype)init{
    if (self = [super init]) {
        self.canAddItemToArray = YES;
    }
    return self;
}

- (void)handleOcrItemCallRefresh:(void(^)(void))refreshBlock{
    if (_originalFileArray.count <= 0) {
        return;
    }
    //保存文件到本地和数据库 - 过程为同步
    [self saveFilesToLocalAndDb:_originalFileArray andPackageId:_packageId];
    //获取此时所有的本地数据
    NSArray *arr = [self getAllLocalItemByPackageId:_packageId];
    //加入到操作容器
    [self.ocrItemArray addObjectsFromArray:arr];
    //挨个上传、提交识别任务
    __weak typeof(self) weakSelf = self;
    NSMutableArray *removes = NSMutableArray.new;
    for (CMPOcrItemModel *item in self.ocrItemArray) {
        if (item.taskStatus == CMPOcrItemStateUploadSuccess) {
            [self submitTask:item completion:^(NSError *error) {
                if (error) {
                    [weakSelf cmp_showHUDWithText:[NSString stringWithFormat:@"%@提交任务失败",item.filename]];
                }else{
                    if (refreshBlock) {
                        NSLog(@"ocr-item提交任务后刷新1");
                        refreshBlock();
                    }
                }
            }];
        }else{
            if (![[NSFileManager defaultManager] fileExistsAtPath:item.filePath]) {
                [removes addObject:item];
                continue;
            }
            [self upload:item Completion:^(NSError *error) {
                if (error) {
                    NSLog(@"item-%@上传失败",item.itemid);
                    [weakSelf cmp_showHUDWithText:[NSString stringWithFormat:@"%@上传失败",item.filename]];
                }else{
                    NSLog(@"item-%@上传成功",item.itemid);
                    [weakSelf submitTask:item completion:^(NSError *error) {
                        if (refreshBlock) {
                            NSLog(@"ocr-item提交任务后刷新2");
                            refreshBlock();
                        }
                    }];
                }
            }];
        }
        
    }
    [self.ocrItemArray removeObjectsInArray:removes];//删除无效的
}

//检查识别
- (void)checkInvoiceCallRefresh:(void(^)(void))refreshBlock errorBlock:(void(^)(NSError *))errorBlock{
    __weak typeof(self) weakSelf = self;
    [self checkInvoiceWithPackageId:self.packageId successBlock:^(NSArray<CMPOcrItemModel *> *serverItemArray) {
        //和本地信息对比，做替换，识别成功的删除
        if (self.canAddItemToArray) {
            NSMutableArray *removeArray = [NSMutableArray new];
            //映射服务端的
            NSMutableDictionary *serverItemDict = [NSMutableDictionary new];
            for (CMPOcrItemModel *serverItem in serverItemArray) {
                [serverItemDict setObject:serverItem forKey:serverItem.fileId];
            }
            NSMutableArray *matchedArr = [NSMutableArray new];
            for (CMPOcrItemModel *localItem in weakSelf.ocrItemArray) {
                CMPOcrItemModel *serverItem = [serverItemDict objectForKey:localItem.fileId];
                if (serverItem) {
                    [matchedArr addObject:serverItem];
                    //如果server有和本地对应的数据
                    if (serverItem.taskStatus == CMPOcrItemStateCheckSuccess) {
                        //识别成功的需要删除
                        [removeArray addObject:localItem];
                    }else{
                        //未成功的替换
                        NSInteger idx = [weakSelf.ocrItemArray indexOfObject:localItem];
                        [weakSelf.ocrItemArray replaceObjectAtIndex:idx withObject:serverItem];
                    }
                }
            }
            [weakSelf.ocrItemArray removeObjectsInArray:removeArray];
            
            //不在本地列表，并且没有识别成功的，需要append
            [[serverItemArray mutableCopy]removeObjectsInArray:matchedArr];
            for (CMPOcrItemModel *serverItem in serverItemArray) {
                if (serverItem.taskStatus != CMPOcrItemStateCheckSuccess) {
                    [weakSelf.ocrItemArray addObject:serverItem];
                }
            }
            
            if (refreshBlock) {
                refreshBlock();
            }
        }
    } errorBlock:^(NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

//把新添加的加到本地目录和db - 全程同步
//fileArray：UIimage或者NSURL
- (void)saveFilesToLocalAndDb:(NSArray *)fileArray andPackageId:(NSString *)packageId{
    [fileArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:CMPOcrFileModel.class]) {
            CMPOcrFileModel *originalFile = obj;
            
            CMPOcrItemModel *item = [[CMPOcrItemModel alloc]init];
            item.serviceId = kCMP_ServerID;
            item.userId = CMP_USERID;
            item.packageId = packageId;
            item.fileType = originalFile.fileType;
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
                    NSLog(@"ocr-item-添加我的收藏到数据库成功");
                }else{
                    NSLog(@"ocr-item-添加我的收藏到数据库失败");
                }
            }
        }
        
    }];
}

//获取数据库本地数据
- (NSArray<CMPOcrItemModel *> *)getAllLocalItemByPackageId:(NSString *)packageId{
    NSArray *arr = [self.dbManager getAllItemWithServerId:kCMP_ServerID andUserId:CMP_USERID andPackageId:packageId];
    NSLog(@"ocr-item获取本地数据：%ld",arr.count);
    return arr;
}

//文件重复检查
- (void)fileRepeatCheck:(CMPOcrItemModel *)ocrItem completion:(void(^)(NSError *))completion{
    
}
//上传
- (void)upload:(CMPOcrItemModel *)ocrItem Completion:(void(^)(NSError *))completion{
    if (ocrItem.filePath.length <= 0) {
        return;
    }

    __weak typeof(self) weakSelf = self;
    [CMPUploadFileTool.sharedTool uploadFileWithPath:ocrItem.filePath startBlock:^(NSString * requestId) {
        ocrItem.uploadRequestId = requestId;
    } successBlock:^(NSString * fileId) {
        //上传成功后删除文件
        [CMPFileManager removeFileWithPath:ocrItem.filePath];
        NSLog(@"ocr-item上传成功");
        //并修改数据库状态
        ocrItem.fileId = fileId;
        ocrItem.filePath = @"";
        ocrItem.taskStatus = CMPOcrItemStateUploadSuccess;
        [weakSelf.dbManager updateItem:ocrItem];
        if (completion) {
            completion(nil);
        }
    } failedBlock:^(NSError * _Nonnull error) {
        NSLog(@"ocr-item上传失败%@",error);
        ocrItem.taskStatus = CMPOcrItemStateUploadError;
        [weakSelf.dbManager updateItemTaskStatus:ocrItem];
        if (completion) {
            completion(error);
        }
    }];
}

//提交任务
- (void)submitTask:(CMPOcrItemModel *)ocrItem completion:(void(^)(NSError *))completion{
    __weak typeof(self) weakSelf = self;
    //创建发票识别任务 -> [创建成功后就不需要本地记录]
    [self createInvoiceWithFileId:ocrItem.fileId
                                      packageId:self.packageId
                                   successBlock:^(NSString *taskId){
        NSLog(@"ocr-item提交任务成功");
        ocrItem.taskStatus = CMPOcrItemStateSubmitSuccess;//提交服务器成功
        [weakSelf.dbManager deleteItem:ocrItem];
        if (completion) {
            completion(nil);
        }
    } errorBlock:^(NSError *error){
        ocrItem.taskStatus = CMPOcrItemStateSubmitFail;//提交服务器失败
        [weakSelf.dbManager updateItemTaskStatus:ocrItem];
        NSLog(@"ocr-item提交任务失败");
        if (completion) {
            completion(error);
        }
    }];
}

//删除发票任务
- (void)deleteInvoice:(CMPOcrItemModel *)ocrItem completion:(void(^)(NSError *))completion{
    if (!ocrItem.invoiceId) {
        return;
    }
    [self.deleteInvoiceProvider deleteInvoiceById:ocrItem.invoiceId completion:^(NSError *error) {
        NSLog(@"ocr-item删除发票%@",error);
        if (completion) {
            completion(error);
        }
    }];
}

#pragma mark - 对外方法
- (void)reUpload:(CMPOcrItemModel *)item callRefresh:(void(^)(void))refreshBlock{
    BOOL exist = [[NSFileManager defaultManager]fileExistsAtPath:item.filePath];
    if (!exist) {
        [self.dbManager deleteItem:item];
        [self.ocrItemArray removeObject:item];
        if (refreshBlock) {
            refreshBlock();
        }
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self upload:item Completion:^(NSError *error) {
        if (error) {
            NSLog(@"ocr-item-%@重新上传失败",item.itemid);
        }else{
            NSLog(@"ocr-item-%@重新上传成功",item.itemid);
            item.taskStatus = CMPOcrItemStateUploadSuccess;
            [weakSelf.dbManager updateItem:item];
            //继续提交任务
            [weakSelf submitTask:item completion:^(NSError *error) {
                if (refreshBlock) {
                    refreshBlock();
                }
            }];
        }
    }];
}

- (void)cancelUpload:(CMPOcrItemModel *)itemModel callRefresh:(void(^)(void))refreshBlock{
    if (itemModel.uploadRequestId.length) {
        [CMPUploadFileTool.sharedTool cancelRequestById:itemModel.uploadRequestId];
        itemModel.taskStatus = CMPOcrItemStateUploadPause;
        [self.dbManager updateItemTaskStatus:itemModel];
        NSLog(@"ocr-item-已取消上传-%@",itemModel.fileId);
        if (refreshBlock) {
            refreshBlock();
        }
    }
}

- (void)reSubmit:(CMPOcrItemModel *)itemModel callRefresh:(void(^)(void))refreshBlock{
    [self submitTask:itemModel completion:^(NSError *error) {
        if (refreshBlock) {
            refreshBlock();
        }
    }];
}

- (void)deleteModel:(NSInteger)idx callRefresh:(void(^)(NSError *error))refreshBlock{
    CMPOcrItemModel *model = self.ocrItemArray[idx];
    self.canAddItemToArray = NO;
    if (model.invoiceId) {
        __weak typeof(self) weakSelf = self;
        [self deleteInvoice:model completion:^(NSError *error) {
            if (error) {
                NSLog(@"ocr-item删除失败");
                if (refreshBlock) {
                    refreshBlock(error);
                }
            }else{
                [weakSelf.ocrItemArray removeObject:model];//删除本地数据
                NSLog(@"ocr-item删除成功");
                if (refreshBlock) {
                    refreshBlock(nil);
                }
            }
            self.canAddItemToArray = YES;
        }];
    }else{
        [self.ocrItemArray removeObject:model];//直接删除本地数据
        NSLog(@"ocr-item直接删除本地成功");
        if (refreshBlock) {
            refreshBlock(nil);
        }
        self.canAddItemToArray = YES;
    }
    
}

#pragma mark - 获取数据
//票据识别
- (void)checkInvoiceWithPackageId:(NSString *)packageId successBlock:(void(^)(NSArray <CMPOcrItemModel *>*arr))successBlock errorBlock:(void(^)(NSError *error))errorBlock{
    if(packageId.length<=0)return;
    
    [self.checkInvoiceProvider requestOcrTaskWithPackageId:packageId successBlock:^(NSArray *arr) {
        NSArray *resultArr = [NSArray yy_modelArrayWithClass:CMPOcrItemModel.class json:arr];
        if (successBlock) {
            successBlock(resultArr);
        }
    } failedBlock:^(NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

//创建发票任务
- (void)createInvoiceWithFileId:(NSString *)fileId packageId:(NSString *)packageId successBlock:(void(^)(NSString *taskId))successBlock errorBlock:(void(^)(NSError *))errorBlock{
    if (!fileId.length && !packageId.length) {
        return;
    }
    [self.createInvoiceProvider requestToSubmitFileWithId:fileId
                                        andPackageId:packageId
                                        successBlock:^(NSString *taskId) {
        if (successBlock) {
            successBlock(taskId);
        }
    } failedBlock:^(NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

#pragma mark - getter
- (CMPOcrCreateInvoiceDataProvider *)createInvoiceProvider{
    if (!_createInvoiceProvider) {
        _createInvoiceProvider = [[CMPOcrCreateInvoiceDataProvider alloc]init];
    }
    return _createInvoiceProvider;
}

- (CMPOcrValidateManageDataProvider *)checkInvoiceProvider{
    if (!_checkInvoiceProvider) {
        _checkInvoiceProvider = [[CMPOcrValidateManageDataProvider alloc]init];
    }
    return _checkInvoiceProvider;
}

- (CMPOcrDeleteInvoiceDataProvider *)deleteInvoiceProvider{
    if (!_deleteInvoiceProvider) {
        _deleteInvoiceProvider = [[CMPOcrDeleteInvoiceDataProvider alloc]init];
    }
    return _deleteInvoiceProvider;
}

- (CMPOcrItemDBManager *)dbManager{
    if (!_dbManager) {
        _dbManager = [[CMPOcrItemDBManager alloc]init];
    }
    return _dbManager;
}

- (NSMutableArray *)ocrItemArray{
    if (!_ocrItemArray) {
        _ocrItemArray = [NSMutableArray new];
    }
    return _ocrItemArray;
}
@end
