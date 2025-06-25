//
//  CMPprivacyProtocolWebViewController.h
//  M3
//
//  Created by 程昆 on 2019/8/13.
//

#import <CMPLib/CMPBannerWebViewController.h>

@interface CMPPrivacyProtocolWebViewController : CMPBannerWebViewController

@property (nonatomic, copy) void (^agreeButtonActionBlock)(void);
@property (nonatomic, copy) void (^notAgreeButtonActionBlock)(void);

+ (BOOL)popUpPrivacyProtocolPageWithPresentedController:(UIViewController *)presentedController
                                     beforePopPageBlock:(void (^)(void))beforePopPageBlock
                                 agreeButtonActionBlock:(void (^)(void))agreeButtonActionBlock
                              notAgreeButtonActionBlock:(void (^)(void))notAgreeButtonActionBlock;

+ (BOOL)singlePopUpPrivacyProtocolPageWithPresentedController:(UIViewController *)presentedController
                                           beforePopPageBlock:(void (^)(void))beforePopPageBlock
                                       agreeButtonActionBlock:(void (^)(void))agreeButtonActionBlock
                                    notAgreeButtonActionBlock:(void (^)(void))notAgreeButtonActionBlock;

+ (BOOL)isAlreadySinglePopUpPrivacyProtocolPage;

+ (void)setupSinglePopUpPrivacyProtocolPageFlag;

@end


