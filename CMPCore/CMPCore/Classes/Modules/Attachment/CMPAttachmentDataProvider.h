//
//  CMPAttachmentDataProvider.h
//  CMPLib
//
//  Created by SeeyonMobileM3MacMini2 on 2022/4/18.
//  Copyright © 2022 crmo. All rights reserved.
//

#import <CMPLib/CMPDataProvider.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPAttachmentDataProvider : CMPDataProvider<CMPDataProviderDelegate>

-(void)fetchAttaPreviewConfigWithParams:(NSDictionary *)params completion:(void(^)(id respData,NSError *error,id ext))completion;
-(void)fetchAttaPreviewUrlWithParams:(NSDictionary *)params completion:(void(^)(id respData,NSError *error,id ext))completion;
-(void)shareAttaActionLogType:(NSInteger)acttype withParams:(NSDictionary *)params completion:(void(^)(id respData,NSError *error,id ext))completion;

@end

NS_ASSUME_NONNULL_END
