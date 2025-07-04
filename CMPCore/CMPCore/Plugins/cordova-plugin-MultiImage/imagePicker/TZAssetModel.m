//
//  TZAssetModel.m
//  TZImagePickerController
//
//  Created by 谭真 on 15/12/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import "TZAssetModel.h"
#import "TZImageManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@interface TZAssetModel ()
@property (nonatomic, assign) PHImageRequestID imageRequestID;

@end
@implementation TZAssetModel

+ (instancetype)modelWithAsset:(id)asset type:(TZAssetModelMediaType)type{
    TZAssetModel *model = [[TZAssetModel alloc] init];
    model.asset = asset;
    model.isSelected = NO;
    model.type = type;
    return model;
}

+ (instancetype)modelWithAsset:(id)asset type:(TZAssetModelMediaType)type timeLength:(NSString *)timeLength {
    TZAssetModel *model = [self modelWithAsset:asset type:type];
    model.timeLength = timeLength;
    return model;
}

- (void)requestImageDataSize
{
    if (self.imageDataSize != 0 ) {
        return;
    }
    id asset = self.asset;
    if ([asset isKindOfClass:[PHAsset class]]) {
       PHImageRequestID imageRequestID = [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            if (self.type != TZAssetModelMediaTypeVideo) self.imageDataSize = imageData.length;
        }];
        if (imageRequestID && self.imageRequestID && imageRequestID != self.imageRequestID) {
            [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
        }
        self.imageRequestID = imageRequestID;
        
    } else if ([asset isKindOfClass:[ALAsset class]]) {
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        if (self.type != TZAssetModelMediaTypeVideo)  self.imageDataSize= (NSInteger)representation.size;
    }
}

@end



@implementation TZAlbumModel

- (void)setResult:(id)result {
    _result = result;
    BOOL allowPickingImage = [[[NSUserDefaults standardUserDefaults] objectForKey:@"tz_allowPickingImage"] isEqualToString:@"1"];
    BOOL allowPickingVideo = [[[NSUserDefaults standardUserDefaults] objectForKey:@"tz_allowPickingVideo"] isEqualToString:@"1"];
    [[TZImageManager manager] getAssetsFromFetchResult:result allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage completion:^(NSArray<TZAssetModel *> *models) {
        _models = models;
        if (_selectedModels) {
            [self checkSelectedModels];
        }
    }];
}

- (void)setSelectedModels:(NSArray *)selectedModels {
    _selectedModels = selectedModels;
    if (_models) {
        [self checkSelectedModels];
    }
}

- (void)checkSelectedModels {
    self.selectedCount = 0;
    NSMutableArray *selectedAssets = [NSMutableArray array];
    for (TZAssetModel *model in _selectedModels) {
        [selectedAssets addObject:model.asset];
    }
    for (TZAssetModel *model in _models) {
        if ([[TZImageManager manager] isAssetsArray:selectedAssets containAsset:model.asset]) {
            self.selectedCount ++;
        }
    }
}

@end
