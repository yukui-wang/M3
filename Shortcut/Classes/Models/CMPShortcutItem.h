//
//  CMPQuickModuleItem.h
//  CMPCore
//
//  Created by wujiansheng on 2017/7/5.
//
//

#import <CMPLib/CMPBaseView.h>

@interface CMPShortcutItemModel : NSObject
@property(nonatomic, copy) NSString *appName;
@property(nonatomic, copy) UIImage *icon;
@property(nonatomic, copy) UIColor *color;
@property(nonatomic, copy) NSString *appId;
/* tag */
@property (assign, nonatomic) NSInteger tag;
@end

@interface CMPShortcutItem : CMPBaseView

@property(nonatomic, strong) CMPShortcutItemModel *info;

+ (CGFloat)defaultWidth;
+ (CGFloat)defaultHeight;

@end
