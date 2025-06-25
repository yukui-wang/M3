//
//  CMPPhotoPickerController.h
//  CMPImagePickerController
//
//  Created by 谭真 on 15/12/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMPScreenshotControlProtocol.h"

@class CMPAlbumModel;
@interface CMPPhotoPickerController : UIViewController<CMPScreenshotControlProtocol>

@property (nonatomic, assign) BOOL isFirstAppear;
@property (nonatomic, assign) NSInteger columnNumber;
@property (nonatomic, strong) CMPAlbumModel *model;
@end


@interface CMPCollectionView : UICollectionView

@end
