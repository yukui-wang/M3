//
//  CMPEmptyViewController.m
//  CMPLib
//
//  Created by CRMO on 2019/5/7.
//  Copyright © 2019 crmo. All rights reserved.
//

#import "CMPEmptyViewController.h"
#import "UIColor+Hex.h"
#import "Masonry.h"
#import "CMPConstant.h"
#import "CMPFileManager.h"
#import "UIImage+CMPImage.h"
#import <CMPLib/CMPThemeManager.h>


@interface CMPEmptyViewController ()
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *text;
@end

@implementation CMPEmptyViewController

+ (instancetype)emptyViewController {
    CMPEmptyViewController *vc = [[CMPEmptyViewController alloc] init];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor cmp_colorWithName:@"p-bg"];
    [self.view addSubview:self.imageView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGSize maxSize = self.view.frame.size;
    UIImage *image = [UIImage imageNamed:@"empty_nothing_new"];
    CGSize imageSize1 = image.size;
    if (imageSize1.width > maxSize.width || imageSize1.height > maxSize.height) {
        //图片比较大，需要缩放
        CGFloat w = maxSize.width/imageSize1.width;
        CGFloat h = maxSize.height/imageSize1.height;
        if (w > h) {
            w = h;
        }
        NSInteger width = imageSize1.width*w;
        NSInteger height = imageSize1.height*w;
        image = [image resizedToSize:CGSizeMake(width, height)];
    }
    _imageView.image = image;
    CGSize imageSize = image.size;
    _imageView.frame = CGRectMake(maxSize.width/2-imageSize.width/2, maxSize.height/2-imageSize.height/2, imageSize.width, imageSize.height);
}

#pragma mark-
#pragma mark Getter

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

- (UILabel *)text {
    if (!_text) {
        _text = [[UILabel alloc] init];
        NSAttributedString *str = [[NSAttributedString alloc]
                                   initWithString:SY_STRING(@"common_Nothing")
                                   attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18],
                                                NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#999999"]}];
        _text.attributedText = str;
        _text.textAlignment = NSTextAlignmentCenter;
    }
    return _text;
}

#pragma mark - CMPScreenshotControlProtocol

- (NSString *)currentPageScreenshotControlTitle {
    return SY_STRING(@"screeenshot_page_title_empty");
}

@end
