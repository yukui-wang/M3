//
//  CMPImpAlertView.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2023/8/23.
//

#import "CMPImpAlertView.h"
#import <WebKit/WKWebView.h>
#import <CMPLib/UIImageView+WebCache.h>
#import "CMPShareManager.h"
#import "CMPHomeAlertManager.h"
#import <CMPLib/CMPBannerWebViewController.h>
#import "CMPImpAlertViewModel.h"
#import "UIView+Layer.h"
#import <CMPLib/NSObject+CMPHUDView.h>
#import <CMPLib/CMPCachedUrlParser.h>
#import <CordovaLib/CDVWKWebView.h>

@interface CMPImpAlertContentItemView : CMPBaseView<WKNavigationDelegate>
{
    UIImageView *_bgImgV;
    UIView *_alphaView;
    CDVWKWebView *_webview;
    
    __block id _itemData;
    __block NSData *_shareData;
    
    CMPImpAlertViewModel *_viewModel;
    
    UIActivityIndicatorView *_acV;
}

@end
@implementation CMPImpAlertContentItemView
-(void)setup
{
    [super setup];
    self.backgroundColor = [UIColor clearColor];
    
    _bgImgV = [[UIImageView alloc] init];
    _bgImgV.backgroundColor = [UIColor whiteColor];
    [_bgImgV setContentMode:UIViewContentModeScaleAspectFill];
    _bgImgV.clipsToBounds = YES;
    _bgImgV.layer.cornerRadius = 14;
//    _bgImgV.layer.masksToBounds = YES;
//    _bgImgV.layer.borderWidth = 2;
//    _bgImgV.layer.borderColor = RGBCOLOR(233, 236, 237).CGColor;
//    [_bgImgV setImage:[UIImage imageNamed:@"ocr_card_check_list_no_data"]];
    [self addSubview:_bgImgV];
    [_bgImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
//    _alphaView = [[UIView alloc] init];
//    _alphaView.backgroundColor = [UIColor grayColor];
////    _alphaView.alpha = 0.7;
//    _alphaView.layer.cornerRadius = 10;
//    _alphaView.layer.masksToBounds = YES;
//    _alphaView.clipsToBounds = YES;
//    [self addSubview:_alphaView];
//    [_alphaView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.center.offset(0);
//            make.top.left.offset(30);
//            make.right.offset(-30);
//            make.bottom.offset(-50);
//        }];
    UIBlurEffect * blur;
    if (@available(iOS 10.0, *)) {
         blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
    } else {
         blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    }
    _alphaView = [[UIVisualEffectView alloc] initWithEffect:blur];
    _alphaView.userInteractionEnabled = NO;
    _alphaView.layer.cornerRadius = 14;
    _alphaView.layer.masksToBounds = YES;
    _alphaView.clipsToBounds = YES;
    _alphaView.backgroundColor = [UIColorFromRGB(0x000000) colorWithAlphaComponent:0.7];
    _alphaView.alpha = 0.90;
    [self addSubview:_alphaView];
//    [_effectView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.offset(0);
//    }];
    
    _webview = [[CDVWKWebView alloc] initWithFrame:CGRectZero];
    _webview.userInteractionEnabled = NO;
    _webview.opaque = NO;
    _webview.backgroundColor = [UIColor clearColor];
    _webview.scrollView.backgroundColor = [UIColor clearColor];
    _webview.scrollView.scrollEnabled = NO;
    _webview.allowsLinkPreview = NO;
    _webview.scrollView.zoomScale = NO;
    _webview.navigationDelegate = self;
    if (@available(iOS 16.4, *)) {
//            _webview.inspectable = YES;
    } else {
        // Fallback on earlier versions
    }
    [self addSubview:_webview];
//    [_webview mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.center.offset(0);
//        make.top.left.offset(5);
//        make.right.bottom.offset(-5);
//    }];
    
    _alphaView.hidden = YES;
    
    _acV = [[UIActivityIndicatorView alloc] init];
    [self addSubview:_acV];
    [_acV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    
    NSString *localHref = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:@"http://cmp/v/page/cmp-greet-preview.html"]];
    if (localHref) localHref = [localHref replaceCharacter:@"file://" withString:@""];
    NSString *urlpath = localHref ? : [[NSBundle mainBundle] pathForResource:@"cmp-greet-preview" ofType:@"html"];
    NSURL *url = [NSURL fileURLWithPath:urlpath];
    [_webview loadFileURL:url allowingReadAccessToURL:url.URLByDeletingLastPathComponent];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGSize s = self.bounds.size;
    CGRect r = _alphaView.frame;
//    if (s.height>=s.width){
        r.size.width = (211*1.00/275) * s.width;
        r.size.height = (190*1.00/354) * s.height;
//    }else{
//        r.size.width = 0.8 * s.width;
//        r.size.height = 0.6 * s.height;
//    }
    _alphaView.frame = CGRectMake(s.width/2-r.size.width/2, s.height/2-r.size.height/2, r.size.width, r.size.height);
//    _alphaView.center = self.center;
//
//    _webview.frame = CGRectMake(5+_alphaView.frame.origin.x, 5+_alphaView.frame.origin.y, r.size.width-10, r.size.height-10);
    _webview.frame = CGRectMake(0, 0, s.width, s.height);
}

-(void)setGreetingId:(NSString *)greetingId  ext:(_Nullable id)ext
{
    if (!greetingId) return;
    if (!_viewModel) {
        _viewModel = [[CMPImpAlertViewModel alloc] init];
    }
    _viewModel.greetingId = greetingId;
    __weak typeof(self) wSelf = self;
    [_viewModel fetchImpMsgDetailByGid:greetingId completion:^(NSDictionary * _Nonnull datas, NSError * _Nonnull err) {
        _itemData = datas;
        if (!err) {
            NSString *s = datas[@"mobileImgUrl"];
            NSString *imageUrl = s && [s isKindOfClass:NSString.class] && s.length ? [NSString stringWithFormat:@"%@/rest/commonImage/showImage?id=%@&type=image&w=627&h=189",[[CMPCore sharedInstance] serverurlForSeeyon],s] : @"";
//            NSString *detailStr = datas[@"mobileDetails"];
//            BOOL mobileMaskSet = [@"1" isEqualToString:[NSString stringWithFormat:@"%@",datas[@"mobileMaskSet"]]];
//            [wSelf setBackgroundImageUrl:[NSURL URLWithString:imageUrl] htmlStr:detailStr mobileMaskSet:mobileMaskSet];
            [wSelf setBackgroundImageUrl:[NSURL URLWithString:imageUrl] showInfo:_itemData];
        }
    }];
}

-(void)setBackgroundImageUrl:(NSURL *)url showInfo:(NSDictionary *)showInfo
{
    if (url && url.absoluteString.length){
        [_bgImgV sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"ocr_card_check_list_no_data"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                    
        }];
    }
    if (showInfo) {
//        NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:showInfo];
//        [d addEntriesFromDictionary:@{@"mobileMaskSize":@"big",@"mobileShowType":@"1"}];
        NSString *p = [showInfo JSONRepresentation];
        NSLog(@"initGreetView:showInfo===%@",p);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_webview evaluateJavaScript:[NSString stringWithFormat:@"initGreetView(%@);",p] completionHandler:^(id _Nullable pa, NSError * _Nullable error) {
                NSLog(@"impalert eval js:%@",error);
            }];
        });
    }
}

-(void)setBackgroundImageUrl:(NSURL *)url htmlStr:(NSString *)htmlStr mobileMaskSet:(BOOL)mobileMaskSet
{
    if (url && url.absoluteString.length){
        [_bgImgV sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"ocr_card_check_list_no_data"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                    
        }];
    }
    if (htmlStr) {
        NSString *s = [NSString stringWithFormat:@"<html>"
                       "<body>"
                       "%@"
                       "</body>"
                       "</html>",htmlStr];
        [_webview loadHTMLString:s baseURL:nil];
    }
//    _alphaView.hidden = !mobileMaskSet;
}

-(id)itemData
{
    return _itemData;
}

-(void)shareData:(void(^)(NSData *shareData,NSString *localPath,NSError *error))result
{
    if (!result) return;
//    NSString *pa = [CMPImpAlertViewModel shareImageLocalPathWithGreetingId:_viewModel.greetingId];
//    if (_shareData) {
//        result(_shareData,pa,nil);
//        return;
//    };
//    if ([[NSFileManager defaultManager] fileExistsAtPath:pa]) {
//        _shareData = [NSData dataWithContentsOfFile:pa];
//        if (_shareData) {
//            result(_shareData,pa,nil);
//            return;
//        };
//    }
    UIImage *img = [self captureView:self frame:self.bounds];
    _shareData = UIImageJPEGRepresentation(img, 1);
    result(_shareData,nil,nil);
    return;
    if (_viewModel) {
//        [_acV startAnimating];
        [self cmp_showProgressHUDWithText:SY_STRING(@"imp_msg_loadimage")];
        [_viewModel fetchImpMsgShareImageByGid:_viewModel.greetingId completion:^(NSData * _Nonnull data,NSString *localPath, NSError * _Nonnull err) {
//            [_acV stopAnimating];
            [self cmp_hideProgressHUD];
            if (data) {
                _shareData = data;
            }
            if (!_shareData) {
                _shareData = [NSData dataWithContentsOfFile:localPath];
            }
            if (_shareData) {
                result(_shareData,localPath,nil);
                return;
            };
            if (!_shareData) {
                result(nil,nil,err);
            }
        }];
    }
}

- (UIImage*)captureView:(UIView *)theView frame:(CGRect)frame{
    UIGraphicsBeginImageContextWithOptions(frame.size, YES, 0);
    [theView drawViewHierarchyInRect:frame afterScreenUpdates:NO];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

//- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
//    // 禁止放大缩小
//    NSString *injectionJSString = @"var script = document.createElement('meta');"
//    "script.name = 'viewport';"
//    "script.content=\"width=device-width, initial-scale=1.0,maximum-scale=1.0, minimum-scale=1.0, user-scalable=no\";"
//    "document.getElementsByTagName('head')[0].appendChild(script);";
//    [webView evaluateJavaScript:injectionJSString completionHandler:nil];
//}

@end

@interface CMPImpAlertView()<UIScrollViewDelegate>
{
    UIView *_shadeView;
    UIView *_contentView;
    UIButton *_closeBtn;
    UIButton *_shareBtn;
    
    UIScrollView *_scrollView;
    UIPageControl *_pageControl;
    
    NSTimer *_timer;
    __block BOOL _sharing;
}
@end

@implementation CMPImpAlertView

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }

}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}
- (void)deviceOrientationDidChange {
    [self layoutSubviews];
}

-(void)setup
{
    [super setup];
    self.backgroundColor = [UIColor clearColor];
        
    _shadeView = [[UIView alloc] init];
    _shadeView.backgroundColor =[[UIColor cmp_colorWithName:@"mask-bgc"] colorWithAlphaComponent:0.5f];
    [self addSubview:_shadeView];
    [_shadeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    _contentView = [[UIView alloc] init];
    _contentView.backgroundColor = [UIColor whiteColor];
    _contentView.layer.cornerRadius = 14;
    [self addSubview:_contentView];
//    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.offset(40);
//        make.right.offset(-40);
//        make.centerX.offset(0);
//        make.centerY.offset(-6);
//        make.height.mas_equalTo(_contentView.mas_width).multipliedBy(386*1.00/295);
//    }];
    
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.layer.cornerRadius = 14;
        _scrollView.layer.masksToBounds = YES;
        _scrollView.clipsToBounds = YES;
        _scrollView.delegate = self;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.pagingEnabled=YES;
        [_scrollView setLayerShadowRadius:14 color:UIColorFromRGB(0x000000) offset:CGSizeMake(0, 1) opacity:0.2];
        [_contentView addSubview:_scrollView];
    }
    
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.pageIndicatorTintColor = UIColorFromRGB(0xC6CEE9);
        _pageControl.currentPageIndicatorTintColor = [CMPThemeManager sharedManager].themeColor;
        _pageControl.backgroundColor = [UIColor clearColor];
        [_contentView addSubview:_pageControl];
    }
    [_pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(20);
        make.centerX.equalTo(_contentView);
        make.bottom.equalTo(_contentView.mas_bottom);
    }];
    
    
    if (!_closeBtn) {
        _closeBtn = [self buttonWithImage:@"imp_close" action:@selector(_closeAction:)];
    }
    [self addSubview:_closeBtn];
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_contentView).offset(60);
        make.top.equalTo(_contentView.mas_bottom).offset(26);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    
    if (!_shareBtn) {
        _shareBtn = [self buttonWithImage:@"imp_transmit" action:@selector(_shareAction:)];
    }
    [self addSubview:_shareBtn];
    [_shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_contentView).offset(-60);
        make.top.equalTo(_contentView.mas_bottom).offset(26);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
}


- (UIButton *)buttonWithImage:(NSString *)imageName action:(SEL)sel {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    UIImage *image = [UIImage imageNamed:imageName];
//    [button setImage:image forState:UIControlStateNormal];
    button.layer.cornerRadius = 20;
    button.layer.masksToBounds = YES;
    button.layer.borderWidth = 1;
    button.layer.borderColor = [UIColorFromRGB(0xFFFFFF) colorWithAlphaComponent:0.5].CGColor;
    button.clipsToBounds = YES;
    button.backgroundColor = [UIColorFromRGB(0x000000) colorWithAlphaComponent:0.14];
    [button addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *img = [[UIImageView alloc] initWithImage:IMAGE(imageName)];
    img.backgroundColor = [UIColor clearColor];
    img.userInteractionEnabled = NO;
    [button addSubview:img];
    [img mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
    
    return button;
}


-(void)_closeAction:(UIButton *)btn
{
    if (self.viewController) {
        [self.viewController dismissViewControllerAnimated:NO completion:^{
                    
        }];
    }else{
        [self removeFromSuperview];
    }
    [[CMPHomeAlertManager sharedInstance] taskDone];
}

-(void)_shareAction:(UIButton *)btn
{
    NSInteger index = _pageControl.currentPage;
    CMPImpAlertContentItemView *itemV = [_scrollView viewWithTag:10+index];
    if (!itemV) return;
    _sharing = YES;
    [itemV shareData:^(NSData *shareData, NSString *localPath, NSError *error) {
        if (shareData) {
            NSArray *arr = [self _shareItems];
            NSDictionary *data = @{@"configs":arr,
                                   @"data":@{@"mediaData":shareData,
                                             @"mediaType":@"image",
                                             @"title":@"M3"}
            };
            [[CMPShareManager sharedManager] ksCommonShare:data ext:nil result:^(NSInteger step, NSDictionary * _Nonnull actInfo, NSError * _Nonnull err, id  _Nullable ext) {
                _sharing = NO;
            }];
        }else{
            _sharing = NO;
        }
    }];
}

-(NSArray *)_shareItems
{
    NSArray *keys = @[@{@"key":CMPShareComponentWechatString},
                     @{@"key":CMPShareComponentWechatTimelineString}];
    NSArray *resultKeys = [CMPShareManager filterShareTypeWithAppId:@"122" keys:keys];
#if APPSTORE
    return resultKeys;
#else
    NSMutableArray *arr = [NSMutableArray arrayWithArray:resultKeys];
    [arr addObject:@{@"key":CMPShareComponentOtherString}];
    return arr;
#endif
}

-(void)setDatas:(NSArray *)datas ext:(_Nullable id)ext completion:(void(^)(void))completion
{
    if (!datas || ![datas isKindOfClass:NSArray.class]) return;
    [_scrollView removeAllSubviews];
    for (int i=0; i<datas.count; i++) {
        NSDictionary *data = datas[i];
        NSString *gidStr = [NSString stringWithFormat:@"%@",data[@"greetingId"]];
        CMPImpAlertContentItemView *itemV = [[CMPImpAlertContentItemView alloc] init];
        itemV.tag = 10+i;
        [_scrollView addSubview:itemV];
        [itemV setGreetingId:gidStr ext:data];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapItem:)];
        [itemV addGestureRecognizer:tap];
    }
    _pageControl.numberOfPages = datas.count;
    [self _updateCurrentPage:0];
    _pageControl.hidden = datas.count <=1;
    
    NSArray *resultKeys = [self _shareItems];
    if (resultKeys.count){
        [_closeBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_contentView).offset(60);
        }];
        _shareBtn.hidden = NO;
    }else{
        [_closeBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_contentView);
        }];
        _shareBtn.hidden = YES;
    }
    
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(_timerAction) userInfo:nil repeats:YES];
    }
    if (!_timer.isValid) {
        [_timer invalidate];
    }
}

-(void)_timerAction
{
    if (_sharing) return;
    NSInteger index = _pageControl.currentPage;
    index = index +1;
    if (index >= _pageControl.numberOfPages) {
        index = 0;
    }
    [_scrollView setContentOffset:CGPointMake(_scrollView.bounds.size.width*index, 0) animated:YES];
    [self _updateCurrentPage:index];
}

-(void)_tapItem:(UITapGestureRecognizer *)tap
{
    CMPImpAlertContentItemView *itemV = tap.view;
    if (itemV) {
        id itemData = [itemV itemData];
        if (!itemData) {
            NSLog(@"itemData nil");
            return;
        }
        NSString *url = itemData[@"mobileSkipUrl"];
        if (url && [url isKindOfClass:NSString.class] && url.length > 0) {
            CMPBannerWebViewController *aCMPBannerViewController = [[CMPBannerWebViewController alloc] init];
            aCMPBannerViewController.hideBannerNavBar = NO;
            aCMPBannerViewController.startPage = url;
            if (self.viewController) {
                [self.viewController.navigationController pushViewController:aCMPBannerViewController animated:YES];
            }
        } else {
            NSLog(@"mobileSkipUrl null: %@",url);
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger width = _scrollView.width;
    NSInteger currentX = scrollView.contentOffset.x;
    NSInteger index = currentX/width;
    [self _updateCurrentPage:index];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    if (_contentView && _scrollView && _scrollView.subviews){
        NSInteger cou = _scrollView.subviews.count;
        
        CGSize s = self.bounds.size;
        CGRect r = _contentView.frame;
//        if (s.height>=s.width){
            r.size.width = (295*1.00/375) * s.width;
//            r.size.height = (386*1.00/812) * s.height;
//        }else{
//            r.size.width = 0.8 * s.width;
//            r.size.height = 0.6 * s.height;
//        }
        CGFloat scale = 1;//[UIScreen mainScreen].scale;
        if (r.size.width > 400.00 * scale) {
            r.size.width = 400.00 *scale;
        }
        r.size.height = 1.28 * r.size.width;
        _contentView.frame = r;
        _contentView.center = self.center;

        [_scrollView setFrame:CGRectMake(10, 10, r.size.width-20, r.size.height-20-(cou>1?10:0))];
        CGRect r2 = _scrollView.bounds;
        [_scrollView setContentSize:CGSizeMake(r2.size.width * cou, r2.size.height)];
        for (int i=0; i<cou; i++) {
            UIView *itemV = [_scrollView viewWithTag:10+i];
            if (itemV) {
                [itemV setFrame:CGRectMake(r2.size.width*i, 0, r2.size.width, r2.size.height)];
            }
        }
        [_scrollView setContentOffset:CGPointMake(r2.size.width*_pageControl.currentPage, 0) animated:YES];
    }
}

-(void)_updateCurrentPage:(NSInteger)index
{
    _pageControl.currentPage = index;
//    for (int i=0; i<_pageControl.numberOfPages; i++) {
//        UIView *itemV = [_scrollView viewWithTag:10+i];
//        [UIView animateWithDuration:0.3 animations:^{
//            if (itemV && i == index){
//                itemV.hidden = NO;
//            }else{
//                itemV.hidden = YES;
//            }
//        }];
//    }
}

@end
