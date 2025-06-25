//
//  BUnitResult.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/4/9.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "BUnitResult.h"
#import "SPConstant.h"

@implementation BUnitResult

- (BOOL)isEnd {
    return [self.intentType isEqualToString:kBUnitResult_SUCESS];
}
- (BOOL)needKeepSessionId {
    if ([self isEnd]) {
        return NO;
    }
    if ([self.intentName isEqualToString:kBUnitIntent_LEAVE]||
        [self.intentName isEqualToString:kBUnitIntent_CALL]||
        [self.intentName isEqualToString:kBUnitIntent_SENDMESSAGE]||
        [self.intentName isEqualToString:kBUnitIntent_SENDIMMESSAGE]||
        [self.intentName isEqualToString:kBUnitIntent_LOOKUPSMARTMSG]||
        [self.intentName isEqualToString:kBUnitIntent_LOOKUPPERSON]||
        [self.intentName isEqualToString:kBUnitIntent_LOOKUPEXPENSE]||
        [self.intentName isEqualToString:kBUnitIntent_LEAVE]) {
        //配置单不需要sessionId
        return YES;;
    }
    return NO;
}
@end

@implementation BUnitQAExtra

@end

@implementation BUnitOptionalOpenIntent

@end
