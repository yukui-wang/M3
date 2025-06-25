//
//  CMPFileManagementManager.m
//  M3
//
//  Created by MacBook on 2019/10/14.
//

#import "CMPFileManagementManager.h"
#import "SyFileProvider.h"
#import "SyFileDBProvider.h"
#import <CMPLib/CMPFileManagementRecord.h>
#import <CMPLib/CMPCommonTool.h>
#import <CMPLib/CMPFileManager.h>



@interface CMPFileManagementManager()

/* selectedFiles */
@property (strong, nonatomic) NSMutableArray *selectedFiles;

@end

@implementation CMPFileManagementManager

#pragma mark - 初始化

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.selectedFiles = [NSMutableArray array];
    }
    return self;
}

#pragma mark - 外部方法

- (void)addSelectedFile:(CMPFileManagementRecord *)fileRecord {
    if (fileRecord) {
        [_selectedFiles addObject:fileRecord];
        
    }
}

- (void)addSelectedFiles:(NSArray<CMPFileManagementRecord *> *)fileRecords {
    if (fileRecords.count) {
        [_selectedFiles addObjectsFromArray:fileRecords];
    }
}

- (void)removeSelectedFile:(CMPFileManagementRecord *)fileRecord {
    if (!fileRecord) return;
    
    if ([_selectedFiles containsObject:fileRecord]) {
        [_selectedFiles removeObject:fileRecord];
    }
}

- (void)removeSelectedFiles:(NSArray<CMPFileManagementRecord *> *)fileRecords {
    if (!fileRecords.count) return;
    
    for (CMPFileManagementRecord *fileRecord in fileRecords) {
        CMPFileManagementRecord *rmMfr = nil;
        for (CMPFileManagementRecord *tmpMfr in _selectedFiles) {
            if ([tmpMfr.fileId isEqualToString: fileRecord.fileId]) {
                rmMfr = tmpMfr;
                break;
            }
        }
        if (rmMfr) {
            [_selectedFiles removeObject:rmMfr];
        }
    }
}

- (NSArray *)getCurrentSelectedFiles {
    if (_selectedFiles.count) {
        
        return [_selectedFiles copy];
    }
    return nil;
}

- (NSInteger)getCurrentSelectedCount {
    return _selectedFiles.count;
}

/// 删除文件
- (BOOL)deleteFilesWithOfflineFiles:(NSArray<CMPFileManagementRecord *> *)fileList {

    NSMutableArray *offlineArray = [NSMutableArray array];
    for (CMPFileManagementRecord *record in fileList) {
        [offlineArray addObject:[self managementRecord2OfflineRecord:record]];
    }
    
    if (offlineArray.count > 0) {
        [_selectedFiles removeAllObjects];
        return [SyFileProvider.instance deleteFilesWithOfflineFiles:offlineArray];
    }
    return NO;
}

#pragma mark - 查询文件

- (CMPFileManagementRecord *)offlineRecord2ManagementRecord:(CMPOfflineFileRecord *)ofr {
    
    CMPFileManagementRecord *record = [[CMPFileManagementRecord alloc] init];
    record.filePath = ofr.savePath;
    record.fileUrl = ofr.savePath;
    record.fileId = ofr.fileId;
    record.fileName = ofr.fileName;
    record.fileSize = ofr.fileSize;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    NSDate *date = [dateFormatter dateFromString:ofr.downloadTime];
    record.lastModify = [[NSNumber numberWithDouble:[date timeIntervalSince1970]] longValue]*1000;
  
    record.from = ofr.extend2;//来源
    record.fromType = ofr.extend3;
    record.fileType = [NSString isNull:ofr.extend4] ? [CMPFileTypeHandler mineTypeWithPathExtension:record.fileName.pathExtension] : ofr.extend4;
    if ([CMPFileTypeHandler fileMineTypeWithMineType:record.fileType] == CMPFileMineTypeImage) {
        NSString *aIconPath = ofr.extend1;
        if ([NSString isNull:aIconPath]) {
            //需要生成缩略图 并保存到数据库
            NSString *aZipPath = [NSHomeDirectory() stringByAppendingPathComponent:ofr.savePath];
            NSString *aFilePath = [CMPFileManager unEncryptFile:aZipPath fileName:ofr.fileName];
            aIconPath = [[CMPFileManager defaultManager] saveThumbnailImgWithPath:aFilePath];
            ofr.extend1 = aIconPath;
            //更新数据库
            [[SyFileDBProvider instance]updateOfflineFileIconPath:ofr];
        }
        aIconPath = [NSHomeDirectory() stringByAppendingPathComponent:aIconPath];
        record.iconPath = [NSString stringWithFormat:@"file://%@", aIconPath];
    }
         //拼接来源
    if ([NSString isNotNull:record.fromType] &&
        [NSString isNotNull:record.from] &&
        ![record.from containsString:SY_STRING(record.fromType)]) {
        record.from = [SY_STRING(record.fromType) stringByAppendingString:record.from];
    }
    record.isUc = [CMPStringConst fromTypeIsUC:record.fromType];
    
    
    
    return record;
      
}
- (CMPOfflineFileRecord *)managementRecord2OfflineRecord:( CMPFileManagementRecord*)managementRecord {
    CMPOfflineFileRecord *offlineRecord = [[CMPOfflineFileRecord alloc] init];
    offlineRecord.fileId = managementRecord.fileId;
    offlineRecord.fileName = managementRecord.fileName;
    offlineRecord.localName = managementRecord.fileName;
    offlineRecord.fileSuffix = managementRecord.fileName.pathExtension;
    offlineRecord.origin = managementRecord.origin;
    offlineRecord.modifyTime = [NSString stringWithLongLong:managementRecord.lastModify];
    offlineRecord.extend2 = managementRecord.from;
    offlineRecord.extend3 = managementRecord.fromType;//来源类型
    offlineRecord.createDate = @"";
    offlineRecord.creatorName = @"";
    offlineRecord.serverId = kCMP_ServerID;
    offlineRecord.ownerId = CMP_USERID;
 
    offlineRecord.savePath = managementRecord.fileUrl;

    if ([CMPFileManager getFileType:offlineRecord.fileName] == QK_AttchmentType_Image) {
        offlineRecord.extend1 = [managementRecord.iconPath replaceCharacter:@"file://" withString:@""];
    }

    return offlineRecord;
}


- (NSString *)fileTypeString{
    return @"'txt','doc','docx','xls','xlsx','ppt','pptx','pdf','php','htm','html','et','wps','dps'";
}
- (NSString *)imageString{
    return @"'png','jpg','jpeg','bmp','tiff','tif','tga','ico','gif'";
}
- (NSString *)videoString{
    return @"'asf','wma','mp4','mov','m4v'";
}

//doc docx xls xlsx wps（金山文字） et(金山表格) pdf ofd（福昕pdf) 大多数图片格式
+ (NSArray *)getAcceptFileByType:(NSString *)type{
    if ([type hasPrefix:@"."]) {
        type = [type stringByReplacingOccurrencesOfString:@"." withString:@""];
    }
    
    NSMutableSet *set = [NSMutableSet new];
    if([@[@"doc",@"docx"] containsObject:type]){
        [set addObject:@"com.microsoft.word.doc"];
        [set addObject:@"org.openxmlformats.wordprocessingml.document"];
    }else if([@[@"xls",@"xlsx"] containsObject:type]){
        [set addObject:@"com.microsoft.excel.xls"];
        [set addObject:@"org.openxmlformats.spreadsheetml.sheet"];
    }else if([@[@"ppt",@"pptx"] containsObject:type]){
        [set addObject:@"com.microsoft.powerpoint.ppt"];
        [set addObject:@"org.openxmlformats.presentationml.presentation"];
    }else if ([@[@"pdf"] containsObject:type]){
        [set addObject:@"com.adobe.pdf"];
    }else if ([@[@"ofd"] containsObject:type]){
        [set addObject:@"public.ofd"];
    }else if ([@[@"wps"] containsObject:type]){
        [set addObject:@"com.kingsoftoffice.www.wpsoffice.wps"];
    }else if ([@[@"et"] containsObject:type]){
        [set addObject:@"com.kingsoftoffice.www.wpsoffice.et"];
    }else if ([@[@"dwg",@"dxf",@"gif",@"jp2",@"jpe",@"jpeg",@"jpg",@"png",@"svf",@"tif",@"tiff"] containsObject:type]){
        [set addObject:@"public.image"];
    }
    return [set allObjects];
}
//根据type返回手机文件格式
+ (NSArray *)getIphoneAcceptFileByType:(NSString *)type{
    NSMutableSet *set = [NSMutableSet new];
    if([@[@"3gpp",@"mp2",@"mp4",@"mpeg",@"mpg"] containsObject:type]){
        [set addObject:@"public.movie"];
    }else if ([@[@"ac3",@"au",@"mp3",@"ogg",@"mpg"] containsObject:type]){
        [set addObject:@"public.audio"];
    }else if ([@[@"asf"] containsObject:type]){
        [set addObject:@"public.audiovisual-​content"];
    }else if ([@[@"css",@"csv",@"dtd",@"htm",@"html",@"rtf",@"txt",@"xml",@"xhtml"] containsObject:type]){
        [set addObject:@"public.text"];
        [set addObject:@"public.xml"];
        [set addObject:@"public.html"];
    }else if ([@[@"doc",@"dot",@"docx"] containsObject:type]){
        [set addObject:@"com.microsoft.word.doc"];
    }else if ([@[@"dwg",@"dxf",@"gif",@"jp2",@"jpe",@"jpeg",@"jpg",@"png",@"svf",@"tif",@"tiff"] containsObject:type]){
        [set addObject:@"public.image"];
    }else if ([@[@"js",@"json"] containsObject:type]){
        [set addObject:@"public.source-code"];
    }else if ([@[@"pdf"] containsObject:type]){
        [set addObject:@"com.adobe.pdf"];
        [set addObject:@"public.composite-​content"];
    }else if ([@[@"pot",@"pps",@"ppt",@"pptx"] containsObject:type]){
        [set addObject:@"com.microsoft.powerpoint.ppt"];
    }else if ([@[@"wdb",@"wps"] containsObject:type]){
        [set addObject:@"public.data"];
    }else if ([@[@"xlc",@"xlm",@"xls",@"xlsx",@"xlt",@"xlw"] containsObject:type]){
        [set addObject:@"com.microsoft.excel.xls"];
    }else if ([@[@"zip"] containsObject:type]){
        [set addObject:@"public.archive"];
    }
    return [set allObjects];
}



- (NSArray *)searchOfflineFilesWithKeyWord:(NSString *)aKeyWord startIndex:(NSInteger)startIndex rowCount:(NSInteger)rowCount type:(CMPFileMineType)type{
    NSString *typeStr = @"";
    
    switch (type) {
        case CMPFileMineTypeAll:
            break;
         case CMPFileMineTypeFile:
            typeStr = [NSString stringWithFormat:@" in ( %@ )",[self fileTypeString]];
            break;
        case CMPFileMineTypeImage:
            typeStr = [NSString stringWithFormat:@" in ( %@ )",[self imageString]];
            break;
        case CMPFileMineTypeVideo:
            typeStr = [NSString stringWithFormat:@" in ( %@ )",[self videoString]];
            break;
        case CMPFileMineTypeUnknown:
            typeStr = [NSString stringWithFormat:@" not in ( %@ , %@ , %@)",[self fileTypeString],[self imageString],[self videoString]];
            break;
        default:
            break;
    }

    NSArray *offlineResult = [[SyFileDBProvider instance] searchOfflineFilesWithKeyWord:aKeyWord startIndex:startIndex rowCount:rowCount typeStr:typeStr];
    NSMutableArray *result = [[NSMutableArray alloc] init];
       for (CMPOfflineFileRecord *ofr in offlineResult) {
           [result addObject:[self offlineRecord2ManagementRecord:ofr]];
       }
       return result;
}


// 找到显示在最前面的控制器
+ (UIViewController *)p_cmp_frontVc:(UIViewController *)vc {
    if (vc.presentedViewController) {
        return [self p_cmp_frontVc:(vc.presentedViewController)];
    }else if ([vc isKindOfClass:[RDVTabBarController class]]) {
        return [self p_cmp_frontVc:(((RDVTabBarController *)vc).selectedViewController)];
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self p_cmp_frontVc:(((UINavigationController *)vc).visibleViewController)];
    } else {
        NSInteger count = vc.childViewControllers.count;
        for (NSInteger i = count - 1; i >= 0; i--) {
            UIViewController *childVc = vc.childViewControllers[i];
            if (childVc && childVc.view.window) {
                vc = [self p_cmp_frontVc:childVc];
                break;
            }
        }
        return vc;
    }
};

+ (UIViewController *)cmp_frontVc {
    return [self p_cmp_frontVc:(UIApplication.sharedApplication.keyWindow.rootViewController)];
};


@end
