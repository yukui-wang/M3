//
//  CMPAttachmentHelper.h
//  CMPLib
//
//  Created by SeeyonMobileM3MacMini2 on 2022/4/18.
//  Copyright © 2022 crmo. All rights reserved.
//

#import <CMPLib/CMPObject.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPAttachmentHelper : CMPObject

+(CMPAttachmentHelper *)shareManager;
-(BOOL)isSupportOnlinePreviewWithFileExtension:(NSString *)extention;
-(BOOL)isSupportOnlinePreviewDownload;
-(void)updateAttaPreviewConfigWithCompletion:(void(^)(id respData,NSError *error,id ext))completion;
-(void)fetchAttaPreviewUrlWithFileId:(NSString *)fileId completion:(void(^)(NSString *previewUrlStr,NSError *error,id ext))completion;
-(void)shareAttaActionLogType:(NSInteger)acttype withParams:(NSDictionary *)params completion:(void(^)(id respData,NSError *error,id ext))completion;
+(void)free;

@end

NS_ASSUME_NONNULL_END
