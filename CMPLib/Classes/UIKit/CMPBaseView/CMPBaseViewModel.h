//
//  CMPBaseViewModel.h
//  CMPLib
//
//  Created by Kaku Songu on 11/23/21.
//  Copyright © 2021 crmo. All rights reserved.
//

#import <CMPLib/CMPObject.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^CommonCompletionBlk)(id respData,NSError *error,id ext);

@interface CMPBaseViewModel : CMPObject

@end

NS_ASSUME_NONNULL_END
