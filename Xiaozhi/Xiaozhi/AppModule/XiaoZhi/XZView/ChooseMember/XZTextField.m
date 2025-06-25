//
//  XZTextField.m
//  M3
//
//  Created by wujiansheng on 2017/11/22.
//

#import "XZTextField.h"

@implementation XZTextField

- (void)deleteBackward{
    if (self.text.length == 0) {
        if (_xzDelegate && [_xzDelegate respondsToSelector:@selector(nullDeleteBackward)]) {
            [_xzDelegate nullDeleteBackward];
        }
    }
    [super deleteBackward];
   
}
@end
