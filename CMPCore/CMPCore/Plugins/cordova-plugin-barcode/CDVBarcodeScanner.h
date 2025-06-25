//
//  CDVBarcodeScanner.h
//  CMPCore
//
//  Created by lin on 15/8/28.
//
//

#import <CordovaLib/CDVPlugin.h>

@interface CDVBarcodeScanner : CDVPlugin

//打开扫一扫页面
- (void)openScanPage:(CDVInvokedUrlCommand*)command;


@end
