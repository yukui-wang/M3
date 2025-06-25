//
//  AttachmentReaderViewController.h
//  HelloCordova
//
//  Created by lin on 15/8/20.
//
//

#import <UIKit/UIKit.h>
#import <CMPLib/CMPBannerViewController.h>
#import "AttachmentReaderParam.h"

@protocol AttachmentReaderViewControllerDelegate;

@interface AttachmentReaderViewController : CMPBannerViewController<UIDocumentInteractionControllerDelegate>

@property (nonatomic,retain) AttachmentReaderParam *attReaderParam;
@property (nonatomic,weak) id<AttachmentReaderViewControllerDelegate> delegate;

@end

@protocol AttachmentReaderViewControllerDelegate <NSObject>

- (void)attachmentReaderViewController:(AttachmentReaderViewController *)controller
                                sucess:(BOOL)sucess
                               message:(NSString *)message;
- (void)attachmentReaderViewController:(AttachmentReaderViewController *)controller openWpsEt:(NSString *)path;

@end
