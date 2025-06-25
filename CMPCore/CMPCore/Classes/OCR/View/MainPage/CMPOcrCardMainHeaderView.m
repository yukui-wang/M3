//
//  CMPOcrCardMainHeaderView.m
//  M3
//
//  Created by Shoujian Rao on 2021/11/27.
//
#import "CMPOcrMyFilesViewController.h"

#import "CMPOcrCardMainHeaderView.h"
#import "CMPOcrAddPhotoOrCameraOrFileTool.h"
#import <CMPLib/CMPImagePickerController.h>
#import <CMPLib/CMPCameraViewController.h>

#import "CMPOcrUploadManageViewController.h"
#import "CMPOcrDefaultInvoiceViewController.h"
#import "CMPOcrMyFilesViewController.h"
#import "CMPOcrPickFileTool.h"
@interface CMPOcrCardMainHeaderView()<CMPMyFilesViewControllerDelegate>

@property (nonatomic, strong) CMPOcrPickFileTool *pickFileTool;

@end
@implementation CMPOcrCardMainHeaderView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor cmp_specColorWithName:@"p-bg"];
        
        CGFloat imageH = 268*frame.size.width/375;
        //背景图
        UIImageView *topBgImageView = [[UIImageView alloc]init];
        topBgImageView.backgroundColor = [UIColor cmp_specColorWithName:@"theme-bgc"];
        topBgImageView.image = IMAGE(@"ocr_card_main_header");
        [self addSubview:topBgImageView];
        topBgImageView.frame = CGRectMake(0, 0,frame.size.width, imageH);
        
        //操作栏
        UIView *controlView = UIView.new;
        controlView.backgroundColor = UIColor.whiteColor;
        controlView.layer.cornerRadius = 8.f;
        [self addSubview:controlView];
        controlView.frame = CGRectMake(14, imageH-104/2, frame.size.width-28, 104);
        [self addFourSidesShadowToView:controlView withColor:UIColor.grayColor];
        
        //拍照、相册、文件
        UIStackView *stackView = [[UIStackView alloc]init];
        stackView.axis = UILayoutConstraintAxisHorizontal;
        stackView.distribution = UIStackViewDistributionFillEqually;
        [controlView addSubview:stackView];
        [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(14);
            make.bottom.mas_equalTo(-14);
            make.left.right.mas_equalTo(0);
        }];
        
        UIView *v1 = [self titleBtnViewWith:[UIImage imageNamed:@"ocr_card_control_takephoto"] title:@"智能拍票" size:CGSizeMake(60, 76) tag:30001];
        UIView *v2 = [self titleBtnViewWith:[UIImage imageNamed:@"ocr_card_control_imagepick"] title:@"相册选取" size:CGSizeMake(60, 76) tag:30002];
        UIView *v3 = [self titleBtnViewWith:[UIImage imageNamed:@"ocr_card_control_fileupload"] title:@"文件上传" size:CGSizeMake(60, 76) tag:30003];
        [stackView addArrangedSubview:v1];
        [stackView addArrangedSubview:v2];
        [stackView addArrangedSubview:v3];
        
        
        //默认票夹
        UIView *defaultView = UIView.new;
        defaultView.layer.cornerRadius = 8.f;
        [self addSubview:defaultView];
        defaultView.frame = CGRectMake(11, CGRectGetMaxY(controlView.frame)+14, frame.size.width-11*2, 55);
        
        UIImageView *bgImageView = [[UIImageView alloc]init];
        bgImageView.image = [UIImage imageNamed:@"ocr_card_defult_pack_bg"];
        [defaultView addSubview:bgImageView];
        [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        
            //icon
        UIImageView *iconIgv = [[UIImageView alloc]init];
        iconIgv.image = [UIImage imageNamed:@"ocr_card_default_bag"];
        [defaultView addSubview:iconIgv];
        [iconIgv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(12);
            make.centerY.equalTo(defaultView).offset(-2);
            make.width.height.mas_equalTo(16);
        }];
            //title
        UIImageView *defaultIgv = [[UIImageView alloc]init];
        defaultIgv.image = [UIImage imageNamed:@"ocr_card_default_bag_title"];
        [defaultView addSubview:defaultIgv];
        [defaultIgv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(12+16+10);
            make.centerY.equalTo(defaultView).offset(-2);
            make.height.mas_equalTo(14);
        }];
            //arrow  ocr_card_default_arrow_right
        UIImageView *arrowIgv = [[UIImageView alloc]init];
        arrowIgv.image = [UIImage imageNamed:@"ocr_card_default_arrow_right"];
        [defaultView addSubview:arrowIgv];
        [arrowIgv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-14);
            make.centerY.equalTo(defaultView).offset(-2);
            make.width.height.mas_equalTo(16);
        }];
            //btn点击
        UIButton *defaultBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [defaultBtn setTitle:@"" forState:(UIControlStateNormal)];
        [defaultView addSubview:defaultBtn];
        [defaultBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        [defaultBtn addTarget:self action:@selector(defaultBtnClick:) forControlEvents:(UIControlEventTouchUpInside)];
                
        
    }
    return self;
}

//添加四边阴影效果
-(void)addFourSidesShadowToView:(UIView *)theView withColor:(UIColor*)theColor{
    //阴影颜色
    theView.layer.shadowColor = theColor.CGColor;
    //阴影偏移
    theView.layer.shadowOffset = CGSizeMake(0, 0 );
    //阴影透明度，默认0
    theView.layer.shadowOpacity = 0.1;
    //阴影半径，默认3
    theView.layer.shadowRadius = 8;
}

//默认票夹
- (void)defaultBtnClick:(id)sender{
    if (self.actBlk) {
        self.actBlk(0, nil, self.viewController);
    }
}


//相机、相册、文件上传按钮view
- (UIView *)titleBtnViewWith:(UIImage *)image title:(NSString *)title size:(CGSize)size tag:(NSInteger)tag{
    UIView *containerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    UIImageView *igv = [[UIImageView alloc]initWithImage:image];
    [containerView addSubview:igv];
    [igv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(50);
        make.centerX.equalTo(containerView);
        make.top.mas_equalTo(0);
    }];
    
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.text = title;
    titleLabel.textColor = UIColor.blackColor;
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [containerView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(igv.mas_bottom).offset(6);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(20);
    }];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = tag;
    [containerView addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:(UIControlEventTouchUpInside)];
    
    return containerView;
}

- (void)btnAction:(UIButton *)btn{
    NSInteger tag = btn.tag;
    if (tag == 30001) {
        NSLog(@"拍照");
        [self openCamera];
    }else if (tag == 30002) {
        NSLog(@"相册");
        [self openCustomAlbum];
    }else if (tag == 30003) {
        NSLog(@"文件");
        [self openFileChoose];
    }
}

#pragma mark - click method
- (void)openCustomAlbum {
    if (self.actBlk) {
        self.actBlk(1, nil, self.viewController);
    }
}

- (void)openCamera{
    if (self.actBlk) {
        self.actBlk(2, nil, self.viewController);
    }
}

- (void)openFileChoose{
    if (self.actBlk) {
        self.actBlk(3, nil, self.viewController);
    }
}

#pragma mark - private
- (void)scrollViewDidScroll:(CGFloat)contentOffsetY {
//    CGRect frame = self.imageViewFrame;
//    frame.size.height -= contentOffsetY;
//    frame.origin.y = contentOffsetY;
//    self.imageView.frame = frame;
//    NSLog(@"contentOffsetY = %.f",contentOffsetY);
}

- (CMPOcrPickFileTool *)pickFileTool{
    if (!_pickFileTool) {
        _pickFileTool = [CMPOcrPickFileTool new];
    }
    return _pickFileTool;
}

@end
