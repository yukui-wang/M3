//
//  CMPGuidePagesView.m
//  CMPCore
//
//  Created by wujiansheng on 16/8/19.
//
//

#import "CMPGuidePagesView.h"
#import "CMPPageControl.h"
#import "CMPGuidePagesImageView.h"
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/UIView+RTL.h>
#import <CMPLib/SOLocalization.h>

@interface CMPGuidePagesView ()<UIScrollViewDelegate>
{
    NSMutableArray          *_imageArray;
    NSInteger _index;
    CMPGuidePagesImageView *_imageView;
    UIButton *_skipButton;
}

//@property (nonatomic,strong)UIImageView *backgroundImageView;
@property (nonatomic,strong)UIView *pageControl;
@property (nonatomic,strong)UIView *currentPage;
@property (nonatomic,strong)UIButton *startButton;

@end

@implementation CMPGuidePagesView

- (void)setup {
    self.backgroundColor = CMP_HEXCOLOR(0xFFFFFF);
//    if (!_backgroundImageView) {
//        _backgroundImageView = [[UIImageView alloc] init];
//        NSString *bundle = @"guidePagesImages.bundle/";
//        NSString *image = nil;
//        if (INTERFACE_IS_PHONE) {
//            image = [NSString stringWithFormat:@"%@guide_page_bg",bundle];
//        } else {
//            image = [NSString stringWithFormat:@"%@guide_page_pad_bg",bundle];
//        }
//        _backgroundImageView.image = [UIImage imageNamed:image];
//        [self addSubview:_backgroundImageView];
//    }
    if (!_imageView) {
        _imageView = [[CMPGuidePagesImageView alloc] init];
        _imageView.image = nil;
        [self addSubview:_imageView];
    }
    
    if (!_skipButton) {
        _skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIColor *color = UIColorFromRGB(0x4F6DFA);
        [_skipButton setTitle:SY_STRING(@"GestureLogin_Skip_Confirm") forState:UIControlStateNormal];
        _skipButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        [_skipButton setTitleColor:color forState:UIControlStateNormal];
        [_skipButton setBackgroundColor: UIColorFromRGB(0xF4F5FF)];
        _skipButton.layer.masksToBounds = YES;
        _skipButton.layer.cornerRadius = 11;
        [self addSubview:_skipButton];
        [_skipButton addTarget:self action:@selector(skipButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (!_startButton) {
        NSDictionary *attributesDic = @{NSFontAttributeName :  [UIFont systemFontOfSize:16]};
        CGSize textSize = CGSizeZero;
        CGSize contentMaxSizes = CGSizeMake(MAXFLOAT, MAXFLOAT);
        textSize = [SY_STRING(@"guide_start") boundingRectWithSize:contentMaxSizes options:NSStringDrawingUsesLineFragmentOrigin attributes:attributesDic context:nil].size;
        
        _startButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_startButton setTitle:SY_STRING(@"guide_start") forState:UIControlStateNormal];
        [_startButton setTitleColor:UIColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
        _startButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_startButton setBackgroundColor:CMP_HEXCOLOR(0x3659F9)];
        _startButton.layer.masksToBounds = YES;
        [_startButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_startButton];
        _startButton.hidden = YES;
        _startButton.cmp_width = textSize.width +  40;
        _startButton.cmp_height = 36;
        _startButton.layer.cornerRadius = _startButton.cmp_height * 0.5;
    }
    
    [self addCustomPageControl];
    
    if (!_imageArray) {
        _imageArray = [[NSMutableArray alloc] init];
    }
    _index = 0;
    [self addGestureRecognizer];
}

- (void)addCustomPageControl{
    if (!_pageControl) {
        _pageControl = [[UIView alloc]init];
        _pageControl.backgroundColor = [UIColor clearColor];
        [self addSubview:_pageControl];
        
        NSInteger count = [[self defaultImageNameArray] count];
        _pageControl.cmp_size = CGSizeMake(7*count+12*(count -1), 7);
        
        for (int i = 1; i <= count + 1; i++) {
            UIView *page = [[UIView alloc]init];
            page.backgroundColor = UIColorFromRGB(0xEEF0FF);
            page.layer.masksToBounds = YES;
            page.layer.cornerRadius = 3.5;
            page.cmp_size = CGSizeMake(7, 7);
            page.frame = CGRectMake((7+12)*(i-1), 0, 7, 7);
            if (i == count + 1) {
                page.backgroundColor = [UIColorFromRGB(0x98A7FE) colorWithAlphaComponent:0.6];
                page.frame = CGRectMake(0, 0, 7, 7);
                self.currentPage = page;
            }
            [_pageControl addSubview:page];
        }
    }
}

- (NSArray *)defaultImageNameArray
{
    NSMutableArray *imageArray = [NSMutableArray array];
    NSString *bundle = @"guidePagesImages.bundle/page";
    NSString *serverIdRegion = [[SOLocalization sharedLocalization] getRegionWithServerId:kCMP_ServerID inSupportRegions:[SOLocalization loacalSupportRegions]];
    NSString *region = ([serverIdRegion isEqualToString:SOLocalizationSimplifiedChinese] || [serverIdRegion isEqualToString:SOLocalizationTraditionalChinese]) ? @"ch" : @"en";
    for (NSInteger t =1 ; t<=5; t++) {
        NSString *image = [NSString stringWithFormat:@"%@_%ld_%@.png",bundle,(long)t,region];
        [imageArray addObject:image];
    }
    return imageArray;
}

- (void)fillImageByInfoArray:(NSArray *)aImageInfoArray
{
    NSArray *imageNameList = [NSArray arrayWithArray:aImageInfoArray];
    if (!aImageInfoArray || aImageInfoArray.count ==0) {
        // default image names
        imageNameList = [self defaultImageNameArray];
    }
    [_imageArray removeAllObjects];
    [_imageArray addObjectsFromArray:imageNameList];
    _imageView.image = [UIImage imageNamed:[_imageArray firstObject]];
    
    [self customLayoutSubviews];
}

- (void)buttonAction:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(guidePagesView:buttonTag:)]) {
        [_delegate guidePagesView:self buttonTag:1];
    }
}
- (void)skipButtonAction:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(guidePagesView:buttonTag:)]) {
        [_delegate guidePagesView:self buttonTag:2];
    }
}

- (void)customLayoutSubviews
{
    CGFloat baseWidth = MIN(self.width, self.height);
    _imageView.frame = CGRectMake(0, 0, self.width, self.height);
    
    CGFloat backgroundImageViewWidth;
    if (INTERFACE_IS_PAD) {
        backgroundImageViewWidth = baseWidth * 0.5;
    } else {
        backgroundImageViewWidth = baseWidth;
    }
    CGFloat backgroundImageViewHeight = backgroundImageViewWidth * 1920 /1080;
    CGFloat backgroundImageViewX = (self.width - backgroundImageViewWidth) * 0.5;
    CGFloat backgroundImageViewY = (self.height - backgroundImageViewHeight) * 0.5;
//    _backgroundImageView.frame = CGRectMake(backgroundImageViewX,backgroundImageViewY, backgroundImageViewWidth, backgroundImageViewHeight);
    _imageView.frame = CGRectMake(backgroundImageViewX,backgroundImageViewY, backgroundImageViewWidth, backgroundImageViewHeight);
    
    [_skipButton sizeToFit];
    CGFloat skipButtonWidth = _skipButton.cmp_width + 10;
    CGFloat skipButtonHeight = _skipButton.cmp_height - 5;
    
    CGFloat startButtonWidth = _startButton.cmp_width;
    CGFloat startButtonHeight = _startButton.cmp_height;
    if (IS_IPHONE_X_LATER) {
        [_skipButton setFrame:CGRectMake(self.width-(25+skipButtonWidth), 69, skipButtonWidth, skipButtonHeight)];
        _pageControl.cmp_origin = CGPointMake((self.width-_pageControl.cmp_width)*0.5, self.height-7-110);
        self.startButton.frame = CGRectMake((self.width - startButtonWidth) * 0.5, self.height - startButtonHeight - 90, startButtonWidth, startButtonHeight);
    }else {
        [_skipButton setFrame:CGRectMake(self.width-(25+skipButtonWidth), 25, skipButtonWidth, skipButtonHeight)];
        _pageControl.cmp_origin = CGPointMake((self.width-_pageControl.cmp_width)*0.5, self.height-7-34);
        self.startButton.frame = CGRectMake((self.width - startButtonWidth) * 0.5, self.height - startButtonHeight - 18, startButtonWidth, startButtonHeight);
    }
    [_skipButton resetFrameToFitRTL];
    
}

- (void)addGestureRecognizer
{
    UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureRecognizerAction:)];
    left.direction = UISwipeGestureRecognizerDirectionLeft;
    UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureRecognizerAction:)];
    right.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:left];
    [self addGestureRecognizer:right];
    
}

- (void)swipeGestureRecognizerAction:(UISwipeGestureRecognizer *)gesture {
    if ((gesture.direction == UISwipeGestureRecognizerDirectionRight && _index>0)||(gesture.direction == UISwipeGestureRecognizerDirectionLeft&&_index <_imageArray.count-1)) {
        CMPGuidePagesImageView *becomeShowImageView = [[CMPGuidePagesImageView alloc]init];
        [self insertSubview:becomeShowImageView belowSubview:_skipButton];
        NSString *imageName = nil;
        if (gesture.direction == UISwipeGestureRecognizerDirectionRight) {
            if (_index == [self defaultImageNameArray].count - 1) {
                self.startButton.hidden = YES;
                self.pageControl.hidden = NO;
            }
            if (_index >0) {
                _index --;
                self.gestureRecognizers[0].enabled = NO;
                self.gestureRecognizers[1].enabled = NO;
                imageName = [_imageArray objectAtIndex:_index];
                becomeShowImageView.image =  [UIImage imageNamed:imageName];
                becomeShowImageView.alpha = 0.0;
                becomeShowImageView.frame = _imageView.frame;
                becomeShowImageView.cmp_x = -_imageView.frame.size.width;
                [UIView animateWithDuration:1 animations:^{
                    self->_imageView.alpha = 0.0;
                    self->_imageView.cmp_x = self.width;
                    becomeShowImageView.alpha = 1.0;
                    becomeShowImageView.cmp_x = (self.width - becomeShowImageView.cmp_width) * 0.5;
                } completion:^(BOOL finished) {
                    self->_currentPage.cmp_x = self->_index*(7+12);
                    [self->_imageView removeFromSuperview];
                    [becomeShowImageView removeFromSuperview];
                    self->_imageView = becomeShowImageView;
                    [self insertSubview:self->_imageView belowSubview:self->_skipButton];
                    self.startButton.hidden = self->_index != self->_imageArray.count-1;
                    self->_pageControl.hidden = self->_index == self->_imageArray.count-1;
                    self.gestureRecognizers[0].enabled = YES;
                    self.gestureRecognizers[1].enabled = YES;
                }];
            }
        }else if (gesture.direction == UISwipeGestureRecognizerDirectionLeft) {
            if (_index <_imageArray.count-1) {
                _index ++;
                self.gestureRecognizers[0].enabled = NO;
                self.gestureRecognizers[1].enabled = NO;
                [self.gestureRecognizers makeObjectsPerformSelector:@selector(setEnabled:) withObject:@(NO)];
                imageName = [_imageArray objectAtIndex:_index];
                becomeShowImageView.image =  [UIImage imageNamed:imageName];
                becomeShowImageView.alpha = 0.0;
                becomeShowImageView.frame = _imageView.frame;
                becomeShowImageView.cmp_x = self.width;
                [UIView animateWithDuration:1 animations:^{
                    self->_imageView.alpha = 0.0;
                    self->_imageView.cmp_x = -self->_imageView.cmp_width;
                    becomeShowImageView.alpha = 1.0;
                    becomeShowImageView.cmp_x = (self.width - becomeShowImageView.cmp_width) * 0.5;
                } completion:^(BOOL finished) {
                    self->_currentPage.cmp_x = self->_index*(7+12);
                    [self->_imageView removeFromSuperview];
                    [becomeShowImageView removeFromSuperview];
                    self->_imageView = becomeShowImageView;
                    [self insertSubview:self->_imageView belowSubview:self->_skipButton];
                    self.startButton.hidden = self->_index != self->_imageArray.count-1;
                    self->_pageControl.hidden = self->_index == self->_imageArray.count-1;
                    self.gestureRecognizers[0].enabled = YES;
                    self.gestureRecognizers[1].enabled = YES;
                }];
            }
        }
    }
}

@end
