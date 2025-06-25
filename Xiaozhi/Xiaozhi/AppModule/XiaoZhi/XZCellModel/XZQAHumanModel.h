//
//  XZQAHumanModel.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/12/10.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZCellModel.h"

typedef void(^EditContentBlock)(NSString * _Nullable text);
typedef void(^ClickSpaceBlock)(void);
#define kXZQAHumanBubbleMaxWidth 273

NS_ASSUME_NONNULL_BEGIN

@interface XZQAHumanModel : XZCellModel
@property(nonatomic, strong)NSString *content;
@property(nonatomic, assign)CGSize bubbleSize;
@property(nonatomic, copy)EditContentBlock editContentBlock;
@property(nonatomic, copy)ClickSpaceBlock clickSpaceBlock;
@property(nonatomic, assign)BOOL showAnimation;

@end

NS_ASSUME_NONNULL_END
