//
//  CMPFaceImageManager.m
//  CMPCore
//
//  Created by wujiansheng on 16/9/6.
//
//
#define LINE_BORDER_WIDTH 1.0
#define LINE_PATH_WIDTH 1.0

#import "CMPFaceImageManager.h"
#import "CMPFileManager.h"
#import "CMPCommonDBProvider.h"
#import "ZipArchiveUtils.h"
#import "CMPDataRequest.h"
#import "CMPDataProvider.h"
#import "CMPDataResponse.h"
#import "NSString+CMPString.h"
#import "CMPDateHelper.h"
#import "CMPAppDelegate.h"

@interface CMPFaceImageManager ()<CMPDataProviderDelegate> {
    NSMutableDictionary *_faceImagePathsDict;
    NSMutableDictionary *_downloadRecordsDict;
    NSMutableDictionary *_containersDict;
    NSMutableDictionary *_blocksDict;
}

@end

@implementation CMPFaceImageManager

- (id)init
{
    self = [super init];
    if (self) {
        _faceImagePathsDict = [[NSMutableDictionary alloc] init];
        _containersDict = [[NSMutableDictionary alloc] init];
        _downloadRecordsDict = [[NSMutableDictionary alloc] init];
        _blocksDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma -mark public method

static CMPFaceImageManager *_imageManager;
+ (CMPFaceImageManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_imageManager) {
            _imageManager = [[CMPFaceImageManager alloc] init];
        }
    });
    return _imageManager;
}

- (void)clearData {
    [_faceImagePathsDict removeAllObjects];
    [_containersDict removeAllObjects];
    [_downloadRecordsDict removeAllObjects];
    [_blocksDict removeAllObjects];
    [[CMPDataProvider sharedInstance] cancelRequestsWithDelegate:self];
}

- (void)fetchfaceImageWithFaceDownloadObj:(SyFaceDownloadObj *)obj container:(CMPFaceImageView *)aImageView complete:(void(^)(UIImage *image))complete cache:(BOOL)aCache
{
    if (!obj || !obj.memberId || !obj.serverId || !obj.downloadUrl) {
        if (complete) {
            complete(nil);
        }
        return;
    }
    if (!aImageView && !complete) {
        return;
    }
    
    NSString *memberId = obj.memberId;
    // 是否加载缓存成功
    if (aCache) {
        BOOL aLoadSuccessful = [self loadImageWithMemberId:memberId container:aImageView complete:complete];
        if (aLoadSuccessful) return;
        aLoadSuccessful = [self loadImageWithFaceDownloadObj:obj container:aImageView complete:complete];
        if (aLoadSuccessful) return;
    }

    // 是否需要下载
    BOOL aNeedDownload = YES;
    if (aImageView) {
        NSMutableArray *array = [_containersDict objectForKey:memberId];
        if (!array) {
            array = [NSMutableArray array];
        }
        else {
            aNeedDownload = NO;
        }
        if (![array containsObject:aImageView]) {
            [array addObject:aImageView];
        }
        [_containersDict setObject:array forKey:memberId];
    }
    // 添加bock
    if (complete) {
        NSMutableArray *aBlocks = [_blocksDict objectForKey:memberId];
        if (!aBlocks) {
            aBlocks = [NSMutableArray array];
        }
        else {
            aNeedDownload = NO;
        }
        CMPImageBlockObj *aBlockObj = [[CMPImageBlockObj alloc] init];
        aBlockObj.imageBlock = complete;
        [aBlocks addObject:aBlockObj];
        [_blocksDict setObject:aBlocks forKey:memberId];
    }
    if (aNeedDownload) {
        [self downloadWithWithFaceDownloadObj:obj];
    }
}

- (void)fetchfaceImageWithMemberId:(NSString *)aMemberId complete:(void(^)(UIImage *image))complete cache:(BOOL)aCache
{
    if (!complete) {
        return;
    }
    NSString *imageUrl = [CMPCore memberIconUrlWithId:aMemberId];
    SyFaceDownloadObj *memberIcon = [[SyFaceDownloadObj alloc] init];
    memberIcon.memberId = aMemberId;
    memberIcon.serverId = [CMPCore sharedInstance].serverID;
    memberIcon.downloadUrl = imageUrl;
    [self fetchfaceImageWithFaceDownloadObj:memberIcon container:nil complete:complete cache:aCache];
}

- (void)clearWithMemberId:(NSString *)aMemberId serverId:(NSString *)aServerId
{
    [_faceImagePathsDict removeObjectForKey:aMemberId];
    CMPCommonDBProvider *dbConnection = [CMPCommonDBProvider sharedInstance];
    [dbConnection deleteFaceRecordsWithMemberId:aMemberId serverId:aServerId onCompletion:nil];
}

- (BOOL)loadImageWithMemberId:(NSString *)aMemberId container:(CMPFaceImageView *)aImageView complete:(void(^)(UIImage *image))complete
{
    // 根据memberId从_faceImagePathsDict查找记录，如果有就直接设置，如果没有就从数据库查找
    BOOL aSuccessful = NO;
    NSString *aFaceImagePath = [_faceImagePathsDict objectForKey:aMemberId];
    // 根据max-age、过期时间判断是否去缓存
    if (aFaceImagePath) {
        UIImage *aImage = [self imageWithPath:aFaceImagePath];
        if (aImage) {
            aImage = [UIImage imageWithCGImage:aImage.CGImage scale:3.0 orientation:UIImageOrientationUp];
            if ([aImageView.memberId isEqualToString:aMemberId]) {
                aImageView.image = aImage;
            }
            if (complete) complete(aImage);
            aSuccessful = YES;
        }
    }
    if (!aSuccessful) {
        [_faceImagePathsDict removeObjectForKey:aMemberId];
    }
    return aSuccessful;
}

- (BOOL)loadImageWithFaceDownloadObj:(SyFaceDownloadObj *)obj container:(CMPFaceImageView *)aImageView complete:(void(^)(UIImage *image))complete
{
    BOOL aSuccessful = NO;
    // 首先判断是否本地存在，根据服务器id获取文件路径
    CMPCommonDBProvider *dbConnection = [CMPCommonDBProvider sharedInstance];
    __block NSArray *findResult = nil;
    [dbConnection faceDownloadRecordsWithObj:obj
                                onCompletion:^(NSArray *result) {
                                    findResult = [result copy];
                                }];
    
    if (findResult.count > 0) {
        NSString *memberId = obj.memberId;
        SyFaceDownloadRecordObj *aFaceDownloadRecordObj = [findResult objectAtIndex:0];
        //判断是否过期了
        long long expiresDate = [aFaceDownloadRecordObj.extend1 longLongValue];
        long long currentDate = [CMPDateHelper localeDateTimeInterval];
        if (currentDate > expiresDate) {
            //过期了 删除图片及数据库 重新下载
            [dbConnection deleteFaceRecordsWithMemberId:memberId serverId:aFaceDownloadRecordObj.serverId onCompletion:nil];
            [[NSFileManager defaultManager] removeItemAtPath:aFaceDownloadRecordObj.fullSavePath error:nil];
            return aSuccessful;
        }
        
        [_faceImagePathsDict setObject:aFaceDownloadRecordObj.fullSavePath forKey:memberId];
        
        UIImage *aImage = [self imageWithPath:aFaceDownloadRecordObj.fullSavePath];
        if (aImage) {
            aImage = [UIImage imageWithCGImage:aImage.CGImage scale:3.0 orientation:UIImageOrientationUp];
            if ([aImageView.memberId isEqualToString:memberId]) {
                aImageView.image = aImage;
            }
            if (complete) complete(aImage);
            aSuccessful = YES;
        }
        if (!aSuccessful) {
            [dbConnection deleteFaceRecordsWithMemberId:memberId serverId:aFaceDownloadRecordObj.serverId onCompletion:nil];
            [[NSFileManager defaultManager] removeItemAtPath:aFaceDownloadRecordObj.fullSavePath error:nil];
        }
    }
    return aSuccessful;
}

- (void)downloadWithWithFaceDownloadObj:(SyFaceDownloadObj *)obj
{
    NSString *downloadUrl = obj.downloadUrl;
    NSString *name = [NSString stringWithFormat:@"%@.png",obj.memberId];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.requestUrl = downloadUrl;
    aDataRequest.httpShouldHandleCookies = NO;
    aDataRequest.headers = [CMPDataProvider headers];
    NSString *localPath = [[CMPFileManager createFullPath:kFaceImagePath] stringByAppendingPathComponent:name];
   
    if ( [[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
        //先把已有的删除掉
        [[NSFileManager defaultManager] removeItemAtPath:localPath error:nil];
    }
    aDataRequest.downloadDestinationPath = localPath;
    aDataRequest.requestType = kDataRequestType_FileDownload;
    NSMutableDictionary *aDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"getFaceImage",@"methd",obj.memberId, @"memberId",obj.serverId, @"serverId",obj.downloadUrl.md5String,@"downloadUrlMd5", nil];
    
    aDataRequest.userInfo = aDict;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (UIImage *)imageWithPath:(NSString *)aPath
{
    UIImage *aResult = nil;
    BOOL bDestIsDir = NO;
    BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:aPath isDirectory:&bDestIsDir];
    if (isExists) {
        NSData *aData = [NSData dataWithContentsOfFile:aPath];
        aResult = [UIImage imageWithData:aData];
    }
    return aResult;
}

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse
{
    if ([[[aRequest userInfo]objectForKey:@"methd"] isEqualToString:@"getFaceImage"]) {
        
        NSString *aPath = aResponse.downloadDestinationPath;
        NSDictionary *aDict = (NSDictionary *)aRequest.userInfo;
        
        NSData *aData = [NSData dataWithContentsOfFile:aPath];
        NSString *memberId = [aDict objectForKey:@"memberId"];
//        NSMutableArray *array1 = [_containersDict objectForKey:memberId];
//        UIColor *color = nil;
//        if (array1.count >0) {
//            CMPFaceImageView *f = [array1 lastObject];
//            color = f.circularColor;
//        }
//        color = color? color: UIColorFromRGB(0xd4d4d4);
        UIImage *aImage = [UIImage imageWithData:aData];
        
        CGFloat imageWidth = CGImageGetWidth(aImage.CGImage), imageHeight = CGImageGetHeight(aImage.CGImage);
        if(aImage && imageWidth != imageHeight) {
            CGFloat _w = (imageWidth<=imageHeight) ? imageWidth:imageHeight;
            CGRect r = CGRectMake(imageWidth/2-_w/2, imageHeight/2-_w/2, _w, _w);
            aImage = [UIImage imageWithClipImage:aImage inRect:r];
        }

        
        //[self reSizeImage:[UIImage imageWithData:aData] newSize:CGSizeMake(40, 40) circularColor:color];
        
        if (!aImage) {
            [self provider:aProvider request:aRequest didFailLoadWithError:nil];
            return;
        }
//        aImage = [UIImage imageWithCGImage:aImage.CGImage scale:3.0 orientation:UIImageOrientationUp];
        NSString *aSavePath = aPath;
        BOOL aSaveSuccessful = [self saveImageWithPath:aSavePath image:aImage];
        if (!aSaveSuccessful) {
            [self didFinishWithMemberId:memberId];
            return;
        }
        
        NSString *serverId = [aDict objectForKey:@"serverId"];
        NSString *downloadUrlMd5 = [aDict objectForKey:@"downloadUrlMd5"];
        CMPCommonDBProvider *dbConnection = [CMPCommonDBProvider sharedInstance];
        SyFaceDownloadRecordObj *aFaceDownloadRecordObj = [[SyFaceDownloadRecordObj alloc] init];
        aFaceDownloadRecordObj.memberId = memberId;
        aFaceDownloadRecordObj.serverId = serverId;
        NSString *aHomePath = [NSString stringWithFormat:@"%@/", [CMPFileManager homeDirectory]];
        NSString  *attaPath = [aSavePath replaceCharacter:aHomePath withString:@""];
        
        aFaceDownloadRecordObj.savePath = attaPath;
        aFaceDownloadRecordObj.downloadUrlMd5 = downloadUrlMd5;
        
        NSString *aCacheControl = [aResponse.responseHeaders objectForKey:@"Cache-Control"];
        NSDictionary *propertyValue = [self propertyValue:aCacheControl];
        NSString *maxAge = [propertyValue objectForKey:@"max-age"];
        if (![NSString isNull:maxAge]) {
            long long maxAgeL = [maxAge longLongValue];
            long long currentDate = [CMPDateHelper localeDateTimeInterval];;
            long long expiresDate = currentDate + maxAgeL;
            aFaceDownloadRecordObj.extend1 = [NSString stringWithLongLong:expiresDate];
        }
        
        [dbConnection deleteFaceRecordsWithMemberId:memberId serverId:serverId onCompletion:nil];
        [dbConnection insertFaceDownloadRecord:aFaceDownloadRecordObj onCompletion:nil];
        [_faceImagePathsDict setObject:aSavePath forKey:memberId];
        NSMutableArray *array = [_containersDict objectForKey:memberId];
        for (CMPFaceImageView *aFaceImageView in array) {
            if (aFaceImageView.memberId && [aFaceImageView.memberId isEqualToString:memberId]) {
                aFaceImageView.image = [UIImage imageWithCGImage:aImage.CGImage];
            }
        }
        // block
        // 如果是block
        NSMutableArray *aBlocks = [_blocksDict objectForKey:memberId];
        for (CMPImageBlockObj *aBlockObj in aBlocks) {
            UIImage *image = [UIImage imageWithData:aData];
            aBlockObj.imageBlock(image);
        }
        [self didFinishWithMemberId:memberId];
    }
}

- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error{
    
    NSDictionary *aDict = aRequest.userInfo;
    NSString *memberId = [aDict objectForKey:@"memberId"];
    [self didFinishWithMemberId:memberId];
    
    [[CMPAppDelegate shareAppDelegate] handleError:error];
}

- (void)providerDidStartLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest;
{
    
}

- (UIImage *)reSizeImage:(UIImage *)image newSize:(CGSize)aSize  circularColor:(UIColor*)color
{
    if (!image) {
        return nil;
    }
    UIImage *newImage = nil;
    UIColor *pathColor = color?color: [UIColor whiteColor];
    UIColor *borderColor = [UIColor darkGrayColor];
    
    CGRect rect;
    rect.size = aSize;
    rect.origin = CGPointMake(0, 0);
    
    CGRect rectImage = rect;
    rectImage.origin.x += LINE_PATH_WIDTH;
    rectImage.origin.y += LINE_PATH_WIDTH;
    rectImage.size.width -= LINE_PATH_WIDTH*2.0;
    rectImage.size.height -= LINE_PATH_WIDTH*2.0;
    
    UIGraphicsBeginImageContextWithOptions(rect.size,0,0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextAddEllipseInRect(ctx, rect);
    
    CGContextClip(ctx);
    [image drawInRect:rectImage];
    
    //Add intern and extern line
    rectImage.origin.x -= LINE_BORDER_WIDTH/2.0;
    rectImage.origin.y -= LINE_BORDER_WIDTH/2.0;
    rectImage.size.width += LINE_BORDER_WIDTH;
    rectImage.size.height += LINE_BORDER_WIDTH;
    
    rect.origin.x += LINE_BORDER_WIDTH/2.0;
    rect.origin.y += LINE_BORDER_WIDTH/2.0;
    rect.size.width -= LINE_BORDER_WIDTH;
    rect.size.height -= LINE_BORDER_WIDTH;
    
    CGContextSetStrokeColorWithColor(ctx, borderColor.CGColor);
    CGContextSetLineWidth(ctx, LINE_BORDER_WIDTH);
    
    CGContextStrokeEllipseInRect(ctx, rectImage);
    CGContextStrokeEllipseInRect(ctx, rect);
    
    //Add center line
    float centerLineWidth = LINE_PATH_WIDTH - LINE_BORDER_WIDTH*2.0;
    rectImage.origin.x -= LINE_BORDER_WIDTH/2.0+centerLineWidth/2.0;
    rectImage.origin.y -= LINE_BORDER_WIDTH/2.0+centerLineWidth/2.0;
    rectImage.size.width += LINE_BORDER_WIDTH+centerLineWidth;
    rectImage.size.height += LINE_BORDER_WIDTH+centerLineWidth;
    CGContextSetStrokeColorWithColor(ctx, [pathColor CGColor]);
    CGContextSetLineWidth(ctx, centerLineWidth);
    CGContextStrokeEllipseInRect(ctx, rectImage);
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return newImage;
}

- (BOOL)saveImageWithPath:(NSString *)aPath image:(UIImage *)aImage
{
    BOOL isDirectory = NO;
    BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:aPath isDirectory:&isDirectory];
    if (isExists) {
        [[NSFileManager defaultManager] removeItemAtPath:aPath error:nil];
    }
    return [UIImagePNGRepresentation(aImage) writeToFile:aPath atomically:YES];
}

- (void)didFinishWithMemberId:(NSString *)memberId
{
    [_downloadRecordsDict setObject:@"true" forKey:memberId];
    NSMutableArray *array = [_containersDict objectForKey:memberId];
    [array removeAllObjects];
    [_containersDict removeObjectForKey:memberId];
    // block
    NSMutableArray *aBlocks = [_blocksDict objectForKey:memberId];
    [aBlocks removeAllObjects];
    [_blocksDict removeObjectForKey:memberId];
}

- (NSDictionary *)propertyValue:(NSString *)string
{
    NSMutableDictionary *aDict = [[NSMutableDictionary alloc] init];
    NSArray *aList1 = [string componentsSeparatedByString:@","];
    for (NSString *aStr in aList1) {
        NSArray *l = [aStr componentsSeparatedByString:@"="];
        if (l.count == 2) {
            NSString *k = [l objectAtIndex:0];
            k = [k replaceCharacter:@" " withString:@""];
            NSString *v = [l objectAtIndex:1];
            [aDict setObject:v forKey:k];
        }
    }
    return aDict;
}

@end
