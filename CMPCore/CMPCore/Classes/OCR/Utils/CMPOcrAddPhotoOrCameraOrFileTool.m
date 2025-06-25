//
//  CMPOcrAddPhotoOrCameraOrFileTool.m
//  M3
//
//  Created by Shoujian Rao on 2021/12/7.
//

#import "CMPOcrAddPhotoOrCameraOrFileTool.h"
#import <CMPLib/CMPImagePickerController.h>
#import <CMPLib/CMPCameraViewController.h>


@implementation CMPOcrAddPhotoOrCameraOrFileTool
+ (void)openCustomAlbumFromVC:(UIViewController *)fromVC choosedPhotos:(void(^)(NSArray<CMPOcrFileModel *> *))choosedPhotos cancel:(void(^)(void))cancel {
    CMPImagePickerController *imagePickerVc = [[CMPImagePickerController alloc] initWithMaxImagesCount:9 columnNumber:4 delegate:nil pushPhotoPickerVc:YES];
    imagePickerVc.allowTakePicture = YES;
    imagePickerVc.allowTakeVideo = NO;
    imagePickerVc.allowPickingGif = NO;
    imagePickerVc.allowPickingOriginalPhoto = YES;//是否原图
    
    imagePickerVc.sortAscendingByModificationDate = NO;
    imagePickerVc.statusBarStyle = UIStatusBarStyleLightContent;
    imagePickerVc.showSelectedIndex = YES;
    imagePickerVc.modalPresentationStyle = UIModalPresentationFullScreen;
    [fromVC presentViewController:imagePickerVc animated:YES completion:nil];

    imagePickerVc.didFinishPickingPhotosWithInfosHandle = ^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto, NSArray<NSDictionary *> *infos) {
//        NSString *imageName = [assets[0] valueForKey:@"filename"]; //获取到的是相册中的顺序名字，IMG_4583.PNG
        //获取资源名称，例如tsest.png
        NSMutableArray *fileArray = [NSMutableArray new];
        for (PHAsset *asset in assets) {
            CMPOcrFileModel *file = [CMPOcrFileModel new];
            NSArray *sourcesArr = [PHAssetResource assetResourcesForAsset:asset];
            PHAssetResource *source = sourcesArr.firstObject;
            file.originalName = source.originalFilename;
            file.image = [photos objectAtIndex:[assets indexOfObject:asset]];
            file.fileType = @"jpg";//originalFileName拿到名字会出现heic，但使用均为jpg
            file.imageFileIdentifier = source.assetLocalIdentifier;
            [fileArray addObject:file];
        }
        if (choosedPhotos) {
            choosedPhotos(fileArray);
        }
    };
    imagePickerVc.imagePickerControllerDidCancelHandle = ^{
        if (cancel) {
            cancel();
        }
    };
}
+ (void)openCameraFromVC:(UIViewController *)fromVC cameraPhotos:(void(^)(NSArray<CMPOcrFileModel *> *))cameraPhotos cancel:(void(^)(void))cancel{
    CMPCameraViewController *cameraVc = CMPCameraViewController.alloc.init;
    cameraVc.isNotShowTakeVideo = YES;
    [fromVC presentViewController:cameraVc animated:YES completion:nil];
    cameraVc.usePhotoClicked = ^(UIImage *img, NSDictionary *videoInfo) {
        if (cameraPhotos && img) {
            CMPOcrFileModel *file = [CMPOcrFileModel new];
            file.originalName = [[NSString uuid] stringByAppendingString:@".jpg"];
            file.fileType = @"jpg";
            file.image = img;
            cameraPhotos(@[file]);
        }
    };
    cameraVc.didDismissBlock = ^{
        if (cancel) {
            cancel();
        }
    };
}
@end
