//
//  XZFrequentView.h
//  M3
//
//  Created by wujiansheng on 2017/11/3.
//

#import "XZBaseView.h"
#import "XZViewDelegate.h"


@interface XZPreFrequentView : XZBaseView

@property(nonatomic,assign)id<XZViewDelegate> delegate;//老版本用pre
@property(nonatomic,assign)BOOL isMultiSelect;//是否是多选
@property(nonatomic,retain)NSArray *members;//是否是多选

+ (CGFloat)defaultHeight;
- (void)clearSelect;
- (NSArray *) selectMembers;

@end
