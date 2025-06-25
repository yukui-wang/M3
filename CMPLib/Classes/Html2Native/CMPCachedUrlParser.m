//
//  CMPCachedUrlParser.m
//  CMPCore
//
//  Created by youlin on 16/5/17.
//
//

#import "CMPCachedUrlParser.h"
#import "CMPCachedResManager.h"
#import "CMPV5ProductEditionModel.h"

#ifdef CMPCachedUrlParser_GOV
#import "CMPCore.h"
#endif

@implementation CMPCachedUrlParser

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
    });
}

+ (BOOL)chacedUrl:(NSURL *)aUrl {
    if ([aUrl.scheme isEqualToString:@"jsbridge"]) {
        return NO;
    }
    NSString *host = aUrl.host;
    if ([CMPCachedResManager checkCachedResWithHost:host]) {
        return YES;
    }
    return NO;
}

+ (NSString *)mimeTypeWithSuffix:(NSString *)aSuffix {
    NSString *mimeType = @"";
    aSuffix = [aSuffix lowercaseString];
    if([aSuffix isEqualToString:@"js"] || [aSuffix isEqualToString:@"s3js"]){
        mimeType = @"text/javascript";
    }
    else if([aSuffix isEqualToString:@"png"]) {
        mimeType = @"image/png";
    }
    else if([aSuffix isEqualToString:@"jgeg"]) {
        mimeType = @"image/jgeg";
    }
    else if([aSuffix isEqualToString:@"css"] || [aSuffix isEqualToString:@"s3css"]){
        mimeType = @"text/css";
    }
    else if([aSuffix isEqualToString:@"html"] || [aSuffix isEqualToString:@"htm"]){
        mimeType = @"text/html";
    }
    return mimeType;
}

+ (NSString *)govPathWithPath:(NSString *)path {
    NSString *aProductSuffix = [CMPCore sharedInstance].V5ProductEdition.suffix;
    if ([NSString isNull:aProductSuffix]) {
        return path;
    }
    
    NSURL *url = [NSURL URLWithString:path];
    NSString *lastPath = url.lastPathComponent;
    NSString *lastPathExtension = [lastPath pathExtension];
    
    // 判断是否有后缀，只处理有后缀的资源文件
    if ([NSString isNull:lastPathExtension]) {
        return path;
    }
    
    NSString *aName = [lastPath stringByDeletingPathExtension];
    NSString *aNewFileName = [[aName stringByAppendingString:aProductSuffix] stringByAppendingPathExtension:lastPathExtension];
    NSString *aNewFilePath = [path replaceCharacter:lastPath withString:aNewFileName];
    //获取url路径，因为path后面可能拼接参数
    NSURL *aNewUrl = [NSURL URLWithString:aNewFilePath];
    NSString *localPath = aNewUrl.path;
    if (![[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
        return path;
    }
    return aNewFilePath;
}

+ (NSString *)cachedPathWithUrl:(NSURL *)aUrl {
    if (![CMPCachedUrlParser chacedUrl:aUrl]) {
        return nil;
    }
    NSString *host = aUrl.host;
    // 根据host找到对应资源包
    NSMutableArray *urlPaths  = [NSMutableArray arrayWithArray:aUrl.pathComponents];
    if (urlPaths.count == 0) {
        return nil;
    }
    if (urlPaths.count == 1) {
        [urlPaths addObject:@"v"];
    }
    NSString *aVersion = [urlPaths objectAtIndex:1];
    NSString *aRootPath = [CMPCachedResManager rootPathWithHost:host version:aVersion];
    NSLog(@"%s:host:%@,rootpath:%@",__func__,host,aRootPath);
    if (!aRootPath) {
        return nil;
    }
    NSMutableString *resPath = [[NSMutableString alloc] initWithFormat:@"file://%@", aRootPath];
    NSInteger aCount = urlPaths.count;
    // add by guoyl f
    NSInteger startIndex = 1;
    if ([aVersion.lowercaseString hasPrefix:@"v"]) {
        startIndex = 2;
    }
    // add end
    for (NSInteger i = startIndex; i < aCount; i ++) {
        [resPath appendString:@"/"];
        NSString *aStr = [urlPaths objectAtIndex:i];
        if ([aStr isEqualToString:@"__CMPSHELL_PLATFORM__"]) {
            [resPath appendString:@"ios"];
        }
        else {
            [resPath appendString:aStr];
        }
    }
    NSString *aQuery = aUrl.query;
    if (aQuery) {
        [resPath appendString:@"?"];
        [resPath appendString:aQuery];
    }
    else {
        NSString *absoluteStr = aUrl.absoluteString;
        // add for #
        NSArray *paramList = [absoluteStr componentsSeparatedByString:@"#"];
        if (paramList.count == 2) {
            [resPath appendString:@"#"];
            [resPath appendString:[paramList lastObject]];
        }
    }
    NSString *result = [resPath copy];
#ifdef CMPCachedUrlParser_GOV
    result = [[self class] govPathWithPath:result];
#endif
    return result;
}

static NSData *_cordovaJSData = nil;

+ (NSData *)cachedDataWithUrl:(NSURLRequest *)aRequest {
    NSURL *aUrl = aRequest.URL;
    NSString *resPath = [CMPCachedUrlParser cachedPathWithUrl:aUrl];
    if (!resPath) {
        NSLog(@"can't find the file path:%@", aUrl.absoluteString);
        return nil;
    }
    if ([resPath containsString:@"cordova.js"]) {
        if (!_cordovaJSData) {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"cordova" ofType:@"js"];
            _cordovaJSData = [[NSData alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]];
        }
        return _cordovaJSData;
    }
    // if cordova.js
    NSLog(@"file path:%@", resPath);
    NSData *data = [[NSData alloc ] initWithContentsOfURL:[NSURL URLWithString:resPath]];
    if (!data) {
        NSLog(@"path:%@,data is null.", aUrl.absoluteString);
    }
    return data;
}


+ (void)clearCache {
}

@end
