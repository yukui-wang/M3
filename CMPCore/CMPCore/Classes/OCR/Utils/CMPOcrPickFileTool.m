//
//  CMPOcrPickFileTool.m
//  M3
//
//  Created by Shoujian Rao on 2021/12/26.
//

#import "CMPOcrPickFileTool.h"
#import <CMPLib/CMPActionSheet.h>
#import "CMPOcrAddPhotoOrCameraOrFileTool.h"
#import "CMPOcrMyFilesViewController.h"
@interface CMPOcrPickFileTool() <CMPMyFilesViewControllerDelegate>

@property (nonatomic, copy) void(^PickCompletion)(NSArray<CMPOcrFileModel *> *);
@property (nonatomic, copy) void(^PickCompletion1)(NSArray<CMPOcrFileModel *> *);
@end

@implementation CMPOcrPickFileTool

- (void)pushPickToVC:(UIViewController *)targetVC Completion:(void(^)(NSArray<CMPOcrFileModel *> *))completion{
    self.PickCompletion1 = completion;
    CMPOcrMyFilesViewController *vc = [[CMPOcrMyFilesViewController alloc] init];
    vc.delegate = self;    
    [targetVC.navigationController pushViewController:vc animated:YES];
}

- (void)showSheetForPickToVC:(UIViewController *)targetVC Completion:(void(^)(NSArray<CMPOcrFileModel *> *))completion{
    self.PickCompletion = completion;
    CMPActionSheet *actionSheet = [CMPActionSheet actionSheetWithTitle:@"智能拍票支持一次拍摄多张纸质发票，电子发票通过微信电子发票或上传附件方式添加" sheetTitles:@[@"智能拍票",@"从相册选取",@"文件上传"] cancleBtnTitle:SY_STRING(@"common_cancel") sheetStyle:CMPActionSheetIconAndTitle callback:^(NSInteger buttonIndex) {
        //0是取消
        if (buttonIndex == 1) {//相机
            [CMPOcrAddPhotoOrCameraOrFileTool openCameraFromVC:targetVC.navigationController cameraPhotos:^(NSArray<CMPOcrFileModel *> * imageArray) {
                if (self.PickCompletion) {
                    self.PickCompletion(imageArray);
                }
            } cancel:nil];
        }else if (buttonIndex == 2){//相册
            [CMPOcrAddPhotoOrCameraOrFileTool openCustomAlbumFromVC:targetVC.navigationController choosedPhotos:^(NSArray<CMPOcrFileModel *> * imageArray) {
                if (self.PickCompletion) {
                    self.PickCompletion(imageArray);
                }
            } cancel:nil];
        }else if (buttonIndex == 3){//文件
            CMPOcrMyFilesViewController *vc = [[CMPOcrMyFilesViewController alloc] init];
            vc.delegate = self;
            [targetVC.navigationController pushViewController:vc animated:YES];
        }
    }];
    actionSheet.iconArr = [@[[UIImage imageNamed:@"ocr_card_control_takephoto"],[UIImage imageNamed:@"ocr_card_control_imagepick"],[UIImage imageNamed:@"ocr_card_control_fileupload"]] mutableCopy];
    [actionSheet show];
}

#pragma mark - CMPMyFilesViewControllerDelegate

//手机文件
- (void)myFilesVCDocumentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSString *> *)urls{
    NSMutableArray *arr = [NSMutableArray new];
    for (NSString *url in urls) {
        CMPOcrFileModel *fileModel = [CMPOcrFileModel new];
        if ([[url lowercaseString] hasSuffix:@".jpg"]) {
            fileModel.fileType = @"jpg";
        }else if ([[url lowercaseString] hasSuffix:@".jpeg"]){
            fileModel.fileType = @"jpeg";
        }else if ([[url lowercaseString] hasSuffix:@".png"]){
            fileModel.fileType = @"png";
        }else if ([[url lowercaseString] hasSuffix:@".heic"]){
            fileModel.fileType = @"heic";
        }else if ([[url lowercaseString] hasSuffix:@".pdf"]){
            fileModel.fileType = @"pdf";
        }
        fileModel.localUrl = url;
        [arr addObject:fileModel];
    }
    if (self.PickCompletion) {
        self.PickCompletion(arr);
    }
    if (self.PickCompletion1) {
        self.PickCompletion1(arr);
    }
}

//我的收藏
- (void)myFilesVCSendClicked:(NSArray<CMPFileManagementRecord *> *)selectedFiles{
    NSMutableArray *fileArray = [NSMutableArray array];
    for (CMPFileManagementRecord *file in selectedFiles) {
        CMPOcrFileModel *fileModel = [CMPOcrFileModel new];
        fileModel.fileId = file.fileId;
        fileModel.originalName = file.fileName;
        fileModel.fileType = file.fileType;
        [fileArray addObject:fileModel];
    }
    if (self.PickCompletion) {
        self.PickCompletion(fileArray);
    }
    if (self.PickCompletion1) {
        self.PickCompletion1(fileArray);
    }
}


@end
