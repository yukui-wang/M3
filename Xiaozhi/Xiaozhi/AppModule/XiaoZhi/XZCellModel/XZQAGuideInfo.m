//
//  XZQAGuideInfo.m
//  M3
//
//  Created by wujiansheng on 2018/10/22.
//

#import "XZQAGuideInfo.h"
#import "XZTextModel.h"
#import "XZQAGuideModel.h"
#import "XZQAGuideTips.h"

@implementation XZQAGuideInfo


- (id)initWithResult:(NSDictionary *)result {
    if (self = [super init]) {
        self.intentId = result[@"intentId"];
        self.intentName = result[@"intentName"];
        self.welcoming = result[@"welcoming"];
        self.preset = [result[@"preset"] boolValue];
        NSArray *tipsSet = result[@"tipsSet"];
        if (![tipsSet isKindOfClass:[NSArray class]]) {
            tipsSet = [NSArray array];
        }
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *dic in tipsSet) {
            XZQAGuideTips *tips = [[XZQAGuideTips alloc] initWithResult:dic];
            [array addObject:tips];
        }
        self.tipsSet = array;

    }
    return self;
    
}
- (NSArray *)cellModels:(BOOL)showWelcome {
    NSMutableArray *array = [NSMutableArray array];
    if (![NSString isNull:self.welcoming] && showWelcome) {
        //welcoming 存在且显示全部
        XZTextModel *model = [XZTextModel modelWithMessageType:ChatCellTypeRobotMessage itemTag:0 contentInfo:self.welcoming];
        [array addObject:model];
    }
    XZQAGuideModel *model = [[XZQAGuideModel alloc] initWithQuestions:self.tipsSet];
    [array addObject:model];
    return array;
}



@end
