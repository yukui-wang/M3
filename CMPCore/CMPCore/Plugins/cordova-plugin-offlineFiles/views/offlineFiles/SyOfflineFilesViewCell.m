//
//  SyOfflineFilesViewCell.m
//  M1IPad
//
//  Created by chenquanwei on 14-3-10.
//  Copyright (c) 2014年 北京致远协创软件有限公司. All rights reserved.
//

#import "SyOfflineFilesViewCell.h"
#import <CMPLib/CMPDateHelper.h>
#import <CMPLib/CMPFileTypeHandler.h>
#import <CMPLib/RTL.h>

@implementation SyOfflineFilesViewCell
@synthesize isSelecte = _isSelecte;
@synthesize isLongPress = _isLongPress;
@synthesize downloadFile = _downloadFile;
@synthesize delegate = _delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setDefualtSelectedBkImage];
        [self setDefualtBkView];
        if (!_archiveImageView) {
            _archiveImageView = [[UIImageView alloc]initWithFrame:CGRectMake(14,18,30,30)];
            [self addSubview:_archiveImageView];
        }
        if (!_titleLabel) {
            _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(54 , 12, self.frame.size.width-78, 22)];
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
            _sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(54 , 36, 40, 18)];
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
            _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(115 , 36, 100, 18)];
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
        if (!_grayColorView) {
            _grayColorView = [[UIView alloc]initWithFrame:CGRectMake(14,18,30,30)];
            _grayColorView.backgroundColor = [UIColor grayColor];
            [self addSubview:_grayColorView];
        }
        
        if (!_separatorLine) {
            _separatorLine = [[UIView alloc]initWithFrame: CGRectMake(14, self.height - 0.5, self.width -14, 0.5)];
            _separatorLine.backgroundColor = UIColorFromRGB(0xE4E4E4);
            [self addSubview:_separatorLine];
        }
        
        [self->_topLineView removeFromSuperview];
        [self->_separatorImageView removeFromSuperview];

    }
    return  self;
    
}

- (void)dealloc
{
    SY_RELEASE_SAFELY(_archiveImageView);
    SY_RELEASE_SAFELY(_timeLabel);
    SY_RELEASE_SAFELY(_titleLabel);
    SY_RELEASE_SAFELY(_nameLabel);
    SY_RELEASE_SAFELY(_sizeLabel);
    SY_RELEASE_SAFELY(_grayColorView);
    SY_RELEASE_SAFELY(_downloadFile);
    SY_RELEASE_SAFELY(_separatorLine);
    _delegate = nil;
    [super dealloc];
}

-(void)setSelectedCell:(BOOL)selected animated:(BOOL)animated
{
//    [super setSelected:selected animated:animated];
    _isSelecte = selected;
    [self setOfflineFilesListItem:_downloadFile];
    if (_isLongPress ) {
        [self offlineFilesSelecte:self];
    }
}


- (void)setOfflineFilesListItem:(CMPOfflineFileRecord *)aDownloadFile
{
    _titleLabel.text = aDownloadFile.fileName;
    _sizeLabel.text = [CMPFileTypeHandler getSize:[aDownloadFile.fileSize longLongValue]];
    _timeLabel.text = [CMPDateHelper localDateByDay:aDownloadFile.downloadTime hasTime:YES];
    _nameLabel.text = aDownloadFile.creatorName;
    NSString *imageName;
    if (_isSelecte && _isLongPress) {
        imageName =@"ic_The_selected_icon.png";
        _grayColorView.alpha = 0;
    }else if(_isLongPress){
        imageName =[CMPFileTypeHandler loadAttachmentImageForPhone:aDownloadFile.fileName];
        _grayColorView.alpha = 0.5;
    }else{
        imageName =[CMPFileTypeHandler loadAttachmentImageForPhone:aDownloadFile.fileName];
        _grayColorView.alpha = 0;
    }
    
    _archiveImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"offlineFilesImage.bundle/%@",imageName]];
//    _attachmentImageView.hidden = !aItem.hasAttachments;
    [self customLayoutSubviewsFrame:self.frame];
}


//从新设置frame
- (void)customLayoutSubviewsFrame:(CGRect)frame {
    CGFloat x = 54;
    _titleLabel.frame = CGRectMake(x , 12, self.width-78, 22);
    CGSize size = CGSizeMake(self.width,18);
    CGSize labelsize = [_sizeLabel.text sizeWithFont:_sizeLabel.font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    _sizeLabel.frame = CGRectMake(x , 36, labelsize.width, 18);
    CGSize timesize = [_timeLabel.text sizeWithFont:_timeLabel.font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    x += labelsize.width+20;
    _timeLabel.frame =CGRectMake(x , 36, timesize.width, 18);
    x +=timesize.width+10;
    _nameLabel.frame = CGRectMake(x , 30, self.width-x, 20);
    _separatorLine.frame = CGRectMake(14, self.height - 0.5, self.width -14, 0.5);
    
    [_titleLabel resetFrameToFitRTL];
    [_sizeLabel resetFrameToFitRTL];
    [_timeLabel resetFrameToFitRTL];
    [_nameLabel resetFrameToFitRTL];
    [_separatorLine resetFrameToFitRTL];
    
    _archiveImageView.frame = CGRectMake(14,18,30,30);
    _grayColorView.frame = CGRectMake(14,18,30,30);
    [_archiveImageView resetFrameToFitRTL];
    [_grayColorView resetFrameToFitRTL];
    
}

- (void)offlineFilesSelecte:(SyOfflineFilesViewCell*)aCell
{
    if (_delegate && [_delegate respondsToSelector:@selector(offlineFilesSelecte:)]) {
        [_delegate performSelector:@selector(offlineFilesSelecte:) withObject:self];
    }
}
@end
