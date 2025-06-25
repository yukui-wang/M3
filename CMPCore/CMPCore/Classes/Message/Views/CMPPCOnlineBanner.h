//
//  CMPPCOnlineBanner.h
//  M3
//
//  Created by CRMO on 2019/5/24.
//

#import <UIKit/UIKit.h>
@class CMPOnlineDevModel;

NS_ASSUME_NONNULL_BEGIN

@interface CMPPCOnlineBanner : UIView
@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *textLabel;

-(void)updateTipMessageWithOnlineModel:(CMPOnlineDevModel*)model muteState:(BOOL)isMute;
- (void)setTip:(NSString *)tip;

@end

NS_ASSUME_NONNULL_END
