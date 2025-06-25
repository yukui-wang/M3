//
//  CMPInputObserver.m
//  M3
//
//  Created by CRMO on 2018/9/10.
//

#import "CMPInputObserver.h"

@interface CMPInputObserver()

@property (strong, nonatomic) NSMutableArray *inputs;

@end

@implementation CMPInputObserver

- (void)registerInput:(id)input {
    if (!input) {
        return;
    }
    if (![input respondsToSelector:@selector(text)]) {
        NSLog(@"%s:input 没有实现text方法", __FUNCTION__);
        return;
    }
    [input addTarget:self
              action:@selector(contentDidChange:)
    forControlEvents:UIControlEventEditingChanged];
    [self.inputs addObject:input];
    [self contentDidChange:input];
}

- (void)removeInput:(id)input {
    if (!input) {
        return;
    }
    [input removeTarget:self
                 action:@selector(contentDidChange:)
       forControlEvents:UIControlEventEditingChanged];
    [self.inputs removeObject:input];
    [self contentDidChange:input];
}

- (void)removeAll {
    [self.inputs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeTarget:self
                     action:@selector(contentDidChange:)
           forControlEvents:UIControlEventEditingChanged];
    }];
    [self.inputs removeAllObjects];
}

- (void)refreshState {
    [self contentDidChange:nil];
}

#pragma mark-
#pragma mark 响应事件

- (void)contentDidChange:(id)sender {
    __block BOOL empty = NO;
    [self.inputs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *content = [obj text];
        if ([NSString isNull:content]) {
            *stop = YES;
            if (self.didSomeEmpty) {
                self.didSomeEmpty();
            }
            empty = YES;
        }
    }];
    if (!empty) {
        if (self.didAllFill) {
            self.didAllFill();
        }
    }
}

#pragma mark-
#pragma mark Getter

- (NSMutableArray *)inputs {
    if (!_inputs) {
        _inputs = [NSMutableArray array];
    }
    return _inputs;
}

@end

@implementation CMPButtonEnableObserver

+ (instancetype)observerWithButton:(UIButton *)button inputs:(NSArray<id> *)inputs {
    if (!button || !inputs || inputs.count == 0) {
        return nil;
    }
    CMPButtonEnableObserver *observer = [[CMPButtonEnableObserver alloc] init];
    
    BOOL hasEmptyInput = NO;
    for (id input in inputs) {
        [observer registerInput:input];
        NSString *text = ((UITextField *)input).text;
        if ([NSString isNull:text]) {
            hasEmptyInput = YES;
        }
    }
    button.enabled = !hasEmptyInput;
    observer.didAllFill = ^{
        button.enabled = YES;
    };
    observer.didSomeEmpty = ^{
        button.enabled = NO;
    };
    return observer;
}

@end
