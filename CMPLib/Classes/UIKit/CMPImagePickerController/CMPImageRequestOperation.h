//
//  CMPImageRequestOperation.h
//  CMPImagePickerControllerFramework
//
//  Created by 谭真 on 2018/12/20.
//  Copyright © 2018 谭真. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPImageRequestOperation : NSOperation

typedef void(^CMPImageRequestCompletedBlock)(UIImage *photo, NSDictionary *info, BOOL isDegraded);
typedef void(^CMPImageRequestProgressBlock)(double progress, NSError *error, BOOL *stop, NSDictionary *info);

@property (nonatomic, copy, nullable) CMPImageRequestCompletedBlock completedBlock;
@property (nonatomic, copy, nullable) CMPImageRequestProgressBlock progressBlock;
@property (nonatomic, strong, nullable) PHAsset *asset;
@property (nonatomic, assign) BOOL needOriginalImage;

@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;

- (instancetype)initWithAsset:(PHAsset *)asset needOriginalImage:(BOOL)needOriginalImage completion:(CMPImageRequestCompletedBlock)completionBlock progressHandler:(CMPImageRequestProgressBlock)progressHandler;
- (void)done;
@end

NS_ASSUME_NONNULL_END
