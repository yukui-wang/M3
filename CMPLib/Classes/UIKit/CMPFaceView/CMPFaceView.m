//
//  CMPFaceView.m
//  CMPCore
//
//  Created by wujiansheng on 16/9/6.
//
//



#define kFaceViewSize CGSizeMake(42, 42)
#define kFaceImgViewSize CGSizeMake(40, 40)


#import <QuartzCore/QuartzCore.h>
#import "CMPFaceView.h"
#import "CMPFaceImageManager.h"
#import "stdlib.h"
#import "UIImage+CMPImage.h"
@interface CMPFaceView () {
    UIView *_faceShadowView;
}

@end

@implementation CMPFaceView
@synthesize imageView = faceImgView_;
@synthesize delegate = _delegate;
@synthesize userInfo = _userInfo;
@synthesize backgroundImgViewHidden = _backgroundImgViewHidden;
@synthesize memberIcon = _memberIcon;
@synthesize loadImageLazily = _loadImageLazily;

- (void)dealloc
{
    SY_RELEASE_SAFELY(faceImgView_);
    SY_RELEASE_SAFELY(_userInfo);
    SY_RELEASE_SAFELY(_backgroundImageView);
    SY_RELEASE_SAFELY(_faceShadowView);
    SY_RELEASE_SAFELY(_memberIcon);
    SY_RELEASE_SAFELY(_placeholdImage);
    
    [super dealloc];
}

- (void)setup
{
    self.autoresizesSubviews = NO;
    self.clipsToBounds = NO;
    self.backgroundColor = [UIColor clearColor];
    
    if (!faceImgView_) {
        faceImgView_ = [[CMPFaceImageView alloc] initWithFrame:CGRectMake(0, 0, kFaceImgViewSize.width, kFaceImgViewSize.height)];
        if (self.placeholdImage) {
            faceImgView_.image = self.placeholdImage;
        } else {
            faceImgView_.image = [UIImage imageNamed:@"guesture.bundle/ic_def_person.png"];
        }
        [self addSubview:faceImgView_];
    }
    [self bringSubviewToFront:_backgroundImageView];
}

- (void)setFrame:(CGRect)frame
{
    //    frame.size = kFaceImgViewSize;
    [super setFrame:frame];
    CGSize s = frame.size;
    _backgroundImageView.frame = CGRectMake(-1, -1, s.width + 2, s.height + 2);
    faceImgView_.frame = CGRectMake(0, 0, s.width, s.height);
}

- (void)loadImageWithOnlyCache:(BOOL)aCache
{
    if (!faceImgView_.image) {
        if (self.placeholdImage) {
            faceImgView_.image = self.placeholdImage;
        } else {
            faceImgView_.image = [UIImage imageNamed:@"guesture.bundle/ic_def_person.png"];
        }
    }
    faceImgView_.memberId = self.memberIcon.memberId;
    [[CMPFaceImageManager sharedInstance] fetchfaceImageWithFaceDownloadObj:self.memberIcon container:faceImgView_ complete:nil cache:YES];
}

- (void)loadImage
{
    [self loadImageWithOnlyCache:NO];
}

- (void)setBackgroundImgViewHidden:(BOOL)backgroundImgViewHidden
{
    _backgroundImageView.hidden = backgroundImgViewHidden;
}

- (void)setImage:(UIImage *)aImage
{
    faceImgView_.image = aImage;
}

- (void)fetchImage {
}

- (void)showShadow:(BOOL)aShowShadow
{
    if (!aShowShadow) {
        [_faceShadowView removeFromSuperview];
        SY_RELEASE_SAFELY(_faceShadowView);
    }
    else {
        if (!_faceShadowView) {
            CGRect f = self.bounds;
            _faceShadowView = [[UIView alloc] initWithFrame:f];
            _faceShadowView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
            _faceShadowView.alpha = 1;
            _faceShadowView.layer.masksToBounds = YES;
            _faceShadowView.layer.cornerRadius = kFaceViewSize.width/2;
        }
        [_faceShadowView removeFromSuperview];
        [self addSubview:_faceShadowView];
    }
    [self bringSubviewToFront:_backgroundImageView];
}

#pragma -mark touches Method
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    BOOL isRespondsOne = NO;
    BOOL isRespondsTwo = NO;
    isRespondsOne = [_delegate respondsToSelector:@selector(faceViewTouch:)];
    isRespondsTwo = [_delegate respondsToSelector:@selector(faceViewTouch:touches:withEvent:)];
    if (isRespondsOne) {
        [_delegate faceViewTouch:self];
    }
    if (isRespondsTwo) {
        [_delegate faceViewTouch:self touches:touches withEvent:event];
    }
    if (!isRespondsOne && !isRespondsTwo) {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([_delegate respondsToSelector:@selector(faceViewDraging:touches:withEvent:)]) {
        [_delegate faceViewDraging:self touches:touches withEvent:event];
        return;
    }
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([_delegate respondsToSelector:@selector(faceViewDragEnded:touches:withEvent:)]) {
        [_delegate faceViewDragEnded:self touches:touches withEvent:event];
        return;
    }
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([_delegate respondsToSelector:@selector(faceViewDragEnded:touches:withEvent:)]) {
        [_delegate faceViewDragEnded:self touches:touches withEvent:event];
        return;
    }
    [super touchesCancelled:touches withEvent:event];
}
- (void)setMemberIcon:(SyFaceDownloadObj *)memberIcon customImage:(NSString *)imageName
{
    [_memberIcon release];
    _memberIcon = [memberIcon retain];
    faceImgView_.image = [UIImage imageNamed:imageName];
//    faceImgView_.memberId = memberIcon.iconPath;
    if (!_loadImageLazily) {
        [self loadImage];
    }
    else {
        [self loadImageWithOnlyCache:YES];
    }
}


-(void)addBackgroundImgViewWithImageName:(NSString *)imgName
{
    if (!_backgroundImageView) {
        UIImage *img = [UIImage imageNamed:imgName];
        _backgroundImageView = [[UIImageView alloc] initWithImage:img];
        _backgroundImageView.frame = CGRectMake(0, 0, self.bounds.size.width+8*2, self.bounds.size.height+8*2);
        _backgroundImageView.clipsToBounds = NO;
        _backgroundImageView.center = faceImgView_.center;
        [self addSubview:_backgroundImageView];
        [self sendSubviewToBack:_backgroundImageView];
    }
}
- (void)setMemberIcon:(SyFaceDownloadObj *)memberIcon
{
    [_memberIcon release];
    _memberIcon = [memberIcon retain];

//    faceImgView_.image = [UIImage imageNamed:@"guesture.bundle/ic_def_person.png"];
    faceImgView_.memberId = memberIcon.memberId;
    if (!_loadImageLazily) {
        [self loadImage];
    }
    else {
        [self loadImageWithOnlyCache:YES];
    }
}
@end
