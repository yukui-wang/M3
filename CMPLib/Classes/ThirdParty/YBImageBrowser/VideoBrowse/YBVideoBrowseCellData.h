//
//  YBVideoBrowseCellData.h
//  YBImageBrowserDemo
//
//  Created by 杨波 on 2018/8/28.
//  Copyright © 2018年 杨波. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <CMPLib/CMPStringConst.h>
#import "YBImageBrowserCellDataProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface YBVideoBrowseCellData : NSObject <YBImageBrowserCellDataProtocol>
/* fileSize */
@property (assign, nonatomic) long long fileSize;
/* 视频保存在本地的路径 */
@property (copy, nonatomic) NSString *videoPath;
/* 视频缩率图 */
@property (strong, nonatomic) UIImage *thumbImg;
/* imgName用于保存图片到本地沙盒 */
@property (copy, nonatomic) NSString *imgName;
/* 来源，用于存储到本地 */
@property (copy, nonatomic) NSString *from;
/* 来源类型 */
@property (copy, nonatomic) CMPFileFromType fromType;
/* 消息发送时间 */
@property (copy, nonatomic) NSString *time;

/** The network address of video. */
@property (nonatomic, strong, nullable) NSURL *url;
/* fileId用于收藏 */
@property (copy, nonatomic) NSString *fileId;

/** Video from the system album */
@property (nonatomic, strong, nullable) PHAsset *phAsset;

/** Usually, use 'AVURLAsset'. */
@property (nonatomic, strong, nullable) AVAsset *avAsset;

/** The source rendering object corresponding to the current data model, it's used for animation.
 In general, it's 'UIImageView', but it can also be 'UIView' or 'CALayer'. */
@property (nonatomic, weak, nullable) id sourceObject;

/** As a preview image. Without explicit settings, the first frame will be loaded from the video source and consume some CPU resources. */
@property (nonatomic, strong, nullable) UIImage *firstFrame;

/** The number of play video automatically. Default is 0.
 User interaction may be caton when playing automatically, so don't use automatic play unless really necessary. */
@property (nonatomic, assign) NSUInteger autoPlayCount;

/** The number of repeat play video. Default is 0. */
@property (nonatomic, assign) NSUInteger repeatPlayCount;

/** The default is YES. */
@property (nonatomic, assign) BOOL allowSaveToPhotoAlbum;

/** The default is YES. */
@property (nonatomic, assign) BOOL allowShowSheetView;

/** You can set any data. */
@property (nonatomic, strong, nullable) id extraData;

@end

NS_ASSUME_NONNULL_END
