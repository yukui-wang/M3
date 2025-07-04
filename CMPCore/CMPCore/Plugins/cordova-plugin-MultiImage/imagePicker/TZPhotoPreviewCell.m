//
//  TZPhotoPreviewCell.m
//  TZImagePickerController
//
//  Created by 谭真 on 15/12/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import "TZPhotoPreviewCell.h"
#import "TZAssetModel.h"
#import "UIView+Layout.h"
#import "TZImageManager.h"
#import <CMPLib/CMPConstant.h>

@interface TZPhotoPreviewCell ()<UIGestureRecognizerDelegate,UIScrollViewDelegate> {
    CGFloat _aspectRatio;
}

@property (nonatomic, strong) UIView *imageContainerView;

@end

@implementation TZPhotoPreviewCell
- (void)dealloc
{
    _scrollView = nil;
    _imageContainerView = nil;
    _imageView = nil;
    _model = nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        if (_popoverSupported) {
            self.tz_width = 320;
            self.tz_height = 480;
        }
        self.backgroundColor = [UIColor blackColor];
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.frame = CGRectMake(0, 0, self.tz_width, self.tz_height);
        _scrollView.bouncesZoom = YES;
        _scrollView.maximumZoomScale = 2.5;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delaysContentTouches = NO;
        _scrollView.canCancelContentTouches = YES;
        _scrollView.alwaysBounceVertical = NO;
        [self addSubview:_scrollView];
        
        _imageContainerView = [[UIView alloc] init];
        _imageContainerView.clipsToBounds = YES;
        [_scrollView addSubview:_imageContainerView];
        
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
        _imageView.clipsToBounds = YES;
        [_imageContainerView addSubview:_imageView];
        
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [self addGestureRecognizer:tap1];
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        tap2.numberOfTapsRequired = 2;
        [tap1 requireGestureRecognizerToFail:tap2];
        [self addGestureRecognizer:tap2];
    }
    return self;
}

- (void)setModel:(TZAssetModel *)model {
    _model = model;
    [_model requestImageDataSize];
    [_scrollView setZoomScale:1.0 animated:NO];
    [[TZImageManager manager] getPhotoWithAsset:model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        self.imageView.image = photo;
        [self resizeSubviews];
    }];
}

- (void)recoverSubviews {
    [_scrollView setZoomScale:1.0 animated:NO];
    [self resizeSubviews];
}

- (void)resizeSubviews {
    if (_popoverSupported) {
        self.tz_width = 320;
        self.tz_height = 480;
    }
    _imageContainerView.tz_origin = CGPointZero;
    _imageContainerView.tz_width = self.tz_width;
    
    UIImage *image = _imageView.image;
    if (image.size.height / image.size.width > self.tz_height / self.tz_width) {
        _imageContainerView.tz_height = floor(image.size.height / (image.size.width / self.tz_width));
    } else {
        CGFloat height = image.size.height / image.size.width * self.tz_width;
        if (height < 1 || isnan(height)) height = self.tz_height;
        height = floor(height);
        _imageContainerView.tz_height = height;
        _imageContainerView.tz_centerY = self.tz_height / 2;
    }
    if (_imageContainerView.tz_height > self.tz_height && _imageContainerView.tz_height - self.tz_height <= 1) {
        _imageContainerView.tz_height = self.tz_height;
    }
    
    if (_allowCrop) {
        // 头像裁剪模式特殊处理
        CGFloat contentOffsetX = [self contentOffsetXInCropMode];
        CGFloat contentOffsetY = [self contentOffsetYInCropMode];
        CGFloat contentHeight = MAX(_imageContainerView.tz_height, self.tz_height) + contentOffsetY * 2;
        CGFloat contentWidth = self.tz_width;
        if (contentOffsetX != -1) {
            contentWidth = MAX(_imageContainerView.tz_width, self.tz_width) + contentOffsetX * 2;
        }
        if (@available(iOS 11.0,*)) {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        _scrollView.contentSize = CGSizeMake(contentWidth, contentHeight);
        _scrollView.contentOffset = CGPointMake(contentOffsetX == -1 ? 0 : contentOffsetX, contentOffsetY);
        
        if (contentOffsetX > 0) {
            _imageContainerView.tz_centerX = _scrollView.contentSize.width / 2;
        }
        if (contentOffsetY > 0) {
            _imageContainerView.tz_centerY = _scrollView.contentSize.height / 2;
        }
        
    } else {
        _scrollView.contentSize = CGSizeMake(self.tz_width, MAX(_imageContainerView.tz_height, self.tz_height));
        [_scrollView scrollRectToVisible:self.bounds animated:NO];
    }
    
    _scrollView.alwaysBounceVertical = _imageContainerView.tz_height <= self.tz_height ? NO : YES;
    _imageView.frame = _imageContainerView.bounds;
}

- (CGFloat)contentOffsetYInCropMode {
    if (CMP_SCREEN_WIDTH > CMP_SCREEN_HEIGHT) {
        CGFloat cropHeight = self.tz_height - 128;
        CGFloat contentOffsetY = (_imageContainerView.tz_height - cropHeight) / 2;
        CGFloat cropMarginTop = (self.tz_height - cropHeight) / 2;
        if (contentOffsetY > cropMarginTop) {
            contentOffsetY = cropMarginTop;
        }
        
        if (contentOffsetY < 0) {
            contentOffsetY = 0;
        }
        return contentOffsetY;
    }
    
    CGFloat cropHeight = self.tz_width;
    CGFloat contentOffsetY = (_imageContainerView.tz_height - cropHeight) / 2;
    CGFloat cropMarginTop = (self.tz_height - cropHeight) / 2;
    if (contentOffsetY > cropMarginTop) {
        contentOffsetY = cropMarginTop;
    }
    
    if (contentOffsetY < 0) {
        contentOffsetY = 0;
    }
    return contentOffsetY;
}

- (CGFloat)contentOffsetXInCropMode {
    if (CMP_SCREEN_WIDTH > CMP_SCREEN_HEIGHT) {
        CGFloat cropWidth = self.tz_height - 128;
        CGFloat contentOffsetX = (_imageContainerView.tz_width - cropWidth) / 2;
        CGFloat cropMarginLeft = (self.tz_width - cropWidth) / 2;
        if (contentOffsetX > cropMarginLeft) {
            contentOffsetX = cropMarginLeft;
        }
        
        if (contentOffsetX < 0) {
            contentOffsetX = 0;
        }
        return contentOffsetX;
    }
    return -1;
    
}

#pragma mark - UITapGestureRecognizer Event

- (void)doubleTap:(UITapGestureRecognizer *)tap {
    if (_scrollView.zoomScale > 1.0) {
        [_scrollView setZoomScale:1.0 animated:YES];
    } else {
        CGPoint touchPoint = [tap locationInView:self.imageView];
        CGFloat newZoomScale = _scrollView.maximumZoomScale;
        CGFloat xsize = self.frame.size.width / newZoomScale;
        CGFloat ysize = self.frame.size.height / newZoomScale;
        [_scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

- (void)singleTap:(UITapGestureRecognizer *)tap {
    if (self.singleTapGestureBlock) {
        self.singleTapGestureBlock();
    }
}

#pragma mark - UIScrollViewDelegate

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageContainerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (_allowCrop) {
        return;
    }
    
    CGFloat offsetX = (scrollView.tz_width > scrollView.contentSize.width) ? (scrollView.tz_width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.tz_height > scrollView.contentSize.height) ? (scrollView.tz_height - scrollView.contentSize.height) * 0.5 : 0.0;
    self.imageContainerView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    if (!_allowCrop) {
        return;
    }
    
    // 头像裁剪模式特殊处理
    CGFloat contentOffsetY = [self contentOffsetYInCropMode];
    CGFloat contentOffsetX = [self contentOffsetXInCropMode];
    CGFloat contentWidth = _scrollView.contentSize.width;
    CGFloat contentHeight = MAX(_scrollView.contentSize.height, self.tz_height) + contentOffsetY * 2;
    if (contentOffsetX != -1) {
        contentWidth = MAX(_scrollView.contentSize.width, self.tz_width) + contentOffsetX * 2;
    }
    _scrollView.contentSize = CGSizeMake(contentWidth, contentHeight);
//    _scrollView.contentOffset = CGPointMake(0, contentOffsetY);
    
//    if (self.imageContainerView.tz_height < self.tz_height) {
    self.imageContainerView.tz_centerY = _scrollView.contentSize.height / 2;
//    }
}

@end
