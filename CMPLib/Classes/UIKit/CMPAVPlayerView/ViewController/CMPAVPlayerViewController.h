//
//  CMPAVPlayerViewController.h
//  CMPLib
//
//  Created by MacBook on 2019/12/20.
//  Copyright © 2019 crmo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CMPLib/CMPStringConst.h>
#import <CMPLib/CMPScreenshotControlProtocol.h>

typedef NS_ENUM(NSInteger, CMPAVPlayerPalyType) {
    CMPAVPlayerPalyTypeVideo = 0,
    CMPAVPlayerPalyTypeAudio   = 1,
};


NS_ASSUME_NONNULL_BEGIN

@interface CMPAVPlayerViewController : UIViewController<CMPScreenshotControlProtocol>
/* mediaUrlArr */
@property (strong, nonatomic) NSArray *mediaUrlArr;
/* rcImgModels */
@property (strong, nonatomic) NSArray *rcImgModels;
/* 是否能分享,默认NO */
@property (assign, nonatomic) BOOL canNotShare;
/* 是否能收藏,默认NO */
@property (assign, nonatomic) BOOL canNotCollect;
/* 是否能保存,默认NO */
@property (assign, nonatomic) BOOL canNotSave;
/* default CMPAVPlayerPalyTypeVideo */
@property (assign, nonatomic)CMPAVPlayerPalyType palyType;
/* default NO */
@property (assign, nonatomic)BOOL isOnlinePlay;
/* 音乐封面 仅在CMPAVPlayerPalyTypeAudio有效 */
@property (copy, nonatomic)NSString *audioCoverImageUrlStr;

/* url */
@property (copy, nonatomic) NSURL *url;
/* urlString */
@property (copy, nonatomic) NSString *urlString;
/* messaageModel */
@property (weak, nonatomic) id msgModel;
/* 来源 */
@property (copy, nonatomic) NSString *from;
/* 来源a类型 */
@property (copy, nonatomic) CMPFileFromType fromType;
/* fileId用于收藏 */
@property (copy, nonatomic) NSString *fileId;
/* 用于自动保存 */
@property (copy, nonatomic) NSString *fileName;
/* 是否自动保存video */
@property (assign, nonatomic) BOOL autoSave;
/* 是否显示相册图标 */
@property (assign, nonatomic) BOOL showAlbumBtn;

/* 用于恢复旋转状态 默认为NO */
@property (nonatomic, assign) BOOL isFromControllerAllowRotation;

- (void)showFromVc:(UIViewController *)fromVc fromView:(UIView *)fromView;

@end

NS_ASSUME_NONNULL_END
