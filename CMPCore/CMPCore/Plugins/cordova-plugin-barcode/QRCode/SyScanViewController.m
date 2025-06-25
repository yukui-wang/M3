//
//  SyScanViewController.m
//  M1IPhone
//
//  Created by Aries on 14-4-16.
//  Copyright (c) 2014年 北京致远协创软件有限公司. All rights reserved.
//

#import "SyScanViewController.h"
#import "ZXCapture.h"
#import "ZXParsedResult.h"
#import "ZXResultParser.h"
#import "ZXLuminanceSource.h"
#import "ZXCGImageLuminanceSource.h"
#import "ZXBinaryBitmap.h"
#import "ZXHybridBinarizer.h"
#import "ZXMultiFormatReader.h"
#import "ZXDecodeHints.h"
#import "ZXAddressBookParsedResult.h"
#import "ZXCaptureDelegate.h"
#import "SyQRCodeController.h"
#import "ZXMultiFormatWriter.h"
#import "ZXImage.h"
#import <CMPLib/UIButton+CMPButton.h>
#import <CMPLib/CMPDevicePermissionHelper.h>
#import <CMPLib/NSData+Base64.h>
#import "CMPScanWebViewController.h"
#import <CMPLib/CMPCachedUrlParser.h>
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/CMPCommonTool.h>
@interface SyScanViewController ()<ZXCaptureDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    BOOL _isUsed;
    UILabel *_titleLabel;
    UIPopoverController *_popover;
    BOOL _isShowImagePicker;
}

@property (nonatomic, retain) ZXCapture* capture;

@end

@implementation SyScanViewController

+ (UIImage *)encode:(NSString *)aEncodeString
{
    // 1.创建过滤器
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 2.恢复默认
    [filter setDefaults];
    // 3.给过滤器添加数据(正则表达式/账号和密码)
    NSString *dataString = aEncodeString;
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKeyPath:@"inputMessage"];
    // 4.获取输出的二维码
    CIImage *outputImage = [filter outputImage];
    // 5.将CIImage转换成UIImage，并放大显示
     return [self createNonInterpolatedUIImageFormCIImage:outputImage withSize:500];
}

/**
 * 根据CIImage生成指定大小的UIImage
 *
 * @param image CIImage
 * @param size 图片宽度
 */
+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    CGColorSpaceRelease(cs);
    UIImage *resultImage = [UIImage imageWithCGImage:scaledImage];
    CGImageRelease(scaledImage);
    return resultImage;
}

- (id)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

- (BOOL)isOptimizationStatusBarForiOS7 {
    return YES;
}

- (void)backBarButtonAction:(id)sender
{
    [self.scanWebViewController.navigationController dismissViewControllerAnimated:NO completion:^{
        
    }];
    [_popover dismissPopoverAnimated:NO];
    [super backBarButtonAction:sender];
    if([_delegate respondsToSelector:@selector(scanViewControllerDidCanceled:)]){
        [_delegate scanViewControllerDidCanceled:self];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:SY_STRING(@"QRCode_Scan")];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.backBarButtonItemHidden = YES;
    self.bannerNavigationBar.bannerTitleView.textColor = UIColor.whiteColor;
    self.bannerNavigationBar.backgroundColor = UIColor.clearColor;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleScanSendResult:) name:@"scanSendResult" object:nil];
    
    if (self.scanImage) return;
    
    [self initCaputre];
    [CMPDevicePermissionHelper hasPermissionsForCamera];
    
    _isShowImagePicker = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	self.capture.delegate = self;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_BarcodeScannerWillShow object:nil];
    
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass: CMPBannerNavigationBar.class]) {
            [self.view bringSubviewToFront:view];
        }
        if (view.cmp_x == 0 && view.cmp_y == 0) {
            view.backgroundColor = UIColor.clearColor;
        }
    }
    
    [UIApplication.sharedApplication setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (!_isShowImagePicker) {
        //_isShowImagePicker = yes,正在相册选二维码，不是真的关闭扫描界面
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_BarcodeScannerWillHide object:nil];
    }
    self.capture.delegate = nil;
    _isUsed = NO;
    
    [UIApplication.sharedApplication setStatusBarStyle:UIStatusBarStyleDarkContent];
    
}




- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_callBackID release];
    _callBackID = nil;
    [self.capture.layer removeFromSuperlayer];
	
    [_titleLabel release];
    _titleLabel = nil;
    [_lineView release];
    _lineView = nil;
    
    
    _capture.delegate = nil;
    [_capture release];
    _capture = nil;
    
    [_popover dismissPopoverAnimated:NO];
    [_popover release];
    _popover = nil;
    
    [super dealloc];
}

- (void)setupBannerButtons
{
    self.bannerNavigationBar.leftViewsMargin = 10;
    self.bannerNavigationBar.rightViewsMargin = 10;
    self.bannerNavigationBar.leftMargin = 10;
    self.bannerNavigationBar.rightMargin = 10.0f;
    UIButton *ablumBtn  = nil;
    CGRect aButtonFrame = CGRectMake(0, 0, 50, 35);
    ablumBtn = [UIButton transparentButtonWithFrame:aButtonFrame title:SY_STRING(@"QRCode_Album")];
//    [ablumBtn setTitleColor:[CMPThemeManager sharedManager].iconColor forState:UIControlStateNormal];
    [ablumBtn setTitleColor:[UIColor cmp_colorWithName:@"reverse-fc"] forState:UIControlStateNormal];
    [ablumBtn addTarget:self action:@selector(ablumBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.bannerNavigationBar setRightBarButtonItems:[NSArray arrayWithObjects:ablumBtn, nil]];
    
    UIButton *backBtn = [UIButton.alloc initWithFrame:CGRectMake(12.f, 0, 32.f, 20.f)];
    [backBtn setImage:[UIImage imageNamed:@"ic_banner_return"] forState:UIControlStateNormal];
    [backBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    backBtn.cmp_centerY = self.bannerNavigationBar.cmp_height/2.f;
    [backBtn addTarget:self action:@selector(backBarButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.bannerNavigationBar addSubview:backBtn];
    [self.bannerNavigationBar hideBottomLine:YES];
}

- (void)ablumBtnAction:(UIButton *)sender
{
    [CMPDevicePermissionHelper permissionsForPhotosTrueCompletion:^{
        _isShowImagePicker = YES;
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = self;
        picker.allowsEditing = NO;
        if (INTERFACE_IS_PAD) {
            [_popover dismissPopoverAnimated:NO];
            [_popover release];
            _popover = [[UIPopoverController alloc] initWithContentViewController:picker];
            picker.isInPopoverController = YES;
            CGRect f = [self.view convertRect:sender.frame fromView:self.view];
            [_popover presentPopoverFromRect:f inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        else {
            if (self.scanWebViewController) {
                [self.scanWebViewController presentViewController:picker animated:YES completion:nil];
            }
            else {
                [self presentViewController:picker animated:YES completion:nil];
            }
        }
        [picker release];
    } falseCompletion:^{
        
    } showAlert:YES];
}

- (void)handSelectPic:(NSDictionary *)info
{
    //取出选中的图片
    UIImage *pickImage = info[UIImagePickerControllerOriginalImage];
    [self handleGivenImage:pickImage];
}

- (void)handleGivenImage:(UIImage *)image {
    NSArray *result = [CMPCommonTool scanQRCodeWithImage:image];
    NSString *content = result.firstObject;
    if([NSString isNull:content]) {
        [self showAlertView:SY_STRING(@"scan_picfail")];
        return;
    }
    if([self.delegate respondsToSelector:@selector(scanViewController:didScanFinishedWithResult:)]){
        ZXResult *aZXResult = [[ZXResult alloc] initWithText:content rawBytes:nil resultPoints:nil format:nil];
        ZXParsedResult *parseResult = [ZXResultParser parseResult:aZXResult];
        [aZXResult release];
        [self.delegate scanViewController:(SyScanViewController *)self didScanFinishedWithResult:parseResult];
    }
}



#pragma mark --UIImagePickerDelgate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    _isShowImagePicker = NO;
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]){
        [_popover dismissPopoverAnimated:NO];
        if (INTERFACE_IS_PAD) {
            //OA-125430  M3-IOS端：系统IOS8.3，从相册选择保存到本地的人员二维码进行扫描，扫描框消失后未出现保存到本地的界面
            //估计是popover 冲突了 加个1s的延迟
            [self performSelector:@selector(handSelectPic:) withObject:info afterDelay:1];
        }
        else {
            [picker dismissViewControllerAnimated:NO completion:^{
                [self handSelectPic:info];
            }];
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    _isShowImagePicker = NO;
    [_popover dismissPopoverAnimated:NO];
    [picker dismissViewControllerAnimated:YES completion:^{

    }];
    
}

- (void)setOverlayPickerView:(CALayer *)layer frame:(CGRect)aFrame
{
    
    [layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    CGFloat mX = aFrame.size.width;
    CGFloat mY = aFrame.size.height;
    
//    CGFloat halfSideLength;
//    CGFloat sideLength;
//    if (INTERFACE_IS_PAD) {
//        halfSideLength = MIN(mX, mY) * 0.25;
//    } else {
//        halfSideLength = (mX - 120) * 0.5;
//    }
//    sideLength = halfSideLength * 2;
    CGFloat sideLength = 255;
    CGFloat halfSideLength = sideLength * 0.5;
    
    CGFloat x1 = mX/2 - halfSideLength;
    CGFloat x2 = mX/2 + halfSideLength;
    CGFloat y1 = mY/2 - halfSideLength;
    CGFloat y2 = mY/2 + halfSideLength;
    
    if(!_titleLabel){
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = SY_STRING(@"QRCode_AutoScan");
        _titleLabel.numberOfLines = 2;
        _titleLabel.textColor = [UIColor cmp_colorWithName:@"reverse-fc"];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = [UIColor clearColor];
    }
    _titleLabel.frame = CGRectMake(0, 0, 300, 40);
    _titleLabel.center = CGPointMake(mX/2, y2 + 40);
//    [layer addSublayer:_titleLabel.layer];
    
    UIColor *cornerColor = [UIColor cmp_colorWithName:@"theme-bdc"];
    UIColor *lineColor = [UIColor cmp_colorWithName:@"reverse-fc"];
    lineColor = [UIColor clearColor];
    CGFloat cornerBorderWidth = 2;
    CGFloat cornerWidth = 14;
    
    CALayer *aLineLayer1 = [CALayer layer];
    aLineLayer1.frame = CGRectMake(x1, y1, 200, 0.5);
    aLineLayer1.backgroundColor = lineColor.CGColor;
    [layer addSublayer:aLineLayer1];
    CALayer *aLineLayer1x = [CALayer layer];
    aLineLayer1x.frame = CGRectMake(x1, y1-cornerBorderWidth, cornerWidth - cornerBorderWidth, cornerBorderWidth);
    aLineLayer1x.backgroundColor = cornerColor.CGColor;
    [layer addSublayer:aLineLayer1x];
    CALayer *aLineLayer1y = [CALayer layer];
    aLineLayer1y.frame = CGRectMake(x1-cornerBorderWidth, y1-cornerBorderWidth, cornerBorderWidth, cornerWidth);
    aLineLayer1y.backgroundColor = cornerColor.CGColor;
    [layer addSublayer:aLineLayer1y];
    
    CALayer *aLineLayer2 = [CALayer layer];
    aLineLayer2.frame = CGRectMake(x1, y1, 0.5, 200);
    aLineLayer2.backgroundColor = lineColor.CGColor;
    [layer addSublayer:aLineLayer2];
    CALayer *aLineLayer2x = [CALayer layer];
    aLineLayer2x.frame = CGRectMake(x2-(cornerWidth - cornerBorderWidth), y1-cornerBorderWidth, cornerWidth, cornerBorderWidth);
    aLineLayer2x.backgroundColor = cornerColor.CGColor;
    [layer addSublayer:aLineLayer2x];
    CALayer *aLineLayer2y = [CALayer layer];
    aLineLayer2y.frame = CGRectMake(x2, y1, cornerBorderWidth, cornerWidth - cornerBorderWidth);
    aLineLayer2y.backgroundColor = cornerColor.CGColor;
    [layer addSublayer:aLineLayer2y];
    
    CALayer *aLineLayer3 = [CALayer layer];
    aLineLayer3.frame = CGRectMake(x2, y1, 0.5, 200);
    aLineLayer3.backgroundColor = lineColor.CGColor;
    [layer addSublayer:aLineLayer3];
    CALayer *aLineLayer3x = [CALayer layer];
    aLineLayer3x.frame = CGRectMake(x2-(cornerWidth - cornerBorderWidth), y2, cornerWidth, cornerBorderWidth);
    aLineLayer3x.backgroundColor = cornerColor.CGColor;
    [layer addSublayer:aLineLayer3x];
    CALayer *aLineLayer3y = [CALayer layer];
    aLineLayer3y.frame = CGRectMake(x2, y2-(cornerWidth - cornerBorderWidth), cornerBorderWidth, (cornerWidth - cornerBorderWidth));
    aLineLayer3y.backgroundColor = cornerColor.CGColor;
    [layer addSublayer:aLineLayer3y];
    
    
    CALayer *aLineLayer4 = [CALayer layer];
    aLineLayer4.frame = CGRectMake(x1, y2, 200, 0.5);
    aLineLayer4.backgroundColor = lineColor.CGColor;
    [layer addSublayer:aLineLayer4];
    CALayer *aLineLayer4x = [CALayer layer];
    aLineLayer4x.frame = CGRectMake(x1-cornerBorderWidth, y2-(cornerWidth - cornerBorderWidth), cornerBorderWidth, cornerWidth);
    aLineLayer4x.backgroundColor = cornerColor.CGColor;
    [layer addSublayer:aLineLayer4x];
    CALayer *aLineLayer4y = [CALayer layer];
    aLineLayer4y.frame = CGRectMake(x1, y2, (cornerWidth - cornerBorderWidth), cornerBorderWidth);
    aLineLayer4y.backgroundColor = cornerColor.CGColor;
    [layer addSublayer:aLineLayer4y];
    
    // add guoyl for scan style
    UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, x1, aFrame.size.height)];
    leftView.alpha = 0.5;
    leftView.backgroundColor = [UIColor blackColor];
    [layer addSublayer:leftView.layer];
    [leftView release];
    //右侧的view
    UIImageView *rightView = [[UIImageView alloc] initWithFrame:CGRectMake(aFrame.size.width-x1, 0, x1, aFrame.size.height)];
    rightView.alpha = 0.5;
    rightView.backgroundColor = [UIColor blackColor];
    [layer addSublayer:rightView.layer];
    [rightView release];
    //最上部view
    UIImageView* upView = [[UIImageView alloc] initWithFrame:CGRectMake(x1, 0, aFrame.size.width-2*x1, y1)];
    upView.alpha = 0.5;
    upView.backgroundColor = [UIColor blackColor];
    [layer addSublayer:upView.layer];
    [upView release];
    //底部view
    UIImageView * downView = [[UIImageView alloc] initWithFrame:CGRectMake(x1, y2, aFrame.size.width-2*x1, aFrame.size.height - y2)];
    downView.alpha = 0.5;
    downView.backgroundColor = [UIColor blackColor];
    [layer addSublayer:downView.layer];
    [downView release];
    // add end
    
    if(!_lineView){
        //_lineView = [[UIView alloc] init];
        _lineView = [[UIImageView alloc] init];
        _lineView.image = [[CMPThemeManager sharedManager] skinColorImageWithName:@"scan_code_line"];
    }
//    _lineView.backgroundColor = cornerColor;
    
    _lineView.frame = CGRectMake(x1 + 4, y1, sideLength - 8, 2);
    
    [layer addSublayer:_lineView.layer];
    [layer addSublayer:_titleLabel.layer];
    
    CABasicAnimation *animation = [SyQRCodeController moveYTime:2 fromY:[NSNumber numberWithDouble:0] toY:[NSNumber numberWithDouble:sideLength] rep:OPEN_MAX];
    [_lineView.layer addAnimation:animation forKey:@"LineAnimation"];
    
   /* [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:3.0];
    [UIView setAnimationRepeatCount:999999];
    _lineView.frame =  CGRectMake(x1, y2, 200, 0.5);
    [UIView commitAnimations];*/
}

+ (CABasicAnimation *)moveYTime:(float)time fromY:(NSNumber *)fromY toY:(NSNumber *)toY rep:(int)rep
{
    CABasicAnimation *animationMove = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    [animationMove setFromValue:fromY];
    [animationMove setToValue:toY];
    animationMove.duration = time;
    animationMove.delegate = self;
    animationMove.repeatCount  = rep;
    animationMove.fillMode = kCAFillModeForwards;
    animationMove.removedOnCompletion = NO;
    animationMove.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return animationMove;
}

- (void)initCaputre
{
    if(!_capture){
        _capture = [[ZXCapture alloc] init];
        self.capture.rotation = 90.0f;
        self.capture.camera = self.capture.back;
    }
    CGRect aFrame = [self mainFrame];
    self.capture.layer.frame = aFrame;
    [self.view.layer addSublayer:self.capture.layer];
    [self setOverlayPickerView:self.capture.layer frame:aFrame];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods

- (void)displayForResult:(ZXResult*)result {
    NSString *formatString;
    NSLog(@"resultText:%@",[result text]);
    switch (result.barcodeFormat) {
        case kBarcodeFormatAztec:
            formatString = @"Aztec";
            break;
            
        case kBarcodeFormatCodabar:
            formatString = @"CODABAR";
            break;
            
        case kBarcodeFormatCode39:
            formatString = @"Code 39";
            break;
            
        case kBarcodeFormatCode93:
            formatString = @"Code 93";
            break;
            
        case kBarcodeFormatCode128:
            formatString = @"Code 128";
            break;
            
        case kBarcodeFormatDataMatrix:
            formatString = @"Data Matrix";
            break;
            
        case kBarcodeFormatEan8:
            formatString = @"EAN-8";
            break;
            
        case kBarcodeFormatEan13:
            formatString = @"EAN-13";
            break;
            
        case kBarcodeFormatITF:
            formatString = @"ITF";
            break;
            
        case kBarcodeFormatPDF417:
            formatString = @"PDF417";
            break;
            
        case kBarcodeFormatQRCode:
            formatString = @"QR Code";
            break;
            
        case kBarcodeFormatRSS14:
            formatString = @"RSS 14";
            break;
            
        case kBarcodeFormatRSSExpanded:
            formatString = @"RSS Expanded";
            break;
            
        case kBarcodeFormatUPCA:
            formatString = @"UPCA";
            break;
            
        case kBarcodeFormatUPCE:
            formatString = @"UPCE";
            break;
            
        case kBarcodeFormatUPCEANExtension:
            formatString = @"UPC/EAN extension";
            break;
            
        default:
            formatString = @"Unknown";
            break;
    }
    
    [self showResult:result type:formatString];
}

#pragma mark - ZXCaptureDelegate Methods
- (void)captureResult:(ZXCapture*)capture result:(ZXResult*)result {
    if (result) {
        if(!_isUsed){
            _isUsed = YES;
#ifdef  kSystemSoundID_Vibrate
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
#endif
            [self performSelectorOnMainThread:@selector(displayForResult:) withObject:result waitUntilDone:YES];
        }
    }
}

- (void)showResult:(ZXResult *)result type:(NSString *)aType
{
    [self stopScan];
    if(!result){
        [self showAlertView:SY_STRING(@"scan_picfail")];
        return;
    }
    ZXParsedResult *parseResult = [ZXResultParser parseResult:result];
    [self performScanFinishedWithResult:parseResult];
}

+ (SyScanViewController *)scanViewController
{
    return [(SyScanViewController *)[[SyQRCodeController alloc] init] autorelease];
}

- (void)performScanFailed{
    [self showAlertView:SY_STRING(@"scan_fail")];
//    if(_delegate && [_delegate respondsToSelector:@selector(scanViewControllerScanFailed:)]){
//        [_delegate scanViewControllerScanFailed:self];
//    }
}
- (void)performScanFinishedWithResult:(ZXParsedResult *)aResult{
    if(_delegate && [_delegate respondsToSelector:@selector(scanViewController:didScanFinishedWithResult:)]){
        [_delegate scanViewController:self didScanFinishedWithResult:aResult];
    }
}

- (void)handleScanSendResult:(NSNotification *)notification{
    NSString *message = [notification object];
    [self showAlertView:message];
}

- (void)showAlertView:(NSString *)message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:SY_STRING(@"common_isee"), nil];
    [alert show];
    SY_RELEASE_SAFELY(alert);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self continueScan];
}

- (void)continueScan{
    CGFloat sideLength = 255;
    CABasicAnimation *animation = [SyQRCodeController moveYTime:2 fromY:[NSNumber numberWithFloat:0] toY:[NSNumber numberWithFloat:sideLength] rep:OPEN_MAX];
    [_lineView.layer addAnimation:animation forKey:@"LineAnimation"];
}

- (void)stopScan{
    [_lineView.layer removeAnimationForKey:@"LineAnimation"];
}

@end
