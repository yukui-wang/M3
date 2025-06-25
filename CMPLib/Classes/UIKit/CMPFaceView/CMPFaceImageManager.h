//
//  CMPFaceImageManager.h
//  CMPCore
//
//  Created by wujiansheng on 16/9/6.
//
//

#import "CMPObject.h"
#import "CMPFaceImageView.h"
#import "SyFaceDownloadRecordObj.h"

@interface CMPFaceImageManager : CMPObject

+ (CMPFaceImageManager *)sharedInstance;
- (void)clearData;

- (void)fetchfaceImageWithFaceDownloadObj:(SyFaceDownloadObj *)obj container:(CMPFaceImageView *)aImageView complete:(void(^)(UIImage *image))complete cache:(BOOL)aCache;
- (void)fetchfaceImageWithMemberId:(NSString *)aMemberId complete:(void(^)(UIImage *image))complete cache:(BOOL)aCache;
- (void)clearWithMemberId:(NSString *)aMemberId serverId:(NSString *)aServerId;
- (UIImage *)imageWithPath:(NSString *)aPath;
@end
