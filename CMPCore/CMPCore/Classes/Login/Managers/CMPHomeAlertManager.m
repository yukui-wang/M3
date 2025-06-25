//
//  CMPHomeAlertManager.m
//  M3
//
//  Created by CRMO on 2019/1/23.
//

#import "CMPHomeAlertManager.h"
#import <CMPLib/NSDate+CMPDate.h>

@interface CMPHomeAlertTask : CMPObject
@property (copy, nonatomic) CMPHomeAlertShowBlock showBlock;
@property (copy, nonatomic) NSString *taskID;
@property (assign, nonatomic) NSUInteger priority;
@end

@implementation CMPHomeAlertTask
@end


@interface CMPHomeAlertManager()
/** 任务队列 **/
@property (strong, nonatomic) NSMutableArray<CMPHomeAlertTask *> *taskQueue;
/** 当前正在执行的任务 **/
@property (strong, nonatomic) CMPHomeAlertTask *runningTask;
@property (assign, nonatomic) BOOL isReady;
@end

NSString * const CMPHomeAlertTaskManagerAllTaskDidFinish = @"CMPHomeAlertTaskManagerAllTaskDidFinish";

@implementation CMPHomeAlertManager

#pragma mark-
#pragma mark 单例

+ (instancetype)sharedInstance {
    static CMPHomeAlertManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
        [[NSNotificationCenter defaultCenter] addObserver:instance selector:@selector(removeAllTask) name:kNotificationName_UserLogout object:nil];
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (id)copyWithZone:(struct _NSZone *)zone {
    return self;
}

#pragma mark-
#pragma mark 任务管理

- (NSString *)pushTaskWithShowBlock:(CMPHomeAlertShowBlock)showBlock
                           priority:(NSUInteger)priority {
    NSString *taskID = [NSString stringWithFormat:@"%f", CFAbsoluteTimeGetCurrent()];
    CMPHomeAlertTask *task = [[CMPHomeAlertTask alloc] init];
    task.showBlock = showBlock;
    task.priority = priority;
    task.taskID = taskID;
    [self _pushTask:task];
    if ((self.isReady || (priority >= CMPHomeAlertPriorityShowBeforeLogin)) && !self.runningTask) {
        [self runFrontTask];
    }
    return taskID;
}

- (void)taskDone {
//    if (!self.runningTask || ![self.runningTask.taskID isEqualToString:taskID]) {
//        DDLogDebug(@"zl---[%s]:当前执行的任务ID不是：%@", __FUNCTION__, taskID);
//        return;
//    }
    @synchronized (self) {
        self.runningTask = nil;
    }
    
    if ([self _taskEmpty]) {
        DDLogDebug(@"zl---[%s]:任务队列没有任务了", __FUNCTION__);
        [[NSNotificationCenter defaultCenter] postNotificationName:CMPHomeAlertTaskManagerAllTaskDidFinish object:nil];
        return;
    }
    
    [self runFrontTask];
}

- (void)ready {
    @synchronized (self) {
        self.isReady = YES;
    }
    if ([self _taskEmpty]) {
        DDLogDebug(@"zl---[%s]:当前没有任务，直接停止", __FUNCTION__);
        [[NSNotificationCenter defaultCenter] postNotificationName:CMPHomeAlertTaskManagerAllTaskDidFinish object:nil];
        return;
    }
    if (!self.runningTask) {
        [self runFrontTask];
    }
}

- (void)removeAllTask {
    [self _removeAllTask];
    self.runningTask = nil;
    @synchronized (self) {
        self.isReady = NO;
    }
}

- (void)runFrontTask {
    @synchronized (self) {
        CMPHomeAlertTask *task = [self _frontTask];
        if (!self.isReady &&
            (task.priority < CMPHomeAlertPriorityShowBeforeLogin)) {
            return;
        }
        self.runningTask = task;
        [self _popTask];
    }
    
    if (self.runningTask.showBlock) {
        //修改 bug OA-171766
        CMPHomeAlertTask *task = self.runningTask;
        dispatch_async(dispatch_get_main_queue(), ^{
            task.showBlock();
        });
    } else {
        [self taskDone];
    }
}

#pragma mark-
#pragma mark 队列管理
#warning  @synchronized的性能是苹果提供的加锁方式中性能最低的一种方式，建议使用互斥锁(pthread_mutex_t)、互斥递归锁、不公平锁(unfair_lock)或者信号量(dispatch_semaphore)

/**
 
 @synchronized的性能是苹果提供的加锁方式中性能最低的一种方式，建议使用互斥锁(pthread_mutex_t)、互斥递归锁、不公平锁(unfair_lock)或者信号量(dispatch_semaphore)
 
 苹果提供的锁性能(按高到低排序):
 unfair_lock(不公平锁)
 os_spin_lock(自旋锁)
 dispatch_semaphore(信号量)
 mutex(互斥锁)
 NSLock(封装的mutex)
 NSCondition
 mutex(recursive)(互斥递归锁)
 NSRecursiveLock(封装的mutex(recursive))
 NSConditionLock
 @synchronized
 */
- (void)_pushTask:(CMPHomeAlertTask *)task {
    @synchronized (self) {
        [self.taskQueue addObject:task];
        [self _sortTaskQueue];
    }
}

- (CMPHomeAlertTask *)_frontTask {
    return [self.taskQueue lastObject];
}

- (void)_popTask {
    [self.taskQueue removeLastObject];
}

- (BOOL)_taskEmpty {
    return self.taskQueue.count == 0;
}

- (void)_sortTaskQueue {
    [self.taskQueue sortUsingComparator:^NSComparisonResult(CMPHomeAlertTask *obj1, CMPHomeAlertTask *obj2) {
        if (obj1.priority > obj2.priority) {
            return NSOrderedDescending;
        } else if (obj1.priority == obj2.priority) {
            return NSOrderedSame;
        } else {
            return NSOrderedAscending;
        }
    }];
}

- (void)_removeAllTask {
    @synchronized (self) {
        [self.taskQueue removeAllObjects];
    }
}

#pragma mark-
#pragma mark Getter

- (NSMutableArray<CMPHomeAlertTask *> *)taskQueue {
    if (!_taskQueue) {
        _taskQueue = [[NSMutableArray alloc] init];
    }
    return _taskQueue;
}

@end

