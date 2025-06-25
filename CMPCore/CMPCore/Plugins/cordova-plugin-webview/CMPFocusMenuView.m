//
//  CMPFocusMenuView.m
//  M3
//
//  Created by Shoujian Rao on 2024/1/19.
//

#import "CMPFocusMenuView.h"
#import "CMPFocusMenuCell.h"
#import <CMPLib/CMPThemeManager.h>
#import <CMPLib/MJExtension.h>
#import <CMPLib/CMPCommonTool.h>
#import <CMPLib/CMPCachedUrlParser.h>
#import <CMPLib/UIImageView+WebCache.h>

@interface CMPFocusMenuView()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *menuTableView;
@property (nonatomic, copy) void(^didSelectItemBlock)(CMPFocusMenuItem *);
@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) UIVisualEffectView *visualEffectView;


@end
@implementation CMPFocusMenuView

+ (UIImage *)imageWithAppliedGaussianBlurWithRadius:(CGFloat)blurRadius withImage:(UIImage *)image  {
    CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];

    // 扩展图像
    CGRect originalExtent = inputImage.extent;
    CGRect extent = CGRectInset(originalExtent, -blurRadius, -blurRadius);
    inputImage = [inputImage imageByClampingToExtent];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:@(blurRadius) forKey:kCIInputRadiusKey];

    CIImage *outputImage = filter.outputImage;
    outputImage = [outputImage imageByCroppingToRect:originalExtent];  // 裁剪回原始大小
    CIContext *context = [CIContext contextWithOptions:nil];

    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];

    UIImage *blurredImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);

    return blurredImage;
}

- (void)gaussianBlurBgWithImage:(UIImage *)screenImage{
    UIImage *blurredImage = [CMPFocusMenuView imageWithAppliedGaussianBlurWithRadius:30.0 withImage:screenImage];
    UIImageView *blurOverlayView = [[UIImageView alloc] initWithImage:blurredImage];
    blurOverlayView.frame = self.bounds;
    blurOverlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    blurOverlayView.userInteractionEnabled = YES;
    [self addSubview:blurOverlayView];
    
    UIView *grayView = [[UIView alloc]initWithFrame:self.bounds];
    [self addSubview:grayView];
    
    if (CMPThemeManager.sharedManager.isDisplayDrak) {
        grayView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.75];
    }else{
        grayView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.2];
    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeMaskView:)];
    [grayView addGestureRecognizer:tap];
    
}

- (void)blurBg{
    UIVisualEffectView *blurView = nil;
    if (@available(iOS 13.0, *)) {
        blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular]];//UIBlurEffectStyleSystemUltraThinMaterial
        blurView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        blurView.alpha = 0.95f;
        [self addSubview:blurView];
    } else {
        blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular]];
        blurView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:blurView];
    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeMaskView:)];
    [blurView addGestureRecognizer:tap];
}

- (void)showFocusImage:(UIImage *)focusImage screenImage:(UIImage *)screenShotImage inPosition:(CGRect)screenRect topGroup:(NSArray *)topGroup didSelectItem:(void(^)(CMPFocusMenuItem *))didSelectItemBlock{
    [self gaussianBlurBgWithImage:screenShotImage];
    [self showFocusImage:focusImage inPosition:screenRect topGroup:topGroup didSelectItem:didSelectItemBlock];
    
}
- (void)showFocusImage:(UIImage *)screenShotImage inPosition:(CGRect)screenRect topGroup:(NSArray *)topGroup didSelectItem:(void(^)(CMPFocusMenuItem *))didSelectItemBlock{
    
    self.didSelectItemBlock = didSelectItemBlock;
    //毛玻璃
//    [self blurBg];
    
    //focus截图
    UIImageView *focusIgv = [[UIImageView alloc]initWithFrame:CGRectMake(screenRect.origin.x, screenRect.origin.y, screenRect.size.width, screenRect.size.height)];
    [self addSubview:focusIgv];
    
    //圆角图片
    UIGraphicsBeginImageContextWithOptions(screenShotImage.size, NO, screenShotImage.scale);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, screenShotImage.size.width, screenShotImage.size.height) cornerRadius:4.f];
    [path addClip];
    [screenShotImage drawInRect:CGRectMake(0, 0, screenShotImage.size.width, screenShotImage.size.height)];
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    focusIgv.image = roundedImage;
    //圆角
    focusIgv.layer.cornerRadius = 4.f;
//    focusIgv.layer.masksToBounds = YES;
    //阴影效果
    focusIgv.layer.shadowColor = [UIColor blackColor].CGColor;
    focusIgv.layer.shadowOffset = CGSizeMake(0, 2);
    focusIgv.layer.shadowOpacity = 0.2;
    focusIgv.layer.shadowRadius = 4;
    
    //计算菜单出现的位置
    //1、计算table高度(2\2+1\2+2...，分组间隔是8，单个cell高度是44)
    
    int sep = topGroup.count-1;
    NSInteger totalCount = 0;
    for (NSArray *arr in topGroup) {
        totalCount += arr.count;
    }
    
    CGFloat tableH = totalCount * 44.f + sep * 8.0;
    CGFloat maxY = CGRectGetMaxY(focusIgv.frame) + 12;
    CGFloat botLeft = self.frame.size.height - maxY - 34;//减34底部安全区域
    
    CGFloat x = focusIgv.frame.origin.x > 14 ? : 14;
    CGFloat y = 0;
    CGFloat w = 226;
    CGFloat h = tableH;
    if (tableH>botLeft) {//如果table比底部剩余高度高
        //显示到上边
        y = CGRectGetMinY(focusIgv.frame) - 12 - tableH;
    }else{
        //显示到下边
        y = CGRectGetMaxY(focusIgv.frame)+12;
    }
    
    [self addMenuTableInFrame:CGRectMake(x, y, w, h)];
    
    //组装数据
    NSArray *topArr = [CMPFocusMenuItem mj_objectArrayWithKeyValuesArray:topGroup];
    
    self.sections = topArr;
    
    [self.menuTableView reloadData];
    
}

//菜单表
- (void)addMenuTableInFrame:(CGRect)frame{
    // 创建UITableView
    _menuTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    
    _menuTableView.backgroundColor = [[UIColor cmp_colorWithName:@"liactive-bgc"] colorWithAlphaComponent:0.6];
    _menuTableView.delegate = self;
    _menuTableView.dataSource = self;
    _menuTableView.layer.cornerRadius = 8.f;
    _menuTableView.clipsToBounds = YES;
    _menuTableView.scrollEnabled = NO;
    _menuTableView.showsVerticalScrollIndicator = NO;
    if (@available(iOS 15.0, *)) {
        _menuTableView.sectionHeaderTopPadding = 0;
    } else {
        // Fallback on earlier versions
    }
    [self addSubview:_menuTableView];
    _menuTableView.tableFooterView = [UIView new];

}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *arr = self.sections[section];
    return arr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return 8.f;
    }
    return 0.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CMPFocusMenuCell";
    CMPFocusMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[CMPFocusMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    CMPFocusMenuItem *item = self.sections[indexPath.section][indexPath.row];
    // 设置cell的标题和图标
    cell.titleLabel.text = item.name;
    
    NSString *localPath = [self localH5Url:item.icon];
    if (localPath) {
        cell.iconImageView.image = [UIImage imageWithContentsOfFile:localPath];
    }else{
        NSURL *iconURL =[NSURL URLWithString:[[CMPCore sharedInstance].serverurl stringByAppendingString:item.icon]];
        [cell.iconImageView sd_setImageWithURL:iconURL placeholderImage:nil];
    }

    if (indexPath.section == [tableView numberOfSections] - 1 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
        cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0);
    } else {
        cell.separatorInset = UIEdgeInsetsZero;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (self.didSelectItemBlock) {
        CMPFocusMenuItem *item = self.sections[indexPath.section][indexPath.row];
        self.didSelectItemBlock(item);
        [self removeFromSuperview];
    }
}

#pragma mark - other
- (void)removeMaskView:(UIGestureRecognizer *)recongizer{
    [self removeFromSuperview];
}

- (NSString *)localH5Url:(NSString *)url{
    NSString *localUrl = nil;
    if ([CMPCachedUrlParser chacedUrl:[NSURL URLWithString:url]]) {
        localUrl = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:url]];
        localUrl = [localUrl replaceCharacter:@"file://" withString:@""];
    }
    return localUrl;
}

#pragma mark - getter
- (NSArray *)sections{
    if (!_sections) {
        _sections = [NSArray new];
    }
    return _sections;
}

@end
