//
//  CMPProgressView.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2024/1/3.
//

#import "CMPZipDownProgressView.h"
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/CMPThemeManager.h>
@implementation CMPZipDownProgressView

-(instancetype)init
{
    if (self = [super init]) {
        _state = -1;
    }
    return self;
}

-(void)setState:(NSInteger)state
{
    if (state != _state) {
        _state = state;
//        self.hidden = NO;
//        self.alpha = 1;
        switch (_state) {
//            case 1:
//                self.progressTintColor = CMP_HEXSTRINGCOLOR(@"");
//                break;
//            case 2:
//                self.progressTintColor = CMP_HEXSTRINGCOLOR(@"#FF0505");
//                break;
                
            default:
                self.progressTintColor = [UIColor cmp_colorWithName:@"theme-fc"];
                break;
        }
    }
}

@end
