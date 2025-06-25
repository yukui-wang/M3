//
//  CMPSoundPlayer.h
//  M1Core
//
//  Created by wujiansheng on 14/12/31.
//
//

#import <Foundation/Foundation.h>
#import <CMPLib/SyAttachment.h>

@protocol CMPSoundPlayerDelegate;

@interface CMPSoundPlayer : NSObject

+ (CMPSoundPlayer *)sharedPlayer;
- (void)playWithPath:(NSString *)aPath delegate:(id<CMPSoundPlayerDelegate>) delegate;
- (void)playWithSyAttachment:(SyAttachment *)att delegate:(id<CMPSoundPlayerDelegate>) delegate;
- (void)stop;
- (void)removeDelegate:(id<CMPSoundPlayerDelegate>)delegate;
+ (NSInteger)durationForSoundPath:(NSString *)aPath;//录音时长
@end

@protocol CMPSoundPlayerDelegate <NSObject>

@optional
- (void)soundPlayerDidStart:(CMPSoundPlayer *)soundPlayer; // 开始
- (void)soundPlayerDidPause:(CMPSoundPlayer *)soundPlayer; // 暂停
- (void)soundPlayer:(CMPSoundPlayer *)soundPlayer didFinishPlayWithPath:(NSString *)aPath; // 完成
@end
