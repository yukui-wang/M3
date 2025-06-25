//
//  SyImageView.m
//  M1Core
//
//  Created by youlin guo on 14-3-18.
//
//

#import "CMPImageView.h"
#import <CMPLib/MAttachment.h>
#import "CMPImageViewManager.h"

@interface CMPImageView ()

- (void)loadImageWithOnlyCache:(BOOL)aCache;

@end

@implementation CMPImageView
@synthesize attachment = _attachment;
@synthesize loadImageLazily = _loadImageLazily;

- (void)dealloc
{
    [_attachment release];
    _attachment = nil;
    [super dealloc];
}

- (void)loadImageWithOnlyCache:(BOOL)aCache
{
	[[CMPImageViewManager instance] fetchImageWithAttachment:self.attachment imageView:self onlyCache:aCache];
}

- (void)loadImage
{
	[self loadImageWithOnlyCache:NO];
}

- (void)setAttachment:(MAttachment *)aAttachment
{
	self.image = nil; // 设置默认图片
	[_attachment release];
	_attachment = [aAttachment retain];
	[self loadImageWithOnlyCache:self.loadImageLazily];
}

@end
