//
//  CMPCopDrawerView.h
//  M3
//
//  Created by Shoujian Rao on 2023/12/7.
//

#import <UIKit/UIKit.h>
#import "CMPCopDrawerModel.h"
#define CMPCopDrawerView_TableY 159
#define kNotifyCMPCopDrawerItemChanged @"kNotifyCMPCopDrawerItemChanged"
@interface CMPCopDrawerView : UIView

- (instancetype)initViewWithCollectionData:(NSArray *)cDataArr tableData:(NSArray *)tDataArr withFrame:(CGRect)frame showIndicator:(BOOL)show;
- (void)setTableViewHeight:(CGFloat)height;

@property (nonatomic,copy) void(^CloseDrawerBlock)(void);
@property (nonatomic,copy) void(^ItemDidSelectedBlock)(CMPCopDrawerModel *);

@end
