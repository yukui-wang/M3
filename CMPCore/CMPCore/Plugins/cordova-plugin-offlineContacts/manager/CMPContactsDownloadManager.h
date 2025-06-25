//
//  CMPContactsDownloadManager.h
//  CMPCore
//
//  Created by wujiansheng on 2017/2/18.
//
//

#import <CMPLib/CMPObject.h>
@protocol CMPContactsDownloadManagerDelegate;
@interface CMPContactsDownloadManager : CMPObject

- (void)updateContactsWithMD5Dic:(NSDictionary *)md5Dic
                     settingInfo:(NSString *)info
                        delegate:(id<CMPContactsDownloadManagerDelegate>)delegate;
- (void)clearData;

@end


@protocol CMPContactsDownloadManagerDelegate <NSObject>

- (void)managerBeginUpdateContacts:(CMPContactsDownloadManager *)manager;
- (void)managerEndUpdateContacts:(CMPContactsDownloadManager *)manager;
- (void)manager:(CMPContactsDownloadManager *)manager failUpdateContactsWithMessage:(NSString *)message;
- (void)manager:(CMPContactsDownloadManager *)manager saveMd5:(NSString *)md5 type:(NSString *)type;

- (void)managerFinishDownLoadTable:(CMPContactsDownloadManager *)manager
                              info:(NSDictionary *)info
                         filePaths:(NSArray *)filePath;

- (void)manager:(CMPContactsDownloadManager *)manager finishLoadSettings:(NSArray *)settings;

- (void)managerShouldClearTables:(CMPContactsDownloadManager *)manager;



@end
