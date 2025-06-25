//
//  XZOptionMemberModel.m
//  M3
//
//  Created by wujiansheng on 2018/1/8.
//

#import "XZOptionMemberModel.h"
#import "XZTextTapModel.h"
#import "XZOptionMemberView.h"
@implementation XZOptionMemberModel

- (id)init {
    if (self = [super init]) {
        self.cellClass = @"XZOptionMemberCell";
        self.ideltifier = [NSString stringWithFormat:@"XZOptionMemberCell%u", arc4random_uniform(99999)];//随机 不重用
        self.chatCellType = ChatCellTypeRobotMessage;
        self.canOperate = YES;
    }
    return self;
}

- (void)setCanOperate:(BOOL)canOperate {
    if (!canOperate && _canOperate) {
        _cellHeight = 0;
    }
    _canOperate = canOperate;
}

- (XZTextInfoModel *)modelForMessage:(NSString*)msg {
    NSString *str = msg;
    str = [str replaceCharacter:@"{}" withString:@""];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[[str componentsSeparatedByString:@"##"] componentsJoinedByString:@""]];
    [attributedString addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}
                              range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:NSFontAttributeName
                             value:[UIFont systemFontOfSize:16]
                             range:NSMakeRange(0, attributedString.length)];
    NSString *pattern = @"##[^#]+##";
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:nil];
    NSArray *results = [regex matchesInString:msg options:0 range:NSMakeRange(0, msg.length)];
    
    __weak typeof(self) weakSelf = self;
    NSMutableArray * tapModels = [NSMutableArray array];
    [results enumerateObjectsUsingBlock:^(NSTextCheckingResult*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange range = NSMakeRange(obj.range.location-4*idx, obj.range.length-4);
        NSString *rangeStr = [attributedString.string substringWithRange:range];
        
        if ([rangeStr isEqualToString:@"取消"] ) {
            if (self->_canOperate) {
                [attributedString addAttribute:NSForegroundColorAttributeName
                                         value:UIColorFromRGB(0x1865ef)
                                         range:range];
                if (self->_canOperate) {
                    weakSelf.canOperate = YES;
                    XZTextTapModel *model = [[XZTextTapModel alloc] init];
                    model.range = range;
                    model.text = rangeStr;
                    model.tapType = XZTextTapTypeNormal;
                    [tapModels addObject:model];
                }
            }
        }
        else {
            [attributedString addAttribute:NSForegroundColorAttributeName
                                     value:UIColorFromRGB(0xff9601)
                                     range:range];
        }
    }];
    XZTextInfoModel *model = [[XZTextInfoModel alloc] init];
    model.info = attributedString;
    model.tapModel = tapModels;
    return model;
}


- (CGFloat)cellHeight {
    if (_isNewCell) {
        return [XZOptionMemberView viewHeightForModel:self]+20;
    }
    if (_cellHeight == 0) {
        self.lableWidth = self.scellWidth-144;
        NSInteger heigh = 10+10;
        UIFont *font = [UIFont systemFontOfSize:16];
        
        NSString *contentInfo = self.param.showContent;
        self.textInfo = [self modelForMessage:contentInfo];
        NSString *string = [contentInfo replaceCharacter:@"##" withString:@""];
        CGSize s = [string sizeWithFontSize:font defaultSize:CGSizeMake(self.lableWidth, MAXFLOAT)];
        
        NSInteger h = s.height+1;
        self.lableHeight = h;
        heigh += self.lableHeight;
        NSMutableArray *array = [NSMutableArray array];
        for (NSInteger index = 0 ; index < self.param.members.count; index++) {
            heigh += 10;
            CMPOfflineContactMember *member = self.param.members[index];
            NSString *title = [NSString stringWithFormat:@"%ld、%@%@",(long)index+1,member.department,member.name];
            
            s = [title sizeWithFontSize:FONTSYS(14) defaultSize:CGSizeMake(self.lableWidth, MAXFLOAT)];
            NSString *sizeString = NSStringFromCGSize(CGSizeMake(s.width +20, 30));
            NSString *orgY = [NSString stringWithFormat:@"%ld",(long)heigh];
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:orgY,@"orgY",sizeString,@"size",title,@"title",member,@"member", nil];
            [array addObject:dic];
            heigh += 30;
        }
        self.showInfoList = array;
        heigh += kXZCellSpace;
        _cellHeight = heigh;
    }
    return _cellHeight;
}

- (void)disableOperate {
    self.canOperate = NO;
}

- (void)dealloc {
    self.didChoosedMembersBlock  = nil;
    self.showMoreBlock = nil;
    self.clickTextBlock = nil;
    self.clickOKButtonBlock = nil;
    self.param = nil;
    self.showInfoList = nil;
    self.textInfo = nil;
}

@end
