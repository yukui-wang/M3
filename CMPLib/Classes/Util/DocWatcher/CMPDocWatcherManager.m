//
//  CMPDocWatcherManager.m
//  CMPLib
//
//  Created by SeeyonMobileM3MacMini2 on 2022/2/24.
//  Copyright © 2022 crmo. All rights reserved.
//

#import "CMPDocWatcherManager.h"
#import "MonitorFileChangeUtils.h"

@interface CMPDocWatcherManager ()

@property (nonatomic,copy) NSString *watchFolderPath;
@property (nonatomic,strong) MonitorFileChangeUtils *fileMonitor;

@end

@implementation CMPDocWatcherManager

static CMPDocWatcherManager *_instance;

+(CMPDocWatcherManager *)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[CMPDocWatcherManager alloc] init];
    });
    return _instance;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        _watchFolderPath = [self defaultPath];
    }
    return self;
}

-(NSString *)defaultPath
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

-(void)invalidate
{
    _watchFolderPath = nil;
    _fileMonitor = nil;
}

-(void)watchFolderWithPath:(NSString *)folderPath
{
    [self invalidate];
    if (!folderPath || folderPath.length==0) {
        _watchFolderPath = [self defaultPath];
    }
    [self directoryDidChange];
    
    _fileMonitor = [MonitorFileChangeUtils new];
    [_fileMonitor watcherForPath:_watchFolderPath block:^(NSInteger type) {
        [self directoryDidChange];
    }];
}

- (void)directoryDidChange
{
    if (!_watchFolderPath) {
        return;
    }
    NSString *documentsDirectoryPath = _watchFolderPath;
    
    NSArray *documentsDirectoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectoryPath error:NULL];
    
    NSLog(@"ks log --- %s -- watchPath: %@ \n filesInPath : %@", __FUNCTION__,documentsDirectoryPath,documentsDirectoryContents);
//    for (NSString* curFileName in [documentsDirectoryContents objectEnumerator])
//    {
//        NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:curFileName];
//        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
//    }
}

@end
