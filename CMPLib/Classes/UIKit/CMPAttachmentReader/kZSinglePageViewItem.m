//
//  kZPageViewItem.m
//  测试ShowPhoto
//
//  Created by lin on 14-9-29.
//  Copyright (c) 2014年 lin. All rights reserved.
//

#import "kZSinglePageViewItem.h"

@interface kZSinglePageViewItem()
{
    NSInteger _index;
}
@end

@implementation kZSinglePageViewItem

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
        [self layOutSubviewsForPhone];
    }
    return self;
}

-(void)setupView{
    _imageView = nil;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.delegate = self;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.backgroundColor = [UIColor blackColor];
    UITapGestureRecognizer *vDoubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTaped:)];
    vDoubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:vDoubleTap];
    [vDoubleTap release];

}

-(void)dealloc{
    [_pageIndexLabel release];
    [_imageView release];
    [super dealloc];
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self layOutSubviewsForPhone];
    [self setImageViewFrame];
}

-(void)layOutSubviewsForPhone{
    self.pageIndexLabel.frame = CGRectMake(172.5, 323, 30, 21);
}

-(void)setImageViewFrame{
    _imageView.frame = CGRectMake(0, 0, _imageView.image.size.width, _imageView.image.size.height);
    [self setmaxiMinZoomScale];
    //不设置这个的化，放大到一定程度，就会滑动出现问题。
    self.contentSize = _imageView.frame.size;
}

-(void)setmaxiMinZoomScale{
    self.maximumZoomScale = 1.0;
    self.minimumZoomScale = 0.25;

    if (_imageView.frame.size.width > 0) {

        CGSize imageSize = _imageView.image.size;
        CGFloat xZoomScale = self.bounds.size.width / imageSize.width;
        CGFloat yZoomScale = self.bounds.size.height / imageSize.height;
        CGFloat minScale = MIN(yZoomScale, xZoomScale);
        minScale = MIN(1, minScale);
        //        self.maximumZoomScale =1.0 + (1.0- minScale);
        //        self.minimumZoomScale = 1.0;
        self.maximumZoomScale = 3.0;
        self.minimumZoomScale = 1.0;

        NSLog(@"miniScale:%f",minScale);
        
        CGFloat xWidth = imageSize.width * minScale;
        CGFloat yHight = imageSize.height * minScale;
        CGRect  imageScaledFrame = _imageView.frame;
        imageScaledFrame.size = CGSizeMake(xWidth, yHight);
        _imageView.transform = CGAffineTransformIdentity;
        _imageView.frame = imageScaledFrame;
        
        [self centerTheImageView];
    
    }
}

-(void)centerTheImageView{
    CGRect centerRect;
    CGRect imageViewRect = _imageView.frame;
    if (imageViewRect.size.width < self.bounds.size.width) {
        centerRect.origin.x = (self.bounds.size.width - imageViewRect.size.width)/2.0;
    }else{
        centerRect.origin.x = 0.0;
    }
    
    if (imageViewRect.size.height < self.bounds.size.height) {
        centerRect.origin.y = (self.bounds.size.height - imageViewRect.size.height)/2.0;
    }else{
        centerRect.origin.y = 0.0;
    }
    centerRect.size = imageViewRect.size;

    _imageView.frame = centerRect;
}

//先调用这个方法初始化控件，再设置self.frame设置位置
-(void)disPlayWithImage:(UIImage *)aImage{
    
    if (_imageView) {
        [_imageView removeFromSuperview];
        [_imageView release];
        _imageView = nil;
    }
    
    UIImageView *vImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, aImage.size.width, aImage.size.height)];
    vImageView.image = aImage;
    [self addSubview:vImageView];
    self.imageView = vImageView;
    [vImageView release];
    
    if (_pageIndexLabel) {
        [_pageIndexLabel removeFromSuperview];
        [_pageIndexLabel release];
        _pageIndexLabel = nil;
    }
    UILabel *indexLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 21)];
    [self addSubview:indexLable];
    self.pageIndexLabel = indexLable;
    [indexLable release];
    
    [self setImageViewFrame];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    [self centerTheImageView];
}

-(void)doubleTaped:(UITapGestureRecognizer *)aTap{
    if (self.zoomScale != self.maximumZoomScale) {
        [self setZoomScale:self.maximumZoomScale animated:YES];
    }else{
         [self setZoomScale:self.minimumZoomScale animated:YES];
    }
}


@end
