//
//  CMPOfflineFile.m
//  CMPLib
//
//  Created by wujiansheng on 16/9/7.
//  Copyright © 2016年 CMPCore. All rights reserved.
//

#import "CMPOfflineFileRecord.h"

@implementation CMPOfflineFileRecord
@synthesize fileId;
@synthesize fileName;
@synthesize localName;
@synthesize fileSuffix;
@synthesize savePath;
@synthesize origin;
@synthesize modifyTime;
@synthesize createDate;
@synthesize downloadTime;
@synthesize fileSize;
@synthesize creatorName;
@synthesize serverId;
@synthesize ownerId;
@synthesize extend1;
@synthesize extend2;
@synthesize extend3;
@synthesize extend4;
@synthesize extend5;

- (void)dealloc {
    [fileId release];
    [fileName release];
    [localName release];
    [fileSuffix release];
    [savePath release];
    [origin release];
    [modifyTime release];
    [createDate release];
    [downloadTime release];
    [fileSize release];
    [creatorName release];
    [serverId release];
    [ownerId release];
    [extend1 release];
    [extend2 release];
    [extend3 release];
    [extend4 release];
    [extend5 release];
    [super dealloc];
}
- (NSString *)fullLocalPath
{
    NSString *aPath = [NSHomeDirectory() stringByAppendingPathComponent:self.savePath];
    return aPath;
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"localName" : @"saveName",
             @"createDate" : @"createTime",
             @"fileSuffix" : @"suffix",
             @"serverId" : @"serverIdentifier"};
}

@end
