//
//  CMPGuideManager.h
//  M3
//
//  Created by Shoujian Rao on 2024/3/5.
//

#import <Foundation/Foundation.h>

@interface CMPGuideManager : NSObject

+ (instancetype)sharedInstance;
+ (BOOL)commonGuidePageShown;
@property (nonatomic,assign) BOOL showingCommonGuidePage;//是否正在展示应用中心的引导页

@property (nonatomic,copy) void(^waitTapIknowButtonCompletion)(void);

@end

