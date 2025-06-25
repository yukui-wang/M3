//
//  CMPDocWatcherManager.h
//
//  CMPLib
//  Created by SeeyonMobileM3MacMini2 on 2022/2/24.
//  Copyright © 2022 crmo. All rights reserved.
//

#import <CMPLib/CMPObject.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPDocWatcherManager : CMPObject

+(CMPDocWatcherManager *)shareManager;
-(void)watchFolderWithPath:(NSString *)folderPath;
-(void)invalidate;

@end

NS_ASSUME_NONNULL_END
