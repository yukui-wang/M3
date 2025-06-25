//
//  AttachmentReaderView.m
//  HelloCordova
//
//  Created by lin on 15/8/20.
//
//

#import "AttachmentReaderView.h"
#import <UIKit/UIKit.h>
#import <CMPLib/CMPDataUtil.h>
#import <CMPLib/CMPConstant.h>
#import <CMPLib/Masonry.h>
#import <CMPLib/NSURL+CMPURL.h>

static const CGFloat k_unknownLabel_marginEdge = 40;
static const CGFloat k_unknownLabel_height = 40;

@interface AttachmentReaderView()
{
}
@end

@implementation AttachmentReaderView

- (void)showOpenFileErrorType:(CMPOpenFileErrorType)type {
    UIView *unkownFileTypeView = [[UIView alloc] initWithFrame:self.bounds];
    unkownFileTypeView.backgroundColor = [UIColor cmp_colorWithName:@"white-bg"];
    [self addSubview:unkownFileTypeView];
    
    UILabel *unkownFileTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(k_unknownLabel_marginEdge, unkownFileTypeView.center.y - 30, unkownFileTypeView.bounds.size.width - k_unknownLabel_marginEdge * 2, k_unknownLabel_height)];
    [unkownFileTypeView addSubview:unkownFileTypeLabel];
    if (type == CMPOpenFileErrorTypeUnknown) {
        unkownFileTypeLabel.text = SY_STRING(@"offlineFiles_unknownFiles");
    } else if (type == CMPOpenFileErrorTypeUnZipFail) {
        unkownFileTypeLabel.text = SY_STRING(@"offlineFiles_unzipFail");
    }
    unkownFileTypeLabel.textColor = [UIColor cmp_colorWithName:@"cont-fc"];
    unkownFileTypeLabel.adjustsFontSizeToFitWidth = YES;
    unkownFileTypeLabel.numberOfLines = 2;
    unkownFileTypeLabel.textAlignment = NSTextAlignmentCenter;
    
    [unkownFileTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(k_unknownLabel_marginEdge);
        make.trailing.mas_equalTo(-k_unknownLabel_marginEdge);
        make.centerY.equalTo(self.center).offset(-30);
    }];
}

@end
