//
//  XZBaseMsgData.m
//  M3
//
//  Created by wujiansheng on 2018/9/12.
//

#import "XZBaseMsgData.h"

@implementation XZBaseMsgData
- (void)dealloc {
    SY_RELEASE_SAFELY(_content);
    SY_RELEASE_SAFELY(_gotoUrl);
    SY_RELEASE_SAFELY(_gotoParams);
    SY_RELEASE_SAFELY(_cellClass);
    SY_RELEASE_SAFELY(_ideltifier);
    SY_RELEASE_SAFELY(_extData);
    SY_RELEASE_SAFELY(_timeStr);
    [super dealloc];
}

- (NSString *)stringValue:(NSString *)vaule {
    if ([vaule isKindOfClass:[NSString class]]) {
        return vaule;
    }
    return @"";
}

- (id)initWithMsg:(NSDictionary *)msg {
    if (self = [super init]) {
        self.content = [self stringValue:msg[@"content"]];
        self.gotoUrl = [self stringValue:msg[@"gotoUrl"]];
        self.gotoParams = msg[@"gotoParams"];
        self.extData = msg[@"extData"];
        if (![self.extData isKindOfClass:[NSDictionary class]]) {
            self.extData = nil;
        }
        if (self.extData) {
            NSString *startTime = [self stringValue:self.extData[@"startTime"]];
            NSString *endTime = [self stringValue:self.extData[@"endTime"]];
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"时间：%@-%@",startTime,endTime]];
            [str addAttribute:NSForegroundColorAttributeName
                        value:UIColorFromRGB(0x3F3F3F)
                        range:NSMakeRange(0, 3)];
            [str addAttribute:NSForegroundColorAttributeName
                        value:UIColorFromRGB(0x2887E9)
                        range:NSMakeRange(3, str.string.length-3)];
            self.timeStr = str;
            SY_RELEASE_SAFELY(str);
        }
    }
    return self;
}
- (CGFloat)cellHeightForWidth:(CGFloat)width {
    //上下个10
    NSInteger height = 8;//顶部距离
    //标题
    UIFont *font = kMsgDataContentFont;
    CGSize s = [self.content sizeWithFontSize:font defaultSize:CGSizeMake(width, 1000)];
    if (s.height > font.lineHeight+1) {
        height += font.lineHeight *2+1;
    }
    else {
        height += font.lineHeight+1;
    }
    height += 4;//间距
    height += FONTSYS(14).lineHeight+1;//时间
    height += 8;//下边距
    return height;
}
@end
