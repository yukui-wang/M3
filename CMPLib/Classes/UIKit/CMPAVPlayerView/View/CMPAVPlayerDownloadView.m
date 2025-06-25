//
//  CMPAVPlayerDownloadView.m
//  CMPLib
//
//  Created by MacBook on 2020/2/17.
//  Copyright © 2020 crmo. All rights reserved.
//

#import "CMPAVPlayerDownloadView.h"
#import "CMPAVPlayerProgressView.h"

#import <CMPLib/UIView+CMPView.h>
#import <CMPLib/CMPThemeManager.h>
#import <CMPLib/SDWebImageDownloader.h>


@interface CMPAVPlayerDownloadView()

/* imgView */
@property (strong, nonatomic) UIImageView *imgView;
/* progressView */
@property (strong, nonatomic) CMPAVPlayerProgressView *progressView;

@end

@implementation CMPAVPlayerDownloadView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.backgroundColor = [UIColor blackColor];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.bounds];
    imgView.layer.masksToBounds = YES;
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    imgView.image = [UIImage imageNamed:@"avplayer_video_default_cover"];
    
    [self addSubview:imgView];
    _imgView = imgView;
    
    CMPAVPlayerProgressView *progressView = [[CMPAVPlayerProgressView alloc] initWithFrame:CGRectMake(0, self.height - 20.f - 68.f, self.width, 68.f)];
    progressView.backgroundColor = UIColor.clearColor;
    [self addSubview:progressView];
    _progressView = progressView;
    
    __weak typeof(self) weakSelf = self;
    progressView.closeClicked = ^{
        if (weakSelf.closeBtnClicked) {
            weakSelf.closeBtnClicked();
        }
    };
    
    
}

-(void)setDownloadType:(CMPAVPlayerDownloadType)downloadType {
    _downloadType = downloadType;
    if (self.downloadType == CMPAVPlayerDownloadTypeVideo) {
        self.imgView.image = [UIImage imageNamed:@"avplayer_video_default_cover"];
    } else {
        self.imgView.image = [UIImage imageNamed:@"audio_cover"];
    }
}

- (void)setProgress:(CGFloat)progress {
    [self.progressView setProgress:progress];
}

- (void)setRecievedSize:(long long)recievedSize {
    self.progressView.recievedSize = recievedSize;
}

- (void)setFileSize:(long long)fileSize {
    self.progressView.fileSize = fileSize;
}

- (void)setCoverImage:(NSString *)coverImageUrl {
    if ([NSString isNull:coverImageUrl]) return;
    
    __weak __typeof(self) weakSelf = self;
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:coverImageUrl] options:SDWebImageDownloaderHandleCookies|SDWebImageDownloaderAllowInvalidSSLCertificates progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        if (finished && !error) {
            [weakSelf.imgView setImage:image];
        }
    }];
}

@end
