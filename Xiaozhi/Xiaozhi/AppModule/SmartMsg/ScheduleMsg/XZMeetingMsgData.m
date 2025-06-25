//
//  XZMeetingMsgData.m
//  M3
//
//  Created by wujiansheng on 2018/9/12.
//

#import "XZMeetingMsgData.h"

@implementation XZMeetingMsgData
- (void)dealloc {
    SY_RELEASE_SAFELY(_meetingRoomStr);
    [super dealloc];
}

- (id)initWithMsg:(NSDictionary *)msg {
    if (self = [super initWithMsg:msg]) {
        self.ideltifier = @"XZMeetingMsgData";
        self.cellClass = @"XZMeetingMsgDataCell";
        if (self.extData) {            
            NSString *meetingRoom = [self stringValue:self.extData[@"meetingRoom"]];
            NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"地点：%@",meetingRoom]];
            [str2 addAttribute:NSForegroundColorAttributeName
                         value:UIColorFromRGB(0x3F3F3F)
                         range:NSMakeRange(0, 3)];
            [str2 addAttribute:NSForegroundColorAttributeName
                         value:UIColorFromRGB(0x2887E9)
                         range:NSMakeRange(3, str2.string.length-3)];
            self.meetingRoomStr = str2;
            SY_RELEASE_SAFELY(str2);
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
    height += 4;//间距
    height += FONTSYS(14).lineHeight+1;//地点
    height += 8;//下边距
    return height;
}
@end
