//
//  XZQAModel.m
//  M3
//
//  Created by wujiansheng on 2018/10/19.
//


#import "XZPreQATextModel.h"
#import "XZPreQAFileModel.h"

@implementation XZPreQATextModel

- (void)dealloc {
    self.clickAppBlock = nil;
    self.clickLinkBlock = nil;

    self.attrString = nil;
    self.clickItems = nil;
}

- (id)initWithString:(NSString *)string {
    
    if (self = [super init]) {
        self.cellClass = @"XZPreQATextCell";
        self.ideltifier = @"XZPreQATextCellideltifier";
        [self setupWithStr:string];
    }
    return self;
}

- (NSString *)speakString {
    return self.attrString.string;
}

- (void)setupWithStr:(NSString *)qaStr {
    
    self.attrString = nil;
    NSString *pattern = @"\\[([^\\]]*?)\\](\\(|（)(link|app)(:|：)([^\\)]*)[\\)]?(\\)|）)";

    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:nil];
    NSArray *results = [regex matchesInString:qaStr options:0 range:NSMakeRange(0, qaStr.length)];
    
    CGFloat maxLabelWidth = self.scellWidth-144;
    UIFont *font = [UIFont systemFontOfSize:16];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],NSForegroundColorAttributeName,font,NSFontAttributeName, nil];
    NSMutableArray * tapModels = [NSMutableArray array];
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:qaStr attributes:attributes];
    __block NSInteger deleteLenght = 0;
    [results enumerateObjectsUsingBlock:^(NSTextCheckingResult*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange range = obj.range;// NSMakeRange(obj.range.location-4*idx, obj.range.length-4);
        NSInteger number = obj.numberOfRanges;
        NSString *title = number > 2 ? [qaStr substringWithRange:[obj rangeAtIndex:1]]:@"";
        NSString *type = number > 4 ? [qaStr substringWithRange:[obj rangeAtIndex:3]]:@"";
        NSString *value = number > 6 ? [qaStr substringWithRange:[obj rangeAtIndex:5]]:@"";
        XZTextTapType tapType = [type isEqualToString:@"link"] ? XZTextTapTypeLink :XZTextTapTypeAPP;
        NSDictionary *att = [NSDictionary dictionaryWithObjectsAndKeys:UIColorFromRGB(0x1865ef),NSForegroundColorAttributeName,font,NSFontAttributeName, nil];
        NSAttributedString *rangeAttrStr = [[NSAttributedString alloc] initWithString:title attributes:att];
        //替换的位置
        NSRange newRange = NSMakeRange(range.location-deleteLenght, range.length);
        //替换
        [attributedString replaceCharactersInRange:newRange withAttributedString:rangeAttrStr];
        //替换后的位置
        newRange = NSMakeRange(range.location-deleteLenght, title.length);
        XZTextTapModel *model = [[XZTextTapModel alloc] init];
        model.range = newRange;
        model.text = value;
        model.tapType = tapType;
        [tapModels addObject:model];
      
        //标记替换后减少的长度
        deleteLenght += (range.length - title.length);
    }];
    self.attrString = attributedString;
    
    self.clickItems = tapModels;

    CGSize s = [self.attrString.string sizeWithFontSize:font defaultSize:CGSizeMake(maxLabelWidth, MAXFLOAT)];
    NSInteger width = s.width+1;
    NSInteger height = s.height+1;
    NSInteger fontHeight = font.lineHeight+2;
    if (height > fontHeight) {
        width = maxLabelWidth;
    }

    self.contentSize = CGSizeMake(width, height);
    _cellHeight = height+30;
}

- (CGFloat)cellHeight{
    return _cellHeight;
}

+ (void)modelsWithQAResult:(NSString *)resultStr block:(nonnull void (^)(NSArray *, NSString * _Nonnull))block {
    //干掉最后一个</div> 防止最后有空白行
    NSString *qaStr = resultStr.length >6 && [[resultStr substringFromIndex:resultStr.length-6] isEqualToString:@"</div>"]? [resultStr substringToIndex:resultStr.length-6]: resultStr;
    qaStr = [qaStr replaceCharacter:@"</div><div>" withString:@"\n"];
    qaStr = [qaStr replaceCharacter:@"<div>" withString:@"\n"];
    qaStr = [qaStr replaceCharacter:@"</div>" withString:@"\n"];    
    
//    NSString *pattern = @"\\[([^\\]]*?)\\]\\((link|app|file):([^\\)]*)[\\)]?\\)";
//    NSString *pattern = @"\\[([^\\]]*?)\\]\\(file:([^\\)]*)[\\)]?\\)";
    NSString *pattern = @"\\[([^\\]]*?)\\](\\(|（)file:([^\\)]*)[\\)]?(\\)|）)";

    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:nil];
    NSArray *results = [regex matchesInString:qaStr options:0 range:NSMakeRange(0, qaStr.length)];

    
    if (results.count == 0) {
        XZPreQATextModel *model = [[XZPreQATextModel alloc] initWithString:qaStr];
        block([NSArray arrayWithObjects:model, nil],model.speakString);
        return;
    }
    
    NSMutableArray *array = [NSMutableArray array];
    __block NSString *speakStr = @"";
    [results enumerateObjectsUsingBlock:^(NSTextCheckingResult*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange range = obj.range;// NSMakeRange(obj.range.location-4*idx, obj.range.length-4);
        if (idx == 0) {
            if (range.location == 0) {
                speakStr = @"这是为你找到的相关文件";
            }
            else {
                NSString *string = [qaStr substringToIndex:range.location];
                XZPreQATextModel *model = [[XZPreQATextModel alloc] initWithString:string];
                speakStr = model.speakString;
                [array addObject:model];
            }
        }
        else {
            NSTextCheckingResult *r = [results objectAtIndex:idx-1];
            NSRange preRange = r.range;
            NSInteger start = preRange.location +preRange.length;
            
            if (start < range.location) {
                NSString *string = [qaStr substringWithRange:NSMakeRange(start, range.location-start)];
                XZPreQATextModel *model = [[XZPreQATextModel alloc] initWithString:string];
                [array addObject:model];
            }
        }
        NSInteger number = obj.numberOfRanges;
        NSString  *fileName = number > 2 ? [qaStr substringWithRange:[obj rangeAtIndex:1]]:@"";
        NSString  *fileJson = number > 4 ? [qaStr substringWithRange:[obj rangeAtIndex:3]]:nil;
        XZPreQAFileModel *model = [[XZPreQAFileModel alloc] initWithFileName:fileName fileJson:fileJson];
        [array addObject:model];
    }];
    NSTextCheckingResult *last = [results lastObject];
    NSRange range = last.range;
    NSInteger max = range.location +range.length;

    if (max < qaStr.length-1) {
        NSString *string = [qaStr substringFromIndex:max];
        XZPreQATextModel *model = [[XZPreQATextModel alloc] initWithString:string];
        [array addObject:model];
    }
    block(array,speakStr);
}

@end
