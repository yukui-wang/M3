//
//  CMPShareImageView.m
//  M3
//
//  Created by MacBook on 2019/10/29.
//

#import "CMPShareImageView.h"
#import "CMPShareCellModel.h"

#import <CMPLib/UIView+CMPView.h>
#import <AVFoundation/AVFoundation.h>
#import <CMPLib/CMPThemeManager.h>


@interface CMPShareImageView()

/* imageView */
@property (strong, nonatomic) UIImageView *imageView;
/* playImge */
@property (strong, nonatomic) UIImageView *playImge;
/* countLabel */
@property (strong, nonatomic) UILabel *countLabel;
/* imagePath */
@property (copy, nonatomic) NSString *imagePath;

@end

@implementation CMPShareImageView

#pragma mark view点击，用于后续点击查看文件

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_viewClicked) {
        _viewClicked();
    }
}

#pragma mark 初始化工厂方法，用于一步初始化新对象
+ (instancetype)imageViewWithFrame:(CGRect)frame image:(NSString *)imagePath shareFileCount:(NSInteger)shareFileCount {
    CMPShareImageView *instance = [[CMPShareImageView alloc] initWithFrame:frame];
    instance.imageView.image = [UIImage imageWithContentsOfFile:imagePath];
    instance.imagePath = imagePath.copy;
    if (shareFileCount > 1) {
        instance.countLabel.text = [NSString stringWithFormat:SY_STRING(@"share_component_file_share_count_tips"),shareFileCount];
    }else {
        instance.imageView.cmp_height = instance.height;
        instance.countLabel.cmp_height = 0;
        instance.countLabel.hidden = YES;
    }
    return instance;
}


/// 初始化方法
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor cmp_colorWithName:@"white-bg"];
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(14.f, 0, self.width - 28.f, self.height - 20.f)];
        _imageView.backgroundColor = UIColor.clearColor;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.layer.masksToBounds = YES;
        [self addSubview:_imageView];
        
        _playImge = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24.f, 24.f)];
        _playImge.image = [UIImage imageNamed:@"share_icon_play"];
        _playImge.cmp_centerX = _imageView.width/2.f;
        _playImge.cmp_centerY = _imageView.height/2.f;
        [_imageView addSubview:_playImge];
        _playImge.hidden = YES;
        
        _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_imageView.frame), self.width, 20.f)];
        _countLabel.backgroundColor = UIColor.clearColor;
        _countLabel.textAlignment = NSTextAlignmentCenter;
        _countLabel.textColor = [UIColor cmp_colorWithName:@"sup-fc1"];
        _countLabel.font = [UIFont systemFontOfSize:14.f];
        [self addSubview:_countLabel];
    }
    return self;
}

#pragma mark 外部方法

- (void)setIsVideo:(BOOL)isVideo {
    _isVideo = isVideo;
    
    _playImge.hidden = !isVideo;
    if (isVideo) {
        NSString *path = [NSString stringWithFormat:@"file://%@",self.imagePath];
        path = [path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        _imageView.image = [self thumbnailImageForVideo:[NSURL URLWithString:path]];
        
    }
}

#pragma mark - 内部方法
///获取视频封面，本地视频，网络视频都可以用

- (UIImage*)thumbnailImageForVideo:(NSURL *)videoURL {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];

    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(2.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *thumbImg = [[UIImage alloc] initWithCGImage:image];
    return thumbImg;

}



@end
