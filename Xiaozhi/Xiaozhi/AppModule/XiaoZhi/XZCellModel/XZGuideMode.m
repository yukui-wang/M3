//
//  XZGuideMode.m
//  M3
//
//  Created by wujiansheng on 2018/1/4.
//

#import "XZGuideMode.h"
#import "XZCore.h"
@interface XZGuideMode () {
}
@end

@implementation XZGuideMode


- (id)initWithType:(GuideCellType)type {
    if (self = [super init]) {
        self.cellClass = @"XZGuideTableViewCell";
        self.ideltifier = type == GuideCellTypeGuide ? @"xzguidecell" : @"xzhelpcell";
        self.contentInfo = @"你好！你可以这样命令我："; //你可以这样问我
        self.chatCellType = ChatCellTypeRobotMessage;
        self.showMore = type == GuideCellTypeGuide && [[[XZCore sharedInstance] intentPrivilege] showMore] ;
    }
    return self;
}
- (CGFloat)heightForGuideInfo {
    XZIntentPrivilege *intentPrivilege = [[XZCore sharedInstance] intentPrivilege];
    NSString * guideString = self.showMore ?[intentPrivilege showStr] : [intentPrivilege showAllStr];
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.lineSpacing = 6; //设置行间距
    paraStyle.hyphenationFactor = 1.0;
    paraStyle.firstLineHeadIndent = 0.0;
    paraStyle.paragraphSpacingBefore = 0.0;
    paraStyle.headIndent = 0;
    paraStyle.tailIndent = 0;
    //设置字间距 NSKernAttributeName:@1.5f
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:16], NSParagraphStyleAttributeName:paraStyle};
    NSAttributedString *attStr = [[NSAttributedString alloc] initWithString:guideString attributes:dic];
    self.guideInfo = attStr;
    CGSize s = [guideString boundingRectWithSize:CGSizeMake(self.lableWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    NSInteger height = s.height+1;
    return height;
}
- (void)moreBtnClick {
    if (self.showMore) {
        self.showMore = NO;
        _cellHeight = 0;
        [self cellHeight];
        if (self.moreBtnClickAction) {
            self.moreBtnClickAction();
        }
    }
}

- (CGFloat)cellHeight {
    if (_cellHeight == 0) {
        self.lableWidth = self.scellWidth-144;
        NSInteger height = 10;
        UIFont *font = [UIFont systemFontOfSize:16];
        height += font.lineHeight;
        height += [self heightForGuideInfo];
        height += 30;
        height += kXZCellSpace;
        if (self.showMore) {
            height += 20 +10;
        }
        _cellHeight = height;
    }
    return _cellHeight;
}
@end
