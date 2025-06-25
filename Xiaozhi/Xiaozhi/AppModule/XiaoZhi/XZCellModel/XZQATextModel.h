//
//  XZQAModel.h
//  M3
//
//  Created by wujiansheng on 2018/10/19.
//

#import "XZCellModel.h"
#import "XZTextTapModel.h"
#import "XZTextInfoModel.h"

@interface XZQATextModel : XZCellModel
@property(nonatomic, retain)NSAttributedString *attrString;
@property(nonatomic, assign)CGSize contentSize;
@property(nonatomic, retain)NSArray *clickItems;
@property (nonatomic, copy) void (^clickLinkBlock)(NSString *linkUrl);
@property (nonatomic, copy) void (^clickAppBlock)(NSString *text);


- (id)initWithString:(NSString *)string;
- (NSString *)speakString;
+ (void)modelsWithQAResult:(NSString *)resultStr block:(void (^)(NSArray* models,NSString *speakStr))block;

@end
