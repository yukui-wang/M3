//
//  AttachmentReaderParam.m
//  M3
//
//  Created by youlin on 2019/7/4.
//

#import "AttachmentReaderParam.h"
#import "CMPFileManager.h"

@implementation AttachmentReaderParam

- (id)init
{
    self = [super init];
    if (self) {
        self.canDownload = YES;
        self.canShowInThirdApp = YES;
        self.isShowPrintBtn = [CMPFeatureSupportControl isSupportPrint];
        self.isShowShareBtn = [CMPFeatureSupportControl isShowFileShareButton];
        self.fromType = CMPFileFromTypeComeFromM3;
    }
    return self;
}

- (id)initWithDict:(NSDictionary *)parameter
{
    self = [self init];
    if (self) {
        NSString *path = [parameter objectForKey:@"path"];
        BOOL enableEdit = [[parameter objectForKey:@"edit"] boolValue];
        NSString *fileName = [parameter objectForKey:@"filename"];
        self.fileName = [CMPFileManager handelFileNameBySubString:fileName];
        self.header = [parameter objectForKey:@"headers"];
//        self.url = [path urlEncoding2Times];
        self.url = path;
        self.editMode = enableEdit;
        self.canDownload = YES;
        self.canShowInThirdApp = YES;
        self.fileId = [NSString uuid];
        
        NSString *isShowPrintBtn = [parameter objectForKey:@"isShowPrintBtn"];
        if ([NSString isNotNull:isShowPrintBtn]) {
            self.isShowPrintBtn = [isShowPrintBtn boolValue];
        }
        
        // 分享、下载权限获取
        NSDictionary *extData = [parameter objectForKey:@"extData"];
        if (extData && [extData isKindOfClass:[NSDictionary class]]) {
            NSString *share = [extData objectForKey:@"share"];
            NSString *download = [extData objectForKey:@"download"];
            if ([NSString isNotNull:share]) {
                self.canShowInThirdApp = [share boolValue];
            }
            if ([NSString isNotNull:download]) {
                self.canDownload = [download boolValue];
            }
            self.fileId = [extData objectForKey:@"fileId"];
            self.lastModified = [extData objectForKey:@"lastModified"];
            self.origin = [extData objectForKey:@"origin"];
        }
        
        NSDictionary *attPageMenu = [parameter objectForKey:@"attPageMenu"];
        if ([attPageMenu isKindOfClass:[NSDictionary class]]) {
            self.isShowShareBtn = [attPageMenu[@"share"] boolValue];
        }
        //来源
        NSString *from = [parameter objectForKey:@"from"];
        self.from = [NSString isNull:from]?@"":from;
    }
    return self;
}

@end
