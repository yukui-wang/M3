//
//  CMPMultiLoginManageViewController.h
//  M3
//
//  Created by 程昆 on 2019/9/10.
//

#import <UIKit/UIKit.h>
#import <CMPLib/CMPBaseViewController.h>

@class CMPOnlineDevModel;
@interface CMPMultiLoginManageViewController : CMPBaseViewController

- (instancetype)initWithOnlineDevModel:(CMPOnlineDevModel *)model presentViewController:(UIViewController *)viewController;

@end


