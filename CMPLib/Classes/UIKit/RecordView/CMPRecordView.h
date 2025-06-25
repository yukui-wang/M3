//
//  SyRecordView.h
//  M1Core
//
//  Created by zhengxiaofeng on 13-1-9.
//
//
//pad
#define kPadBackViewHeight          246     //
#define kPadBackViewWidth           386     //

//phone
#define kCMPPhoneBackViewHeight         174     //
#define kCMPPhoneBackViewWidth          244     //

//common
#define kRecordViewType_Record   1
#define kRecordViewType_Play     2

typedef enum CMPRecordViewType {
    CMPRecordViewTypeRecord               = 1,
    CMPRecordViewTypePlay                 = 2,
    CMPRecordViewTypeRecordNilTitle       = 3,
    CMPRecordViewTypePlayNilTitle         = 4
}CMPRecordViewType;


#import "CMPBaseView.h"
#import <AVFoundation/AVFoundation.h>
@protocol CMPRecordViewDelegate;

@class CMPVisualizer;

@interface CMPRecordView : CMPBaseView<UITextFieldDelegate,AVAudioPlayerDelegate>{
   }


+ (BOOL)canRecord;

- (id)initWithDelegate:(id)aDelegate type:(CMPRecordViewType)aType;
- (void)show;
- (void)dismiss;
- (void)playWithFilePath:(NSString *)aFilePath;
@end

@protocol CMPRecordViewDelegate <NSObject>

@optional
- (void)recordViewDidStart:(CMPRecordView *)aRecordView; // 开始录音
- (void)recordViewDidPause:(CMPRecordView *)aRecordView; // 暂停录音
- (void)recordView:(CMPRecordView *)aRecordView didFinishRecordWithPath:(NSString *)aPath; // 完成录音
- (void)recordViewDidCancel:(CMPRecordView *)aRecordView; // 取消录音

@end
