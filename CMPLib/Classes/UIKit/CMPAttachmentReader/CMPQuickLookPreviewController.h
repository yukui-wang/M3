//
//  CMPQuickLookPreviewController.h
//  CMPLib
//
//  Created by 程昆 on 2020/7/7.
//  Copyright © 2020 crmo. All rights reserved.
//

#import <QuickLook/QuickLook.h>
#import <CMPLib/CMPBannerViewController.h>
#import <CMPLib/AttachmentReaderParam.h>

@protocol CMPQuickLookPreviewControllerDelegate;

@interface CMPQuickLookPreviewController : CMPBannerViewController

@property (nonatomic,assign) BOOL canReceiveFile;//是否可以查看文档

@property (nonatomic,strong) AttachmentReaderParam *attReaderParam;
@property (nonatomic,weak) id<CMPQuickLookPreviewControllerDelegate> customDelegate;
@end

@protocol CMPQuickLookPreviewControllerDelegate <NSObject>

- (void)quickLookPreviewController:(CMPQuickLookPreviewController *)controller
                                sucess:(BOOL)sucess
                               message:(NSString *)message;
- (void)quickLookPreviewController:(CMPQuickLookPreviewController *)controller openWpsEt:(NSString *)path;

@end

