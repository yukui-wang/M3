//
//  CMPPageBaseModel.h
//  M3
//
//  Created by Kaku Songu on 12/14/21.
//

#import <CMPLib/CMPObject.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPPageBaseModel : CMPObject

@property (nonatomic,assign) NSUInteger pageSize;
@property (nonatomic,assign) NSUInteger pageNo;

@end

NS_ASSUME_NONNULL_END
