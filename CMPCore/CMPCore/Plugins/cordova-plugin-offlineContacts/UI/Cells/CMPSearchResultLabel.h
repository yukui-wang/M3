//
//  CMPSearchResultLabel.h
//  CMPCore
//
//  Created by wujiansheng on 2017/1/7.
//
//

#import <UIKit/UIKit.h>

@interface CMPSearchResultLabel : UILabel
@property(nonatomic, retain) UIColor *keyColor;
- (void)setText:(NSString *)text key:(NSString *)key;
@end
