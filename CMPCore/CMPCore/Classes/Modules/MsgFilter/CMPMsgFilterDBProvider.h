//
//  CMPMsgFilterDBProvider.h
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2022/4/13.
//

#import <CMPLib/CMPObject.h>
@class CMPMsgFilter;

NS_ASSUME_NONNULL_BEGIN

@interface CMPMsgFilterDBProvider : CMPObject

-(BOOL)updateFilters:(NSArray<CMPMsgFilter *> *)filters;
-(NSArray<CMPMsgFilter *>*)allFilters;
-(void)close;

@end

NS_ASSUME_NONNULL_END
