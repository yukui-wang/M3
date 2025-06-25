//
//  CMPLocalAuthenticationViewController.h
//  M3
//
//  Created by CRMO on 2019/1/17.
//

#import <CMPLib/CMPBaseViewController.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPLocalAuthenticationViewController : CMPBaseViewController

@property (copy, nonatomic) void(^authDidFinish)(BOOL result, NSError *error);
@property (copy, nonatomic) void(^tapGestureView)(void);
@property (copy, nonatomic) void(^tapLoginView)(void);


@end

NS_ASSUME_NONNULL_END
