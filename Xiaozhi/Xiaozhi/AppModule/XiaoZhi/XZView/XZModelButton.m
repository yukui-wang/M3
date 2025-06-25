//
//  XZModelButton.m
//  M3
//
//  Created by wujiansheng on 2017/11/3.
//

#import "XZModelButton.h"

@interface XZModelButton (){
    NSInteger _memberWidth;
    NSInteger _textWWidth;
}
@end

@implementation XZModelButton

- (CGFloat)memberWidth {
    if (_memberWidth == 0) {
        UILabel *label = self.titleLabel;
        CGSize s = [label.text sizeWithFontSize:label.font defaultSize:CGSizeMake(CGFLOAT_MAX, 30)];
        _memberWidth = s.width+24;
    }
    return _memberWidth;
}

- (CGFloat)textWWidth {
    if (_textWWidth == 0) {
        UILabel *label = self.titleLabel;
        CGSize s = [label.text sizeWithFontSize:label.font defaultSize:CGSizeMake(CGFLOAT_MAX, 30)];
        _textWWidth = s.width+6;
    }
    return _textWWidth;
}
@end
