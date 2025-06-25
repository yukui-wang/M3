//
//  CMPShareCellModel.h
//  M3
//
//  Created by MacBook on 2019/10/29.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CMPShareType) {
    CMPShareTypeChat,
    CMPShareTypeFileAssistant,
    CMPShareTypeMyFiles,
    CMPShareTypeNewCoaop,
    CMPShareTypeDocCenter
};


NS_ASSUME_NONNULL_BEGIN

@interface CMPShareCellModel : NSObject
/* index */
@property (assign, nonatomic) CMPShareType shareType;
/* title */
@property (copy, nonatomic) NSString *title;
/* icon */
@property (copy, nonatomic) NSString *icon;
/* appId用于区分是哪个分享按钮点击了 */
@property (copy, nonatomic) NSString *appId;
/* type用于区分是那种类型的分享 */
@property (copy, nonatomic) NSString *key;


@end

NS_ASSUME_NONNULL_END
