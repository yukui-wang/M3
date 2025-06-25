//
//  RCChatSessionInputBarControl+CMP.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2022/5/11.
//

#import "RCChatSessionInputBarControl+CMP.h"
#import <CMPLib/SOSwizzle.h>
#import "CMPMessageFilterManager.h"
#import <CMPLib/NSObject+CMPHUDView.h>

@implementation RCChatSessionInputBarControl (CMP)

+ (void)load {
    SOSwizzleInstanceMethod(self, @selector(textView:shouldChangeTextInRange:replacementText:),@selector(cmp_textView:shouldChangeTextInRange:replacementText:));
    SOSwizzleInstanceMethod(self, @selector(layoutBottomBarWithStatus:),@selector(cmp_layoutBottomBarWithStatus:));
}

- (BOOL)cmp_textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        NSString *content = textView.text;
        content = [content stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        CMPMsgFilterResult *filterRslt = [CMPMessageFilterManager filterStr:content];
        if (filterRslt.filter.level == CMPMsgFilterLevelIntercept) {
            [self cmp_showHUDWithText:SY_STRING(@"msg_content_sensitive_notsend")];
            return NO;
        }
    }
    return [self cmp_textView:textView shouldChangeTextInRange:range replacementText:text];
}

- (void)cmp_layoutBottomBarWithStatus:(KBottomBarStatus)bottomBarStatus
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationName_rcBottomBarStatusWillChange" object:@(bottomBarStatus)];
    [self cmp_layoutBottomBarWithStatus:bottomBarStatus];
}

@end
