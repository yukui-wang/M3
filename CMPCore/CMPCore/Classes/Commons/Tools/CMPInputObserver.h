//
//  CMPInputObserver.h
//  M3
//
//  Created by CRMO on 2018/9/10.
//

#import <CMPLib/CMPObject.h>

typedef void(^InputObserverDidAllFill)(void);
typedef void(^InputObserverDidSomeEmpty)(void);

@interface CMPInputObserver : CMPObject

/** 所有输入框都有内容了 **/
@property (copy, nonatomic) InputObserverDidAllFill didAllFill;
/** 有输入框没有输入内容 **/
@property (copy, nonatomic) InputObserverDidSomeEmpty didSomeEmpty;

- (void)registerInput:(id)input;
- (void)removeInput:(id)input;
- (void)removeAll;

/**
 手动触发状态回调
 */
- (void)refreshState;

@end

@interface CMPButtonEnableObserver : CMPInputObserver

/**
 适用与多个输入框+一个按钮的场景
 只有所有输入框有内容后按钮才可点击

 @param button 需要控制的按钮
 @param inputs 需要监听的输入框
 @return
 */
+ (instancetype)observerWithButton:(UIButton *)button inputs:(NSArray<id> *)inputs;
@end
