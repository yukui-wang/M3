//
//  SyLocalOfflineFilesListViewCell.m
//  M1Core
//
//  Created by chenquanwei on 14-3-14.
//
//

#import "SyLocalOfflineFilesListViewCell.h"
#import <CMPLib/CMPDateHelper.h>
#import <CMPLib/CMPFileTypeHandler.h>
#import <CMPLib/UIImage+CMPImage.h>
#import <CMPLib/RTL.h>

@implementation SyLocalOfflineFilesListViewCell

@synthesize downloadFile = _downloadFile;
@synthesize attachmentButton = _attachmentButton;
@synthesize delegate = _delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageWithTop:@"offlineFilesImage.bundle/list_pressdown_top.png"
                                                                                 center:@"offlineFilesImage.bundle/list_pressdown_center.png"
                                                                                 bottom:@"offlineFilesImage.bundle/list_pressdown_bottom.png"
                                                                                   size:CGSizeMake(320, 62)]];
        imgView.frame = CGRectMake(0, 0, 320, 62);
        [self setSelectedBackgroundView:imgView];
        [imgView release];
        [self setBkViewColor:UIColorFromRGB(0xF1F1F1)];
        if (!_archiveImageView) {
            _archiveImageView = [[UIImageView alloc]initWithFrame:CGRectMake(15,18,40,40)];
            [self addSubview:_archiveImageView];
        }
        if (!_attachmentImageView) {
            _attachmentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-34, 20, 14, 14)];
            _attachmentImageView.contentMode = UIViewContentModeScaleToFill;
            _attachmentImageView.autoresizesSubviews = YES;
            _attachmentImageView.clearsContextBeforeDrawing = YES;
            _attachmentImageView.clipsToBounds = YES;
            _attachmentImageView.highlighted = NO;
            _attachmentImageView.multipleTouchEnabled = NO;
            _attachmentImageView.userInteractionEnabled = NO;
            _attachmentImageView.image = [UIImage imageNamed:@"ic_attach.png"];
            _attachmentImageView.hidden = YES;
            [self addSubview:_attachmentImageView];
        }
        if (!_titleLabel) {
            _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(65 , 18, self.frame.size.width-99, 22)];
            _titleLabel.backgroundColor = [UIColor clearColor];
            _titleLabel.adjustsFontSizeToFitWidth = NO;
            _titleLabel.clearsContextBeforeDrawing = YES;
            _titleLabel.clipsToBounds = YES;
            _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            _titleLabel.font = [UIFont systemFontOfSize:16.000];
            _titleLabel.numberOfLines = 1;
            _titleLabel.textAlignment = NSTextAlignmentLeft;
            _titleLabel.textColor = [UIColor colorWithRed:0.000 green:0.000 blue:0.000 alpha:1.000];
            [self addSubview:_titleLabel];
        }
        if (!_sizeLabel) {
            _sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(65 , 40, 40, 20)];
            _sizeLabel.backgroundColor = [UIColor clearColor];
            _sizeLabel.adjustsFontSizeToFitWidth = NO;
            _sizeLabel.clearsContextBeforeDrawing = YES;
            _sizeLabel.clipsToBounds = YES;
            _sizeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            _sizeLabel.font = [UIFont systemFontOfSize:12.000];
            _sizeLabel.numberOfLines = 1;
            _sizeLabel.textAlignment = NSTextAlignmentLeft;
            _sizeLabel.textColor = UIColorFromRGB(0x9d9d9d);
            [self addSubview:_sizeLabel];
        }
        if (!_timeLabel) {
            _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(115 , 40, 100, 20)];
            _timeLabel.backgroundColor = [UIColor clearColor];
            _timeLabel.adjustsFontSizeToFitWidth = NO;
            _timeLabel.clearsContextBeforeDrawing = YES;
            _timeLabel.clipsToBounds = YES;
            _timeLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
            _timeLabel.font = [UIFont systemFontOfSize:12.000];
            _timeLabel.numberOfLines = 1;
            _timeLabel.textAlignment = NSTextAlignmentLeft;
            _timeLabel.textColor = UIColorFromRGB(0x9d9d9d);
            [self addSubview:_timeLabel];
        }
        if (!_nameLabel) {
            _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(216 , 40, 110, 20)];
            _nameLabel.backgroundColor = [UIColor clearColor];
            _nameLabel.adjustsFontSizeToFitWidth = NO;
            _nameLabel.clearsContextBeforeDrawing = YES;
            _nameLabel.clipsToBounds = YES;
            _nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
            _nameLabel.font = [UIFont systemFontOfSize:12.000];
            _nameLabel.numberOfLines = 1;
            _nameLabel.textAlignment = NSTextAlignmentLeft;
            _nameLabel.textColor = UIColorFromRGB(0x9d9d9d);
            [self addSubview:_nameLabel];
        }
        if (!_attachmentButton) {
            _attachmentButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _attachmentButton.frame =  CGRectMake(320-34, 12, 40, 40);
            [_attachmentButton setImage:[UIImage imageNamedAutoRTL:@"offlineFilesImage.bundle/ic_sub_department.png"] forState:UIControlStateNormal];
            [self addSubview:_attachmentButton];
            [self bringSubviewToFront:_attachmentButton];
            [_attachmentButton addTarget:self action:@selector(attachmentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return  self;
    
}

- (void)dealloc
{
    SY_RELEASE_SAFELY(_archiveImageView);
    SY_RELEASE_SAFELY(_attachmentImageView);
    SY_RELEASE_SAFELY(_timeLabel);
    SY_RELEASE_SAFELY(_titleLabel);
    SY_RELEASE_SAFELY(_nameLabel);
    SY_RELEASE_SAFELY(_sizeLabel);
    SY_RELEASE_SAFELY(_downloadFile);
    _attachmentButton = nil;
    [super dealloc];
}


- (void)setOfflineFilesListItem:(CMPOfflineFileRecord *)downloadFile
{
    _titleLabel.text = downloadFile.fileName;
    _sizeLabel.text = [CMPFileTypeHandler getSize:[downloadFile.fileSize longLongValue]];
    _timeLabel.text = [CMPDateHelper localDateByDay:downloadFile.downloadTime hasTime:YES];

    NSString *imageName =[CMPFileTypeHandler loadAttachmentImageForPhone:downloadFile.fileName];
    _archiveImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"offlineFilesImage.bundle/%@",imageName]];

    [self customLayoutSubviewsFrame:self.frame];
}


//从新设置frame
- (void)customLayoutSubviewsFrame:(CGRect)frame {
    CGFloat x = 65;
    _titleLabel.frame = CGRectMake(x , 12, self.width-99, 20);
    _attachmentImageView.frame = CGRectMake(self.width-34, 20, 14, 14);
    CGSize size = CGSizeMake(self.width,20);
    CGSize labelsize = [_sizeLabel.text sizeWithFont:_sizeLabel.font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    _sizeLabel.frame = CGRectMake(x , 32, labelsize.width, 20);
    CGSize timesize = [_timeLabel.text sizeWithFont:_timeLabel.font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    x += labelsize.width+10;
    _timeLabel.frame =CGRectMake(x , 32, timesize.width, 20);
    x +=timesize.width+10;
    _nameLabel.frame = CGRectMake(x , 32, self.width-x, 20);
    _attachmentButton.frame = CGRectMake(self.width-50, 12, 40, 40);
    
    [_titleLabel resetFrameToFitRTL];
    [_attachmentImageView resetFrameToFitRTL];
    [_sizeLabel resetFrameToFitRTL];
    [_timeLabel resetFrameToFitRTL];
    [_nameLabel resetFrameToFitRTL];
    [_attachmentButton resetFrameToFitRTL];
    
    _archiveImageView.frame = CGRectMake(15,18,40,40);
    [_archiveImageView resetFrameToFitRTL];

}

- (void)attachmentButtonAction:(id )sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(attachmentButtonAction:)]) {
        [_delegate performSelector:@selector(attachmentButtonAction:) withObject:_downloadFile];
    }
}

@end
