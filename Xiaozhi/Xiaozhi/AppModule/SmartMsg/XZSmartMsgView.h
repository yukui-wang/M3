//
//  XZSmartMsgView.h
//  M3
//
//  Created by wujiansheng on 2018/9/7.
//

#import "XZBaseView.h"

@interface XZSmartMsgView : XZBaseView<UIScrollViewDelegate> {
    UIView *_shadeView;//遮罩层
    NSMutableArray *_msgViewArray;
    UIScrollView *_scrollView;
    UIPageControl *_pageControl;
  
    UIButton *_voiceButton;
    UIButton *_closeButton;
    BOOL _voiceOn;

}
@property (nonatomic, copy) void (^needDismissBlock)(void);
@property (nonatomic, copy) void (^needSpeakBlock)(NSString *string);
@property (nonatomic, copy) void (^needStopSpeakBlock)(void);
@property (nonatomic, assign)BOOL isfirst;//是否是首次展示，历史消息不算

- (void)setupMsgArray:(NSArray *)msgArray;
- (void)showInView:(UIView *)view;
- (void)dismiss;
@end
