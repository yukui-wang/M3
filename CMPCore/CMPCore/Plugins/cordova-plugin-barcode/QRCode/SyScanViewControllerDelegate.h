//
//  SyScanViewControllerDelegate.h
//  M1Core
//
//  Created by youlinguo on 16/3/28.
//
//

@class SyScanViewController;
@class ZXParsedResult;

@protocol SyScanViewControllerDelegate <NSObject>

@optional
- (void)scanViewController:(SyScanViewController *)scanViewController didScanFinishedWithResult:(ZXParsedResult *)aResult;
- (void)scanViewControllerScanFailed:(SyScanViewController *)scanViewController;
- (void)scanViewControllerDidCanceled:(SyScanViewController *)scanViewController;

@end

