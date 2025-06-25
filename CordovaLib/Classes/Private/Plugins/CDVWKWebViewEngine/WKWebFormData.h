//
//  WKWebRequestData.h
//  CordovaLib
//
//  Created by wujiansheng on 2020/7/10.
//  Copyright © 2020 crmo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WKWebFormData : NSObject
@property(nonatomic, copy)NSString *value;
@property(nonatomic, copy)NSString *name;
@property(nonatomic, copy)NSString *fileName;
@property(nonatomic, copy)NSString *mimeType;
- (id)initWithFormData:(NSDictionary *)formData;
- (id)initWithFileData:(NSDictionary *)fileData;
- (NSData *)fileData;
- (NSData *)convertToDataFromBase64:(NSString *)base64;
@end

