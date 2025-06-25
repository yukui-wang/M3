//
//  CMPHorizontalMenuView.m
//  YFMHorizontalMenu
//
//  Created by CMP on 2018/11/26.
//  Copyright © 2018年 iOS. All rights reserved.
//

#import "CMPHorizontalMenuView.h"

#import <Masonry.h>
#import <UIImageView+WebCache.h>
#import "CMPHorizontalMenuCollectionLayout.h"
#import "NSString+CMPString.h"

#define kHorizontalMenuViewInitialPageControlDotSize CGSizeMake(6, 6)

@implementation CMPHorizontalMenuItem

- (instancetype)initWithItemTile:(NSString *)itemTile itemIconTitle:(NSString *)itemIconTitle target:(id)target action:(SEL)action {
    self = [super init];
    if (self) {
        self.itemTile = itemTile;
        self.itemIconTitle = itemIconTitle;
        self.target = target;
        self.action = action;
    }
    return self;
}

@end

@interface CMPHorizontalMenuViewCell:UICollectionViewCell

@property (nonatomic,strong) UILabel *menuTile;
@property (nonatomic,strong) UIImageView *menuIcon;

@end

@implementation CMPHorizontalMenuViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.menuTile = [UILabel new];
        self.menuTile.textAlignment = 1;
        self.menuTile.font = [UIFont systemFontOfSize:14];
        self.menuTile.textColor = [UIColor blackColor];
        [self.contentView addSubview:self.menuTile];
        
        self.menuIcon = [UIImageView new];
        [self.contentView addSubview:self.menuIcon];
        
        [self.menuIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(12);
            make.centerX.mas_equalTo(self.contentView);
        }];
        
        [self.menuTile mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.contentView);
            make.top.mas_equalTo(self.menuIcon.mas_bottom).offset(6);
            make.height.mas_equalTo(17);
        }];
        
    }
    return self;
}

@end

static NSString *CMPHorizontalMenuViewCellID = @"CMPHorizontalMenuViewCell";
@interface CMPHorizontalMenuView ()<UICollectionViewDelegate,UICollectionViewDataSource,CMPlipsePageControlDelegate,CMPHorizontalMenuViewDelegate,CMPHorizontalMenuViewDataSource>

@property (nonatomic,strong) UICollectionView *collectionView;

@property (strong,nonatomic) UIControl         *pageControl;
@property (strong,nonatomic) CMPHorizontalMenuCollectionLayout         *layout;

@end

@implementation CMPHorizontalMenuView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _pageControlDotSize = kHorizontalMenuViewInitialPageControlDotSize;
        _pageControlAliment = CMPHorizontalMenuViewPageControlAlimentCenter;
        _pageControlBottomOffset = 0;
        _pageControlRightOffset = 0;
        _controlSpacing = 10;
        _pageControlStyle = CMPHorizontalMenuViewPageControlStyleAnimated;
        _currentPageDotColor = [UIColor whiteColor];
        _pageDotColor = [UIColor lightGrayColor];
        _hidesForSinglePage = YES;
        self.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1];
        _delegate = self;
        _dataSource = self;
    }
    return self;
}

-(void)setUpPageControl
{
    if (_pageControl) {
        [_pageControl removeFromSuperview];//重新加载数据时调整
    }
    if (([self.layout currentPageCount] == 1) && self.hidesForSinglePage) {//一页并且单页隐藏pageControl
        return;
    }
    switch (self.pageControlStyle) {
        case CMPHorizontalMenuViewPageControlStyleAnimated:
        {
            CMPlipsePageControl *pageControl = [[CMPlipsePageControl alloc]init];
            pageControl.numberOfPages = [self.layout currentPageCount];
            pageControl.currentPage = 0;
            pageControl.controlSize = self.pageControlDotSize.width;
            pageControl.controlSpacing = self.controlSpacing;
            pageControl.currentColor = self.currentPageDotColor;
            pageControl.otherColor = self.pageDotColor;
            pageControl.delegate = self;
            [self addSubview:pageControl];
            _pageControl = pageControl;
        }
            break;
        case CMPHorizontalMenuViewPageControlStyleClassic:
        {
            UIPageControl *pageControl = [[UIPageControl alloc]init];
            pageControl.numberOfPages = [self.layout currentPageCount];
            pageControl.currentPageIndicatorTintColor = self.currentPageDotColor;
            pageControl.pageIndicatorTintColor = self.pageDotColor;
            pageControl.userInteractionEnabled = NO;
            pageControl.currentPage = 0;
            [self addSubview:pageControl];
            _pageControl = pageControl;
        }
            break;
        default:
            break;
    }
    
    
    //重设pageControlDot图片
    if (self.currentPageDotImage) {
        self.currentPageDotImage = self.currentPageDotImage;
    }
    if (self.pageDotImage) {
        self.pageDotImage = self.pageDotImage;
    }
    
    NSInteger count = self.numOfPage;
    CGFloat pageWidth = (count - 1)*self.pageControlDotSize.width + self.pageControlDotSize.width * 2 + (count - 1) *self.controlSpacing;
    CGSize size = CGSizeMake(pageWidth, self.pageControlDotSize.height);
    CGFloat x = (self.frame.size.width - size.width) * 0.5;
    CGFloat y = self.frame.size.height - size.height;
    if (self.pageControlAliment == CMPHorizontalMenuViewPageControlAlimentRight) {
        x = self.frame.size.width - size.width - 15;
        y = 0;
    }
    if ([self.pageControl isKindOfClass:[CMPlipsePageControl class]]) {
        CMPlipsePageControl *pageControl = (CMPlipsePageControl *)_pageControl;
        [pageControl sizeToFit];
    }
    CGRect pageControlFrame = CGRectMake(x, y, size.width, size.height);
    pageControlFrame.origin.y -= self.pageControlBottomOffset;
    pageControlFrame.origin.x -= self.pageControlRightOffset;
    //self.pageControl.frame = pageControlFrame;
    [self addSubview:_pageControl];
    
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(size);
        make.centerX.mas_equalTo(self).offset(-self.pageControlRightOffset);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-self.pageControlBottomOffset);
    }];
}

-(UICollectionView *)collectionView{
    
    if (_collectionView == nil) {
        self.layout = [CMPHorizontalMenuCollectionLayout new];
    
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
        _collectionView.pagingEnabled = YES;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
        //        _collectionView.scrollEnabled
        [_collectionView registerClass:[CMPHorizontalMenuViewCell class] forCellWithReuseIdentifier:CMPHorizontalMenuViewCellID];
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [self addSubview:_collectionView];
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
    }
    return _collectionView;
}

/**
 刷新
 */
-(void)reloadData{
    //设置行数
    [self.collectionView reloadData];
    
    [self setUpPageControl];
    
}


#pragma mark - properties

- (void)setDelegate:(id<CMPHorizontalMenuViewDelegate>)delegate
{
    _delegate = delegate;
    
    if ([self.delegate respondsToSelector:@selector(customCollectionViewCellClassForHorizontalMenuView:)] && [self.delegate customCollectionViewCellClassForHorizontalMenuView:self]) {
        [self.collectionView registerClass:[self.delegate customCollectionViewCellClassForHorizontalMenuView:self] forCellWithReuseIdentifier:CMPHorizontalMenuViewCellID];
    }else if ([self.delegate respondsToSelector:@selector(customCollectionViewCellNibForHorizontalMenuView:)] && [self.delegate customCollectionViewCellNibForHorizontalMenuView:self]) {
        [self.collectionView registerNib:[self.delegate customCollectionViewCellNibForHorizontalMenuView:self] forCellWithReuseIdentifier:CMPHorizontalMenuViewCellID];
    }
}
#pragma mark - UIScrollViewDelegate -
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self.pageControl isKindOfClass:[CMPlipsePageControl class]]) {
    } else {
        UIPageControl *pageControl = (UIPageControl *)_pageControl;
        pageControl.currentPage = scrollView.contentOffset.x / scrollView.frame.size.width;
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    NSInteger currentPage = targetContentOffset->x / self.frame.size.width;
    if ([self.pageControl isKindOfClass:[CMPlipsePageControl class]]) {
        CMPlipsePageControl *pageControl = (CMPlipsePageControl *)_pageControl;
        pageControl.currentPage = currentPage;
    }
    if ([self.delegate respondsToSelector:@selector(horizontalMenuView:WillEndDraggingWithVelocity:targetContentOffset:)]) {
        [self.delegate horizontalMenuView:self WillEndDraggingWithVelocity:velocity targetContentOffset:targetContentOffset];
    }
}
#pragma mark - UICollectionViewDataSource -
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger count = 0;
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfItemsInHorizontalMenuView:)]) {
        count = [self.dataSource numberOfItemsInHorizontalMenuView:self];
    }
    return count;
}

- (CMPHorizontalMenuViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CMPHorizontalMenuViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CMPHorizontalMenuViewCellID forIndexPath:indexPath];
    if ([self.delegate respondsToSelector:@selector(setupCustomCell:forIndex:horizontalMenuView:)] &&
        [self.delegate respondsToSelector:@selector(customCollectionViewCellClassForHorizontalMenuView:)] && [self.delegate customCollectionViewCellClassForHorizontalMenuView:self]) {
        [self.delegate setupCustomCell:cell forIndex:indexPath.item horizontalMenuView:self];
        return cell;
    }else if ([self.delegate respondsToSelector:@selector(setupCustomCell:forIndex:horizontalMenuView:)] &&
              [self.delegate respondsToSelector:@selector(customCollectionViewCellNibForHorizontalMenuView:)] && [self.delegate customCollectionViewCellNibForHorizontalMenuView:self]) {
        [self.delegate setupCustomCell:cell forIndex:indexPath.item horizontalMenuView:self];
        return cell;
    }
    NSString *title = @"";
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(horizontalMenuView:titleForItemAtIndex:)]) {
        title = [self.dataSource horizontalMenuView:self titleForItemAtIndex:indexPath.row];
    }
    cell.menuTile.text = title;
    
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(horizontalMenuView:iconURLForItemAtIndex:)]) {
        NSURL *url = [self.dataSource horizontalMenuView:self iconURLForItemAtIndex:indexPath.row];
        if(self.defaultImage) {
            [cell.menuIcon sd_setImageWithURL:url placeholderImage:self.defaultImage];
        } else {
            [cell.menuIcon sd_setImageWithURL:url];
        }
    }else if (self.dataSource && [self.dataSource respondsToSelector:@selector(horizontalMenuView:localIconStringForItemAtIndex:)]){
        NSString *imageName = [self.dataSource horizontalMenuView:self localIconStringForItemAtIndex:indexPath.row];
        cell.menuIcon.image = [UIImage imageNamed:imageName];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(iconSizeForHorizontalMenuView:)]) {
        CGSize imageSize = [self.delegate iconSizeForHorizontalMenuView:self];
        [cell.menuIcon mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(imageSize);
        }];
    }
    
    return cell;
}


#pragma mark - UICollectionViewDelegate -
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(self.delegate && [self.delegate respondsToSelector:@selector(horizontalMenuView:didSelectItemAtIndex:)]) {
        [self.delegate horizontalMenuView:self didSelectItemAtIndex:indexPath.row];
    }
}

- (void)setPageControlDotSize:(CGSize)pageControlDotSize
{
    _pageControlDotSize = pageControlDotSize;
    [self setUpPageControl];
}
- (void)setCurrentPageDotColor:(UIColor *)currentPageDotColor
{
    _currentPageDotColor = currentPageDotColor;
    if ([self.pageControl isKindOfClass:[CMPlipsePageControl class]]) {
        CMPlipsePageControl *pageControl = (CMPlipsePageControl *)_pageControl;
        pageControl.currentColor = currentPageDotColor;
    } else {
        UIPageControl *pageControl = (UIPageControl *)_pageControl;
        pageControl.currentPageIndicatorTintColor = currentPageDotColor;
    }
    
}

- (void)setPageDotColor:(UIColor *)pageDotColor
{
    _pageDotColor = pageDotColor;
    if ([self.pageControl isKindOfClass:[UIPageControl class]]) {
        UIPageControl *pageControl = (UIPageControl *)_pageControl;
        pageControl.pageIndicatorTintColor = pageDotColor;
    }else{
        CMPlipsePageControl *pageControl = (CMPlipsePageControl *)_pageControl;
        pageControl.otherColor = pageDotColor;
    }
}

- (void)setCurrentPageDotImage:(UIImage *)currentPageDotImage
{
    _currentPageDotImage = currentPageDotImage;
    
    if (self.pageControlStyle != CMPHorizontalMenuViewPageControlStyleAnimated) {
        self.pageControlStyle = CMPHorizontalMenuViewPageControlStyleAnimated;
    }
    
    [self setCustomPageControlDotImage:currentPageDotImage isCurrentPageDot:YES];
}

- (void)setPageDotImage:(UIImage *)pageDotImage
{
    _pageDotImage = pageDotImage;
    
    if (self.pageControlStyle != CMPHorizontalMenuViewPageControlStyleAnimated) {
        self.pageControlStyle = CMPHorizontalMenuViewPageControlStyleAnimated;
    }
    
    [self setCustomPageControlDotImage:pageDotImage isCurrentPageDot:NO];
}

- (void)setCustomPageControlDotImage:(UIImage *)image isCurrentPageDot:(BOOL)isCurrentPageDot
{
    if (!image || !self.pageControl) return;
    
    if ([self.pageControl isKindOfClass:[CMPlipsePageControl class]]) {
        CMPlipsePageControl *pageControl = (CMPlipsePageControl *)_pageControl;
        pageControl.currentBkImg = image;
    }
}

-(NSInteger)numOfPage
{
    return [self.layout currentPageCount];
}

#pragma  mark CMPlipsePageControlDelegate。监听用户点击 (如果需要点击切换,如果将CMPlipsePageControl 中的userInteractionEnabled切换成YES或者注掉)
-(void)ellipsePageControlClick:(CMPlipsePageControl *)pageControl index:(NSInteger)clickIndex{
    CGPoint position = CGPointMake(self.frame.size.width * clickIndex, 0);
    [self.collectionView setContentOffset:position animated:YES];
}

#pragma mark === CMPHorizontalMenuViewDataSource

/**
 提供数据的数量
 
 @param horizontalMenuView 控件本身
 @return 返回数量
 */
-(NSInteger)numberOfItemsInHorizontalMenuView:(CMPHorizontalMenuView *)horizontalMenuView{
    return self.menuItems.count;
}

#pragma mark === CMPHorizontalMenuViewDelegate
/**
 设置每页的行数 默认 2
 
 @param horizontalMenuView 当前控件
 @return 行数
 */
-(NSInteger)numOfRowsPerPageInHorizontalMenuView:(CMPHorizontalMenuView *)horizontalMenuView{
    return 1;
}

/**
 设置每页的列数 默认 4
 
 @param horizontalMenuView 当前控件
 @return 列数
 */
-(NSInteger)numOfColumnsPerPageInHorizontalMenuView:(CMPHorizontalMenuView *)horizontalMenuView{
    return 5;
}

/**
 当选项被点击回调
 
 @param horizontalMenuView 当前控件
 @param index 点击下标
 */
-(void)horizontalMenuView:(CMPHorizontalMenuView *)horizontalMenuView didSelectItemAtIndex:(NSInteger)index{
    id target = self.menuItems[index].target;
    SEL action = self.menuItems[index].action;
//    if ([target respondsToSelector:action]) {
//         [target performSelector:action];
//    }
    
    IMP imp = [target methodForSelector:action];
    void (*func)(id, SEL) = (void *)imp;
    func(target, action);
}

/**
 当前菜单的title
 
 @param horizontalMenuView 当前控件
 @param index 下标
 @return 标题
 */
-(NSString *)horizontalMenuView:(CMPHorizontalMenuView *)horizontalMenuView titleForItemAtIndex:(NSInteger)index{
    return self.menuItems[index].itemTile;
}

/**
 本地图片
 
 @param horizontalMenuView 当前控件
 @param index 下标
 @return 图片名称
 */
-(NSString *)horizontalMenuView:(CMPHorizontalMenuView *)horizontalMenuView localIconStringForItemAtIndex:(NSInteger)index{
    return self.menuItems[index].itemIconTitle;
}

-(CGSize)iconSizeForHorizontalMenuView:(CMPHorizontalMenuView *)horizontalMenuView{
    return CGSizeMake(50, 50);
}

#pragma mark - 新增方法

- (void)showMenuFromView:(UIView *)targetView {
    [self removeFromSuperview];
    [[targetView viewWithTag:1111111111] removeFromSuperview];
    [targetView addSubview:self];

    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.bottom.mas_equalTo(targetView.mas_safeAreaLayoutGuideBottom);
        } else {
            make.bottom.mas_equalTo(targetView);
        }
        if (self.menuItems.count > 4) {
            make.size.mas_equalTo(CGSizeMake(targetView.frame.size.width, 106));
        } else {
            make.size.mas_equalTo(CGSizeMake(targetView.frame.size.width, 98));
        }
        make.leading.mas_equalTo(targetView.mas_leading);
    }];
    [self reloadData];
    
    UIView *extraView = [[UIView alloc] init];
    extraView.backgroundColor = self.backgroundColor;
    extraView.tag = 1111111111;
    [targetView addSubview:extraView];
    [extraView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(targetView);
        if (@available(iOS 11.0, *)) {
            make.top.mas_equalTo(targetView.mas_safeAreaLayoutGuideBottom);
        } else {
            make.top.mas_equalTo(targetView.mas_bottom);
        }
    }];
}

- (void)hideMenu {
    [[self.superview viewWithTag:1111111111] removeFromSuperview];
    [self removeFromSuperview];
}

@end
