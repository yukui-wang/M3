//
//  CMPCheckUpdate2Manager.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2024/1/4.
//

#import "CMPCheckUpdate2Manager.h"
#import "CMPCheckUpdateManager.h"
#import "CMPH5AppDownloadOperation.h"
#import <CMPLib/CMPAppManager.h>
#import <CMPLib/NSObject+CMPHUDView.h>
#import <CMPLib/CMPCommonTool.h>
#import "AppDelegate.h"
#import <CMPLib/CMPCustomAlertView.h>
#import "CMPCommonManager.h"

@interface CMPCheckUpdate2Manager()<CMPCheckUpdateManagerDelegate>
@property (nonatomic, strong) NSOperationQueue *downloadOperationQueue;
@property (strong, nonatomic) NSOperationQueue *handleH5AppOperationQueue;
@property (nonatomic, strong) NSArray *downloadAppList; // 需要下的zip包列表
@property (nonatomic, weak) CMPCheckUpdateManager *baseManager;
@property (nonatomic, assign) NSInteger downloadedCount;
@property (nonatomic, assign) BOOL firstDownloadApp;
@property (assign, nonatomic) BOOL restartApping;//正在重启中，重启中不发弹框消息
@property (nonatomic,strong) NSMutableArray *appUpdateIdList;
@property (nonatomic, strong) __block NSArray *downloadErrAppList;
/**
 1.开始。
 2.下载（21下载成功 22下载失败）（221下载失败已弹框。222下载失败未弹框）
 3.解压 （31解压成功 32解压失败）（321解压失败已弹框。322解压失败未弹框）
 4.合并（41合并成功 42合并失败）（421合并失败已弹框。422合并失败未弹框）
 5.更新（51更新成功 52更新失败）（521更新失败已弹框。522更新失败未弹框）
 6.网络变化（61 wifi变4g 62无网络）（611已弹框，612未弹框。621已弹框 622未弹框）
 */
@property (nonatomic,assign) __block NSInteger step;
@property (nonatomic, copy) void(^h5AppCheckCompletionBlock)(BOOL success);

@end

@implementation CMPCheckUpdate2Manager

static CMPCheckUpdate2Manager *checkUpdate2ManagerInstance = nil;

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (CMPCheckUpdate2Manager *)sharedManager {
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        checkUpdate2ManagerInstance = [[self alloc] init];
    });
    return checkUpdate2ManagerInstance;
}

-(instancetype)init{
    self = [super init];
    if (self){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_startViewDidClosed) name:@"kNotificationName_startViewDidClosed" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_startViewDidClosed) name:kNotificationName_GestureWillHiden object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_otherControllerViewDidAppear:) name:@"kNotificationName_viewDidAppear" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_logout) name:kNotificationName_UserLogout object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_startViewDidClosed) name:kNotificationName_HideGuidePagesView object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_progressViewDidTap:) name:@"kNotificationName_progressViewDidTap" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_padTabbarDidSelect:) name:@"kNotificationName_padTabbarDidSelect" object:nil];
    }
    return self;
}

-(void)_reset{
    _baseManager = nil;
    _downloadAppList = nil;
    _downloadedCount = 0;
    _appUpdateIdList = nil;
    _downloadErrAppList = nil;
    _step = 0;
}

-(BOOL)checkUpdateManager:(CMPCheckUpdateManager *)manager startCheckUpdate:(void (^)(BOOL))completionBlock ext:(id)ext
{
    _step = 1;
    _baseManager = manager;
    
    //查询本地数据库applist是否为空，空是第一次 reture yes，非空执行后续新操作
    //非空 检查本地是否有上一次的新应用更新
    //没有 reture yes
    //有 reture no，解压更新数据安装(上次用户选择了下次更新)，然后再次调用startCheckUpdate
    [self setFirstDownloadApp:![CMPCheckUpdateManager sharedManager].firstDownloadDone];
    if (_firstDownloadApp) return YES;
    if ([CMPCheckUpdate2Manager _unzipsNames].count<=0) return YES;
    
    //todo此处应该是本地是全亮下载的才解压 不然如果上次中间下载失败了杀掉进程，此处解压 会出现本地版本不一致问题，而且还允许正常操作
    BOOL finish = [self _localTagForIfDownloadFinish];
    if (!finish) return YES;
    
    NSArray *errList = [self _unZipAndUpdateDb];
    if (errList && errList.count) {
        if (completionBlock) completionBlock(YES);
       //解压出错,弹提示
    }else{
        [self handleSuccess];
        [CMPAppManager startMerge];
        if (completionBlock) {
            completionBlock(YES);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[CMPCheckUpdateManager sharedManager] startCheckUpdate:nil];
            });
        }else{
            [self reStartApp:^(NSError *error) {
                if (!error) {//继续新一轮的检查更新
                    [self notifyStatus:@{@"state":@"success",@"value":@"restart"}];//通知成功
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [[CMPCheckUpdateManager sharedManager] startCheckUpdate:nil];
                    });
                }else{
                    //重启报错
                }
            }];
        }
    }
    return NO;
}

-(BOOL)checkUpdateManager:(CMPCheckUpdateManager *)manager preHandleDownloadApplist:(NSArray *)applist ext:(id)ext{
    if (_firstDownloadApp) return YES;
    if (applist.count == 0) {
        [self handleSuccess];
        return NO;
    }
    NSMutableArray *aDownloadList = [[NSMutableArray alloc] init];
    // 判断出需要下载的zip
    for (NSDictionary *aItem in applist) {
        BOOL isUpdate = [[aItem objectForKey:@"isUpdate"] boolValue];
        if (isUpdate) {
            [aDownloadList addObject:aItem];
        }
    }

    if (aDownloadList.count > 0) {
        if ([CMPCommonManager networkReachabilityStatus] == AFNetworkReachabilityStatusReachableViaWiFi || manager.ignoreNetworkStatus) {
            [self downloadWithList:aDownloadList];
        }
        else {
            _step = 61;
            [self _cancelDownload];
            if([self _nowCanShowAlert:nil]){
                _step = 611;
                [self _showAlertWithTitle:nil message:SY_STRING(@"UpdatePackage_TipNotWifi") cancel:nil others:@[SY_STRING(@"UpdatePackage_Download"),_firstDownloadApp?SY_STRING(@"UpdatePackage_CloseApp"):SY_STRING(@"common_cancel")] handler:^(NSInteger buttonIndex, id  _Nullable value) {
                    if (buttonIndex == 1) {
                        _baseManager.ignoreNetworkStatus = YES;
                        [[CMPCheckUpdateManager sharedManager] startCheckUpdate:nil];
                    }else if (buttonIndex == 2){
                        if (_firstDownloadApp){
                            exit(0);
                        }
                    }
                }];
            }else{
                _step = 612;
            }
        }
    } else {
        [self handleSuccess];
    }
    return NO;
}

-(BOOL)checkUpdateManager:(CMPCheckUpdateManager *)manager startDownloadApplist:(NSArray *)applist ext:(id)ext{
    if (_firstDownloadApp) return YES;
    [self _reset];
    
    _baseManager = manager;

    [self downloadWithList:applist];//多线程下载
    return NO;
}

-(BOOL)checkUpdateManager:(CMPCheckUpdateManager *)manager canShowApp:(id)ext{
    if (_firstDownloadApp && manager.state != CMPCheckUpdateManagerSuccess){
        return NO;
    }
    return YES;
}

- (void)downloadWithList:(NSArray *)appList{
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        _downloadAppList = nil;
        _downloadedCount = 0;
        _downloadErrAppList = nil;
        _baseManager.infoModel.downloadErrString = nil;
        
        [self.downloadOperationQueue cancelAllOperations];
        if (!appList || appList.count ==0) {
            [self handleSuccess];
            return;
        }
        //todo 检查一下本地有没有，有就过滤掉
        NSMutableArray *_temp = [NSMutableArray array];
        NSArray *localUnzipNames = [CMPCheckUpdate2Manager _unzipsNames];
        if (localUnzipNames.count) {
            for (NSDictionary *app in appList) {
                NSString *md5 = app[@"md5"];
                if (![localUnzipNames containsObject:[md5 stringByAppendingString:@".zip"]]) {
                    [_temp addObject:app];
                }
            }
        }else{
            [_temp addObjectsFromArray:appList];
        }
        //end
        _downloadAppList = [NSArray arrayWithArray:_temp];
        if (_downloadAppList.count==0) {
            [self handleSuccess];
            return;
        }
        _step = 2;
        if (!_appUpdateIdList) _appUpdateIdList = [NSMutableArray array];
        for (NSDictionary *app in _downloadAppList) {
            NSString *appId = [app objectForKey:@"appId"];
            if(appId.length){
                [_appUpdateIdList addObject:appId];
            }
        }
        [self _localTagToUpdateState:@"0"];
        _baseManager.state = CMPCheckUpdateManagerDownload;
        [self notifyStatus:@{
            @"state":@"progress",
            @"value":@(0.01),
        }];
        [self notifyStatus:@{@"state":@"start",@"value":SY_STRING(@"UpdatePakageNew_applicationing")}];
        NSLog(@"h5zip-startDownload:%@",_downloadAppList);
        __block NSMutableArray *errArr = [NSMutableArray new];
        
        for (NSDictionary *app in _downloadAppList) {
            CMPH5AppDownloadOperation *op = [[CMPH5AppDownloadOperation alloc] initWithApp:app downloadSession:nil completion:^(id  _Nonnull respData, NSError * _Nonnull error) {
                weakSelf.downloadedCount++;//下载完成+1
                NSLog(@"h5zip-下载完成数:%ld/%ld",weakSelf.downloadedCount,_downloadAppList.count);
                [weakSelf notifyProgress];//更新下载进度
                //测试数据begin
//                if(errArr.count<2){
//                    [errArr addObject:app];
//                }
                //测试数据end
                if(error){
                    [app setValue:error forKey:@"error"];
                    [errArr addObject:app];
                }
            }];
            [self.downloadOperationQueue addOperation:op];
        }
        
        [self.downloadOperationQueue waitUntilAllOperationsAreFinished];
        NSLog(@"h5zip-所有下载完成");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(errArr.count){//提示错误
                [self _localTagToUpdateState:@"2"];
                weakSelf.downloadErrAppList = [NSArray arrayWithArray:errArr];
                NSLog(@"h5-zip-下载完成后错误：%@",errArr);
                weakSelf.baseManager.state = CMPCheckUpdateManagerFail;
                [self notifyStatus:@{@"state":@"fail",@"value":@"download"}];
                
                //出错信息
                NSMutableArray *appIdArr = [NSMutableArray new];
                for (NSDictionary *app in errArr) {
                    NSString *appId = app[@"appId"];
                    if (appId) {
                        [appIdArr addObject:appId];
                    }
                }
                NSString *errString =[[appIdArr.firstObject stringByAppendingString:@".zip"] stringByAppendingString: SY_STRING(@"UpdatePakageNew_downloadFail")];
                weakSelf.baseManager.infoModel.downloadErrString = errString;
                if (_step == 621) return;
                _step = 22;
                if([weakSelf _nowCanShowAlert:nil]){
                    [weakSelf _showFailAlert];
                }else{
                    _step = 222;
                }
                
            }else{
                [self _localTagToUpdateState:@"1"];
                _step = 21;
                weakSelf.baseManager.infoModel.downloadErrString = nil;
                
                [self notifyStatus:@{@"state":@"success",@"value":@"download"}];
                //如果是第一次进入app，则自动去reStart
                if(_firstDownloadApp){
                    [weakSelf _unzipAndRestart];
                }else{
                    if([weakSelf _nowCanShowAlert:nil]){
                        [weakSelf _showSuccessAlert];
                    }else{
                        _step = 212;
                    }
                }
            }
        });
    });
}

-(BOOL)checkUpdateManager:(CMPCheckUpdateManager *)manager cancelDownload:(id)ext{
    if (_firstDownloadApp) return YES;
    if (manager.state == CMPCheckUpdateManagerCheck ||
        manager.state == CMPCheckUpdateManagerDownload) {
        [self _cancelDownload];
    }
    return NO;
}


-(BOOL)checkUpdateManager:(CMPCheckUpdateManager *)manager networkChanged:(id)ext{
    if (_firstDownloadApp) return YES;
    if (manager.state != CMPCheckUpdateManagerDownload) {
        return NO;
    }
    
    if (![CMPCommonManager reachableServer]) {
       //todo 暂时通过下载逻辑处理 不单独处理了
        if (_step == 211 || _step == 221) return NO;
        _step = 62;
        [self _cancelDownload];
        if ([self _nowCanShowAlert:nil]){
            _step = 621;
            [self _showAlertWithTitle:nil message:SY_STRING(@"Common_Network_Unavailable") cancel:_firstDownloadApp?nil:SY_STRING(@"UpdatePakageNew_downloadNext") others:@[SY_STRING(@"UpdatePakageNew_reDownload")] handler:^(NSInteger buttonIndex, id  _Nullable value) {
                _step = 0;
                if (buttonIndex == 1){
                    [[CMPCheckUpdateManager sharedManager] startCheckUpdate:nil];
                }
                [self _errAlertDidClick:buttonIndex];
            }];
        }else{
            _step = 622;
        }
        return NO;
    }
    
    // 如果切换到4g，弹出提示
    NSInteger value = [CMPCommonManager networkReachabilityStatus];
    if (value == AFNetworkReachabilityStatusReachableViaWWAN && !_baseManager.ignoreNetworkStatus) {
        _step = 61;
        [self _cancelDownload];
        if([self _nowCanShowAlert:nil]){
            _step = 611;
            [self _showAlertWithTitle:nil message:SY_STRING(@"UpdatePackage_TipNotWifi") cancel:nil others:@[SY_STRING(@"UpdatePackage_Download"),_firstDownloadApp?SY_STRING(@"UpdatePackage_CloseApp"):SY_STRING(@"common_cancel")] handler:^(NSInteger buttonIndex, id  _Nullable value) {
                if (buttonIndex == 1) {
                    _baseManager.ignoreNetworkStatus = YES;
                    [[CMPCheckUpdateManager sharedManager] startCheckUpdate:nil];
                }else if (buttonIndex == 2){
                    if (_firstDownloadApp){
                        exit(0);
                    }
                }
            }];
        }else{
            _step = 612;
        }
    }else if (value == AFNetworkReachabilityStatusReachableViaWiFi && _baseManager.state == CMPCheckUpdateManagerCancel){
        [[CMPCheckUpdateManager sharedManager] startCheckUpdate:nil];
    }
    return NO;
}

-(BOOL)checkUpdateManager:(CMPCheckUpdateManager *)manager isFirstDownload:(id)ext{
    return _firstDownloadApp;
}

//-(BOOL)checkUpdateManager:(CMPCheckUpdateManager *)manager showAlertViewForWWAN:(id)ext{
//    _step = 61;
//    [self _cancelDownload];
//    if([self _nowCanShowAlert:nil]){
//        _step = 611;
//        [self _showAlertWithTitle:nil message:SY_STRING(@"UpdatePackage_TipNotWifi") cancel:nil others:@[SY_STRING(@"UpdatePackage_Download"),_firstDownloadApp?SY_STRING(@"UpdatePackage_CloseApp"):SY_STRING(@"common_cancel")] handler:^(NSInteger buttonIndex, id  _Nullable value) {
//            if (buttonIndex == 1) {
//                _baseManager.ignoreNetworkStatus = YES;
//                [[CMPCheckUpdateManager sharedManager] startCheckUpdate:nil];
//            }else if (buttonIndex == 2){
//                if (_firstDownloadApp){
//                    exit(0);
//                }
//            }
//        }];
//    }
//}

-(void)_logout{
    [self _cancelDownload];
    [self _reset];
}

-(void)_cancelDownload{
    NSLog(@"update---取消下载应用包，CMPCheckUpdateManagerInit");
    if (_baseManager.state != CMPCheckUpdateManagerDownload
        ||_baseManager.state == CMPCheckUpdateManagerSuccess) {
        return;
    }
    _baseManager.state = CMPCheckUpdateManagerCancel;

    if (self.downloadOperationQueue.operations) {
        for (CMPH5AppDownloadOperation *op in self.downloadOperationQueue.operations) {
            [op cancel];
        }
    }
    [self.downloadOperationQueue cancelAllOperations];
    [self.handleH5AppOperationQueue cancelAllOperations];
    NSDictionary *aValue = [NSDictionary dictionaryWithObjectsAndKeys:@"cancel", @"state", nil];
    [self notifyStatus:aValue];
}

- (void)notifyStatus:(NSDictionary *)aValue{
    [self dispatchAsyncToMain:^{
        NSLog(@"checkmanager send noti value:%@",aValue);
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_AppsDownload object:aValue];
    }];
}

-(void)_unzipAndRestart{
    [self dispatchAsyncToMain:^{
        [self cmp_showProgressHUDWithText:SY_STRING(@"UpdatePakageNew_zipupdating")];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSArray *errList = [self _unZipAndUpdateDb];
            if (errList && errList.count) {
               //解压出错,弹提示
            }else{
                [self handleSuccess];
                [self reStartApp:^(NSError *error) {
                    if (!error) {//继续新一轮的检查更新
                        [self notifyStatus:@{@"state":@"success",@"value":@"restart"}];//通知成功
    //                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //                            [[CMPCheckUpdateManager sharedManager] startCheckUpdate:nil];
    //                        });
                    }else{
                        //重启报错
                    }
                }];
                [self cmp_hideProgressHUD];
            }
        });
    }];
}

- (void)notifyProgress{
    CGFloat progess = self.downloadedCount*1.0 / self.downloadAppList.count;
    progess = progess>1?1.0:progess;//确保不会大于1
    NSLog(@"downloaded:%ld,downloadlist:%ld",self.downloadedCount,self.downloadAppList.count);
    NSLog(@"h5zip-notifyProgress:%f",progess);
    [self notifyStatus:@{
        @"state":@"progress",
        @"value":[NSNumber numberWithFloat:progess],
    }];
    self.baseManager.infoModel.currentProgress = progess;
}

+(NSArray *)_unzipsNames{
    NSError *error;
    NSArray *downloadH5ZipNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[CMPAppManager cmpH5ZipDownloadPath] error:&error];
    return downloadH5ZipNames;
}


- (BOOL)successUnZip{
    NSLog(@"h5zip-开始解压");
    NSArray *errorList = [self _unZipAndUpdateDb];
    if(errorList.count){
        NSLog(@"h5zip-reStartApp-error:%@",errorList);
        //解压出错
        self.baseManager.state = CMPCheckUpdateManagerUnzipFail;
        [self notifyStatus:nil];
        
        //解析appId
        NSMutableDictionary *dic = [NSMutableDictionary new];
        for (NSDictionary *app in self.downloadAppList) {
            NSString *md5 = app[@"md5"];
            NSString *appId = app[@"appId"];
            if(md5.length && appId.length){
                [dic setValue:appId forKey:md5];
            }
        }
        NSMutableArray *appIdArr = [NSMutableArray new];
        for (NSDictionary *d in errorList) {
            NSString *md5 = d[@"md5"];
            if (md5.length) {
                NSString *appId = [dic objectForKey:md5];
                if(appId.length){
                    [appIdArr addObject:appId];
                }
            }
        }
                
        NSString *errString = [@"解压出错文件：" stringByAppendingString:[appIdArr componentsJoinedByString:@","]];
        self.baseManager.infoModel.unzipErrString = errString;
        return NO;
    }
    NSLog(@"h5zip-解压结束");
    self.baseManager.state = CMPCheckUpdateManagerUnzipSuccess;
    self.baseManager.infoModel.unzipErrString = nil;
    return YES;
}

//解压、存库,返回解压错误的list
- (NSArray *)_unZipAndUpdateDb{
    _step = 3;
    //0.整个备份之前的包
    
    //1.解压后拷贝到指定目录
    NSError *error;
    NSArray *downloadH5ZipNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[CMPAppManager cmpH5ZipDownloadPath] error:&error];
    NSMutableArray *h5ZipErrorList = [NSMutableArray new];
    if(downloadH5ZipNames.count){
        for (NSString *h5Zip in downloadH5ZipNames) {
            NSString *zipPath = [[CMPAppManager cmpH5ZipDownloadPath] stringByAppendingPathComponent:h5Zip];
            NSString *md5 = [h5Zip stringByDeletingPathExtension];
            //解压、存库
            [self handleH5AppWithPath:zipPath md5:md5 errorList:h5ZipErrorList];
        }
        [self.handleH5AppOperationQueue waitUntilAllOperationsAreFinished];//全部解压完成后进行下一步操作
        
        //解压完成
        if(h5ZipErrorList.count){
            _step = 32;
            return h5ZipErrorList;
        }else{
            //解压完成后删除对应目录的包
            NSError *removeError;
            BOOL success = [[NSFileManager defaultManager] removeItemAtPath:[CMPAppManager cmpH5ZipDownloadPath] error:&removeError];
            if(!success){
                NSLog(@"h5zip-删除zip包目录失败:%@",removeError);
            }
        }
    }
    _step = 31;
    return nil;
}

//多线程，解压&&存包
- (void)handleH5AppWithPath:(NSString *)aZipAppPath md5:(NSString *)md5 errorList:(NSMutableArray *)errorList
{
    if ([NSString isNull:aZipAppPath]) {
        return;
    }
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
//        NSLog(@"op-unzip-currentThread=%@",[NSThread currentThread]);
        //解压包+存数据库
        NSError *aError = [CMPAppManager storeAppWithZipPath:aZipAppPath md5:md5 restAppsMap:NO];
        if(aError){
            [errorList addObject:@{
                @"md5":md5,
                @"error":aError
            }];
        }else{
            [[NSFileManager defaultManager] removeItemAtPath:aZipAppPath error:nil];
        }
        //测试数据begin
//        if(errorList.count<5){
//            [errorList addObject:@{@"md5":md5}];
//        }
        //测试数据end
    }];
    
    [self.handleH5AppOperationQueue addOperation:operation];
}

- (void)reStartApp:(void(^)(NSError *error))completion{
    _step = 5;
    NSLog(@"h5zip-reStartApp");

    self.restartApping = YES;
    NSLog(@"h5zip-restart-begin");
    dispatch_async(dispatch_get_main_queue(), ^{

        if ([AppDelegate shareAppDelegate].tabBarViewController && [CMPCore sharedInstance].jsessionId) {
            [[AppDelegate shareAppDelegate] reloadApp];
            if (completion) completion(nil);
            NSLog(@"h5zip-restart-success");
        }else{
            if (completion) completion([NSError errorWithDomain:@"user not login" code:-1002 userInfo:nil]);
            NSLog(@"h5zip-restart-err:user not login");
        }
        
        _step = 51;
        NSLog(@"h5zip-restart-end");
        
        self.restartApping = NO;
    });
}

- (void)handleSuccess{
    NSLog(@"h5zip-handleSuccess");
//    if (self.baseManager.state == CMPCheckUpdateManagerSuccess) {
//        return;
//    }
    _step = 4;
    NSLog(@"h5zip-handleSuccess重置h5");
    //重置h5 app数据
    [CMPAppManager resetAppsMap];
    if (self.downloadAppList.count > 0) {
        // 如果有H5应用更新，就需要合并文件
        [CMPAppManager startMerge];
    }
    _step = 41;
    NSLog(@"h5zip-update---应用包更新成功，CMPCheckUpdateManagerSuccess");
    self.baseManager.state = CMPCheckUpdateManagerSuccess;
    [self notifyStatus:@{@"state":@"success",@"value":@"merge"}];//通知成功
    
    //清理数据
    [self _reset];
}


//检测资源url是否正在下载中
- (BOOL)checkUpdateManager:(CMPCheckUpdateManager *)manager checkUrlState:(NSURL *)url ext:(id)ext{
    if(self.baseManager.state != CMPCheckUpdateManagerSuccess){
        NSString *urlStr = url.absoluteString;
        if ([urlStr containsString:@"http://cmp"]
            ||[urlStr containsString:@"https://cmp"]
            ||[urlStr containsString:@"seeyonbase.v5.cmp"]
            ||([urlStr containsString:@"http://"] && [urlStr containsString:@".cmp"])
            ||([urlStr containsString:@"https://"] && [urlStr containsString:@".cmp"])) {

            NSString *appId = [self appIdFromURL:url];//根据URL获取appId
            BOOL exist = [self.appUpdateIdList containsObject:appId];
//            if(!appId || exist){//正在更新的app
//                NSLog(@"h5zip【exist:%d/appId:%@】- url:%@",exist,appId,urlStr);
//                if(!self.restartApping){//重启中不发消息
//                    [self _showAppCannotActionAlert];
//                }
//            }
        }
    }
}
//根据URL获取对应的appId
- (NSString *)appIdFromURL:(NSURL *)url{
    NSMutableArray *urlPaths  = [NSMutableArray arrayWithArray:url.pathComponents];
    if (urlPaths.count == 0) {
        return nil;
    }
    if (urlPaths.count == 1) {
        [urlPaths addObject:@"v"];
    }
    NSString *version = [urlPaths objectAtIndex:1];
    version = [version stringByReplacingOccurrencesOfString:@"v" withString:@""];
    NSString *host = url.host;
    NSDictionary *aDict = [[CMPAppManager appInfoMap] objectForKey:host];
    if(!aDict){
        return nil;
    }
    CMPDBAppInfo *appInfo = [aDict objectForKey:version];
    if (!appInfo) {
        appInfo = [[aDict allValues] lastObject];
    }
    return appInfo.appId;
}

-(void)_showAppCannotActionAlert{
    [self _showAlertWithTitle:nil message:@"应用正在更新，当前应用不可用" cancel:nil others:@[@"确定"] handler:^(NSInteger buttonIndex, id  _Nullable value) {
        
    }];
}

-(void)_startViewDidClosed{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([CMPCheckUpdateManager sharedManager].firstDownloadDone && _baseManager && _baseManager.state == CMPCheckUpdateManagerDownload && (_baseManager.infoModel.currentProgress>0 && _baseManager.infoModel.currentProgress<1)) {
            [self notifyStatus:@{@"state":@"start",@"value":SY_STRING(@"UpdatePakageNew_applicationing")}];
        }
    });
}

-(void)_otherControllerViewDidAppear:(NSNotification *)noti
{
    UIViewController *vc = noti.object;
    if (vc) {
        if([self _nowCanShowAlert:vc]){
            __weak typeof(self) weakSelf = self;
            if (_step == 222) {//下载失败未弹框
                [self _showFailAlert];
            }else if (_step == 212) {//下载成功未弹框
                [self _showSuccessAlert];
            }else if (_step == 612){
                NSInteger value = [CMPCommonManager networkReachabilityStatus];
                if (value == AFNetworkReachabilityStatusReachableViaWiFi && _baseManager.state == CMPCheckUpdateManagerCancel){
                    [[CMPCheckUpdateManager sharedManager] startCheckUpdate:nil];
                }else if (value == AFNetworkReachabilityStatusReachableViaWWAN && _baseManager.state == CMPCheckUpdateManagerCancel){
                    _step = 611;
                    //通知用户选择，立即更新，下次更新
                    [self _showAlertWithTitle:nil message:SY_STRING(@"UpdatePackage_TipNotWifi") cancel:nil others:@[SY_STRING(@"UpdatePackage_Download"),_firstDownloadApp?SY_STRING(@"UpdatePackage_CloseApp"):SY_STRING(@"common_cancel")] handler:^(NSInteger buttonIndex, id  _Nullable value) {
                        if (buttonIndex == 1) {
                            _baseManager.ignoreNetworkStatus = YES;
                            [[CMPCheckUpdateManager sharedManager] startCheckUpdate:nil];
                        }else if (buttonIndex == 2){
                            if (_firstDownloadApp){
                                exit(0);
                            }
                        }
                    }];
                }
            }else if (_step == 622){
                NSInteger value = [CMPCommonManager networkReachabilityStatus];
                if (value == AFNetworkReachabilityStatusNotReachable && _baseManager.state == CMPCheckUpdateManagerCancel){
                    _step = 621;
                    [self _showAlertWithTitle:nil message:SY_STRING(@"Common_Network_Unavailable") cancel:_firstDownloadApp?nil:SY_STRING(@"UpdatePakageNew_downloadNext") others:@[SY_STRING(@"UpdatePakageNew_reDownload")] handler:^(NSInteger buttonIndex, id  _Nullable value) {
                        _step = 0;
                        if (buttonIndex == 1){
                            [[CMPCheckUpdateManager sharedManager] startCheckUpdate:nil];
                        }
                        [self _errAlertDidClick:buttonIndex];
                    }];
                }
            }
        }
        if ([vc isKindOfClass:NSClassFromString(@"CMPTabBarViewController")]){
            if (_baseManager && _baseManager.state == CMPCheckUpdateManagerDownload && (_baseManager.infoModel.currentProgress>0 && _baseManager.infoModel.currentProgress<1)) {
                [self notifyStatus:@{@"state":@"start",@"value":SY_STRING(@"UpdatePakageNew_applicationing")}];
            }
        }
    }
}

-(void)_errAlertDidClick:(NSInteger)index{
    [self notifyStatus:@{@"state":@"alert",@"value":@"err_alert_click"}];
}

-(void)_downloadSuccessAlertDidClick:(NSInteger)index{
    [self notifyStatus:@{@"state":@"alert",@"value":@"success_alert_click"}];
}

-(BOOL)_nowCanShowAlert:(UIViewController *)ctrl{
    if (INTERFACE_IS_PHONE) {
        UIViewController *vc = ctrl?:[CMPCommonTool getCurrentShowViewController];
        if([vc isKindOfClass:NSClassFromString(@"CMPMessageListViewController")]||
           [vc isKindOfClass:CMPTabBarViewController.class]||
           [vc isKindOfClass:NSClassFromString(@"CMPTabBarWebViewController")]
           ||[vc isKindOfClass:NSClassFromString(@"CMPSplitViewController")]){
            return YES;
        }
    }
    return NO;
}

-(void)_showAlertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel others:(NSArray *)others handler:(nullable void(^)(NSInteger buttonIndex,id _Nullable value))handler{
    dispatch_async(dispatch_get_main_queue(), ^{
        id<CMPCustomAlertViewProtocol> alert = [CMPCustomAlertView alertViewWithTitle:title message:message preferredStyle:CMPCustomAlertViewStyleAlert footStyle:CMPAlertPublicFootStyleVertical bodyStyle:CMPAlertPublicBodyStyleDefalut cancelButtonTitle:cancel otherButtonTitles:others handler:handler];
        [alert setTheme:CMPTheme.new];
        [alert show];
    });
}

-(void)_showSuccessAlert {
    _step = 211;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self _showAlertWithTitle:nil message:SY_STRING(@"UpdatePakageNew_downloadSuc") cancel:nil others:@[SY_STRING(@"UpdatePakageNew_updateNow"),SY_STRING(@"UpdatePakageNew_updateNext")] handler:^(NSInteger buttonIndex, id  _Nullable value) {
            if (buttonIndex == 1) {
                [self _unzipAndRestart];
            }
            [self _downloadSuccessAlertDidClick:buttonIndex];
        }];
    });
}

-(void)_showFailAlert {
    if (self.baseManager.infoModel.downloadErrString) {
        _step = 221;
        [self _showAlertWithTitle:nil message:self.baseManager.infoModel.downloadErrString cancel:self.firstDownloadApp?nil:SY_STRING(@"UpdatePakageNew_downloadNext") others:@[SY_STRING(@"UpdatePakageNew_reDownload")] handler:^(NSInteger buttonIndex, id  _Nullable value) {
            if (buttonIndex == 1) {
                [self downloadWithList:self.downloadErrAppList];
            }
            self.baseManager.infoModel.downloadErrString = nil;
            [self _errAlertDidClick:buttonIndex];
        }];
    }
}

-(void)_progressViewDidTap:(NSNotification *)noti {
    NSNumber *val = noti.object;
    if (val.integerValue == 1) {
        if ([CMPCheckUpdateManager sharedManager].state == CMPCheckUpdateManagerDownload && _step == 212) {
            [self _showSuccessAlert];
        }
    }else if (val.integerValue == 2) {
        if ([CMPCheckUpdateManager sharedManager].state == CMPCheckUpdateManagerFail && _step == 222) {
            [self _showFailAlert];
        }
    }
}

-(void)_padTabbarDidSelect:(NSNotification *)noti {
    if ([CMPCheckUpdateManager sharedManager].state == CMPCheckUpdateManagerDownload && _step == 212) {
        [self _showSuccessAlert];
    }else if ([CMPCheckUpdateManager sharedManager].state == CMPCheckUpdateManagerFail && _step == 222) {
        [self _showFailAlert];
    }
}

-(void)_localTagToUpdateState:(NSString *)state{
    [UserDefaults setObject:state forKey:[self _localTagForCurServerDownloadStateKey]];
}

-(NSString *)_localTagForCurServerDownloadStateKey{
    NSString *serverId = [CMPCore sharedInstance].serverID ? : @"111111";
    return [@"h5resdownload2result_" stringByAppendingString:serverId];
}

-(BOOL)_localTagForIfDownloadFinish{
    NSString *r = [UserDefaults objectForKey:[self _localTagForCurServerDownloadStateKey]];
    return [@"1" isEqualToString:r];
}

- (NSOperationQueue *)downloadOperationQueue{
    if (!_downloadOperationQueue) {
        _downloadOperationQueue = [[NSOperationQueue alloc] init];
        _downloadOperationQueue.maxConcurrentOperationCount = 5;
    }
    return _downloadOperationQueue;
}


- (NSOperationQueue *)handleH5AppOperationQueue {
    if (!_handleH5AppOperationQueue) {
        _handleH5AppOperationQueue = [[NSOperationQueue alloc] init];
        _handleH5AppOperationQueue.maxConcurrentOperationCount = 5;
    }
    return _handleH5AppOperationQueue;
}

@end
