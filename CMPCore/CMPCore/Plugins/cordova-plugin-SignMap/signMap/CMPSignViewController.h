//
//  CMPSignViewController.h
//  CMPCore
//
//  Created by wujiansheng on 16/7/28.
//
//

#import <CMPLib/CMPBannerViewController.h>
#import "SyReverseGeocoder.h"

@protocol CMPSignViewControllerDelegate;

@interface CMPSignViewController : CMPBannerViewController
@property (nonatomic, copy) NSString *webCommandKey;
@property (nonatomic, weak) id<CMPSignViewControllerDelegate> delegate;

@end


@protocol CMPSignViewControllerDelegate <NSObject>

- (void)signViewViewControllerDidCancel:(CMPSignViewController *)aViewController;
- (void)signViewViewControllerDidFail:(CMPSignViewController *)aViewController failError:(NSError *)error;
- (void)signViewViewController:(CMPSignViewController *)aViewController withAddress:(SyAddress *)aAddress currentLoaction:(CLLocation *)aLocation withWebViewCommandKey:(NSString *)aWebViewCommandKey;

@end

// M1 SyMarkInMapViewController
