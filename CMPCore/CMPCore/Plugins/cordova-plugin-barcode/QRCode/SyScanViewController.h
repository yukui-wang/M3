//
//  SyScanViewController.h
//  M1IPhone
//
//  Created by Aries on 14-4-16.
//  Copyright (c) 2014年 北京致远协创软件有限公司. All rights reserved.
//

#import <CMPLib/CMPBannerViewController.h>
#import "ZXParsedResult.h"
#import "ZXAddressBookParsedResult.h"
#import "SyScanViewControllerDelegate.h"

@protocol SyScanViewControllerDelegate;

@interface SyScanViewController : CMPBannerViewController {
    UIImageView *_lineView;
}

@property(nonatomic, copy)NSString *callBackID;
@property(nonatomic, assign)BOOL autoDismiss;
@property(nonatomic, assign)BOOL nativeHandleSpecialResult;

@property(nonatomic, weak)UIViewController *scanWebViewController;
/* scanImage */
@property (strong, nonatomic) UIImage *scanImage;


//生成二维码
+ (UIImage *)encode:(NSString *)aEncodeString;

@property (nonatomic, assign) id<SyScanViewControllerDelegate> delegate;

- (void)initCaputre;
- (void)setOverlayPickerView:(CALayer *)layer frame:(CGRect)aFrame;
+ (SyScanViewController *)scanViewController;
- (void)performScanFailed;
- (void)performScanFinishedWithResult:(ZXParsedResult *)aResult;
- (void)showAlertView:(NSString *)message;
- (void)continueScan;
- (void)stopScan;

/// 处理给定图片
/// @param img 图片
- (void)handleGivenImage:(UIImage *)image;

@end
