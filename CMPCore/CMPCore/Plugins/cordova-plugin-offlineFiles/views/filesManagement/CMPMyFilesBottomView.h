//
//  CMPMyFilesBottomView.h
//  M3
//
//  Created by MacBook on 2019/10/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface CMPMyFilesBottomView : UIView

+ (instancetype)bottomViewWithFrame:(CGRect)frame;
- (void)setNumOfSelectedFielsWithNum:(NSInteger)num;

/* myFilesBottomViewCancelClicked */
@property (copy, nonatomic) void(^myFilesBottomViewCancelClicked)(void);
/* myFilesBottomViewSendClicked */
@property (copy, nonatomic) void(^myFilesBottomViewSendClicked)(void);


@end

NS_ASSUME_NONNULL_END
