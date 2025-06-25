//
//  XZFrequentView.h
//  M3
//
//  Created by wujiansheng on 2017/11/3.
//

#import "XZBaseView.h"
#import "XZViewDelegate.h"

@protocol XZFrequentViewDelegate ;

@interface XZFrequentView : XZBaseView

@property(nonatomic,assign)id<XZFrequentViewDelegate> delegate;//新版本用
@property(nonatomic,assign)BOOL isMultiSelect;//是否是多选
@property(nonatomic,retain)NSArray *members;//是否是多选
+ (CGFloat)defaultHeight;
- (void)clearSelect;
- (NSArray *) selectMembers;

@end

@protocol XZFrequentViewDelegate <NSObject>

- (void)frequentView:(XZFrequentView *)view didFinishSelectMember:(NSArray *)members;
- (void)frequentView:(XZFrequentView *)view showSelectMemberView:(BOOL)isMultiSelect;

@end
