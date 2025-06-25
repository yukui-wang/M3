//
//  CMPOcrItemDBManager.h
//  CMPCore
//
//  Created by Shoujian Rao on 2021/12/9.
//

#import <CMPLib/CMPObject.h>
#import "CMPOcrItemModel.h"

@interface CMPOcrItemDBManager : CMPObject

- (BOOL)addItem:(CMPOcrItemModel *)item;
- (void)updateItem:(CMPOcrItemModel *)item;
- (void)updateItemTaskStatus:(CMPOcrItemModel *)item;
- (void)deleteItem:(CMPOcrItemModel *)item;
- (NSArray<CMPOcrItemModel *> *)getAllItemWithServerId:(NSString *)serverId andUserId:(NSString *)userId andPackageId:(NSString *)packageId;
@end

