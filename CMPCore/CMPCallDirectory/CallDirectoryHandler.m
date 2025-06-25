//
//  CallDirectoryHandler.m
//  CMPCallDirectory
//
//  Created by CRMO on 2017/12/1.
//

#import "CallDirectoryHandler.h"

#if DEBUG
NSString * const CallDirectoryHandlerGroupID = @"group.com.seeyon.m3.inhousedis";
#endif

#if RELEASE
NSString * const CallDirectoryHandlerGroupID = @"group.com.seeyon.m3.inhousedis";
#endif

#if APPSTORE
NSString * const CallDirectoryHandlerGroupID = @"group.com.seeyon.m3.appstore.new.phone.CallDirectory";
#endif


NSString * const CallDirectoryHandlerGroupFileName = @"CallDirectoryData";

@interface CallDirectoryHandler () <CXCallDirectoryExtensionContextDelegate>
@property (nonatomic,copy) NSString *appGroupId;
@end

@implementation CallDirectoryHandler

// 开始请求的方法，在打开设置-电话-来电阻止与身份识别开关时，系统自动调用
// 调用CXCallDirectoryManager的reloadExtensionWithIdentifier方法会调用
- (void)beginRequestWithExtensionContext:(CXCallDirectoryExtensionContext *)context {
    context.delegate = self;
#if CUSTOM
    NSString *aPath = [[NSBundle mainBundle] pathForResource:@"CusParams" ofType:@"json"];
    NSString *jsonString = [NSString stringWithContentsOfFile:aPath encoding:NSUTF8StringEncoding error:nil];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(dic && !err)
    {
        _appGroupId = dic[@"appGroupId"];
    }
    NSLog(@"%s\n%@\n%@\n%@\n%@",__func__,aPath,jsonString,dic,_appGroupId);
#else
    _appGroupId = CallDirectoryHandlerGroupID;
#endif
    if (![self addIdentificationPhoneNumbersToContext:context]) {
        NSError *error = [NSError errorWithDomain:@"CallDirectoryHandler" code:2 userInfo:nil];
        [context cancelRequestWithError:error];
        return;
    }
    
    [context completeRequestWithCompletionHandler:nil];
}

// 添加信息标识：需要修改CXCallDirectoryPhoneNumber数组和对应的标识数组；
// CXCallDirectoryPhoneNumber数组存放的号码和标识数组存放的标识要一一对应;
// CXCallDirectoryPhoneNumber数组内的号码要按升序排列
// 注意点：1.电话号码不能重复
//        2.手机号必须加国家码，例如：8615888888888
//        3.固话必须去掉区号的第一个0，加国家码、区号，例如：862861000000
- (BOOL)addIdentificationPhoneNumbersToContext:(CXCallDirectoryExtensionContext *)context {
    // 利用APP Group把待写入系统数据写到共享区域
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:_appGroupId];
    containerURL = [containerURL URLByAppendingPathComponent:CallDirectoryHandlerGroupFileName];
    
    FILE *file = fopen([containerURL.path UTF8String], "r");
    if (!file) {
        return YES;
    }
    char buffer[1024];
    
    // 从APP Group文件中读取信息，写入到Call kit中
    while (fgets(buffer, 1024, file) != NULL) {
        @autoreleasepool {
            NSString *result = [NSString stringWithUTF8String:buffer];
            NSData *jsonData = [result dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:NSJSONReadingAllowFragments
                                                                  error:&err];
            
            if(!err && dic && [dic isKindOfClass:[NSDictionary class]]) {
                NSString *number = dic.allKeys[0];
                NSString *name = dic[number];
                if (number && [number isKindOfClass:[NSString class]] &&
                    name && [name isKindOfClass:[NSString class]]) {
                    CXCallDirectoryPhoneNumber phoneNumber = [number longLongValue];
                    [context addIdentificationEntryWithNextSequentialPhoneNumber:phoneNumber label:name];
                }
            }
            
            dic = nil;
            result = nil;
            jsonData = nil;
            err = nil;
        }
    }
    fclose(file);
    
    return YES;
}

#pragma mark - CXCallDirectoryExtensionContextDelegate

- (void)requestFailedForExtensionContext:(CXCallDirectoryExtensionContext *)extensionContext withError:(NSError *)error {
}

@end
