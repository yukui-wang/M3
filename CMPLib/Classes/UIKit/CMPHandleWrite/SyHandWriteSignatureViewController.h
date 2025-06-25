//
//  SyHandWriteSignatureViewController.h
//  M1IPhone
//
//  Created by guoyl on 13-5-7.
//  Copyright (c) 2013年 北京致远协创软件有限公司. All rights reserved.
//

#import "CMPBannerViewController.h"

@protocol SyHandWriteSignatureViewControllerDelegate;

@interface SyHandWriteSignatureViewController : CMPBannerViewController

@property (nonatomic, assign)id<SyHandWriteSignatureViewControllerDelegate> delegate;
@property (nonatomic, copy)NSString *signatureListUrl;
@property (nonatomic, copy)NSString *signaturePicUrl;
@property (nonatomic, assign)BOOL hasSignetures;
@property (nonatomic, copy)NSString *affairId;
@property (nonatomic, assign)CGSize initSize;

@end

@protocol SyHandWriteSignatureViewControllerDelegate <NSObject>

- (void)handWriteSignatureViewControllerDidCancel:(SyHandWriteSignatureViewController *)aHandWriteSignatureViewController;
- (void)handWriteSignatureViewControllerDidFinished:(SyHandWriteSignatureViewController *)aHandWriteSignatureViewController result:(UIImage *)aResult signatureName:(NSString *)aSignatureName;

@end
