//
//  CustomCircleSearchBar.h
//  M3
//
//  Created by Shoujian Rao on 2021/12/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomCircleSearchBar : UISearchBar
@property (nonatomic, copy) NSString *lastSearchText;//用于记录上一次搜索过的值
@property (nonatomic, weak) UITextField *textfield;
- (instancetype)initWithPlaceholder:(NSString *)placeholder size:(CGSize)size;
@end

NS_ASSUME_NONNULL_END
