//
//  XZBaseMsgView.h
//  M3
//
//  Created by wujiansheng on 2018/9/7.
//

#define IS_PHONE_Landscape INTERFACE_IS_PHONE && UIInterfaceOrientationIsLandscape(self.interfaceOrientation)


#import "XZBaseView.h"
#import "XZBaseMsg.h"

@interface XZBaseMsgView : XZBaseView {
    UILabel *_titleLabel;
    UIButton *_firstButton;
    BOOL _onoff;
}

@property(nonatomic, retain)XZBaseMsg *msg;
@property(nonatomic, assign)BOOL isFirst;
@property(nonatomic, copy) void (^needOnOffBlock)(BOOL onoff);
@property(nonatomic, assign)BOOL hasSpeaked;//语音以合成播放
@property(nonatomic, copy) void (^willOpenViewBlock)(void);

- (id)initWithMsg:(XZBaseMsg *)msg;
+ (XZBaseMsgView *)viewWithMsg:(XZBaseMsg *)msg;
- (void)loadView;
@end
