//
//  RCIM+DownloadMediaMessage.h
//  M3
//
//  Created by 程昆 on 2020/1/3.
//


#import <RongIMKit/RongIMKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CMPDownloadAttachmentTool;

@interface RCIM(DownloadMediaMessage)

@property(nonatomic, strong) NSMutableDictionary *downloadingFileIds;
@property(nonatomic, strong) CMPDownloadAttachmentTool *downloadTool;

@end


NS_ASSUME_NONNULL_END
