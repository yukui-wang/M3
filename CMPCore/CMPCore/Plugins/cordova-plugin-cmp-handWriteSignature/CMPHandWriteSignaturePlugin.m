//
//  CMPHandWriteSignaturePlugin.m
//  CMPCore
//
//  Created by youlin on 2016/8/10.
//
//
#define kLayoutSignatureImageType_Cover 1 // 覆盖
#define kLayoutSignatureImageType_Vertical 2


#import "CMPHandWriteSignaturePlugin.h"
#import <CMPLib/SyHandWriteSignatureViewController.h>
#import "AppDelegate.h"
#import <CMPLib/SignatureUtils.h>
#import "MJINGESignature.h"

@interface CMPHandWriteSignaturePlugin ()<SyHandWriteSignatureViewControllerDelegate> {
    NSMutableDictionary *_handWriteSignatureViewMap;
}

@property (nonatomic, copy)NSString *callBackId;
@property (nonatomic, copy)NSString *userName;
@property (nonatomic, retain)NSString *initValue;
@property (nonatomic, retain)MJINGESignature *mJINGESignature;

@end

@implementation CMPHandWriteSignaturePlugin

- (void)dealloc
{
    self.callBackId = nil;
    self.userName = nil;
    self.initValue = nil;
    [_mJINGESignature release];
    _mJINGESignature = nil;
    
    [self clearHandWriteSignatureViews];
    
    [super dealloc];
}

- (void)initSignatureData:(CDVInvokedUrlCommand *)command
{
    NSDictionary *parameter = [command.arguments firstObject];
    NSArray *aList = [parameter objectForKey:@"value"];
    NSMutableArray *aResult = [[NSMutableArray alloc] init];
    for (NSDictionary *aDict in aList) {
        NSMutableDictionary *mDict = [[[NSMutableDictionary alloc] initWithDictionary:aDict] autorelease];
        NSString *fieldValue = [aDict objectForKey:@"fieldValue"];
        if ([NSString isNull:fieldValue]) {
            continue;
        }
        NSDictionary *picDict = [SignatureUtils picDataStrWithInitValue:fieldValue];
        NSString *aStr = [picDict objectForKey:@"value"];
        if ([NSString isNull:aStr]) {
            [mDict setObject:@"" forKey:@"picData"];
        }
        else {
            [mDict setObject:aStr forKey:@"picData"];
        }
        NSString *aSizeStr = [aDict objectForKey:@"size"];
        if (![NSString isNull:aSizeStr]) {
            CGSize aSize = CGSizeFromString(aSizeStr);
            NSInteger w = aSize.width;
            [mDict setObject:[NSString stringWithFormat:@"%ld", (long)w] forKey:@"width"];
        }
        [aResult addObject:mDict];
    }
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:aResult];
    [aResult release];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)handWriteSignature:(CDVInvokedUrlCommand *)command
{
    self.callBackId = command.callbackId;
    NSDictionary *parameter = [command.arguments firstObject];
    BOOL hasSignetures = YES;//[[parameter objectForKey:@"hasSignetures"] boolValue];
    NSString *signatureListUrl = [parameter objectForKey:@"signatureListUrl"];
    NSString *signaturePicUrl = [parameter objectForKey:@"signaturePicUrl"];
    NSString *key = [parameter objectForKey:@"fieldName"];
    if ([NSString isNull:key]) {
        key = self.mJINGESignature ? self.mJINGESignature.fieldName :@"";
    }
    SyHandWriteSignatureViewController *aViewController = nil;
    aViewController = [_handWriteSignatureViewMap objectForKey:key];
    if (!aViewController) {
        self.mJINGESignature = [[[MJINGESignature alloc] initWithDictionaryRepresentation:parameter] autorelease];
        self.initValue = self.mJINGESignature.fieldValue;
        key = self.mJINGESignature.fieldName;
        aViewController = [[[SyHandWriteSignatureViewController alloc] init] autorelease];
        aViewController.delegate = self;
        aViewController.signatureListUrl = signatureListUrl;
        aViewController.signaturePicUrl = signaturePicUrl;
        aViewController.hasSignetures = hasSignetures;
        aViewController.affairId = [parameter objectForKey:@"affairId"];
        // 设置初始大小
        NSInteger w = [self.mJINGESignature.width integerValue];
        NSInteger h = [self.mJINGESignature.height integerValue];
        CGFloat screenWidth = [UIWindow mainScreenSize].width;
        if (w > screenWidth) {
            w = screenWidth;
        }
        aViewController.initSize = CGSizeMake(w, h);
    }
    if (!_handWriteSignatureViewMap) {
        _handWriteSignatureViewMap = [[NSMutableDictionary alloc] init];
    }
    [_handWriteSignatureViewMap setObject:aViewController forKey:key];
//    AppDelegate *appDelegate =(AppDelegate *) [UIApplication sharedApplication].delegate;
//    [appDelegate.window.rootViewController presentViewController:aViewController animated:YES completion:nil];
    // add by guoyl for Pushing the same view controller instance more than once is not supported (<SyHandWriteSignatureViewController: 0x10438f200>)
    if (self.viewController.navigationController.topViewController == aViewController) {
        return;
    }
    [self.viewController.navigationController pushViewController:aViewController animated:YES];
}

- (void)clearHandWriteSignatureViews
{
    NSArray *aList = [_handWriteSignatureViewMap allValues];
    for (UIViewController *aViewController in aList) {
        [aViewController dismissViewControllerAnimated:NO completion:^{
            
        }];
    }
    [_handWriteSignatureViewMap removeAllObjects];
    [_handWriteSignatureViewMap release];
    _handWriteSignatureViewMap = nil;
}

- (void)clear:(CDVInvokedUrlCommand *)command
{
    [self clearHandWriteSignatureViews];
}

#pragma -mark SyHandWriteSignatureViewControllerDelegate
- (void)handWriteSignatureViewControllerDidCancel:(SyHandWriteSignatureViewController *)aHandWriteSignatureViewController
{
    NSDictionary *errorDic= [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:44002],@"code",@"Signature cancel",@"message",@"",@"detail", nil];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callBackId];
    [self.viewController.navigationController popViewControllerAnimated:YES];
}

- (void)handWriteSignatureViewControllerDidFinished:(SyHandWriteSignatureViewController *)aHandWriteSignatureViewController result:(UIImage *)aResult signatureName:(NSString *)aSignatureName
{
    NSArray *result = [self handleImageData:aResult];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callBackId];
    [self.viewController.navigationController popViewControllerAnimated:YES];
}

// 对手写签章返回的值做处理
- (NSArray *)handleImageData:(UIImage *)aHandWriteImage
{
    MJINGESignature *aMJINGESignature = self.mJINGESignature;
    NSInteger aLayoutType = kLayoutSignatureImageType_Cover;
    //    if (self.moduleType == kC_iModuleType_EDoc) {
    //        aLayoutType = kLayoutSignatureImageType_Vertical;
    //    }
    aLayoutType = kLayoutSignatureImageType_Vertical;
    NSInteger w = [aMJINGESignature.width integerValue];
    NSInteger h = [aMJINGESignature.height integerValue];
    CGSize size = aHandWriteImage.size;
    CGFloat wScale = w/size.width;
    CGFloat hScale = h/size.height;
    if (wScale == 0 ) {
        wScale = 1;
    }
    if (hScale == 0 ) {
        hScale = 1;
    }
    CGFloat scale = wScale;
    if (scale > hScale && aLayoutType == kLayoutSignatureImageType_Cover) {
        scale = hScale;
    }
    
    if (scale < 1.0) {
        size = CGSizeMake(size.width*scale, size.height*scale);
        UIGraphicsBeginImageContext(size);
        [aHandWriteImage drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
        aHandWriteImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    CGSize initSize = CGSizeMake(w, h);
    NSString *name = aMJINGESignature.currentOrgName;
    if ([NSString isNull:name]) {
        name = [CMPCore sharedInstance].userName;
    }
    aMJINGESignature.fieldValue = [SignatureUtils getSignatureResult:self.initValue
                                                               image:aHandWriteImage
                                                            userName:name
                                                          layoutType:aLayoutType
                                                            initSize:initSize];
    NSDictionary *aDict = [SignatureUtils picDataStrWithInitValue:aMJINGESignature.fieldValue];
    aMJINGESignature.picData = [aDict objectForKey:@"value"];
    if ([NSString isNull:aMJINGESignature.picData]) {
        aMJINGESignature.picData = @"";
    }
    NSString *aSizeStr = [aDict objectForKey:@"size"];
    if (![NSString isNull:aSizeStr]) {
        CGSize aSize = CGSizeFromString(aSizeStr);
        NSInteger w = aSize.width;
        NSInteger h = aSize.height;
        aMJINGESignature.width = [NSString stringWithFormat:@"%ld", (long)w];
        aMJINGESignature.height = [NSString stringWithFormat:@"%ld", (long)h];
    }
     return [NSArray arrayWithObjects:[aMJINGESignature dictionaryRepresentation], nil];
}

@end
