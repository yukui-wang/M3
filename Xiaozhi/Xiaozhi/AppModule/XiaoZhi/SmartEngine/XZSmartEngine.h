//
//  SPSmartEngine.h
//  MSCDemo
//
//  Created by CRMO on 2017/2/11.
//
//

#import <Foundation/Foundation.h>


typedef void(^SmartEngineBlock)(void);

#import "SPSmartEngine.h"
#import "XZSendIMMsgIntent.h"

@interface XZSmartEngine : SPSmartEngine<XZSendIMMsgIntentDelegate> {
    NSDictionary *_selectorDic;
    NSDictionary *_localCommandDic;

}

@property(nonatomic, strong)XZAppIntent *intent;
@property(nonatomic, strong)NSString *targetSlot;//目标词槽
@property(nonatomic, copy)SmartEngineBlock sendBlock;
@property(nonatomic, copy)SmartEngineBlock modifyBlock;
@property(nonatomic, copy)SmartEngineBlock cancelBlock;
@property(nonatomic, strong)XZSendIMMsgIntent *sendIMMsgintent;
@property(nonatomic, strong)NSString* unitSessionId;

- (void)handleBaiduUnitResult:(BUnitResult *)result;
- (void)nextIntent:(NSString *)intentName data:(NSDictionary *)data;

@property(nonatomic,strong)NSDictionary *commandsDic;
@property(nonatomic,copy)void(^commandsBlock)(NSString *key,NSString *word);
- (BOOL)filterResult:(NSString *)result;
- (BOOL)needAnalysisByServer:(NSString *)result;

@end

