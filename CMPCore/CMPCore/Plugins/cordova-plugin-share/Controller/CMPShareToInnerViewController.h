//
//  CMPShareToInnerViewController.h
//  M3
//
//  Created by MacBook on 2019/10/28.
//

#import <CMPLib/CMPBannerViewController.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPShareToInnerViewController : CMPBannerViewController

/* filePath */
@property (copy, nonatomic) NSArray *filePaths;

/* vc dismiss后 */
@property (copy, nonatomic) void(^vcDissmissed)(void);

/* fromVC */
@property (weak, nonatomic) UIViewController *fromVC;

/* fromWindow */
@property (weak, nonatomic) UIWindow *fromWindow;

@end

NS_ASSUME_NONNULL_END
