//
//  XZMainCellModel.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/5/16.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#define kMainCellFont FONTSYS(20)

#import "XZCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZMainCellModel : XZCellModel
@property(nonatomic,assign)NSTextAlignment textAlignment;
@property(nonatomic,strong)NSString *content;
@property(nonatomic,strong)UIColor *contentColor;

+ (XZMainCellModel *)robotSpeak:(NSString *)content;
+ (XZMainCellModel *)humenSpeak:(NSString *)content alignment:(NSTextAlignment) textAlignment;

@end

NS_ASSUME_NONNULL_END
