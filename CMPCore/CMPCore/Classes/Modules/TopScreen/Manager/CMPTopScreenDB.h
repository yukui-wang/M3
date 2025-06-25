//
//  CMPTopScreenDB.h
//  M3
//
//  Created by Shoujian Rao on 2023/12/28.
//

#import <CMPLib/CMPObject.h>
#import "CMPTopScreenModel.h"

@interface CMPTopScreenDB : CMPObject

- (BOOL)addAppClick:(CMPTopScreenModel *)model;
- (NSArray<CMPTopScreenModel *> *)getTopAppClickCount:(NSInteger)topCount;
- (BOOL)delAllTopApp;

@end

