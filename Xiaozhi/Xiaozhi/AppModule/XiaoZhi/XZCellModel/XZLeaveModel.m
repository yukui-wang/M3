//
//  XZLeaveModel.m
//  M3
//
//  Created by wujiansheng on 2017/12/29.
//

#import "XZLeaveModel.h"
#import "XZCore.h"
#import "XZDateUtilsTool.h"

@implementation XZLeaveModel
- (void)dealloc {
    self.sendLeaveBlock = nil;
    self.modifyLeaveBlock = nil;
    self.cancelLeaveBlock = nil;
   
    self.userName = nil;
    self.department = nil;
    self.post = nil;
    self.startTime = nil;
    self.endTime = nil;
    self.timeNumber = nil;
    self.leaveType = nil;
    self.leaveReason = nil;
    self.handleType = nil;
    self.timeAttStr = nil;
    self.clickTitle = nil;
}

- (id)init {
    if (self = [super init]) {
        self.cellClass = @"XZLeaveTableViewCell";
        self.ideltifier = @"xzleavecell";
        self.canOperate = YES;
    }
    return self;
}

- (void)setIsNewInterface:(BOOL)isNewInterface {
    _isNewInterface = isNewInterface;
    if (_isNewInterface) {
        self.cellClass = @"XZLeaveCardCell";
    }
}


- (NSString *)translationArebicStr:(NSString *)chineseStr{
    NSString *str = chineseStr;
    NSArray *arabic_numerals = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0",@"0",@"2",@"."];
    NSArray *chinese_numerals = @[@"一",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"零", @"十",@"两",@"点"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:arabic_numerals forKeys:chinese_numerals];
    NSMutableArray *sums = [NSMutableArray array];
    for (int i = 0; i < str.length; i ++) {
        NSString *substr = [str substringWithRange:NSMakeRange(i, 1)];
        NSString *sum = substr;
        if([chinese_numerals containsObject:substr]){
            if([substr isEqualToString:@"十"] && i < str.length){
                NSString *nextStr = [str substringWithRange:NSMakeRange(i+1, 1)];
                if([chinese_numerals containsObject:nextStr]){
                    continue;
                }
            }
            sum = [dictionary objectForKey:substr];
        }
        [sums addObject:sum];
    }
    
    NSString *sumStr = [sums  componentsJoinedByString:@""];
    if ([chineseStr rangeOfString:@"半"].location != NSNotFound) {
        sumStr = [NSString stringWithFormat:@"%ld",(long)[sumStr integerValue]];
        sumStr = [NSString stringWithFormat:@"%@.5",sumStr];
    }
    sumStr = [sumStr replaceCharacter:@"天" withString:@""];
    return sumStr;
}

- (void)handleUintResult:(NSDictionary *)info {
    /*这儿和 sp2 不一样*/
    self.userName = [XZCore userName];
    self.department = [XZCore departmentName];
    NSString *postID = [XZCore postID];
    if ([NSString isNull:postID] || [postID isEqualToString:@"-1"]) {
        //OA-142308 智能助手：发请假流程，小致显示请假信息的时候获取了编外人员的岗位，应该不获取
        self.post = @"";
    }
    else {
        self.post = [XZCore postName];
    }
    self.leaveType = info[@"user_leave_type"];
    self.startTime = info[@"user_leave_begintime"];
    self.endTime = info[@"user_leave_endtime"];
    self.timeNumber = info[@"user_leave_number"];
    self.startTime = [self.startTime replaceCharacter:@"-00" withString:@"-01"];

    if ([[XZCore sharedInstance] isXiaozVersionLater3_1]) {
        if (![NSString isNull:self.startTime]) {
            self.startTime = [XZDateUtilsTool obtainFormatDateTime:self.startTime];
        }
        if (![NSString isNull:self.endTime]) {
            self.endTime = [XZDateUtilsTool obtainFormatDateTime:self.endTime];
        }
    }
    self.startTime = [self standardTime:self.startTime begin:YES];
    self.endTime = [self standardTime:self.endTime begin:NO];
    if ([NSString isNull:self.leaveReason]) {
        self.leaveReason = [NSString stringWithFormat:@"我于%@请%@",self.startTime,self.leaveType];
    }
}

- (void)setCanOperate:(BOOL)canOperate {
    if (!canOperate && _canOperate) {
        _cellHeight = 0;
    }
    _canOperate = canOperate;
}

- (void)customCellHeight {
    self.spacing = 6;
    UIFont *font = FONTSYS(16);
    NSInteger height = font.lineHeight+1;
    self.defaultHeight = height;
    CGFloat width = self.scellWidth- 24-125;
    CGSize s = [self.leaveReason sizeWithFontSize:font defaultSize:CGSizeMake(width, MAXFLOAT)];
    height = s.height+1;
    self.reasonHeight = height;
    _cellHeight = 40+self.defaultHeight *7 + self.reasonHeight+ self.spacing*7+10;
    
    if ([self canOperate]) {
        _cellHeight += 42;//发送等按钮高度及间距
    }
    if (!self.timeNumber) {
        self.timeNumber = @"2天";
    }
    _cellHeight += kXZCellSpace;
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:self.timeNumber];
    [attStr addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}
                    range:NSMakeRange(0, attStr.length)];
    [attStr addAttribute:NSFontAttributeName
                   value:[UIFont systemFontOfSize:16]
                   range:NSMakeRange(0, attStr.length)];
    NSString *str = [self.timeNumber replaceCharacter:@"天" withString:@""];
    NSRange range = [self.timeNumber rangeOfString:str];
    if (range.location != NSNotFound) {
        [attStr addAttributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0xf57923)}
                        range:range];
    }
    self.timeAttStr = attStr;
}
- (void)newInterfaceCellHeight {
    self.spacing = 10;
    UIFont *font = FONTSYS(14);
    NSInteger height = font.lineHeight+1;
    self.defaultHeight = height;
    CGFloat width = self.scellWidth- 28-80-14;
    CGSize s = [self.leaveReason sizeWithFontSize:font defaultSize:CGSizeMake(width, MAXFLOAT)];
    height = s.height+1;
    self.reasonHeight = height;
  
    _cellHeight = 54 +self.defaultHeight *4 + self.reasonHeight+ self.spacing*4+14;

    if (!self.timeNumber) {
        self.timeNumber = @"2天";
    }
    _cellHeight += 20 ;
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:self.timeNumber];
    [attStr addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}
                    range:NSMakeRange(0, attStr.length)];
    [attStr addAttribute:NSFontAttributeName
                   value:[UIFont systemFontOfSize:16]
                   range:NSMakeRange(0, attStr.length)];
    NSString *str = [self.timeNumber replaceCharacter:@"天" withString:@""];
    NSRange range = [self.timeNumber rangeOfString:str];
    if (range.location != NSNotFound) {
        [attStr addAttributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0xf57923)}
                        range:range];
    }
    self.timeAttStr = attStr;
}

- (CGFloat)cellHeight {
    if (_cellHeight == 0) {
        if (_isNewInterface) {
            [self newInterfaceCellHeight];
        }
        else {
            [self customCellHeight];
        }
    }
    return _cellHeight;
}
- (NSString *)standardTime:(NSString *)time begin:(BOOL)begin {
    //return yyyy-mm-dd hh:mm
    NSString *result = [time replaceCharacter:@"|" withString:@" "];
    if (result.length >16) {
        result = [result substringToIndex:16];
    }
    else if (result.length ==10) {
        //这个代表只有日期，没有时间
        result = [NSString stringWithFormat:@"%@ %@",result,begin?@"08:30":@"17:30"];
    }
    else if ( [result rangeOfString:@"-"].location == NSNotFound && [result rangeOfString:@":"].location != NSNotFound) {
        //这个代表只有时间，没有日期
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
        [dateFormatter setTimeZone:timeZone];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        result = [dateFormatter stringFromDate:[NSDate date]];
        result = [NSString stringWithFormat:@"%@ %@",result,[time substringToIndex:5]];
    }
    return result;
}

- (NSDictionary *)paramsDic {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:self.leaveType forKey:@"type"];
    [dic setObject:self.startTime forKey:@"begintime"];
    [dic setObject:self.endTime?self.endTime:@"" forKey:@"endtime"];
    [dic setObject:self.handleType forKey:@"handleType"];
    [dic setObject:self.leaveReason forKey:@"reason"];
    return dic;
}

- (void)sendLeave {
    if (self.canOperate) {
        self.canOperate = NO;
        self.handleType = @"new";
        if (self.sendLeaveBlock) {
            self.sendLeaveBlock(self);
        }
    }
    
}
- (void)cancelLeave {
    if (self.canOperate) {
        self.canOperate = NO;
        if (self.cancelLeaveBlock) {
            self.cancelLeaveBlock(self);
        }
    }
}
- (void)modifyLeave {
    if (self.canOperate) {
        self.canOperate = NO;
        self.handleType = @"modify";
        if (self.modifyLeaveBlock) {
            self.modifyLeaveBlock(self);
        }
    }
}

- (void)disableOperate {
    self.canOperate = NO;
}

- (CGFloat)scellWidth {
    if (INTERFACE_IS_PHONE) {
        return [super scellWidth];
    }
    return 375;
}

@end
