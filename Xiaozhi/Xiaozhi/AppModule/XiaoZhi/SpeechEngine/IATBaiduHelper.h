//
//  IATBaiduHelper.h
//  M3
//
//  Created by wujiansheng on 2017/12/12.
//

#import <Foundation/Foundation.h>
#define GRAMMAR_TYPE_BNF    @"bnf"
#define GRAMMAR_TYPE_ABNF    @"abnf"


@protocol IATBaiduHelperDelegate <NSObject>
/** 启动识别时
 */
-(void)didStartRecordingVoice:(id)sender;
/** 成功完成识别
 */
-(void)didFinishVoiceRecognizedWithResult:(NSString *)aResult;
/** 识别状态返回，0为成功
 */
-(void)faidWithError:(NSError *) error;
@end

@interface IATBaiduHelper : NSObject
@property (nonatomic,weak)         id<IATBaiduHelperDelegate>  delegate;
-(void)startAudioSourceWithParaDic:(NSDictionary *)aDic;
-(void)buildGrammerWithParaDic:(NSDictionary *)aDic;
/** 取消识别
 */
-(void)cancelVoice;


@end
