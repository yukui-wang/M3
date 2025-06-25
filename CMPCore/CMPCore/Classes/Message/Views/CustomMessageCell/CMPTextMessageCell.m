//
//  CMPTextMessageCell.m
//  M3
//
//  Created by Kaku Songu on 5/6/21.
//

#import "CMPTextMessageCell.h"
#import <CMPLib/CMPConstant.h>
#import <CMPLib/CMPCore.h>
#import <CMPLib/CMPThemeManager.h>

@implementation CMPTextMessageCell

- (void)setDataModel:(RCMessageModel *)model {
    self.textLabel.attributedText = nil;
    [super setDataModel:model];
    
    RCMentionedInfo *mentionInfo = model.content.mentionedInfo;
    if (mentionInfo != nil) {
        NSString *mentionStr = @"";
        switch (mentionInfo.type) {
            case RC_Mentioned_All:{
                mentionStr = [@"@" stringByAppendingString:SY_STRING(@"msg_at_all")];
            }
                break;
            case RC_Mentioned_Users:{
                if (mentionInfo.isMentionedMe) {
                    NSString *myName = [CMPCore sharedInstance].userName;
                    mentionStr = [@"@" stringByAppendingString:myName];
                }
            }
                break;
            default:
                break;
        }
        if (mentionStr.length >0 ) {
            NSString *text = ((RCTextMessage *)model.content).content;
            //ks fix V5-9272 iOS M3群消息多次@群成员，只有一个@群成员有蓝色背景
            NSArray *arr = [self calculateSubStringCount:text str:mentionStr];
            if (arr.count) {
                NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:text];
                for (NSNumber *index in arr) {
                    [str addAttributes:@{NSBackgroundColorAttributeName:[CMPThemeManager sharedManager].themeColor ? : RGBCOLOR(51, 112, 255),NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(index.integerValue, mentionStr.length)];
                }
                self.textLabel.attributedText = str;
            }
        }
    }
}



/**
 查找子字符串在父字符串中的所有位置
 @param content 父字符串
 @param tab 子字符串
 @return 返回位置数组
 */
- (NSMutableArray*)calculateSubStringCount:(NSString *)content str:(NSString *)tab {
    NSMutableArray *locationArr = [NSMutableArray new];
    NSRange range = [content rangeOfString:tab];
    if (range.location == NSNotFound){
        return locationArr;
    }
    NSInteger preTempStrIndex = 0;
    NSString * subStr = content;
    while ([subStr rangeOfString:tab].length) {
        NSRange range = [subStr rangeOfString:tab];
        preTempStrIndex = content.length-subStr.length+range.location;
        [locationArr addObject:@(preTempStrIndex)];
        
        subStr = [subStr substringFromIndex:range.location+range.length];
    }
    return locationArr;
}

@end
