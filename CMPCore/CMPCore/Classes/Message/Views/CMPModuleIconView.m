//
//  CMPModuleIconView.m
//  CMPCore
//
//  Created by yang on 2017/3/9.
//
//

#import "CMPModuleIconView.h"
#import <CMPLib/UIImageView+WebCache.h>
#import <CMPLib/CMPCore.h>
#import "UIImage+CMPIconFont.h"
#import "CMPIconInfo.h"
#import "CMPIconFont.h"
#import <CMPLib/NSString+CMPString.h>
#import <CMPLib/NSObject+Thread.h>

@interface CMPModuleIconView ()
@property (strong, nonatomic) UIImageView *imageView;
@end

@implementation CMPModuleIconView

- (id)init {
    if(self = [super init]) {
        _imageView = [[UIImageView alloc] init];
        [self addSubview:_imageView];
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (void)setImageWithIconUrl:(NSString *)url
{
    NSString *imageStr = nil;

    if([url hasPrefix:@"image:"]){
        NSArray *iconInfo = [url componentsSeparatedByString:@":"];
        long backColorVal = [iconInfo[2] longLongValue];
        UIColor *color = UIColorFromRGB(backColorVal);
        self.layer.backgroundColor = color.CGColor;

        imageStr = [NSString stringWithFormat:@"%@",iconInfo[1]];
        UIImage *image =  [UIImage imageNamed:imageStr];
        _imageView.image = image;
        _imageView.cmp_height = 22;
        _imageView.cmp_width = 22;
        _imageView.center = CGPointMake(22, 22);
    } else if ([url hasPrefix:@"http"]||[url hasPrefix:@"https"]) {
        self.layer.backgroundColor = nil;
        UIImage *placeHolder = [UIImage imageNamed:@"msg_icon_placeholder"];
        NSURL *imageUrl =[NSURL URLWithString:url];
        [_imageView sd_setImageWithURL:imageUrl placeholderImage:placeHolder options:SDWebImageAllowInvalidSSLCertificates|SDWebImageDownloaderAllowInvalidSSLCertificates];
        _imageView.frame = CGRectMake(0, 0, 44, 44);
    }
}

- (void)setIconSize:(CGSize)iconSize {
    _imageView.cmp_width = iconSize.width;
    _imageView.cmp_height = iconSize.height;
    _imageView.cmp_centerX = self.cmp_width * 0.5;
    _imageView.cmp_centerY = self.cmp_height * 0.5;
}

@end
