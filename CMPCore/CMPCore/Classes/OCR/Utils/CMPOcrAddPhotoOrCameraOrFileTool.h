//
//  CMPOcrAddPhotoOrCameraOrFileTool.h
//  M3
//
//  Created by Shoujian Rao on 2021/12/7.
//

#import <Foundation/Foundation.h>
#import "CMPOcrFileModel.h"

@interface CMPOcrAddPhotoOrCameraOrFileTool : NSObject
+ (void)openCustomAlbumFromVC:(UIViewController *)fromVC choosedPhotos:(void(^)(NSArray<CMPOcrFileModel *> *))choosedPhotos cancel:(void(^)(void))cancel;
+ (void)openCameraFromVC:(UIViewController *)fromVC cameraPhotos:(void(^)(NSArray<CMPOcrFileModel *> *))cameraPhotos cancel:(void(^)(void))cancel;
@end
