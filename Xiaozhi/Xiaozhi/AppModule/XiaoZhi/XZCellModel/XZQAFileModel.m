//
//  XZQAFileModel.m
//  M3
//
//  Created by wujiansheng on 2018/10/19.
//

#import "XZQAFileModel.h"
#import "SPTools.h"
#import "XZQAFileView.h"
@implementation XZQAFileModel

- (void)dealloc {
    self.clickFileBlock = nil;
    
    self.filename = nil;
    self.fileId = nil;
    self.type = nil;
    self.extData = nil;
    self.lastModified = nil;
}

- (id)initWithFileName:(NSString *)name fileJson:(NSString *)json {
    
    if (self = [super init]) {
        self.cellClass = @"XZQAFileCell";
        self.ideltifier = @"XZQAFileModelideltifier";
        self.filename = name;
        [self setupWithJsonStr:json];
    }
    return self;
}

- (void)setupWithJsonStr:(NSString *)json {
    NSDictionary *jsonDic = [SPTools dictionaryWithJsonString:json];
    self.filename = [SPTools stringValue:jsonDic forKey:@"filename"];
    self.fileSize = [SPTools longLongValue:jsonDic forKey:@"fileSize"];
    self.fileId = [SPTools stringValue:jsonDic forKey:@"fileId"];
    self.type = [SPTools stringValue:jsonDic forKey:@"type"];
    self.extData = [SPTools dicValue:jsonDic forKey:@"extData"];
    NSString *lastModified = [SPTools stringValue:self.extData forKey:@"lastModified"];
    if ([NSString isNull:lastModified]) {
        self.lastModified = @"";
    }
    else {
        self.lastModified = lastModified;
    }
}

- (CGFloat)cellHeight{
    return [XZQAFileView viewHeight]+20;
}

- (CGFloat) contentBGWidth {
    return  self.scellWidth-144 +31;
}

@end
