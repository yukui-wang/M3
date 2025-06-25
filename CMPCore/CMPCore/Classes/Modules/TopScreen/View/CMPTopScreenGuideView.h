//
//  CMPTopScreenGuideView.h
//  M3
//
//  Created by Shoujian Rao on 2024/1/12.
//

#import <UIKit/UIKit.h>
//显示负一屏引导页
#define kUserDefaultName_showTopScreenTipFlag [NSString stringWithFormat:@"kUserDefaultName_showTopScreenTipFlag_%@_%@_%@",[CMPCore sharedInstance].serverID,[CMPCore sharedInstance].userID,[CMPCore sharedInstance].currentUser.accountID]
//显示新的应用中心引导页
#define kUserDefaultName_showNewCommonGuideTipFlag [NSString stringWithFormat:@"kUserDefaultName_showNewCommonGuideTipFlag_%@_%@_%@",[CMPCore sharedInstance].serverID,[CMPCore sharedInstance].userID,[CMPCore sharedInstance].currentUser.accountID]

typedef void(^CMPTopScreenGuideViewDissmissBlock)(void);
NS_ASSUME_NONNULL_BEGIN

@interface CMPTopScreenGuideView : UIView

+(void)showGuideInView:(UIView *)view isMsgPage:(BOOL)isMsgPage;
+ (void)showInView:(UIView *)inView showTop:(BOOL)showTop showCommon:(BOOL)showCommon dissmiss:(CMPTopScreenGuideViewDissmissBlock)dismissBlock;

@end

NS_ASSUME_NONNULL_END
