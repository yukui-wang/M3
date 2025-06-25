//
//  XZTextField.h
//  M3
//
//  Created by wujiansheng on 2017/11/22.
//

#import <UIKit/UIKit.h>

@protocol XZTextFieldDelegate <NSObject>

- (void)nullDeleteBackward;

@end

@interface XZTextField : UITextField

@property(nonatomic, assign)id<XZTextFieldDelegate> xzDelegate;

@end




