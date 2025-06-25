//
//  WebViewPlugin.h
//  CMPCore
//
//  Created by lin on 15/9/22.
//
//

#import <CordovaLib/CDVPlugin.h>
#import <CMPLib/CMPBannerWebViewController.h>

@interface WebViewPlugin : CDVPlugin
- (void)FocusMenuFromVC:(CMPBannerWebViewController *)fromVC;
@end
