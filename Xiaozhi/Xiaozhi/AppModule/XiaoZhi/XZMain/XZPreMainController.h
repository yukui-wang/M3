//
//  XZMainController.h
//  M3
//
//  Created by wujiansheng on 2017/11/3.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface XZPreMainController : NSObject

+ (instancetype)sharedInstance;
- (void)showInWindow;
- (void)needShowXiaozIconInViewController:(UIViewController *)vc;
- (BOOL)reShowInWindow;
- (void)closeInWindow;
- (void)showQAWithIntentId:(NSString *)intentId;
- (void)addListenToTabbarControllerShow;
- (void)logout;
- (void)willLogout;
@end
