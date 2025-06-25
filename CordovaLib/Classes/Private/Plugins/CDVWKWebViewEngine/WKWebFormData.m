//
//  WKWebRequestData.m
//  CordovaLib
//
//  Created by wujiansheng on 2020/7/10.
//  Copyright © 2020 crmo. All rights reserved.
//

#import "WKWebFormData.h"

@implementation WKWebFormData

- (id)initWithFormData:(NSDictionary *)formData {
    if (self = [super init]) {
        self.value = formData[@"value"];
        self.name = formData[@"key"];
        self.mimeType = formData[@"type"];
        self.fileName = formData[@"name"];
    }
    return self;
}


- (id)initWithFileData:(NSDictionary *)fileData {
    if (self = [super init]) {
        self.value = fileData[@"base64"];
        self.name = fileData[@"key"]?:@"file";
        self.mimeType = fileData[@"type"];
        self.fileName = fileData[@"name"] ?:@"";
    }
    return self;
}
- (NSData *)fileData {
    return [self convertToDataFromBase64:self.value];
}
- (NSData *)convertToDataFromBase64:(NSString *)base64 {
    if (!base64 || ![base64 isKindOfClass:[NSString class]] || base64.length == 0) {
        return [NSData data];
    }
    // data:image/png;base64,iVBORw0...
    NSArray<NSString *> *components = [base64 componentsSeparatedByString:@","];
    if (components.count != 2) {
        return [NSData data];
    }
    
    NSString *splitBase64 = components.lastObject;
    NSUInteger paddedLength = splitBase64.length + (splitBase64.length % 4);
    NSString *fixBase64 = [splitBase64 stringByPaddingToLength:paddedLength withString:@"=" startingAtIndex:0];
    NSData *data = [[NSData alloc] initWithBase64EncodedString:fixBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return data;
}

@end
