//
//  CMPAVPlayerProgressView.m
//  CMPLib
//
//  Created by MacBook on 2020/2/17.
//  Copyright © 2020 crmo. All rights reserved.
//

#import "CMPAVPlayerProgressView.h"

#import <CMPLib/UIView+CMPView.h>
#import <CMPLib/CMPThemeManager.h>
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/CMPCommonTool.h>


@interface CMPAVPlayerProgressView()
{
    NSString *_fileRecievedSizeString;
    NSString *_fileSizeString;
}

/* progressView的总长度 */
@property (assign, nonatomic) CGFloat progressViewWidth;

/* UIView *progressView */
@property (strong, nonatomic) UIView *progressView;
/* tipsLabel */
@property (strong, nonatomic) UILabel *tipsLabel;

@end

@implementation CMPAVPlayerProgressView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    UIView *progressBg = [[UIView alloc] initWithFrame:CGRectMake(14.f, self.height - 40.f, self.width - 42.f - 14.f, 3.f)];
    progressBg.backgroundColor = [UIColor colorWithHexString:@"#dddddd"];
    [self addSubview:progressBg];
    self.progressViewWidth = progressBg.width;
    
    UIView *progressView = [[UIView alloc] initWithFrame:progressBg.bounds];
    progressView.cmp_width = 80.f;
    progressView.backgroundColor = [UIColor colorWithHexString:@"#00AEFF"];
    [progressBg addSubview:progressView];
    _progressView = progressView;
    
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.width - 40.f, self.height - 40.f, 40.f, 40.f)];
    closeBtn.cmp_centerY = progressBg.cmp_centerY;
    [closeBtn setImage:[UIImage imageNamed:@"avplayer_close_btn"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeBtn];
    
    UILabel *tipsLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width - 20.f, 20.f)];
    tipsLable.cmp_centerX = self.width/2.f;
    tipsLable.textColor = [UIColor whiteColor];
    tipsLable.font = [UIFont systemFontOfSize:12.f];
    tipsLable.textAlignment = NSTextAlignmentCenter;
    tipsLable.text = SY_STRING(@"review_image_downloading");
    [self addSubview:tipsLable];
    _tipsLabel = tipsLable;
}

- (void)setProgress:(CGFloat)progress {
    if (progress < 0 || progress > 1.f) return;
    CGFloat width = self.progressViewWidth*progress;
//    long long currentSize = (long long)(self.fileSize*progress);
    [UIView animateWithDuration:0.75f animations:^{
        self.progressView.cmp_width = width;
//        self.tipsLabel.text = [NSString stringWithFormat:@"%@(%@/%@)",SY_STRING(@"review_image_downloading"),[CMPCommonTool fileSizeFormat:currentSize],_fileSizeString];
    }];
}

- (void)setFileSize:(long long)fileSize {
    _fileSize = fileSize;
    
    _fileSizeString = [CMPCommonTool fileSizeFormat:fileSize];
//    self.tipsLabel.text = [NSString stringWithFormat:@"%@(0B/%@)",SY_STRING(@"review_image_downloading"),_fileSizeString];
}

- (void)setRecievedSize:(long long)recievedSize {
    _recievedSize = recievedSize;
    
    _fileRecievedSizeString = [CMPCommonTool fileSizeFormat:recievedSize];
    self.tipsLabel.text = [NSString stringWithFormat:@"%@(%@/%@)",SY_STRING(@"review_image_downloading"),_fileRecievedSizeString,_fileSizeString];
}

#pragma mark - 按钮点击事件

- (void)closeBtnClicked {
    CMPFuncLog;
    if (self.closeClicked) {
        self.closeClicked();
    }
}

@end
