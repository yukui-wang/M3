//
//  CMPMessageFilterManager.h
//  M3
//
//  Created by Kaku Songu on 4/12/22.
//

#import <CMPLib/CMPObject.h>
#import "CMPMsgFilterResult.h"

NS_ASSUME_NONNULL_BEGIN

@interface CMPMessageFilterManager : CMPObject

+(CMPMsgFilterResult *)filterStr:(NSString *)str;
+(void)updateFilter;
+(void)freeFilter;

@end

NS_ASSUME_NONNULL_END
