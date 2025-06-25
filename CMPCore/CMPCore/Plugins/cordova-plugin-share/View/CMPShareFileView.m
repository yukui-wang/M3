//
//  CMPShareFileView.m
//  M3
//
//  Created by MacBook on 2019/10/29.
//

#import "CMPShareFileView.h"
#import <CMPLib/UIView+CMPView.h>
#import <CMPLib/CMPFileTypeHandler.h>
#import <RongIMKit/RCKitUtility.h>
#import <CMPLib/CMPFileManager.h>
#import <CMPLib/CMPThemeManager.h>


static NSString * const kOfflineFilesImageBundleName = @"offlineFilesImage.bundle";

@interface CMPShareFileView()

/* imageView */
@property (strong, nonatomic) UIImageView *imageView;
/* titleLabel */
@property (strong, nonatomic) UILabel *titleLabel;
/* countLabel */
@property (strong, nonatomic) UILabel *countLabel;
/* contentView */
@property (strong, nonatomic) UIView *contentView;

@end

@implementation CMPShareFileView


+ (instancetype)fileViewWithFrame:(CGRect)frame filePath:(NSString *)filePath shareFileCount:(NSInteger)shareFileCount {
    
    CMPShareFileView *instance = [[CMPShareFileView alloc] initWithFrame:frame];
    instance.titleLabel.text = filePath.lastPathComponent;
    
    NSString *fileType = [filePath.lastPathComponent componentsSeparatedByString:@"."].lastObject;
    NSString *fileTypeIcon = [RCKitUtility getFileTypeIcon:fileType];
    UIImage *img = [RCKitUtility imageNamed:fileTypeIcon ofBundle:@"RongCloud.bundle"];
    instance.imageView.image = img;
    if (shareFileCount > 1) {
        instance.countLabel.text = [NSString stringWithFormat:SY_STRING(@"share_component_file_share_count_tips"),shareFileCount];
    }else {
        instance.titleLabel.cmp_height = instance.contentView.height;
        instance.titleLabel.cmp_centerY = instance.contentView.cmp_height/2.f;
        instance.countLabel.cmp_height = 0;
        instance.countLabel.hidden = YES;
    }
    
    return instance;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height - 14.f)];
        _contentView.backgroundColor = [UIColor cmp_colorWithName:@"white-bg"];
    }
    return _contentView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(30.f, 0, 50.f, 50.f)];
        imageView.cmp_centerY = _contentView.height/2.f;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.layer.masksToBounds = YES;
        _imageView = imageView;
    }
    return _imageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(90.f, 0, self.width - 110.f, self.contentView.height - 20.f)];
        titleLabel.cmp_centerY = self.imageView.cmp_centerY;
        titleLabel.numberOfLines = 0;
        titleLabel.font = [UIFont systemFontOfSize:18.f];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.textColor = [UIColor cmp_colorWithName:@"main-fc"];
        _titleLabel = titleLabel;
    }
    return _titleLabel;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame), self.contentView.width, 20.f)];
        _countLabel.backgroundColor = UIColor.clearColor;
        _countLabel.textAlignment = NSTextAlignmentCenter;
        _countLabel.textColor = [UIColor cmp_colorWithName:@"sup-fc1"];
        _countLabel.font = [UIFont systemFontOfSize:14.f];
        
    }
    return _countLabel;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.contentView];
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.countLabel];
        self.backgroundColor = UIColor.clearColor;
    }
    return self;
}

@end
