//
//  CMPZipDownProgressViewPad.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2024/1/10.
//

#import "CMPZipDownProgressViewPad.h"
#import <CMPLib/UIImage+GIF.h>

@interface CMPZipDownProgressViewPad()
{
    UIImageView *_imgView;
    UIImage *_downloadingImage;
}
@end

@implementation CMPZipDownProgressViewPad

-(instancetype)init{
    if(self = [super init]){
        _imgView = [[UIImageView alloc] init];
        [self addSubview:_imgView];
        _state = -1;
    }
    return self;
}

-(void)setState:(NSInteger)state
{
    if (state != _state) {
        _state = state;
//        self.hidden = NO;
//        self.alpha = 1;
        switch (_state) {
            case 1:
                if ([_imgView isAnimating]) {
                    [_imgView stopAnimating];
                }
                _imgView.image = IMAGE(@"download_success");
                break;
            case 2:
                if ([_imgView isAnimating]) {
                    [_imgView stopAnimating];
                }
                _imgView.image = IMAGE(@"download_fail");
                break;
                
            default:
                _imgView.animationImages = [self _downloadingImage].images;
                _imgView.animationDuration = [self _downloadingImage].duration;
                if (![_imgView isAnimating]) {
                    [_imgView startAnimating];
                }
                break;
        }
    }
}

-(UIImage *)_downloadingImage{
    if (_downloadingImage) return _downloadingImage;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"downloading" ofType:@"gif"];
    if (!path) return nil;
    NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:path]];
    if (!data) return nil;
    _downloadingImage = [UIImage sd_animatedGIFWithData:data];
    return _downloadingImage;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    _imgView.frame = self.bounds;
}

@end
