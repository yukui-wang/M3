//
//  CMPAssetModel.h
//  CMPImagePickerController
//
//  Created by 谭真 on 15/12/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    CMPAssetModelMediaTypePhoto = 0,
    CMPAssetModelMediaTypeLivePhoto,
    CMPAssetModelMediaTypePhotoGif,
    CMPAssetModelMediaTypeVideo,
    CMPAssetModelMediaTypeAudio
} CMPAssetModelMediaType;

@class PHAsset;
@interface CMPAssetModel : NSObject

@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, assign) BOOL isSelected;      ///< The select status of a photo, default is No
@property (nonatomic, assign) CMPAssetModelMediaType type;
@property (nonatomic, copy) NSString *timeLength;

/// Init a photo dataModel With a PHAsset
/// 用一个PHAsset实例，初始化一个照片模型
+ (instancetype)modelWithAsset:(PHAsset *)asset type:(CMPAssetModelMediaType)type;
+ (instancetype)modelWithAsset:(PHAsset *)asset type:(CMPAssetModelMediaType)type timeLength:(NSString *)timeLength;

@end


@class PHFetchResult;
@interface CMPAlbumModel : NSObject

@property (nonatomic, strong) NSString *name;        ///< The album name
@property (nonatomic, assign) NSInteger count;       ///< Count of photos the album contain
@property (nonatomic, strong) PHFetchResult *result;

@property (nonatomic, strong) NSArray *models;
@property (nonatomic, strong) NSArray *selectedModels;
@property (nonatomic, assign) NSUInteger selectedCount;

@property (nonatomic, assign) BOOL isCameraRoll;

- (void)setResult:(PHFetchResult *)result needFetchAssets:(BOOL)needFetchAssets;

@end
