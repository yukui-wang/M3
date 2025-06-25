//
//  CMPOcrPickPackageCell.h
//  M3
//
//  Created by Shoujian Rao on 2021/12/7.
//

#import <UIKit/UIKit.h>


@interface CMPOcrPickPackageCell : UITableViewCell
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UILabel *lastLabel;
- (void)selectRow:(BOOL)selected;
- (void)updateLastLabelConstraint:(BOOL)hide;
@end

