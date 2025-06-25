//
//  CMPWKURLSchemeHandler.m
//  CMPLib
//
//  Created by SeeyonMobileM3MacMini2 on 2023/5/24.
//  Copyright © 2023 crmo. All rights reserved.
//

#import "CMPWKURLSchemeHandler.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface CMPWKURLSchemeHandler()

@end

@implementation CMPWKURLSchemeHandler

- (void)webView:(nonnull WKWebView *)webView startURLSchemeTask:(nonnull id<WKURLSchemeTask>)urlSchemeTask {
    NSLog(@"%s, URL:%@", __func__, urlSchemeTask.request.URL);
    NSString *pathExtension = urlSchemeTask.request.URL.pathExtension;
    if (self.delegate && [self.delegate respondsToSelector:@selector(dataForRequestUrl:)]) {
        NSData *respData = [self.delegate dataForRequestUrl:urlSchemeTask.request.URL];
        if (!respData) {
           //构建一个本地默认标识的错误回执
//            respData = [@"cmp no local file" dataUsingEncoding:NSUTF8StringEncoding];
            //如果没有加载到资源，返回404错误，前端会根据404去加载其他资源
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:404 userInfo:nil];
            [self didFailWithError:urlSchemeTask error:error];
            [self didFinish:urlSchemeTask];
            return;
        }
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:urlSchemeTask.request.URL MIMEType:[CMPWKURLSchemeHandler getMIMETypeFromPathExtension:pathExtension] expectedContentLength:respData.length textEncodingName:nil];
        [self didReceiveResponse:urlSchemeTask response:response];
        [self didReceiveData:urlSchemeTask data:respData];
        [self didFinish:urlSchemeTask];
    }else{
        //走网络请求
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlSchemeTask.request.URL];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            [self didReceiveResponse:urlSchemeTask response:response];
            [self didReceiveData:urlSchemeTask data:data];
            if (error) {
                [self didFailWithError:urlSchemeTask error:error];
            } else {
                [self didFinish:urlSchemeTask];
            }
        }];
        [dataTask resume];
    }
}

- (void)webView:(nonnull WKWebView *)webView stopURLSchemeTask:(nonnull id<WKURLSchemeTask>)urlSchemeTask {
    [self didFinish:urlSchemeTask];
}


+ (NSString *)getMIMETypeFromPathExtension:(NSString *)pathExtension {
    NSString *MIMEType = @"text/plain";
    
    if ([pathExtension isEqualToString:@"html"]
        ||[pathExtension isEqualToString:@"htm"]) {
        MIMEType = @"text/html";
    } else if ([pathExtension isEqualToString:@"js"]
               ||[pathExtension isEqualToString:@"s3js"]) {
        MIMEType = @"application/javascript";
    } else if ([pathExtension isEqualToString:@"css"]
               ||[pathExtension isEqualToString:@"s3css"]) {
        MIMEType = @"text/css";
    }
//    else if ([pathExtension isEqualToString:@"png"]) {
//        MIMEType = @"image/png";
//    } else if ([pathExtension isEqualToString:@"jpeg"]) {
//        MIMEType = @"image/jpeg";
//    } else if ([pathExtension isEqualToString:@"json"]) {
//        MIMEType = @"application/json";
//    } else if ([pathExtension isEqualToString:@"xml"]) {
//        MIMEType = @"application/xml";
//    } else if ([pathExtension isEqualToString:@"pdf"]) {
//        MIMEType = @"application/pdf";
//    } else if ([pathExtension isEqualToString:@"gif"]) {
//        MIMEType = @"image/gif";
//    } else if ([pathExtension isEqualToString:@"mp3"]) {
//        MIMEType = @"audio/mpeg";
//    } else if ([pathExtension isEqualToString:@"mp4"]) {
//        MIMEType = @"video/mp4";
//    } else if ([pathExtension isEqualToString:@"zip"]) {
//        MIMEType = @"application/zip";
//    }
//    else{
//        MIMEType = @"application/octet-stream";
//    }
    else {
        CFStringRef pt = (__bridge_retained CFStringRef)pathExtension;
        CFStringRef type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pt, NULL);
        CFRelease(pt);

        MIMEType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType);
        if (type != NULL) {
            CFRelease(type);
        }
    }
    
    return MIMEType;
}


- (void)didReceiveResponse:(id<WKURLSchemeTask>)urlSchemeTask response:(NSURLResponse *)response
{
    @try {
        [urlSchemeTask didReceiveResponse:response];
        NSLog(@"didReceiveResponse exception: null");
    } @catch (NSException *exception) {
        NSLog(@"didReceiveResponse exception: %@", exception);
    }
}

- (void)didReceiveData:(id<WKURLSchemeTask>)urlSchemeTask data:(NSData *)data
{
    @try {
        [urlSchemeTask didReceiveData:data];
        NSLog(@"didReceiveData exception: null");
    } @catch (NSException *exception) {
        NSLog(@"didReceiveData exception: %@", exception);
    }
}

- (void)didFinish:(id<WKURLSchemeTask>)urlSchemeTask
{
    @try {
        [urlSchemeTask didFinish];
        NSLog(@"didFinish exception: null");
    } @catch (NSException *exception) {
        NSLog(@"didFinish exception: %@", exception);
    }
}

- (void)didFailWithError:(id<WKURLSchemeTask>)urlSchemeTask error:(NSError *)error
{
    @try {
        [urlSchemeTask didFailWithError:error];
        NSLog(@"didFailWithError exception: null");
    } @catch (NSException *exception) {
        NSLog(@"didFailWithError exception: %@", exception);
    }
}

@end
