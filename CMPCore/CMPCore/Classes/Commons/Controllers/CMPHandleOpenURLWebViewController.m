//
//  CMPNotificationWebViewController.m
//  CMPCore
//
//  Created by youlin on 2016/8/29.
//
//

#import "CMPHandleOpenURLWebViewController.h"
#import <CMPLib/CMPCachedUrlParser.h>
#import <CMPLib/CMPAppManager.h>

@implementation CMPHandleOpenURLWebViewController

- (void)dealloc {
    if (_didDealloc) {
        _didDealloc();
    }
}

- (void)viewDidLoad {
    self.hideBannerNavBar = YES;
    self.startPage = [self getEntryWithAppId:self.appId version:self.version entryName:self.entryName];
    [super viewDidLoad];
}

- (NSString *)getEntryWithAppId:(NSString *)appId version:(NSString *)aVersion entryName:(NSString *)aEntryName {
    NSDictionary *result = [CMPAppManager appEntrysWithAppId:appId version:aVersion serverId:kCMP_ServerID owerId:kCMP_OwnerID];
    NSString *path = [result objectForKey:@"path"];
    NSString *aEntryPath = [result objectForKey:aEntryName];
    if ([NSString isNull:aEntryPath]) {
        return nil;
    }
//    NSString *aStr = [[CMPAppManager documentWithPath:path] stringByAppendingPathComponent:aEntryPath];
    NSString *aStr = [path stringByAppendingPathComponent:aEntryPath];
    aStr = [@"file://" stringByAppendingString:aStr];
    return aStr;
}

@end
