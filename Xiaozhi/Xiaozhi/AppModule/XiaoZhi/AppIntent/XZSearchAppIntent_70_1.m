//
//  XZSearchAppIntent_70_1.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/6/15.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZSearchAppIntent_70_1.h"

@interface XZSearchAppIntent_70_1 () {
    NSMutableDictionary *_valueListDic;
}

@end

@implementation XZSearchAppIntent_70_1

- (NSDictionary *)dicVaule {
    return _valueListDic;
}
- (void)handleNativeResult:(NSString *)result  {
   if (self.currentStep) {
       if (!_valueListDic) {
           _valueListDic = [[NSMutableDictionary alloc] init];
       }
       [_valueListDic setObject:result forKey:self.currentStep.key];
    }
    [self next:YES];
}
- (void)handleUnitResult:(BUnitResult *)bResult {
    _useUnit = NO;
    if (!_valueListDic) {
        _valueListDic = [[NSMutableDictionary alloc] init];
    }
    [_valueListDic removeAllObjects];
    NSDictionary *dic = bResult.infoListDict;
    if (dic && dic.allKeys.count > 0) {
        for (XZIntentStep *step in self.params) {
            NSString *key = step.slot;
            if (dic[key]) {
                [_valueListDic setObject:dic[key] forKey:step.key];
            }
        }
    }
    XZIntentStep *step = self.intentStepTarget ? [self stepForKey:self.intentStepTarget]:self.currentStep;
    if (step && self.showGuideBlock) {
        self.showGuideBlock(step.guideWord);
    }
    [self next:bResult.isEnd];
}

- (void)next:(BOOL)isEnd {
      
  
    if (isEnd) {
        if ([self.renderType isEqualToString:@"penetrate"]) {
            //penetrate:穿透 （使用openType+openApi）
           if (self.openBlock) {
                self.openBlock(self);
           }
        }
        else if ([self.renderType isEqualToString:@"nesting"]) {
            //nesting:嵌套，在小致界面渲染（使用loadUrl）
            if (self.nestingBlock) {
                self.nestingBlock(self);
            }
        }
        else {
            //card:卡片渲染，先请求，再渲染卡片（使用loadUrl）
            if (self.searchBlock) {
                self.searchBlock(self);
            }
        }
    }
}
@end
