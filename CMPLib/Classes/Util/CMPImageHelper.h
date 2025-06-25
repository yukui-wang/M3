//
//  CMPImageHelper.h
//  CMPLib
//
//  Created by youlin on 2020/3/30.
//  Copyright © 2020 crmo. All rights reserved.
//

#import <CMPLib/CMPObject.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPImageHelper : CMPObject

- (void)saveToPhotoAlbum:(NSArray *)images start:(void(^)(void))start success:(void(^)(void))success failed:(void(^)(NSError *error))failed complete:(void(^)(void))complete;

@end

NS_ASSUME_NONNULL_END
