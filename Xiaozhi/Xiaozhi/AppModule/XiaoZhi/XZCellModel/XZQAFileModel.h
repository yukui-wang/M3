//
//  XZQAFileModel.h
//  M3
//
//  Created by wujiansheng on 2018/10/19.
//

#import "XZCellModel.h"

@interface XZQAFileModel : XZCellModel
- (id)initWithFileName:(NSString *)name fileJson:(NSString *)json;
@property (nonatomic, copy) void (^clickFileBlock)(XZQAFileModel *model);
@property (nonatomic, copy)NSString *filename;
@property (nonatomic, assign)long long fileSize;
@property (nonatomic, copy)NSString *fileId;
@property (nonatomic, copy)NSString *type;
@property (nonatomic, copy)NSString *lastModified;
@property (nonatomic, retain)NSDictionary *extData;
- (CGFloat) contentBGWidth;

@end
