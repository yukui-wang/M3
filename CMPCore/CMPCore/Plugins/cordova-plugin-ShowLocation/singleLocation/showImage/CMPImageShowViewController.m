//
//  SyImageShowViewController.m
//  M1Core
//
//  Created by Aries on 14-3-10.
//
//
#define kLBSImageSpacing 5 //图片间距

#import "CMPImageShowViewController.h"
#import "CMPImageView.h"
@interface CMPImageShowViewController ()<UIScrollViewDelegate>
{
      CGFloat offset;
}
@end

@implementation CMPImageShowViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)dealloc
{
	
	SY_RELEASE_SAFELY(_attachmentList);
	SY_RELEASE_SAFELY(_image);

    [super dealloc];
}

- (void)aTapAction:(UITapGestureRecognizer *)aTap
{
    self.bannerNavigationBar.hidden = !self.bannerNavigationBar.hidden;

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.bannerNavigationBar.leftViewsMargin = 0.0f;
    self.bannerNavigationBar.rightViewsMargin = 0.0f;
    self.bannerNavigationBar.leftMargin = 0.0f;
    self.bannerNavigationBar.rightMargin = 0.0f;
    self.backBarButtonItemHidden = NO;
    // Do any additional setup after loading the view.
   
    _imageShowView = (CMPImageShowView *)self.mainView;
    _imageShowView.userInteractionEnabled = YES;
    UITapGestureRecognizer *aTap = [[UITapGestureRecognizer alloc] init];
    aTap.numberOfTapsRequired = 1;
    aTap.numberOfTouchesRequired = 1;
    [_imageShowView addGestureRecognizer:aTap];
    [aTap release];
    [aTap addTarget:self action:@selector(aTapAction:)];
    self.bannerNavigationBar.hidden = YES;
    _imageShowView.scrollView.delegate = self;
    [_imageShowView.pageControl addTarget:self
                     action:@selector(pageControlChanged:)forControlEvents:UIControlEventValueChanged];
    CGRect f = _imageShowView.scrollView.frame;
    CGFloat w = f.size.width;
    CGFloat h = f.size.height;
    if(_attachmentList){
        
        _imageShowView.pageControl.numberOfPages = _attachmentList.count;
        
        for(int i = 0; i < _attachmentList.count; i++){
            
            CMPImageView *imageView = [[CMPImageView alloc] init];
            imageView.attachment = [_attachmentList objectAtIndex:i];
            imageView.frame = CGRectMake(0, 0, w, h);
            
            UIScrollView *s = [[UIScrollView alloc] initWithFrame:CGRectMake(w*i, 0, w, h)];
            s.backgroundColor = [UIColor clearColor];
            s.contentSize = CGSizeMake(w, h);
            s.delegate = self;
            s.minimumZoomScale = 1.0;
            s.maximumZoomScale = 3.0;
            s.showsHorizontalScrollIndicator = NO;
            s.showsVerticalScrollIndicator = NO;
            [s setZoomScale:1.0];
            s.frame = CGRectMake(i*w+i*kLBSImageSpacing, 0, w, h);

            [s addSubview:imageView];
            
            [_imageShowView.scrollView addSubview:s];
            _imageShowView.scrollView.contentSize = CGSizeMake((i+1)*w+i*kLBSImageSpacing, h);
            SY_RELEASE_SAFELY(imageView);
            SY_RELEASE_SAFELY(s);
        }
    }
    if(_image){
        UIImageView *aImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _imageShowView.scrollView.frame.size.width, _imageShowView.scrollView.frame.size.height)];
        aImageView.image = _image;
        aImageView.frame = CGRectMake(0, 0, w, h);
        
        UIScrollView *s = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
        s.backgroundColor = [UIColor clearColor];
        s.contentSize = CGSizeMake(w, h);
        s.delegate = self;
        s.minimumZoomScale = 1.0;
        s.maximumZoomScale = 3.0;
        s.showsHorizontalScrollIndicator = NO;
        s.showsVerticalScrollIndicator = NO;
        s.frame = CGRectMake(0, 0, w, h);
        [s setZoomScale:1.0];
        
        [s addSubview:aImageView];
        
        [_imageShowView.scrollView addSubview:s];
        _imageShowView.scrollView.contentSize = CGSizeMake(w, h);
        SY_RELEASE_SAFELY(aImageView);
        SY_RELEASE_SAFELY(s);
    }
    if(_pageIndex < 0){
        _pageIndex = 0;
    }
      [_imageShowView.scrollView scrollRectToVisible:CGRectMake(_pageIndex*(_imageShowView.scrollView.frame.size.width+kLBSImageSpacing), 0, _imageShowView.scrollView.frame.size.width,_imageShowView.scrollView.frame.size.height) animated:YES];
    _imageShowView.pageControl.currentPage = _pageIndex;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self aTapAction:nil];
}
- (void)dismissViewController:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)pageControlChanged:(UIPageControl *)sender
{
     [_imageShowView.scrollView scrollRectToVisible:CGRectMake(sender.currentPage*(_imageShowView.scrollView.frame.size.width+kLBSImageSpacing), 0, _imageShowView.scrollView.frame.size.width,_imageShowView.scrollView.frame.size.height) animated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    NSInteger currentPage = floor(_imageShowView.scrollView.contentOffset.x/(_imageShowView.scrollView.frame.size.width+kLBSImageSpacing))+1;
    CGFloat t = _imageShowView.scrollView.contentOffset.x/(_imageShowView.scrollView.frame.size.width+kLBSImageSpacing);
    NSInteger currentPage = floor(t);

    if (t- currentPage >0.5) {
        currentPage +=1;
    }
    _imageShowView.pageControl.currentPage = currentPage;
    [self pageControlChanged:_imageShowView.pageControl];
//    _scrollView.contentOffset = CGPointMake(_pageControl.currentPage, 0);
    
    if (scrollView == _imageShowView.scrollView){
        CGFloat x = scrollView.contentOffset.x;
        if (x==offset){
            
        }
        else {
            offset = x;
            for (UIScrollView *s in scrollView.subviews){
                if ([s isKindOfClass:[UIScrollView class]]){
                    [s setZoomScale:1.0];
                }
            }
        }
    }


}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (scrollView != _imageShowView.scrollView) {
//        return [self currentImageView];
        for (UIView *v in scrollView.subviews){
            return v;
        }
    }
    return nil;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so you need to re-center the contents
}

@end
