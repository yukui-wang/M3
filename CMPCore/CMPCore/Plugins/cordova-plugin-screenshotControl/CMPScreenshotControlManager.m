//
//  CMPScreenshotControlManager.m
//  M3
//
//  Created by MacBook on 2019/11/26.
//

#import "CMPScreenshotControlManager.h"

static CMPScreenshotControlManager *instance_ = nil;

@interface CMPScreenshotControlManager()<NSCopying>

@end

@implementation CMPScreenshotControlManager

#pragma mark - 单例实现

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance_ = [[self alloc] init];
    });
    return instance_;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance_ = [super allocWithZone:zone];
    });
    return instance_;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - 截屏消息拦截及其处理

#pragma mark 外部方法

- (void)initializeScreenshotConfig {
    [self addNoti];
}

#pragma mark 通知相关
- (void)addNoti {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(userDidTakeScreenshot:) name:UIApplicationUserDidTakeScreenshotNotification object:nil];
}

- (void)userDidTakeScreenshot:(NSNotification *)noti {
    //这里通知传过来的也就是一个UIApplication的对象而已，在这里实际h用处不大
    NSLog(@"did take screenshot");
}

@end
