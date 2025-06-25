// RDVTabBar.m
// RDVTabBarController
//
// Copyright (c) 2013 Robert Dimitrov
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "RDVTabBar.h"
#import "RDVTabBarItem.h"
#import "RDVTabBarShortcutItem.h"
#import "UIColor+Hex.h"
#import "CMPConstant.h"
#import "CMPCore.h"
#import "CMPThemeManager.h"
#import "CMPExpandTabBarView.h"
#import <CMPLib/Masonry.h>

#define kScreenWidth UIScreen.mainScreen.bounds.size.width
#define kScreenHeight UIScreen.mainScreen.bounds.size.height
@interface RDVTabBar ()<UIGestureRecognizerDelegate>

@property (nonatomic) CGFloat itemWidth;
@property (nonatomic) UIView *backgroundView;
@property (nonatomic) UIButton *portraitView;
@property (strong, nonatomic) UIView *seperateView;

//扩展导航begin
@property (nonatomic, assign) BOOL canPanExpand;//是否可以pan打开扩展导航
@property (nonatomic, assign) BOOL canEditExpand;//是否可以编辑扩展导航
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) CMPExpandTabBarView *expandView;

@property (nonatomic, assign) CGFloat indicatorHeight;
@property (nonatomic, strong) UIView *indicatorView;
@property (nonatomic, strong) UIButton *editBtn;
@property (nonatomic, strong) UIView *sepLine;
@property (nonatomic, strong) UIView *hideView;

@property (nonatomic, assign) CGFloat iphoneXBot;
@property (nonatomic, assign) CGFloat minTabBarY;
@property (nonatomic, assign) CGFloat maxTabBarY;
@property (nonatomic, assign) BOOL canPanMove;
//扩展导航end
@end

@implementation RDVTabBar

- (instancetype)initWithCanExpand:(BOOL)expand canEdit:(BOOL)canEdit{
    if (self = [super init]) {
        [self commonInitialization];
        self.canPanExpand = expand;
        self.canEditExpand = canEdit;
        if (self.canPanExpand) {
            [self addExpandTabNavi];
        }
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitialization];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInitialization];
    }
    return self;
}

- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (void)commonInitialization {
    _backgroundView = [[UIView alloc] init];
    [self addSubview:_backgroundView];
    
    _portraitView = [[UIButton alloc] init];
    [self addSubview:_portraitView];
    [_portraitView addTarget:self action:@selector(portraitDidSelected:) forControlEvents:UIControlEventTouchDown];
    
    [self setTranslucent:NO];
    
    _seperateView = [[UIView alloc] init];
    [_seperateView setBackgroundColor:[UIColor cmp_colorWithName:@"cmp-bdc"]];
    [self addSubview:_seperateView];
        
}

- (void)layoutSubviews {
    CGSize frameSize = self.frame.size;
    [[self backgroundView] setFrame:CGRectMake(0, 0, frameSize.width, frameSize.height)];
    
    if (self.orientation == RDVTabBarVertical) {
        [self layoutForVertical];
    } else {
        [self layoutForHorizontal];
    }
}

- (void)layoutForVertical {
    CGSize frameSize = self.frame.size;
    CGFloat portraitY = 35;
    CGFloat portraitHeight = 40;
    CGFloat portraitWidth = portraitHeight;
    _portraitView.frame = CGRectMake(roundf((frameSize.width - portraitWidth) / 2), portraitY, portraitWidth, portraitHeight);
    _portraitView.layer.cornerRadius = portraitHeight / 2;
    _portraitView.layer.masksToBounds = YES;
    _portraitView.layer.borderWidth = 1;
    _portraitView.layer.borderColor = [UIColor colorWithHexString:@"DADADA"].CGColor;
    _portraitView.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.portraitView setHidden:NO];
    _seperateView.frame = CGRectMake(frameSize.width, 0, 0.5, frameSize.height);
    
    for (int i = 0; i < self.shortcutItems.count; ++i) {
        RDVTabBarShortcutItem *item = self.shortcutItems[i];
        CGFloat width = frameSize.width;
        CGFloat height = 54;
        // 最下方的按钮距离底部
        CGFloat shortcutMarginBottom = 15;
        CGFloat y = frameSize.height - shortcutMarginBottom - (self.shortcutItems.count - i) * height;
        [item setFrame:CGRectMake(0, y, width, height)];
        [item setNeedsDisplay];
    }
    
    for (int i = 0; i < self.items.count; ++i) {
        RDVTabBarItem *item = self.items[i];
        CGFloat itemWidth = [item itemHeight];
        if (!itemWidth) {
            itemWidth = frameSize.width;
        }
        CGFloat itemHeight = 86;
        CGFloat itemY = roundf((frameSize.height - self.items.count * itemHeight) / 2 - 40) + i * itemHeight;
        item.imageStartingY = 25;
        [item setFrame:CGRectMake(roundf(frameSize.width - itemWidth), itemY, itemWidth, itemHeight)];
        [item setNeedsDisplay];
    }
}

- (void)layoutForHorizontal {
    CGSize frameSize = self.frame.size;
    [self.portraitView setHidden:YES];
    [self setItemWidth:roundf((frameSize.width) / [[self items] count])];
    _seperateView.frame = CGRectMake(0, 0, frameSize.width, 0.5);
    
    CGFloat y = self.indicatorHeight;//y>0表示有扩展导航条
        
    for (int i = 0; i < self.items.count; ++i) {
        RDVTabBarItem *item = self.items[i];
        CGFloat itemHeight = [item itemHeight];
        
        if (!itemHeight) {
            itemHeight = y>0?50:frameSize.height;
        }
        
        item.imageStartingY = y>0?4:14;
        [item setFrame:CGRectMake(i * self.itemWidth, y, self.itemWidth, itemHeight)];
        [item setNeedsDisplay];
    }
    
    if (self.canPanExpand) {
        //扩展导航刘海屏底部遮挡view
        RDVTabBarController *tabVC = (RDVTabBarController *)self.delegate;
        if (![tabVC.view.subviews containsObject:self.hideView]) {
            [tabVC.view addSubview:self.hideView];
        }
        if (![tabVC.view.subviews containsObject:self.maskView]) {
            [tabVC.view addSubview:self.maskView];
            [tabVC.view bringSubviewToFront:self];
            [tabVC.view bringSubviewToFront:self.hideView];
        }
    }
    
}

- (void)hideSeperateView{
    _seperateView.hidden = YES;
}
#pragma mark - Configuration

- (void)setItemWidth:(CGFloat)itemWidth {
    if (itemWidth > 0) {
        _itemWidth = itemWidth;
    }
}

- (void)setItems:(NSArray *)items {
    for (RDVTabBarItem *item in _items) {
        [item removeFromSuperview];
    }
    
    _items = [items copy];
    for (RDVTabBarItem *item in _items) {
        [item addTarget:self action:@selector(tabBarItemWasSelected:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:item];
    }
}

- (void)setHeight:(CGFloat)height {
    [self setFrame:CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame),
                              CGRectGetWidth(self.frame), height)];
}

- (void)setShortcutItems:(NSArray *)shortcutItems {
    for (RDVTabBarShortcutItem *item in _shortcutItems) {
        [item removeFromSuperview];
    }
    
    _shortcutItems = [shortcutItems copy];
    for (RDVTabBarShortcutItem *item in _shortcutItems) {
        [item addTarget:self action:@selector(shortcutDidSelected:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:item];
    }
}

#pragma mark - Item selection

- (void)tabBarItemWasSelected:(id)sender {
    if ([self.delegate respondsToSelector:@selector(tabBarCanUse:)]) {
        if (![self.delegate tabBarCanUse:self]) {
            return;
        }
    }
    
    if (self.canPanExpand) {
        [self hideMask];
    }
    
    void(^block) (void) = ^{
        [self setSelectedItem:sender];
        if ([[self delegate] respondsToSelector:@selector(tabBar:didSelectItemAtIndex:)]) {
            NSInteger index = [self.items indexOfObject:self.selectedItem];
            [[self delegate] tabBar:self didSelectItemAtIndex:index];
        }
    };

    if ([self.delegate respondsToSelector:@selector(tabBar:shouldSelectItemAtIndex:incompleteOperationBlock:)]) {
        NSInteger index = [self.items indexOfObject:sender];
        if (![self.delegate tabBar:self shouldSelectItemAtIndex:index incompleteOperationBlock:block]) {
            return;
        }
    }
    
    block();
    
}

- (void)setSelectedItem:(id)selectedItem {
    if (selectedItem == _selectedItem) {
        return;
    }
    [_selectedItem setSelected:NO];
    _selectedItem = selectedItem;
    [_selectedItem setSelected:YES];
}

- (void)shortcutDidSelected:(RDVTabBarShortcutItem *)sender {
    if ([self.delegate respondsToSelector:@selector(tabBarCanUse:)]) {
        if (![self.delegate tabBarCanUse:self]) {
            return;
        }
    }
    
    if (sender.canSelect) {
        [self setSelectedItem:sender];
    }
    
    void (^block) (void) = ^{
        if (sender.didClick) {
            sender.didClick();
        }
    };
    
    if ([self.delegate respondsToSelector:@selector(tabBar:didSelectShortcutAtIndex:incompleteOperationBlock:)]) {
        NSInteger index = [self.items indexOfObject:self.selectedItem];
        if (![self.delegate tabBar:self didSelectShortcutAtIndex:index incompleteOperationBlock:block]) {
            return;
        }
    }
    
    block();
   
}

- (void)homePageCommonAppDidSelected {
    if(!CMP_IPAD_MODE) {
        return;
    }
    
    if(self.shortcutItems.count != 3)  {
        return;
    }
   
    RDVTabBarShortcutItem *sender = self.shortcutItems[0];
    if (sender.canSelect) {
        [self setSelectedItem:sender];
    }
    
    void (^block) (void) = ^{
        if (sender.didClick) {
            sender.didClick();
        }
    };
    
    if ([self.delegate respondsToSelector:@selector(tabBar:didSelectShortcutAtIndex:incompleteOperationBlock:)]) {
        NSInteger index = [self.items indexOfObject:self.selectedItem];
        if (![self.delegate tabBar:self didSelectShortcutAtIndex:index incompleteOperationBlock:block]) {
            return;
        }
    }
    
    block();
    
}

- (void)portraitDidSelected:(id)sender {
    if ([self.delegate respondsToSelector:@selector(tabBarCanUse:)]) {
        if (![self.delegate tabBarCanUse:self]) {
            return;
        }
    }
    
    [self setSelectedItem:sender];
    
    if ([self.delegate respondsToSelector:@selector(tabBarDidSelectPortrait:)]) {
        [self.delegate tabBarDidSelectPortrait:self];
    }
}

#pragma mark - Translucency

- (void)setTranslucent:(BOOL)translucent {
    _translucent = translucent;
    
    CGFloat alpha = (translucent ? 0.9 : 1.0);
    [_backgroundView setBackgroundColor:[[UIColor cmp_colorWithName:@"white-bg"] colorWithAlphaComponent:alpha]];
}

#pragma mark - Accessibility

- (BOOL)isAccessibilityElement {
    return NO;
}

- (NSInteger)accessibilityElementCount {
    return self.items.count;
}

- (id)accessibilityElementAtIndex:(NSInteger)index {
    return self.items[index];
}

- (NSInteger)indexOfAccessibilityElement:(id)element {
    return [self.items indexOfObject:element];
}

#pragma mark - 扩展导航

- (void)addExpandTabNavi{
    if (@available(iOS 11.0, *)) {
        CGFloat safeAreaBottom = UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom;
        self.iphoneXBot += safeAreaBottom;
    }
    //最低tabBarH=86 最高tabBarH = 216
    self.maxTabBarY = kScreenHeight - 86 - self.iphoneXBot;
    self.minTabBarY = kScreenHeight - 216 - self.iphoneXBot;
    
    self.indicatorHeight = self.canPanExpand?36:0;//滑动条空间高度
    //指示条
    _indicatorView = [[UIView alloc]init];
    _indicatorView.backgroundColor = [UIColor cmp_colorWithName:@"cmp-line"];
    _indicatorView.layer.cornerRadius = 2.0;
    [self addSubview:_indicatorView];
    _indicatorView.frame = CGRectMake((kScreenWidth-24)/2, 16, 24, 4);
    //编辑按钮
    if (_canEditExpand) {
        _editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_editBtn setTitle:@"编辑" forState:(UIControlStateNormal)];
        [_editBtn setTitleColor:[UIColor cmp_colorWithName:@"theme-bdc"] forState:(UIControlStateNormal)];
        _editBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        _editBtn.hidden = YES;
        [_editBtn addTarget:self action:@selector(editBtnClick:) forControlEvents:(UIControlEventTouchUpInside)];
        [self addSubview:_editBtn];
        _editBtn.frame = CGRectMake(kScreenWidth-60, 0, 60, self.indicatorHeight);
        
    }
    
    //分隔线
    _sepLine = [[UIView alloc]initWithFrame:CGRectMake(30, 97, UIScreen.mainScreen.bounds.size.width - 60, 0.5)];
    _sepLine.backgroundColor = [UIColor cmp_colorWithName:@"cmp-line"];
    [self addSubview:_sepLine];
    _sepLine.frame = CGRectMake(30, 91, kScreenWidth-60, 0.5);
    //扩展导航容器
    _expandView = [[CMPExpandTabBarView alloc]initWithFrame:CGRectMake(0, 97, UIScreen.mainScreen.bounds.size.width, 120)];
    [self addSubview:_expandView];
    _expandView.frame = CGRectMake(0, CGRectGetMaxY(_sepLine.frame)+5, kScreenWidth, 120);
    
    
    //拖拽手势
    self.canPanMove = YES;
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    recognizer.delaysTouchesBegan = YES;
    recognizer.delegate = self;
    [self addGestureRecognizer:recognizer];
    
    //点击item block
    __weak typeof(self) wSelf = self;
    _expandView.ItemClickBlock = ^(id obj) {
        [wSelf hideMask];
        if (wSelf.ExpandNaviItemClick) {
            wSelf.ExpandNaviItemClick(obj);
        }
    };
}

- (void)editBtnClick:(id)sender{
    [self hideMask];
    if (_ExpandNaviEditButtonClick) {
        _ExpandNaviEditButtonClick(sender);
    }
}

//设置扩展导航数据
/**
 @{ @"title":@"xxx",
    @"defaultImage":defaultImage,
    @"imageUrl":@"xxx",
    @"appId":@"xxx"
 }
 */
- (void)setExpandItems:(NSArray *)expandItems{
    _expandItems = expandItems;
    [_expandView setItemArray:expandItems];
}

- (UIView *)maskView{
    if (!_maskView) {
        RDVTabBarController *tabVC = (RDVTabBarController *)self.delegate;
        _maskView = [[UIView alloc]initWithFrame:tabVC.view.bounds];
        _maskView.alpha = 0;
        _maskView.backgroundColor = UIColor.blackColor;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideMask)];
        [_maskView addGestureRecognizer:tap];
    }
    return _maskView;
}

- (void)hideMask{
    [UIView animateWithDuration:0.3 animations:^{
        self.maskView.alpha = 0;
        self.cmp_y = self.maxTabBarY;
        self.layer.cornerRadius = 0;
        self.backgroundView.layer.cornerRadius = 0;
    } completion:^(BOOL finished) {
        self.seperateView.hidden = NO;
        if (_tabbarMoveBlock) _tabbarMoveBlock();
    }];
    _editBtn.hidden = YES;
    _sepLine.hidden = YES;
    
}
//iPhoneX底部遮挡
- (UIView *)hideView{
    if (!_hideView) {
        _hideView = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeight-self.iphoneXBot, kScreenWidth, self.iphoneXBot)];
        _hideView.backgroundColor = self.backgroundColor;
    }
    return _hideView;
}

- (void)showMaskView:(BOOL)show{
    self.maskView.hidden = show;
    self.hideView.hidden = show;
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture{
    if ([self.delegate respondsToSelector:@selector(tabBarCanUse:)]) {
        if (![self.delegate tabBarCanUse:self]) {
            return;
        }
    }
    UIView *view = gesture.view;
    CGPoint translation = [gesture translationInView:view.superview];
    
    CGFloat maxY = self.maxTabBarY;//screenH - 70 - 34;
    CGFloat minY = self.minTabBarY;//screenH - 220 - 34;
    
    if (view.cmp_y >= maxY && translation.y > 0) {//如果已经是最下面了。则不接受再向下操作
        return;
    }
    if (view.cmp_y <= minY && translation.y < 0) {//如果已经是最上面了。则不接受再向上操作
        return;
    }
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        CGFloat y = view.cmp_y + translation.y;
        CGPoint speed = [gesture velocityInView:gesture.view];
        if (speed.y>200) {//向下
            y = maxY;
            [self hideMask];
            _seperateView.hidden = NO;

            _canPanMove = NO;
            [UIView animateWithDuration:0.2 animations:^{
                view.cmp_y = y;
                CGFloat distance = maxY - minY;
                self.maskView.alpha = (maxY - y)/distance/2.0;
            } completion:^(BOOL finished) {
                self.canPanMove = YES;
            }];
        }else if(speed.y < -200){//向上
            y = minY;
            _editBtn.hidden = NO;
            _sepLine.hidden = NO;
            _seperateView.hidden = YES;

            _canPanMove = NO;
            [UIView animateWithDuration:0.2 animations:^{
                view.cmp_y = y;
                CGFloat distance = maxY - minY;
                self.maskView.alpha = (maxY - y)/distance/2.0;
            } completion:^(BOOL finished) {
                self.canPanMove = YES;
            }];
        }
    }else if (gesture.state == UIGestureRecognizerStateChanged){
        if (!self.canPanMove) {
            return;
        }
        CGFloat y = view.cmp_y + translation.y;
                        
        if (y < minY) {
            y = minY;
        }
        if (y > maxY) {
            y = maxY;
            self.seperateView.hidden = NO;
        }

        CGFloat deltaY = maxY - view.cmp_y;
        CGFloat distance = maxY - minY;
        if (deltaY >= 0 && deltaY <= distance) {
            view.cmp_y = y;
            self.maskView.alpha = (maxY - view.cmp_y)/distance/2.0;
        }
        if (view.cmp_y < maxY) {
            self.seperateView.hidden = YES;
            self.sepLine.hidden = NO;
        }
        //ks fix -- V5-47894【testin测试-iOS】底导航上滑后，无编辑按钮（后台已开启可自定义底导航
        if (_canEditExpand) {
            BOOL hideStateDes = YES,hideStateNow = self.editBtn.hidden;
            if (self.maskView.alpha >= 0.3) hideStateDes = NO;
            if (hideStateNow != hideStateDes) self.editBtn.hidden = hideStateDes;
        }
        //end

        [gesture setTranslation:CGPointZero inView:view.superview];
    }else if (gesture.state == UIGestureRecognizerStateEnded){
        if (!self.canPanMove) {
            return;
        }
        CGFloat y = view.cmp_y;
        if (y >= maxY - 65) {
            y = maxY;
            [self hideMask];
            _seperateView.hidden = NO;
        }else{
            y = minY;
            _editBtn.hidden = NO;
            _sepLine.hidden = NO;
            _seperateView.hidden = YES;
        }
        [UIView animateWithDuration:0.3 animations:^{
            view.cmp_y = y;
            CGFloat distance = maxY - minY;
            self.maskView.alpha = (maxY - y)/distance/2.0;
        }];
    }
    
    //圆角处理
    if (view.cmp_y < maxY-12) {
        self.layer.cornerRadius = 12.f;
        self.backgroundView.layer.cornerRadius = 12.f;
    }else{
        self.layer.cornerRadius = 0;
        self.backgroundView.layer.cornerRadius = 0;
    }
    
    if (_tabbarMoveBlock) _tabbarMoveBlock();
}

- (void)setExpandBadgeAt:(NSInteger)index show:(BOOL)show{
    [self.expandView showBadge:index show:show];
}

@end
