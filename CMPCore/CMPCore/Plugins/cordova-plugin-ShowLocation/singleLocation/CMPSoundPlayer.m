//
//  CMPSoundPlayer.m
//  M1Core
//
//  Created by wujiansheng on 14/12/31.
//
//

#import "CMPSoundPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <CMPLib/amrFileCodec.h>
#import <CMPLib/CMPConstant.h>
#import <CMPLib/MAttachment.h>
//#import "SyBaseBiz.h"
//#import "SyFileDownloadBizParam.h"
//#import "SyBizManager.h"
//#import "SyFileDownloadBiz.h"
#import <CMPLib/CMPFileTypeHandler.h>
static CMPSoundPlayer *sharedObj;
@interface CMPSoundPlayer ()<AVAudioPlayerDelegate/*,SyBizDelegate*/>
{
    NSTimeInterval            _currentTimeInterval;
    id<CMPSoundPlayerDelegate> _delegate;
//    SyBaseBiz *_fileDownloadBiz;
}
@property(nonatomic,copy)NSString *playPath;
@property(nonatomic,copy)AVAudioPlayer *player;
@end

@implementation CMPSoundPlayer
@synthesize playPath = _playPath;
@synthesize player = _player;
+(CMPSoundPlayer *)sharedPlayer
{
    @synchronized (self)
    {
        if (sharedObj == nil)
        {
            sharedObj =  [[self alloc] init];
            
        }
    }
    return sharedObj;
}

- (id)init
{
    self = [super init];
    if(self){
        _currentTimeInterval = 0;
    }
    return self;
}

+ (id) allocWithZone:(NSZone *)zone
{
    @synchronized (self) {
        if (sharedObj == nil) {
            sharedObj = [super allocWithZone:zone];
            return sharedObj;
        }
    }
    return nil;
}

- (id) copyWithZone:(NSZone *)zone
{
    return self;
}

- (id) retain
{
    return self;
}

- (unsigned) retainCount
{
    return UINT_MAX;
}

- (oneway void) release
{
    
}

- (id) autorelease
{
    return self;
}

- (BOOL)isPlaying
{
    return _player && _player.isPlaying;
}
- (BOOL)isPause
{
    return _player && !_player.isPlaying;
}

- (void)playWithPath:(NSString *)aPath delegate:(id<CMPSoundPlayerDelegate>)delegate
{
    _delegate = delegate;
    if ([self isPlaying] && [aPath isEqualToString:self.playPath]) {
        _currentTimeInterval = _player.currentTime;
        [_player pause];
        [self performPausePlaySelector];
        return;
    }
    else if([self isPause] && [aPath isEqualToString:self.playPath]){
        [_player setCurrentTime:0];
        _currentTimeInterval = 0;
        [self performBeginPlaySelector];
        [_player play];
        return;
    }
    else{
        self.playPath = aPath;
        [self play];
    }
}

- (void)playWithSyAttachment:(SyAttachment *)att delegate:(id<CMPSoundPlayerDelegate>)delegate
{
    _delegate = delegate;
    if (att.localFile) {
        [self playWithPath:att.filePath delegate:delegate];
    }
    else {
//        [self requestDownloadAtta:att type:kDownloadFileType_Att];
    }
}

- (void)stop
{
    [_player stop];
}

- (void)removeDelegate:(id<CMPSoundPlayerDelegate>)delegate
{
    if ([_delegate isEqual:delegate]) {
        _delegate = nil;
        self.playPath = nil;
        SY_RELEASE_SAFELY(_player);
    }
}

//-----------------------下载语音附件start------------------------//

// 附件下载
- (void)requestDownloadAtta:(SyAttachment *)aAttachment type:(NSInteger)iType
{
//    MAttachment *att = (MAttachment *)aAttachment.value;
//    [_fileDownloadBiz cancel];
//    [_fileDownloadBiz release];
//    SyFileDownloadBizParam *aParam = [[SyFileDownloadBizParam alloc] init];
//    aParam.delegate = self;
//    aParam.title = aAttachment.fullName;
//    aParam.createDate = aAttachment.value.createDate;
//    aParam.modifyTime = aAttachment.value.modifyTime;
//    aParam.size = aAttachment.value.size;
//    aParam.attID = [NSString stringWithFormat:@"%lld",att.attID];
//    aParam.type = iType;
//    aParam.vCode = aAttachment.value.verifyCode;
//    _fileDownloadBiz = [SyBizManager instanceSyFileDownloadBiz:aParam];
//    [_fileDownloadBiz request];
//    [aParam release];
//    // show infor
//    if (att.size > 1024*1024*10) {
//        [[SyGlobleManager sharedSyGlobleManager] pushMarqueeView:SY_STRING(@"common_downloadBidDoc_needToolongTime_instability")];
//    }
}

//- (void)bizDidStartLoad:(SyBaseBiz *)aBiz
//{
//}
//
//- (void)bizDidFinishLoad:(SyBaseBiz *)aBiz
//{
//    if (_fileDownloadBiz == aBiz) {
//        SyFileDownloadBiz *biz = (SyFileDownloadBiz *)aBiz;
//        NSString *aPath = biz.downloadDestinationPath;
//        NSString *extUpperStr = [[aPath pathExtension] uppercaseString];
//        NSInteger fileType = [CMPFileTypeHandler fileType:extUpperStr];
//        if ( fileType == kFileType_Audio ) {
//            [self playWithPath:aPath delegate:_delegate];
//        }
//    }
//}
//
//- (void)biz:(SyBaseBiz *)aBiz didFailLoadWithError:(NSError *)error
//{
//    
//}
//-----------------------下载语音附件 end ------------------------//

- (void)play
{
    if (_player) {
        [_player release];
        _player = nil;
    }
    NSData* amrData = [NSData dataWithContentsOfFile:self.playPath];
    if ([_playPath hasSuffix:@".amr"] || [_playPath hasSuffix:@".AMR"]) {
        NSData *wavData = DecodeAMRToWAVE(amrData);
        _player = [[AVAudioPlayer alloc] initWithData:wavData error:nil];
    }
    else{
        _player = [[AVAudioPlayer alloc] initWithData:amrData error:nil];
    }
    [self performBeginPlaySelector];
    [_player setDelegate:self];
    [_player setVolume:1.0];
    [_player setCurrentTime:_currentTimeInterval];
    [_player play];

    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
}

- (void)performBeginPlaySelector
{
    if (_delegate &&[_delegate respondsToSelector:@selector(soundPlayerDidStart:)]) {
        [_delegate soundPlayerDidStart:self];
    }
}

- (void)performPausePlaySelector
{
    if (_delegate &&[_delegate respondsToSelector:@selector(soundPlayerDidPause:)]) {
        [_delegate soundPlayerDidPause:self];
    }
}

- (void)performFinishPlaySelector
{
    if (_delegate &&[_delegate respondsToSelector:@selector(soundPlayer:didFinishPlayWithPath:)]) {
        [_delegate soundPlayer:self didFinishPlayWithPath:self.playPath];
    }
}

#pragma AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    _currentTimeInterval = 0;
    [self performFinishPlaySelector];
}

+ (NSInteger)durationForSoundPath:(NSString *)aPath
{
    NSData* amrData = [NSData dataWithContentsOfFile:aPath];
    AVAudioPlayer *player = nil;
    if ([aPath hasSuffix:@".amr"] || [aPath hasSuffix:@".AMR"]) {
        NSData *wavData = DecodeAMRToWAVE(amrData);
        player = [[AVAudioPlayer alloc] initWithData:wavData error:nil];
    }
    else{
        player = [[AVAudioPlayer alloc] initWithData:amrData error:nil];
    }
    int audioDurationSeconds = player.duration;
    SY_RELEASE_SAFELY(player);
    return audioDurationSeconds;
}


@end
