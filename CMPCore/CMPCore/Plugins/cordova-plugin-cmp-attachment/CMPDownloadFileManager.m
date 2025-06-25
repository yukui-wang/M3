//
//  CMPDownloadFileManager.m
//  M3
//
//  Created by wujiansheng on 2018/3/27.
//

#import "CMPDownloadFileManager.h"


#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/CMPDataRequest.h>
#import <CMPLib/CMPDataResponse.h>
#import <CMPLib/CMPCommonDBProvider.h>
#import <CMPLib/CMPFileManager.h>
#import <CMPLib/ZipArchiveUtils.h>
#import <CMPLib/CMPFileTypeHandler.h>
#import <AVFoundation/AVFoundation.h>
#import <CMPLib/CMPGlobleManager.h>
#import <CMPLib/NSString+CMPString.h>
#import <CMPLib/CMPDevicePermissionHelper.h>
#import <CMPLib/CMPOfflineFileRecord.h>
#import <CMPLib/CMPFileManagementRecord.h>
#import <CMPLib/CMPCommonTool.h>
#import <CMPLib/NSURL+CMPURL.h>
#import <CMPLib/NSString+CMPString.h>

@interface CMPDownloadFileObj :NSObject {
    
}
@property(nonatomic ,assign)id<CMPDownloadFileManagerDelegate> delegate;
@property(nonatomic ,copy)NSString  *callBackID;
@property(nonatomic ,assign)BOOL  directDownload;
@property(nonatomic ,retain)NSString  *title;
@property(nonatomic ,assign)BOOL  isSaveToLocal;
@property(nonatomic ,copy)NSString  *fileId;
@property(nonatomic ,copy)NSString  *lastModified;
@property(nonatomic ,copy)NSString  *origin;
@property(nonatomic ,copy)NSString  *from;

@end

@implementation CMPDownloadFileObj

- (void)dealloc {
    self.delegate = nil;
    self.from = nil;
    SY_RELEASE_SAFELY(_callBackID);
    SY_RELEASE_SAFELY(_title);
    SY_RELEASE_SAFELY(_fileId);
    SY_RELEASE_SAFELY(_lastModified);
    SY_RELEASE_SAFELY(_origin);
    [super dealloc];
}

@end

@interface CMPDownloadFileManager ()<CMPDataProviderDelegate>
@property(nonatomic, retain)NSMutableArray *objList;
@end

@implementation CMPDownloadFileManager
static CMPDownloadFileManager *instance = nil;
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    for (CMPDownloadFileObj *obj in _objList) {
        obj.delegate = nil;
    }
    [_objList removeAllObjects];
    SY_RELEASE_SAFELY(_objList);
    [super dealloc];
}

+ (CMPDownloadFileManager *)defaultManager {
    @synchronized (self)
    {
        if (!instance) {
            instance = [[super allocWithZone:NULL] init];
        }
    }
  
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        // 初始化下载队列
        // 初始化上传队列
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(userLogout)
                                                    name:kNotificationName_UserLogout
                                                  object:nil];
    }
    return self;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self defaultManager] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}

- (oneway void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

- (void)finishDownLoad:(NSDictionary *)dic
              delegate:(id <CMPDownloadFileManagerDelegate>)delegate
            callbackId:(NSString *)callbackId {
    if (delegate && [delegate respondsToSelector:@selector(managerDidFinishDownloadFile:callbackId:)]) {
        [delegate managerDidFinishDownloadFile:dic callbackId:callbackId];
    }
}

- (void)failDownLoad:(NSDictionary *)dic
            delegate:(id <CMPDownloadFileManagerDelegate>)delegate
          callbackId:(NSString *)callbackId {
    if (delegate && [delegate respondsToSelector:@selector(managerDidFailDownloadFile:callbackId:)]) {
        [delegate managerDidFailDownloadFile:dic callbackId:callbackId];
    }
}



- (void)downloadFileWithInfo:(NSDictionary *)argumentsMap
                  callbackId:(NSString *)callbackId
                    delegate:(id <CMPDownloadFileManagerDelegate>) delegate {
    NSString *url = [argumentsMap objectForKey:@"url"];
    if ([NSString isNull:url] || [url isEqualToString:@"null"]) {
        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:22001],@"code",SY_STRING(@"common_downloadAddressEmpty"),@"message",@"",@"detail", nil];
        [self failDownLoad:errorDict delegate:delegate callbackId:callbackId];
        return;
    }
    NSString *title = [argumentsMap objectForKey:@"title"];
    if (![NSString isNull:title] && [CMPFileTypeHandler isEqualPicture:title]) {
        [CMPDevicePermissionHelper permissionsForPhotosTrueCompletion:^{
            [self downloadFile:argumentsMap callbackId:callbackId delegate:delegate];
        } falseCompletion:^{
            [self failDownLoad:nil delegate:delegate callbackId:callbackId];
        } showAlert:YES];
    }
    else {
        [self downloadFile:argumentsMap callbackId:callbackId delegate:delegate];
    }
}

- (void)removeDelegate:(id <CMPDownloadFileManagerDelegate>) delegate {
    for (CMPDownloadFileObj *obj in _objList) {
        if (obj.delegate == delegate) {
            obj.delegate = nil;
        }
    }
}
- (void)userLogout{
    [[CMPDataProvider sharedInstance] cancelRequestsWithDelegate:self];
    for (CMPDownloadFileObj *obj in _objList) {
        obj.delegate = nil;
    }
    [_objList removeAllObjects];
    SY_RELEASE_SAFELY(_objList);
}

- (void)downloadFile:(NSDictionary *)argumentsMap
          callbackId:(NSString *)callbackId
            delegate:(id <CMPDownloadFileManagerDelegate>) delegate{
    NSString *serverID = [CMPCore sharedInstance].serverID;
    NSString *ownerID = [CMPCore sharedInstance].userID;
    // 判断是否是公共包还是应用包  extData ＝ nil,不存数据库，直接下载
    if (![self directDownload:argumentsMap]) {
        NSDictionary *extData = [argumentsMap objectForKey:@"extData"];
        NSString *fileId = [extData objectForKey:@"fileId"];
        NSString *lastModified = [extData objectForKey:@"lastModified"];
        NSString *origin = kCMP_ServerID;//[extData objectForKey:@"origin"];
        CMPCommonDBProvider *dbConnection = [CMPCommonDBProvider sharedInstance];
        __block NSArray *findResult = nil;
        [dbConnection offlineFileRecordsWithFileId:fileId
                                      lastModified:lastModified
                                            origin:origin
                                          serverID:serverID
                                           ownerID:ownerID
                                      onCompletion:^(NSArray *result) {
                                          findResult = [result copy];
                                      }];
        if (findResult.count > 0) {
            CMPOfflineFileRecord *aDownloadFile = [findResult objectAtIndex:0];
            //判断本地文件是否存在 ，不存在就删除记录再下载
            NSString *localPath = [aDownloadFile fullLocalPath];
            BOOL isDirectory = NO;
            BOOL exist =  [[NSFileManager defaultManager] fileExistsAtPath:localPath isDirectory:&isDirectory];
            if (exist) {
                //解压
                NSString *title = aDownloadFile.fileName;
                NSString *filePath = [CMPFileManager unEncryptFile:localPath fileName:title];
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:filePath,@"target",@"1",@"pos",[NSNumber numberWithBool:YES],@"isDownloaded", nil];
                [self finishDownLoad:dic delegate:delegate callbackId:callbackId];
                SY_RELEASE_SAFELY(findResult);
                return;
            }
            else {
                [dbConnection deleteOfflineFileRecordsWithFileId:fileId origin:origin serverID:serverID ownerID:ownerID onCompletion:nil];
            }
        }
        SY_RELEASE_SAFELY(findResult);
    }
    [self downloadFileWithArgumentsMap:argumentsMap callbackId:callbackId delegate:delegate];
}

- (BOOL)directDownload:(NSDictionary *)argumentsMap
{
    // 是否直接下载，不保存到数据库
    NSDictionary *extData = [argumentsMap objectForKey:@"extData"];
    if (!extData) {
        return YES;
    }
    if (![extData isKindOfClass:[NSDictionary class]]) {
        return YES;
    }
    NSString *fileId = [extData objectForKey:@"fileId"];
    if ([NSString isNull:fileId]) {
        return YES;
    }
    NSString *origin = [extData objectForKey:@"origin"];
    if ([NSString isNull:origin]) {
        return YES;
    }
    return NO;
}

- (void)downloadFileWithArgumentsMap:(NSDictionary *)argumentsMap
                          callbackId:(NSString *)callbackId
                            delegate:(id <CMPDownloadFileManagerDelegate>) delegate
{
    NSString *url = [argumentsMap objectForKey:@"url"];
    
    //根据url判断是否相同url资源正在下载中，如果正在下载，则不发起请求
    NSURLSessionTask *task = [[CMPDataProvider sharedInstance] getTaskByUrl:url];
    if (task) {
        return;
    }
    
    NSString *title =[argumentsMap objectForKey:@"title"];
    NSDictionary *headers = [argumentsMap objectForKey:@"headers"];
    title = [title decodeFromPercentEscapeString];
    NSLog(@"download app url: %@", url);
    NSString *handledFileName = [title handleFileNameSpecialCharactersAtPath];
    NSString *downLoadPath = [[CMPFileManager fileTempPath] stringByAppendingPathComponent:handledFileName];
    
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.downloadDestinationPath = downLoadPath;
    aDataRequest.requestType = kDataRequestType_FileDownload;
   
    BOOL directDownload = [self directDownload:argumentsMap];
    BOOL isSaveToLocal = YES;
    if ([[argumentsMap allKeys] containsObject:@"isSaveToLocal"]) {
        isSaveToLocal = [[argumentsMap objectForKey:@"isSaveToLocal"] boolValue];
    }
    CMPDownloadFileObj *obj = [[CMPDownloadFileObj alloc] init];
    obj.delegate = delegate;
    obj.callBackID = callbackId;
    obj.directDownload = directDownload;
    obj.title = title;
    obj.isSaveToLocal = isSaveToLocal;
    //来源
    NSString *from = [argumentsMap objectForKey:@"from"];
    obj.from = [NSString isNull:from]?@"":from;
    
    NSDictionary *extData = [argumentsMap objectForKey:@"extData"];
    if (!extData ||
        ![extData isKindOfClass:[NSDictionary class]]) {
        obj.fileId = @"";
        obj.lastModified = @"";
        obj.origin = @"";
    } else {
        obj.fileId = [extData objectForKey:@"fileId"];
        obj.lastModified = [extData objectForKey:@"lastModified"];
        obj.origin = [extData objectForKey:@"origin"];
    }
    
    obj.directDownload = directDownload;
    aDataRequest.userInfo = (id)obj;
    if (!_objList) {
        _objList = [[NSMutableArray alloc] init];
    }
    [_objList addObject:obj];
    SY_RELEASE_SAFELY(obj);
    
    if ([headers isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *mutableHeader = [[CMPDataProvider headers] mutableCopy];
        [mutableHeader addEntriesFromDictionary:headers];
        aDataRequest.headers =  [mutableHeader copy];
    }
    
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    [aDataRequest release];
}

#pragma -mark CMPDataProviderDelegate
- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider
                      request:(CMPDataRequest *)aRequest
                     response:(CMPDataResponse *)aResponse{
    //store of zip file and record
    CMPDataResponse *fileResponce = (CMPDataResponse *)aResponse;
    NSString *downloadPath = fileResponce.downloadDestinationPath;
    CMPDownloadFileObj *obj = (CMPDownloadFileObj *)aRequest.userInfo;
    [_objList removeObject:obj];
    NSString *aCallBackId = obj.callBackID;
    BOOL directDownload= obj.directDownload;
    NSString *title = obj.title;
    NSString *from = obj.from;

    BOOL isSaveToLocal = obj.isSaveToLocal;
    BOOL isPicture = [CMPFileTypeHandler isEqualPicture:title];
    if (isPicture) {
        if (isSaveToLocal) {
            //是图片就保存到相册
            [self saveImageToPhotosAlbum:downloadPath fileId:obj.fileId imgName:title];
        }
        if (![CMPFeatureSupportControl isAutoSaveFile]) {
            //不自动保存，就结束了，否者不仅需要保存到相册，还需要需要保存到手机本地
             NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:downloadPath,@"target",@"1",@"pos",[NSNumber numberWithBool:NO],@"isDownloaded", nil];
            [self finishDownLoad:dic delegate:obj.delegate callbackId:aCallBackId];
            return;
        }
       
    }
    downloadPath = [CMPFileManager pathForDownloadPath:downloadPath
                                       responseHeaders:aResponse.responseHeaders];
    title = downloadPath.lastPathComponent.originalFileNameSpecialCharactersAtPath;
    title = [title decodeFromPercentEscapeString];
    if (isSaveToLocal && !directDownload && !isPicture) {
        NSString *fileId = obj.fileId;
        NSString *lastModified = obj.lastModified;
        NSString *origin = obj.origin;
        
        CMPFile *aFile = [[[CMPFile alloc] init] autorelease];
        aFile.filePath = downloadPath;
        aFile.fileID = fileId;
        aFile.fileName = title;
        aFile.from = from;
        aFile.fromType = CMPFileFromTypeComeFromM3;
        aFile.origin = origin;
        aFile.lastModified = lastModified;
        [CMPFileManager.defaultManager saveFile:aFile];
    }
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:downloadPath,@"target",@"1",@"pos",[NSNumber numberWithBool:NO],@"isDownloaded", nil];
    [self finishDownLoad:dic delegate:obj.delegate callbackId:aCallBackId];
}

- (void)provider:(CMPDataProvider *)aProvider
         request:(CMPDataRequest *)aRequest
didFailLoadWithError:(NSError *)error{
    NSString *aResult = nil;
    if ([error.userInfo isKindOfClass:[NSDictionary class]] && error.userInfo.count > 0) {
        aResult = [error.userInfo objectForKey:@"responseString"];
        // 判断是否是标准的错误返回格式
        NSDictionary *dict = [aResult JSONValue];
        if (dict && [dict isKindOfClass:[NSDictionary class]] && dict.count > 0) {
            if (![dict objectForKey:@"code"]) {
                aResult = nil;
            }
        }
        else {
            aResult = nil;
        }
        // 判断结束
    }
    NSDictionary *aResultDic = nil;
    if ([NSString isNull:aResult]) {
        aResultDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:error.code], @"code", error.domain, @"message", nil];
    }
    else {
        aResultDic = [aResult JSONValue];
    }
    CMPDownloadFileObj *obj  = (CMPDownloadFileObj *)aRequest.userInfo;
    [_objList removeObject:obj];
    [self failDownLoad:aResultDic delegate:obj.delegate callbackId:obj.callBackID];
}

- (void)saveImageToPhotosAlbum:(NSString *)aPath fileId:(NSString *)fileId imgName:(NSString *)name
{
    //保存到相册
    [CMPCommonTool.sharedTool savePhotoToLocalWithImagePath:aPath completionHandler:nil];

//    UIImage *image = [UIImage imageWithContentsOfFile:aPath];
//    [CMPCommonTool.sharedTool savePhotoWithImage:image target:self action:@selector(image:didFinishSavingWithError:contextInfo:)];
}

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    
}

@end
