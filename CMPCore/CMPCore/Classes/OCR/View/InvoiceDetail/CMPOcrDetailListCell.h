//
//  CMPOcrDetailListCell.h
//  CMPOcr
//
//  Created by 张艳 on 2021/11/24.
//

#import <UIKit/UIKit.h>

@interface CMPOcrDetailListCell : UITableViewCell

@property (nonatomic, strong) NSDictionary *param;
- (void)setParam:(NSDictionary *)param canEdit:(BOOL)canEdit;
@property (nonatomic, copy) void(^DidEditBlock)(NSDictionary *);
- (void)hideLine;
- (void)updateOffsetYConstraint:(CGFloat)offsetY;
@end
