//
//  SyImageViewManager.m
//  M1Core
//
//  Created by youlin guo on 14-3-18.
//
//

#import "CMPImageViewManager.h"
#import <CMPLib/NSString+CMPString.h>
#import "CMPImageView.h"
#import <CMPLib/SyFileManager.h>
#import <CMPLib/MAttachment.h>

@interface CMPImageViewManager () {
	NSMutableDictionary *_imagePathDict; // 记录图片路径  key = attID, value = NSString
	NSMutableDictionary *_imageViewDict; // 记录图片控件view  key为attID, value 为NSArray
}

@end

@implementation CMPImageViewManager

static CMPImageViewManager *_instance;

+ (CMPImageViewManager *)instance
{
	if (!_instance) {
		_instance = [[super allocWithZone:NULL] init];
	}
	return _instance;
}

- (id)init
{
	self = [super init];
	if (self) {
		_imagePathDict = [[NSMutableDictionary alloc] init];
		_imageViewDict = [[NSMutableDictionary alloc] init];
	}
	return self;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self instance] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}

- (oneway void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

- (void)fetchImageWithAttachment:(MAttachment *)aMAttachment imageView:(CMPImageView *)aImageView onlyCache:(BOOL )aCache
{
	// 判断当前缓存是否已经有
	NSString *attID = [NSString stringWithLongLong:aMAttachment.attID];
	NSString *aPath = [_imagePathDict objectForKey:attID];
	UIImage *aImage = nil;
	if (aPath) {
		aImage = [UIImage imageWithContentsOfFile:aPath];
	}
	if (aImage) {
		aImageView.image = aImage;
		return;
	}
	// 如果onlyCache为true，只从缓存拿，
	if (!aCache) {
		// 判断当前下载队列中，是否存在该图片的下载
		NSMutableArray *aList = [_imageViewDict objectForKey:attID];
		if (aList.count > 0) {
			[aList addObject:aImageView];
		}
		else {
			// 下载

		}
	}
}

@end
