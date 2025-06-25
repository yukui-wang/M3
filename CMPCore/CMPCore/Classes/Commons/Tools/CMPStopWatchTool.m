//
//  CMPStopWatchTool.m
//  M3
//
//  Created by CRMO on 2018/2/24.
//

#import "CMPStopWatchTool.h"

@interface CMPStopWatchTool()

@property (strong, nonatomic) NSMutableArray *nodeList;
@property (assign, nonatomic) CFAbsoluteTime startTime;
@property (assign, nonatomic) CFAbsoluteTime endTime;
@property (assign, nonatomic) CFAbsoluteTime totalTime;

@end

@implementation CMPStopWatchTool

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)start {
    NSLog(@"StopWatch---开始计时");
    self.startTime = CFAbsoluteTimeGetCurrent();
    [self addNodeWithTime:self.startTime description:@"开始计时"];
}

- (void)addNodeWithDescription:(NSString *)description {
    CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
    [self addNodeWithTime:currentTime description:description];
}

- (void)stop {
    NSLog(@"StopWatch---结束计时");
    self.endTime = CFAbsoluteTimeGetCurrent();
    self.totalTime = self.endTime - self.startTime;
    [self addNodeWithTime:self.endTime description:@"结束计时"];
    [self printNode];
    NSLog(@"StopWatch---总耗时：%f", self.totalTime);
}

- (void)printNode {
    __block CFAbsoluteTime previousTime = 0;
    __block NSMutableString *result = [NSMutableString string];
    [self.nodeList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *node = (NSDictionary *)obj;
        CFAbsoluteTime time = [node[@"time"] doubleValue];
        NSString *description = node[@"description"];
        CFAbsoluteTime duration = 0;
        
        if (idx != 0) {
            duration = time - previousTime;
            NSString *message = [NSString stringWithFormat:@"【%@】耗时:%.2f(%.1f)", description, duration, duration / self.totalTime * 100];
            NSLog(@"StopWatch---%@", message);
            [result appendString:message];
            [result appendString:@"\n"];
        }
        
        previousTime = time;
    }];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"启动时间监测" message:result delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alertView show];
//    });
}

- (void)addNodeWithTime:(CFAbsoluteTime)time description:(NSString *)description {
    NSDictionary *dic = @{@"time" : [NSNumber numberWithDouble:time],
                          @"description" : description};
    [self.nodeList addObject:dic];
}

- (NSMutableArray *)nodeList {
    if (!_nodeList) {
        _nodeList = [NSMutableArray array];
    }
    return _nodeList;
}

@end
