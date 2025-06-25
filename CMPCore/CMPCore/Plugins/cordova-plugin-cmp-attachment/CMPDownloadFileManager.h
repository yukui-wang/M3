//
//  CMPDownloadFileManager.h
//  M3
//
//  Created by wujiansheng on 2018/3/27.
//

#import <CMPLib/CMPObject.h>

@protocol CMPDownloadFileManagerDelegate;
@interface CMPDownloadFileManager : CMPObject
+ (CMPDownloadFileManager *)defaultManager;
- (void)downloadFileWithInfo:(NSDictionary *)dic callbackId:(NSString *)callbackId delegate:(id <CMPDownloadFileManagerDelegate>) delegate;
- (void)removeDelegate:(id <CMPDownloadFileManagerDelegate>) delegate;
@end

@protocol CMPDownloadFileManagerDelegate <NSObject>
- (void)managerDidFinishDownloadFile:(NSDictionary *)info callbackId:(NSString *)callbackId;
- (void)managerDidFailDownloadFile:(NSDictionary *)info callbackId:(NSString *)callbackId;
@end
