//
//  CMPHandleOpenURLWebViewController
//  CMPCore
//
//  Created by youlin on 2016/8/29.
//
//

#import <CMPLib/CMPBannerWebViewController.h>

typedef void(^CMPHandleOpenURLWebViewControllerDidDealloc)(void);

@interface CMPHandleOpenURLWebViewController : CMPBannerWebViewController

@property (nonatomic, copy)NSString *appId;
@property (nonatomic, copy)NSString *version;
@property (nonatomic, copy)NSString *entryName;
@property (copy, nonatomic) CMPHandleOpenURLWebViewControllerDidDealloc didDealloc;

@end
