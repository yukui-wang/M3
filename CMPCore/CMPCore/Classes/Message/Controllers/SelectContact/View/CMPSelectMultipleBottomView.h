//
//  CMPSelectMultipleBottomView.h
//  M3
//
//  Created by Shoujian Rao on 2023/8/31.
//

#import <CMPLib/CMPBaseView.h>

@interface CMPSelectMultipleBottomView : CMPBaseView
+(CGFloat)defaultHeight;
- (void)refreshData;

@property (nonatomic,copy) void(^confirmBtnBlcok)(void);
@property (nonatomic,copy) void(^cancelBtnBlcok)(void);

@end

