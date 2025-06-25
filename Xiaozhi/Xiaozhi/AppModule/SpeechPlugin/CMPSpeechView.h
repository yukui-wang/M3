//
//  CMPSpeechView.h
//  M3
//
//  Created by wujiansheng on 2019/3/28.
//

#import "XZBaseView.h"

typedef NS_ENUM(NSInteger,CMPSpeechViewType) {
    CMPSpeechViewType_Command = 1,
    CMPSpeechViewType_LongText = 2
};


typedef void(^SpeechViewEndBlock)(NSString *result, BOOL finish, UIView *view);
typedef void(^SpeechViewCancelBlock)(void);

@interface CMPSpeechView : XZBaseView

- (id)initWithType:(NSInteger) type
          endBlock:(SpeechViewEndBlock)endBlock
       cancelBlock:(SpeechViewCancelBlock)cancelBlock;
- (void)didDismiss;
- (void)showToast:(NSString *)msg;

@end
