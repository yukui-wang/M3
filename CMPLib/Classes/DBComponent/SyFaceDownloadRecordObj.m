//
//  SyFaceDownloadRecordObj.m
//  M1Core
//
//  Created by guoyl on 13-5-2.
//  Copyright (c) 2013年 北京致远协创软件有限公司. All rights reserved.
//

#import "SyFaceDownloadRecordObj.h"

@implementation SyFaceDownloadRecordObj

@synthesize extend1;
@synthesize extend2;
@synthesize extend3;
@synthesize extend4;
@synthesize extend5;

@synthesize memberId;
@synthesize serverId;
@synthesize savePath;
@synthesize downloadUrlMd5;
- (void)dealloc 
{
    [extend1 release];
    [extend2 release];
    [extend3 release];
    [extend4 release];
    [extend5 release];
    
    [memberId release];
    [serverId release];
    [savePath release];
    [downloadUrlMd5 release];

    [super dealloc];
}
- (NSString *)fullSavePath
{
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:self.savePath];
    return filePath;
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"downloadUrlMd5" : @"downloaMd5"};
}

@end

@implementation SyFaceDownloadObj


@synthesize memberId;
@synthesize serverId;
@synthesize downloadUrl;
- (void)dealloc
{
    [memberId release];
    [serverId release];
    [downloadUrl release];
    
    [super dealloc];
}

@end

@implementation CMPImageBlockObj

- (void)dealloc
{
    self.imageBlock = nil;
    [super dealloc];
}

@end
