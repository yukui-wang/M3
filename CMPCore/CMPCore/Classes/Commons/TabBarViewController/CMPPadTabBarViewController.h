//
//  CMPPadTabBarViewController.h
//  M3
//
//  Created by CRMO on 2019/5/23.
//

#import "CMPTabBarViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface CMPPadTabBarViewController : CMPTabBarViewController
@property (assign, nonatomic) NSInteger lastSelectIndex;
//小致的逻辑
- (void)openAllSearchPage4Xiaoz:(NSDictionary *)params;
@end

NS_ASSUME_NONNULL_END
