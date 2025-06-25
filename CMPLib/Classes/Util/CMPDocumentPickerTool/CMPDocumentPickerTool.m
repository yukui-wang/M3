//
//  CMPDocumentPickerTool.m
//  FileAccess_iCloud_QQ_Wechat
//
//  Created by 程昆 on 2018/12/13.
//  Copyright © 2018 zzh. All rights reserved.
//



#import "CMPDocumentPickerTool.h"
#import "CMPICloudManager.h"

NSUniformIdentifierType const UniformIdentifierTypeData = @"public.data";

@interface CMPDocumentPickerTool ()<UIDocumentPickerDelegate>

@property (nonatomic,strong)NSArray *fileTypeArr;
@property (nonatomic,strong)UIDocumentPickerViewController *documentPickerController;
@property (nonatomic,copy)DownloadBlock downloadCompleteBlock;
@property (nonatomic,copy)FailedBlock downloadFailedBlock;

@end

static CMPDocumentPickerTool *strongSelf = nil;

@implementation CMPDocumentPickerTool

-(instancetype)init{
    
    if (self = [super init]) {
        
        self.fileTypeArr = @[UniformIdentifierTypeData];
        self.documentPickerController = [[UIDocumentPickerViewController alloc]
                                         initWithDocumentTypes:self.fileTypeArr
                                         inMode:UIDocumentPickerModeOpen];
        self.documentPickerController.delegate = self;
        strongSelf = self;
        
    }
    return self;
}

-(instancetype)initWithFileTypeArray:(NSArray<NSUniformIdentifierType> *)array{
    
    if (self = [super init]) {
        
        self.fileTypeArr = array;
        self.documentPickerController = [[UIDocumentPickerViewController alloc]
                                         initWithDocumentTypes:self.fileTypeArr
                                         inMode:UIDocumentPickerModeOpen];
        self.documentPickerController.delegate = self;
        strongSelf = self;
        
    }
    return self;
    
}

-(void)transmitDataWithIsSeccess:(BOOL)isSeccess fliePath:(NSString *)filePath flieName:(NSString *)fileName fileExtension:(NSString *)fileExtension{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (isSeccess) {
            
            if (self.downloadCompleteBlock) {
                
                self.downloadCompleteBlock(filePath,fileName,fileExtension);
                
            }
            
        }else{
            
            
            if (self.downloadFailedBlock) {
                
                NSError *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:1 userInfo:@{NSLocalizedFailureReasonErrorKey:@"读取文件失败,从iCloud读取文件写入沙盒失败"}];
                self.downloadFailedBlock(error);
                
            }
            
            
        }
        
        strongSelf = nil;
        
    });
    
}

-(void)pickDocumentfromController:(UIViewController *)controller downloadCompleteBlock:(DownloadBlock)completeBlock downloadFailedBlock:(FailedBlock)failedBlock {
    
    self.downloadCompleteBlock = completeBlock;
    self.downloadFailedBlock = failedBlock;
    [controller presentViewController:self.documentPickerController animated:YES completion:nil];
    
}

+(void)documentPickerToolPickDocumentfromController:(UIViewController *)controller downloadCompleteBlock:(DownloadBlock)completeBlock downloadFailedBlock:(FailedBlock)failedBlock{
    
    CMPDocumentPickerTool *tool = [[CMPDocumentPickerTool alloc]init];
    tool.downloadCompleteBlock = completeBlock;
    tool.downloadFailedBlock = failedBlock;
    [controller presentViewController:tool.documentPickerController animated:YES completion:nil];
    
}

+(void)documentPickerToolPickDocumentFileTypeArray:(NSArray<NSUniformIdentifierType> *)array fromController:(UIViewController *)controller downloadCompleteBlock:(DownloadBlock)completeBlock downloadFailedBlock:(FailedBlock)failedBlock{
    
    CMPDocumentPickerTool *tool = [[CMPDocumentPickerTool alloc]initWithFileTypeArray:array];
    tool.downloadCompleteBlock = completeBlock;
    tool.downloadFailedBlock = failedBlock;
    [controller presentViewController:tool.documentPickerController animated:YES completion:nil];
    
}

#pragma mark - UIDocumentPickerDelegate
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    
    NSArray *array = [[url absoluteString] componentsSeparatedByString:@"/"];
    NSString *fileName = [array lastObject];
    fileName = [fileName stringByRemovingPercentEncoding];
    NSString *fileExtension = [fileName pathExtension];
    
    //if ([CMPICloudManager iCloudEnable]) {
    [CMPICloudManager downloadWithDocumentURL:url callBack:^(id obj) {
        NSData *data = obj;
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            if ([fileManager fileExistsAtPath:filePath]) {
                
                [self transmitDataWithIsSeccess:YES fliePath:filePath flieName:fileName fileExtension:fileExtension];
                
            }else{
               
                //写入沙盒Documents
               BOOL seccess =   [data writeToFile:filePath atomically:YES];
               if (seccess) {
                   
                   [self transmitDataWithIsSeccess:YES fliePath:filePath flieName:fileName fileExtension:fileExtension];
                   
               }else{
                   
                   [self transmitDataWithIsSeccess:NO fliePath:nil flieName:nil fileExtension:nil];
                   
               }
                
                
            }
    
        });
        
    }];
    
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller{
    
    strongSelf = nil;
    
}

@end
