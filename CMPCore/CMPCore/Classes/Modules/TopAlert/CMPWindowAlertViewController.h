//
//  CMPWindowAlertViewController.h
//  M3
//
//  Created by Kaku Songu on 12/1/22.
//

#import <CMPLib/CMPBaseViewController.h>
NS_ASSUME_NONNULL_BEGIN

@interface CMPWindowAlertViewController : CMPBaseViewController

@property (nonatomic,copy) void(^dismissBlk)(__nullable id ext);
-(UIView *)showingAlertView;
-(BOOL)showBehind:(UIView *)alertView;

@end

NS_ASSUME_NONNULL_END
