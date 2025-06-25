//
//  XZMainController.h
//  M3
//
//  Created by wujiansheng on 2017/11/3.
//

#import <Foundation/Foundation.h>
#import "XZSmartEngine.h"

@interface XZMainController : NSObject
@property (nonatomic, strong) XZSmartEngine *smartEngine;

+ (instancetype)sharedInstance;
- (void)showInWindow;
- (void)needShowXiaozIconInViewController:(UIViewController *)vc;
- (void)openXiaoz:(NSDictionary *)params;
- (void)openAllSearchPage:(NSDictionary *)params;
- (void)openQAPage:(NSDictionary *)params;
- (BOOL)reShowInWindow;
- (void)closeInWindow;
- (void)showQAWithIntentId:(NSString *)intentId;
- (void)addListenToTabbarControllerShow;
- (void)mainViewControllerInputText:(NSString *)text;
- (void)showCancelCard;
- (void)logout;
- (void)willLogout;
@end
