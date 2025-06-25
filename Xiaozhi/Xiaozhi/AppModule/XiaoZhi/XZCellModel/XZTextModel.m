//
//  XZTextModel.m
//  M3
//
//  Created by wujiansheng on 2017/12/2.
//

#define kXZTextModelPattern @"(##[^#]+##)|\\[([^\\]]*?)\\]\\(([^\\]]*?)\\)"

#import "XZTextModel.h"
#import "SPConstant.h"
@implementation XZTextModel

- (id)init {
    if (self = [super init]) {
        self.cellClass = @"XZTextTableViewCell";
        self.ideltifier = @"XZTextTableViewCellonly_text0";
        self.tapEnable = NO;
        _defalutTapEnable = YES;
    }
    return self;
}

- (XZTextInfoModel *)modelForMessage:(NSString*)msg {
    NSString *str = msg;
    UIColor *textColor = self.chatCellType == ChatCellTypeUserMessage ? [UIColor whiteColor] :[UIColor blackColor];
    UIFont *font = [UIFont systemFontOfSize:16];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:textColor,NSForegroundColorAttributeName,font,NSFontAttributeName, nil];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str attributes:attributes];
    //    NSString *pattern = @"##[^#]+##";
    //    NSString *pattern = @"\\[([^\\]]*?)\\]\\(([^\\]]*?)\\)";//识别[xxx](xxx)
    NSString *pattern = kXZTextModelPattern;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:nil];
    NSArray *results = [regex matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    __weak typeof(self) weakSelf = self;
    NSMutableArray * tapModels = [NSMutableArray array];
    __block NSInteger deleteLenght = 0;
    [results enumerateObjectsUsingBlock:^(NSTextCheckingResult*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange range = obj.range;
        NSRange rang1 = [obj rangeAtIndex:1];
        NSRange rang2 = [obj rangeAtIndex:2];
        NSRange rang3 = [obj rangeAtIndex:3];
        NSString *showStr = nil;
        NSString *valueStr = nil;
        if (rang1.location != NSNotFound) {
            //##xx##
            showStr = [str substringWithRange:NSMakeRange(rang1.location+2, rang1.length-4)];
            valueStr = showStr;
        }
        else {
            //[XX](XX)
            showStr = [str substringWithRange:rang2];
            valueStr = [str substringWithRange:rang3];
            if ([NSString isNull:valueStr]) {
                valueStr = showStr;
            }
        }
        UIColor *replaceColor = UIColorFromRGB(0xff9601);
        if (![weakSelf cannotTapString:showStr] ) {
            replaceColor = self->_defalutTapEnable ? UIColorFromRGB(0x1865ef):[UIColor blackColor];
        }
        NSDictionary *replaceAttributes = [NSDictionary dictionaryWithObjectsAndKeys:replaceColor,NSForegroundColorAttributeName,font,NSFontAttributeName, nil];
        NSMutableAttributedString *replaceString = [[NSMutableAttributedString alloc] initWithString:showStr attributes:replaceAttributes];
        
        NSRange replacedRange = NSMakeRange(range.location-deleteLenght, range.length);
        [attributedString replaceCharactersInRange:replacedRange withAttributedString:replaceString];
        NSRange repaceRange = NSMakeRange(range.location-deleteLenght, showStr.length);
        if (![weakSelf cannotTapString:showStr] && self->_defalutTapEnable) {
            weakSelf.tapEnable = YES;
            XZTextTapModel *model = [[XZTextTapModel alloc] init];
            model.range = repaceRange;
            model.text = showStr;
            model.valueStr = valueStr;
            model.tapType = XZTextTapTypeNormal;
            [tapModels addObject:model];
        }
        deleteLenght += (range.length - showStr.length);
    }];
    
    XZTextInfoModel *model = [[XZTextInfoModel alloc] init];
    model.info = attributedString;
    model.tapModel = tapModels;
    return model;
}


- (BOOL)cannotTapString:(NSString *)string {
    NSArray *array = [NSArray arrayWithObjects:@"小明", nil];
    return [array containsObject:string];
}

- (void)handleInfo {
    CGFloat maxLabelWidth = self.scellWidth-144;
    
    if (!_showItems) {
        _showItems = [[NSMutableArray alloc] init];
    }
    [_showItems removeAllObjects];
    CGFloat cellHeight = kXZCellSpace;
    _lableWidth = 0;
    NSArray *stringList = [self.contentInfo componentsSeparatedByString:@"{}"];
    UIFont *font = [UIFont systemFontOfSize:16];
    NSInteger fontHeight = font.lineHeight+2;
    BOOL lastIsText = YES;
    for (NSInteger i = 0; i < stringList.count; i++) {
        NSString *string = [stringList objectAtIndex:i];
        if (string && string.length > 0) {
            cellHeight += 10;
            
            XZTextInfoModel *model = [self modelForMessage:string];
            NSAttributedString  *str = model.info;
            string = str.string;
            CGSize s = [string sizeWithFontSize:font defaultSize:CGSizeMake(maxLabelWidth, MAXFLOAT)];
            NSInteger width = s.width+1;
            NSInteger height = s.height+1;
            if (height > fontHeight) {
                width = maxLabelWidth;
            }
            width = width >20?width:20;
            if (self.clickItems.count > 0) {
                width = maxLabelWidth;
            }
            model.size = CGSizeMake(width, height);
            _lableWidth = _lableWidth>width ?_lableWidth :width;
            [_showItems addObject:model];
            
            cellHeight += height;
            cellHeight += 10;
            lastIsText = YES;
        }
        if (i < self.clickItems.count) {
            NSArray *itemsList = [self.clickItems objectAtIndex:i];
            for ( id obj in itemsList) {
                NSInteger itemHeight = 0;
                if ([obj isKindOfClass: NSClassFromString(@"SPWillDoneModel")]) {
                    itemHeight = kOverdueModelHeight+1;
                }
                else if ([obj isKindOfClass: NSClassFromString(@"SPWillDoneItemModel")]) {
                    itemHeight = kWillDoneItemHeight+1;
                }
                else if ([obj isKindOfClass: NSClassFromString(@"SPScheduleModel")]) {
                    itemHeight = kScheduleModelHeight+1;
                }
                else if ([obj isKindOfClass: NSClassFromString(@"XZSearchAppModel")]) {
                    itemHeight = kWillDoneItemHeight+1;
                }
                XZTextInfoModel *model = [[XZTextInfoModel alloc] init];
                model.info = obj;
                model.size = CGSizeMake(maxLabelWidth+31, itemHeight);
                [_showItems addObject:model];
                
                cellHeight += itemHeight;
                _lableWidth = maxLabelWidth;
                cellHeight += 1;
                lastIsText = NO;
            }
        }
    }
    /*lastIsText yes:代表最后是文本，no:代表最后是列表，需要+20显示气泡圆角 ，否者会遮住气泡*/
    cellHeight += (self.showMoreBtn ? 44 : (lastIsText ? 0: 20));
    _cellHeight = cellHeight;
}

- (CGFloat)cellHeight {
    if (_cellHeight == 0 || self.resetCellHeight) {
        [self handleInfo];
        self.resetCellHeight = NO;
    }
    return _cellHeight;
}

+ (XZTextModel*)modelWithMessageType:(ChatCellType)type
                             itemTag:(NSInteger)itemTag
                         contentInfo:(NSString *)contentInfo {
    XZTextModel *model = [[XZTextModel alloc] init];
    model.chatCellType = type;
    model.itemTag = itemTag;
    model.contentInfo = contentInfo;
    if ([model.contentInfo rangeOfString:@"{}"].location != NSNotFound) {
        model.cellClass = @"XZItemsTableViewCell";
        model.ideltifier = [NSString stringWithFormat:@"click%u", arc4random_uniform(99999)];//随机 不重用
    } else {
        model.ideltifier = [NSString stringWithFormat:@"only_text%ld",(long)type];
        model.cellClass = @"XZTextTableViewCell";
    }
    return model;
}

- (void)disableTapText {
    if (self.tapEnable) {
        self.tapEnable = NO;
        _defalutTapEnable = NO;
        for (XZTextInfoModel *modle  in self.showItems) {
            if (modle.tapModel.count >0) {
                modle.tapModel = nil;
                NSMutableAttributedString *string = (NSMutableAttributedString *)modle.info;
                [string addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}
                                          range:NSMakeRange(0, string.length)];
                modle.info = string;
                if (modle.reloadTextBlock) {
                    modle.reloadTextBlock();
                }
            }
        }
    }
}
- (void)disableOperate {
    [self disableTapText];
}
- (BOOL)canClickAtIndex:(NSInteger)index{
    NSArray *clickModeList = self.clickItems.firstObject;
    if (index < clickModeList.count) {
        if (self.clickBlock) {
            return YES;
        }
    }
    return NO;
}

- (void)clickAtIndex:(NSInteger)index {
    NSArray *clickModeList = self.clickItems.firstObject;
    if (index < clickModeList.count) {
        id obj = [clickModeList objectAtIndex:index];
        if (self.clickBlock) {
            self.clickBlock(obj);
        }
    }
}



- (void)dealloc {
    self.contentInfo = nil;
    self.clickItems = nil;
    self.showItems = nil;
    
    self.moreBtnClickAction = nil;
    self.clickBlock = nil;
    self.clickTextBlock = nil;
    self.clickLinkBlock = nil;
}


//小致说话解析：去掉“##xxx##”中的“##”，去掉"[XXX](yyy)"中的“[](yyy)”
+ (NSString *)handleGuideWord:(NSString *)guideWord {
    if ([NSString isNull:guideWord]) {
        return nil;
    }
    NSMutableString *string = [NSMutableString stringWithString:guideWord];
    NSString *pattern = kXZTextModelPattern;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:nil];
    NSArray *results = [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    NSInteger originalLength = guideWord.length;//原始长度
    [results enumerateObjectsUsingBlock:^(NSTextCheckingResult*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger decrementLength = originalLength - string.length;//减少长度
        NSRange range = NSMakeRange(obj.range.location-decrementLength, obj.range.length);
        NSRange rang1 = [obj rangeAtIndex:1];
        NSRange rang2 = [obj rangeAtIndex:2];
        NSString *replaceStr = @"";
        if (rang1.location != NSNotFound) {
            replaceStr = [guideWord substringWithRange:rang1];
        }
        else {
            replaceStr = [guideWord substringWithRange:rang2];
        }
        [string replaceCharactersInRange:range withString:replaceStr];        
    }];
    NSString *result = string;
    return result;
}

@end
