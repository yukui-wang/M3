//
//  CMPAreaCodeCell.h
//  M3
//
//  Created by zy on 2022/2/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPAreaCodeCell : UITableViewCell

- (void)setTitle:(NSString *)title desc:(NSString *)desc;

@end

@interface CMPAreaCodeHeader : UITableViewHeaderFooterView

- (void)setTitle:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
