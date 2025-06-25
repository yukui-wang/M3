//
//  CMPShortcutView.m
//  CMPCore
//
//  Created by wujiansheng on 2017/7/5.
//
//

#define kViewTag 1000

#import "CMPShortcutView.h"
#import "CMPVerticalButton.h"
#import <CMPLib/UIView+CMPView.h>
#import <CMPLib/RTL.h>
#import <CMPLib/CMPStringConst.h>
#import <CMPLib/CMPCore.h>
#import <CMPLib/CMPCommonTool.h>


static const CGFloat kCloseButtonWidth = 20;
static const CGFloat kCloseButtonBottomSpacing = 40;
static const CGFloat kCloseButtonTopSpacing = 50;
static const CGFloat kTopListTopButtonBottomSpacing = 140;

/** items区域距离底部 **/
//static const CGFloat kItemsMaiginBottom = 70*2 + 24;
static CGFloat kItemsMaiginBottom = kCloseButtonBottomSpacing + kCloseButtonTopSpacing + kCloseButtonWidth;
/** item竖直方向间距 **/
//static const CGFloat kItemsVerticalSpacing = 40;
static const CGFloat kItemsVerticalSpacing = 30;
/** itemj水平方向间距 **/
static const CGFloat kItemsHorizontalSpacing = 20;

static CGFloat const kAnimTimeInreval = 0.5f;

@interface CMPShortcutView()

@property (strong, nonatomic) UIButton *closeButton;
@property (strong, nonatomic) UIVisualEffectView *effectView;
@property (nonatomic, weak) id<CMPShortcutViewDelegate> delegate;
@property (strong, nonatomic) NSArray *shortcutItemList;
/* topList */
@property (strong, nonatomic) NSArray *topList;
@property (nonatomic, strong) CADisplayLink *displayLink;

/* screenMirroringBtn */
@property (weak, nonatomic) CMPVerticalButton *screenMirroringBtn;


@end

@implementation CMPShortcutView

+ (instancetype)showInView:(UIView *)view
                 shortcuts:(NSArray<CMPShortcutItemModel*> *)shortcuts
                  delegate:(id<CMPShortcutViewDelegate>) delegate {
    CMPShortcutView *instance = [[CMPShortcutView alloc] init];
    instance.delegate = delegate;
    instance.shortcutItemList = shortcuts;
    [instance setupUI];
    instance.frame = [UIScreen mainScreen].bounds;
    [instance showInView:view];
    return instance;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        kItemsMaiginBottom = kCloseButtonBottomSpacing + kCloseButtonTopSpacing + kCloseButtonWidth;
        kItemsMaiginBottom +=  CMP_SafeBottomMargin_height;
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(screenMirroringIsOpenChanged:) name:CMPCoreScreenMirroringIsOpenChangedNoti object:nil];
    }
    return self;
}

- (void)setupUI {
    if (!_effectView) {
        UIBlurEffect * blur;
        if (@available(iOS 10.0, *)) {
             blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
        } else {
             blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        }
        _effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
        [self addSubview:_effectView];
    }
    
    NSArray *topListArray = [CMPFeatureSupportControl quickModuleTopList];
    NSMutableArray *topList = NSMutableArray.array;
    NSMutableArray *animList = NSMutableArray.array;
    NSMutableArray *animList1 = NSMutableArray.array;
    
    for (NSInteger t = 0; t < self.shortcutItemList.count; t++) {
        CMPShortcutItemModel *info = [self.shortcutItemList objectAtIndex:t];
        CMPShortcutItem *item = [[CMPShortcutItem alloc] init];
        item.info = info;
        item.info.tag = kViewTag + t;
        [self addSubview:item];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapItem:)];
        [item addGestureRecognizer:tap];
        if ([topListArray containsObject:item.info.appName]) {//新版本新界面
            [topList addObject:item];
        }else {
            [animList addObject:item.info];
            [animList1 addObject:item];
        }
    }
    self.shortcutItemList = animList.copy;
    
    for (NSInteger t = 0; t < animList1.count; t++) {
        CMPShortcutItem *item = animList1[t];
        item.tag = kViewTag + t;
    }
    
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton cmp_expandClickArea:UIOffsetMake(100, 80)];
        [_closeButton addTarget:self action:@selector(tapClose) forControlEvents:UIControlEventTouchUpInside];
        UIImage *image = [UIImage imageNamed:@"shortcut_close"];
        [_closeButton setImage:image forState:UIControlStateNormal];
        [self addSubview:_closeButton];
        _closeButton.alpha = 0;
    }
    
    if ([topListArray containsObject:[CMPFeatureSupportControl quickMirrorStr]]) {
         //无线投屏按钮
           CMPVerticalButton *screenMirrorBtn = [[CMPVerticalButton alloc] initWithFrame:CGRectMake(0, 0, 100.f, 95.f)];
           screenMirrorBtn.cmp_centerX = CMP_SCREEN_WIDTH/2.f;
           screenMirrorBtn.cmp_y = 100.f;
           if (CMP_SCREEN_HEIGHT <= 667.f && !CMP_IPAD_MODE) {
               screenMirrorBtn.cmp_y = 45.f;
           }
           screenMirrorBtn.imgViewSize = CGSizeMake(70.f, 70.f);
           if (!CMPThemeManager.sharedManager.isDisplayDrak) {
               screenMirrorBtn.imgViewSize = CGSizeMake(90.f, 90.f);
           }
           
           screenMirrorBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12.f];
           [screenMirrorBtn setTitle:SY_STRING(@"screen_mirror_btn_title") forState:UIControlStateNormal];
           [screenMirrorBtn setImage:[UIImage imageNamed:@"screen_mirroring_icon"] forState:UIControlStateNormal];
           
           [screenMirrorBtn setTitleColor:[UIColor cmp_colorWithName:@"cont-fc"] forState:UIControlStateNormal];
           [screenMirrorBtn addTarget:self action:@selector(screenMirrorClicked) forControlEvents:UIControlEventTouchUpInside];
           
           
           _screenMirroringBtn = screenMirrorBtn;
           _screenMirroringBtn.hidden = !CMPCore.sharedInstance.screenMirrorIsOpen;
           
           [topList addObject:screenMirrorBtn];
    }
   
    self.topList = topList.copy;
    CGFloat itemWidth = [CMPShortcutItem defaultWidth];
    CGFloat itemHeight = [CMPShortcutItem defaultHeight];
    if (!CMPThemeManager.sharedManager.isDisplayDrak) {
        itemHeight = [CMPShortcutItem defaultHeight] + 20;
    }
        
    NSInteger itemCount = self.shortcutItemList.count;
    NSInteger row = itemCount / 3 + ((itemCount % 3 == 0) ? 0 : 1);
    CGFloat topListY = [UIScreen mainScreen].bounds.size.height - kItemsMaiginBottom - itemHeight* (row+1) - kItemsVerticalSpacing*(row - 1) - kTopListTopButtonBottomSpacing;
    if (!CMPThemeManager.sharedManager.isDisplayDrak) {
        topListY += 50;
    }
        
    CGFloat space = kItemsHorizontalSpacing;
    NSInteger column = topList.count;
    if (column <= 3) {
        
    }else{
        column = 2;
        topListY += 40;
        //ks fix -- V5-46219【M3向下兼容】iOS13 快捷入口显示样式超出屏幕
        if (CMP_SCREEN_HEIGHT <= 667.f && !CMP_IPAD_MODE) {
            topListY += 55.f;
        }
        //end
    }
    column = column<=0?1:column;//16.0系统iOS模拟器会崩（分母不能为0）
    CGFloat originX = ([UIScreen mainScreen].bounds.size.width - itemWidth * column - space * (column - 1)) * 0.5;
        
    NSInteger count = topList.count;
    NSInteger rowCount = count/column + ((count%column)>0 ? 1 : 0);
    for (NSInteger i = 0; i < count; i++) {
        UIView *view = topList[i];
        view.cmp_width = itemWidth;
        view.cmp_height = itemHeight;
        view.cmp_x = originX + (itemWidth + space) * (i%column);
        view.cmp_y = topListY - ((itemHeight + kItemsVerticalSpacing) *(rowCount-1 - i/column));
        view.alpha = 0;
        [self addSubview:view];
    }
    
    
    UITapGestureRecognizer *tapClose = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCloseAction:)];
    [self addGestureRecognizer:tapClose];
    
}

- (void)customLayoutSubviews {
    CGFloat y1 = self.height - 40 - kCloseButtonWidth - CMP_SafeBottomMargin_height;
    [_closeButton setFrame:CGRectMake(self.width/2-12, y1, kCloseButtonWidth, kCloseButtonWidth)];
    [_effectView setFrame:self.bounds];
}

- (void)orientionDidChange:(NSNotification *)notification {
    self.cmp_height = [UIWindow mainScreenSize].height;
    self.cmp_width = [UIWindow mainScreenSize].width;
    [self customLayoutSubviews];
    [self autoLayoutItems];
}

- (void)autoLayoutItems {
    CGFloat itemWidth = [CMPShortcutItem defaultWidth];
    CGFloat itemHeight = [CMPShortcutItem defaultHeight];
    NSInteger itemCount = self.shortcutItemList.count;
    NSInteger row = itemCount / 3 + ((itemCount % 3 == 0) ? 0 : 1);
    CGFloat y = self.height - kItemsMaiginBottom - itemHeight*row - kItemsVerticalSpacing*row;
    y -= (itemHeight + kItemsVerticalSpacing);
    CGFloat space = kItemsHorizontalSpacing;
    NSInteger column = 3;
    if (itemCount < 3) {
        column = itemCount;
    }
    CGFloat originX = (self.width - itemWidth * column - space * (column - 1)) * 0.5;
    CGFloat x = originX;
    for (NSInteger t = 0; t < itemCount;  t ++ ) {
        NSInteger tag = kViewTag +t;
        UIView *view = [self viewWithTag:tag];
        NSInteger remainder = t%3;//余数
        x += itemWidth+ space;
        if (remainder == 0) {
            y += (itemHeight + kItemsVerticalSpacing);
            x = originX;
        }
        if (view) {
            view.cmp_x = x;
            view.cmp_width = itemWidth;
            view.cmp_height = itemHeight;
            view.cmp_y = y;
            [view resetFrameToFitRTL];
        }
    }
    
    UIView *item0 = [self viewWithTag:0];
    CGFloat topListY = CGRectGetMinY(item0.frame) - itemHeight;
    if (CMP_SCREEN_HEIGHT <= 667.f && !CMP_IPAD_MODE) {
        topListY= 45.f;
    }
    NSInteger count = self.topList.count;
    for (NSInteger i = 0; i < count; i++) {
        UIView *view = self.topList[i];
        view.cmp_width = itemWidth;
        view.cmp_height = itemHeight;
        view.cmp_x = space + (itemWidth + space) * i;
        view.cmp_y = topListY;
    }
    
}


#pragma mark-
#pragma mark 点击事件

- (void)tapItem:(UITapGestureRecognizer *)tap {
    [self dismissWithoutAnimation];
    //检验，防止多次进入此页面
    CMPShortcutItem *item = (CMPShortcutItem *)tap.view;
    if (![item.info.appName isEqualToString:@"quick_scan"] && [CMPCommonTool shortCutViewAvoidMultiTapping]) {
        UIViewController *currentVc = [CMPCommonTool getCurrentShowViewController];
        [currentVc.navigationController popViewControllerAnimated:NO];
    }
    
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(shortcut:selectedIndex:)]) {
        CMPShortcutItem *item = (CMPShortcutItem *)tap.view;
        [self.delegate shortcut:self selectedIndex:item.info.tag - kViewTag];
    }
}

- (void)tapCloseAction:(UITapGestureRecognizer *)tap {
    [self tapClose];
}

- (void)tapClose {
    if (self.shortcutItemList.count == 0) {
        [self dismissWithoutAnimation];
    } else {
        [self dismissWithAnimation];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(shortcutDidClose:)]) {
        [self.delegate shortcutDidClose:self];
    }
}


/// 投屏按钮点击方法
- (void)screenMirrorClicked {
    [self dismissWithoutAnimation];
    
    [NSNotificationCenter.defaultCenter postNotificationName:CMPShortcutViewScreenMirroringClickedNoti object:nil];
}

#pragma mark 通知

- (void)screenMirroringIsOpenChanged:(NSNotification *)noti {
    _screenMirroringBtn.hidden = !CMPCore.sharedInstance.screenMirrorIsOpen;
}

#pragma mark-
#pragma mark 动画

- (void)showInView:(UIView *)view {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_QuickModuleWillShow object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientionDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [view addSubview:self];
    
    CGFloat itemWidth = [CMPShortcutItem defaultWidth];
    CGFloat itemHeight = [CMPShortcutItem defaultHeight];
    NSInteger itemCount = self.shortcutItemList.count;
    NSInteger row = itemCount / 3 + ((itemCount % 3 == 0) ? 0 : 1);
    CGFloat y = self.height - kItemsMaiginBottom - itemHeight*row - kItemsVerticalSpacing*row;
    y -= (itemHeight + kItemsVerticalSpacing);
    CGFloat space = kItemsHorizontalSpacing;
    NSInteger column = 3;
    if (itemCount < 3) {
        column = itemCount;
    }
    CGFloat originX = (self.width - itemWidth * column - space * (column - 1)) * 0.5;
    CGFloat x = originX;
    for (NSInteger t = 0; t < itemCount;  t ++ ) {
        NSInteger tag = kViewTag +t;
        UIView *view = [self viewWithTag:tag];
        NSInteger remainder = t%3;//余数
        x += itemWidth+ space;
        if (remainder == 0) {
            y += (itemHeight + kItemsVerticalSpacing);
            x = originX;
        }
        if (view) {
            view.cmp_x = x;
            view.cmp_width = itemWidth;
            view.cmp_height = itemHeight;
            view.cmp_y = self.cmp_height;
            [view resetFrameToFitRTL];
        }
    }
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(showTimeUpdate:)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    _closeButton.alpha = 0;
    [UIView animateWithDuration:kAnimTimeInreval animations:^{
        self.closeButton.alpha = 1;
        NSInteger count = self.topList.count;
        for (NSInteger i = 0; i < count; i++) {
            UIView *view = self.topList[i];
            view.alpha = 1.f;
        }
    }];
}

- (void)dismissWithAnimation {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_QuickModuleWillHide object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    currentItem = self.shortcutItemList.count;
    
    self.displayLink.paused = YES;
    [self.displayLink invalidate];
    self.displayLink = nil;
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(hideTimeUpdate:)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [UIView animateWithDuration:kAnimTimeInreval animations:^{
        self.closeButton.alpha = 0;
        NSInteger count = self.topList.count;
        for (NSInteger i = 0; i < count; i++) {
            UIView *view = self.topList[i];
            view.alpha = 0;
        }
    }];
}

- (void)dismissWithoutAnimation {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_QuickModuleWillHide object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeFromSuperview];
}

/** 时间戳 **/
static int timeFlag = 0;
/** 正在处理的item编号 **/
static NSUInteger currentItem = 0;

// 展示动画时间轴
- (void)showTimeUpdate:(CADisplayLink *)sender {
    timeFlag++;
    if (timeFlag%2 == 0) {
        NSInteger itemCount = self.shortcutItemList.count;
        if (currentItem > itemCount) {
            self.displayLink.paused = YES;
            [self.displayLink invalidate];
            self.displayLink = nil;
            currentItem = 0;
            timeFlag = 0;
            return;
        }
        
        CGFloat itemHeight = [CMPShortcutItem defaultHeight];
        NSInteger row = itemCount / 3 + ((itemCount % 3 == 0) ? 0 : 1);
        CGFloat y = self.height - kItemsMaiginBottom - itemHeight*row - kItemsVerticalSpacing*(row-1);
        NSInteger tag = kViewTag +currentItem;
        UIView *view = [self viewWithTag:tag];
        y += (itemHeight + kItemsVerticalSpacing) * (currentItem / 3);
        if (view) {
            [self popAnimation:view y:y];
        }
        currentItem++;
    }
}

// 隐藏动画时间轴
- (void)hideTimeUpdate:(CADisplayLink *)sender {
    timeFlag++;
    if (timeFlag%2 == 0) {
        if (currentItem == 0) {
            self.displayLink.paused = YES;
            [self.displayLink invalidate];
            self.displayLink = nil;
            currentItem = 0;
            timeFlag = 0;
            return;
        }
        NSInteger tag = kViewTag + currentItem - 1;
        UIView *view = [self viewWithTag:tag];
        if (view) {
            [self dismissAnimation:view count:currentItem];
        }
        currentItem--;
    }
}

// 单个展示动画
- (void)popAnimation:(UIView *)view y:(CGFloat)y {
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:20 options:UIViewAnimationOptionCurveEaseOut animations:^{
        view.cmp_y = y;
    } completion:^(BOOL finished) {
        
    }];
}

// 单个隐藏动画
- (void)dismissAnimation:(UIView *)view count:(NSUInteger)count {
    [UIView animateWithDuration:0.3 animations:^{
        view.cmp_y = self.cmp_height;
    } completion:^(BOOL finished) {
        if (count == 1 && finished) {
            [self removeFromSuperview];
        }
    }];
}

@end
