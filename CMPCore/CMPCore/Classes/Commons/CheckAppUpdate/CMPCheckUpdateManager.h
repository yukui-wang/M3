//
//  CMPCheckUpdateManager.h
//  CMPCore
//
//  Created by youlin on 2017/1/3.
//
//

#import <CMPLib/CMPObject.h>
@class CMPCheckUpdateManager;
typedef NS_ENUM(NSUInteger, CMPCheckUpdateManagerState) {
    CMPCheckUpdateManagerInit, // 初始状态
    CMPCheckUpdateManagerCheck, // 正在检查更新
    CMPCheckUpdateManagerDownload, // 正在更新
    CMPCheckUpdateManagerSuccess, // 更新成功 或 离线登录不更新
    CMPCheckUpdateManagerFail, // 更新失败
    CMPCheckUpdateManagerOffline, // 离线模式
    CMPCheckUpdateManagerPause,
    CMPCheckUpdateManagerCancel,
    
    CMPCheckUpdateManagerUnzipSuccess,//解压成功
    CMPCheckUpdateManagerUnzipFail//解压失败
};

@protocol CMPCheckUpdateManagerDelegate <NSObject>

-(BOOL)checkUpdateManager:(CMPCheckUpdateManager *)manager startCheckUpdate:(void (^)(BOOL success))completionBlock ext:(id)ext;
-(BOOL)checkUpdateManager:(CMPCheckUpdateManager *)manager preHandleDownloadApplist:(NSArray *)applist ext:(id)ext;
-(BOOL)checkUpdateManager:(CMPCheckUpdateManager *)manager startDownloadApplist:(NSArray *)applist ext:(id)ext;
-(BOOL)checkUpdateManager:(CMPCheckUpdateManager *)manager downloadAppIndex:(NSInteger)index ext:(id)ext;
-(BOOL)checkUpdateManager:(CMPCheckUpdateManager *)manager cancelDownload:(id)ext;
-(BOOL)checkUpdateManager:(CMPCheckUpdateManager *)manager canShowApp:(id)ext;
-(BOOL)checkUpdateManager:(CMPCheckUpdateManager *)manager checkUrlState:(NSURL *)url ext:(id)ext;
-(BOOL)checkUpdateManager:(CMPCheckUpdateManager *)manager networkChanged:(id)ext;
-(BOOL)checkUpdateManager:(CMPCheckUpdateManager *)manager showAlertViewForWWAN:(id)ext;
-(BOOL)checkUpdateManager:(CMPCheckUpdateManager *)manager isFirstDownload:(id)ext;

@end



@interface CMPUpdateInfoModel : CMPObject

@property (nonatomic, copy) NSString *unzipErrString;
@property (nonatomic, copy) NSString *downloadErrString;
@property (assign, nonatomic) float currentProgress;

@end



@interface CMPCheckUpdateManager : CMPObject

//@property (nonatomic, assign)BOOL checkAppsUpdating; // 正在检查更新中，包括H5应用下载
//@property (nonatomic, assign)BOOL checkAppsUpdateSuccess; // 检查应用更新是否成功
//@property (nonatomic, assign)BOOL appsdownloading; // 是否应用正在下载
/** 应用包下载状态 **/
@property (assign, nonatomic) CMPCheckUpdateManagerState state;
@property (nonatomic, copy) void(^updateSuccess)(void);
@property (nonatomic,weak) id<CMPCheckUpdateManagerDelegate> delegate;
@property (nonatomic,strong) CMPUpdateInfoModel *infoModel;
@property (nonatomic, assign) BOOL ignoreNetworkStatus; // 是否忽略网络状态下载，默认是NO
@property (nonatomic, assign,readonly) BOOL firstDownloadDone;

+ (CMPCheckUpdateManager *)sharedManager;

- (void)startCheckUpdate:(void (^)(BOOL success))completionBlock;
- (void)cancelCurrentDownload;
- (void)redownload; // 重新下载
- (void)stopDownload;

/**
 判断应用包是否全部下载完成
 */
- (BOOL)isDownloadAllApp;

/**
 是否可以打开H5应用了
 有两种情况
 1.应用包下载完成
 2.离线模式
 */
- (BOOL)canShowApp;

@end

