//
//  EGOImageView.m
//  EGOImageLoading
//
//  Created by Shaun Harrison on 9/15/09.
//  Copyright (c) 2009-2010 enormego
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "CMPRCloudImageView.h"
#import "CMPRCloudImageLoader.h"
#import <RongIMKit/RongIMKit.h>

@implementation CMPRCloudImageView
@synthesize imageURL, placeholderImage, delegate;

- (instancetype)initWithPlaceholderImage:(UIImage*)anImage {
	return [self initWithPlaceholderImage:anImage delegate:nil];	
}

- (instancetype)initWithPlaceholderImage:(UIImage*)anImage delegate:(id<CMPRCloudImageViewDelegate>)aDelegate {
	if((self = [super initWithImage:anImage])) {
		self.placeholderImage = anImage;
		self.delegate = aDelegate;
	}
	
	return self;
}
-(void)setPlaceholderImage:(UIImage *)__placeholderImage
{
    if (placeholderImage) {
        [placeholderImage release];
        placeholderImage = nil;
    }
    placeholderImage = [__placeholderImage retain];
    
    self.image = placeholderImage;
    
}
- (void)setImageURL:(NSURL *)aURL {
    self.contentMode = UIViewContentModeScaleAspectFit;
	if(imageURL) {
		[[CMPRCloudImageLoader sharedImageLoader] removeObserver:self forURL:imageURL];
		[imageURL release];
		imageURL = nil;
	}
	
	if(!aURL) {
		self.image = self.placeholderImage;
		imageURL = nil;
		return;
	} else {
		imageURL = [aURL retain];
	}

  if (!aURL.scheme || [aURL.scheme.lowercaseString isEqualToString:@"file"]) {
    NSString *path = aURL.absoluteString;
    if([path length] > 0) {
      path = [RCUtilities getCorrectedFilePath:path];
      UIImage *anImage = [[[UIImage alloc]initWithContentsOfFile:path] autorelease];
      if(anImage) {
        self.image = anImage;
        return;
      }
    } else {
      self.image = self.placeholderImage;
      imageURL = nil;
      return;
    }
  }
  
	[[CMPRCloudImageLoader sharedImageLoader] removeObserver:self];
	UIImage* anImage = [[CMPRCloudImageLoader sharedImageLoader] imageForURL:aURL shouldLoadWithObserver:self];
	
	if(anImage) {
        
//        if (anImage.size.width > 2000 || anImage.size.height > 2000) {
//            float scale = 2000 / (anImage.size.width > anImage.size.height ? anImage.size.width : anImage.size.height);
//            anImage = [RCUtilities scaleImage:anImage toScale:scale];
//        }
		self.image = anImage;
//        self.originalImageData = [[RCloudImageLoader sharedImageLoader] getImageDataForURL:aURL];
		// trigger the delegate callback if the image was found in the cache
		if([self.delegate respondsToSelector:@selector(imageViewLoadedImage:)]) {
			[self.delegate imageViewLoadedImage:self];
		}
	} else {
		self.image = self.placeholderImage;
//        self.originalImageData = UIImageJPEGRepresentation(self.placeholderImage, 1.0);
	}
}

-(NSData *)originalImageData {
    NSData* imageData = [[CMPRCloudImageLoader sharedImageLoader] getImageDataForURL:imageURL];
    if(!imageData) {
        imageData = UIImageJPEGRepresentation(self.placeholderImage, 1.0);
    }
    return imageData;
}

#pragma mark -
#pragma mark Image loading

- (void)cancelImageLoad {
	[[CMPRCloudImageLoader sharedImageLoader] cancelLoadForURL:self.imageURL];
	[[CMPRCloudImageLoader sharedImageLoader] removeObserver:self forURL:self.imageURL];
}

- (void)imageLoaderDidLoad:(NSNotification*)notification {
	if(![[notification userInfo][@"imageURL"] isEqual:self.imageURL]) return;

	UIImage* anImage = [notification userInfo][@"image"];
//    if (anImage.size.width > 2000 || anImage.size.height > 2000) {
//        float scale = 2000 / (anImage.size.width > anImage.size.height ? anImage.size.width : anImage.size.height);
//        anImage = [RCUtilities scaleImage:anImage toScale:scale];
//    }
//    self.originalImageData = [notification userInfo][@"originalImageData"];
	self.image = anImage;
	[self setNeedsDisplay];
	
	if([self.delegate respondsToSelector:@selector(imageViewLoadedImage:)]) {
		[self.delegate imageViewLoadedImage:self];
	}	
}

- (void)imageLoaderDidFailToLoad:(NSNotification*)notification {
	if(![[notification userInfo][@"imageURL"] isEqual:self.imageURL]) return;
	
	if([self.delegate respondsToSelector:@selector(imageViewFailedToLoadImage:error:)]) {
		[self.delegate imageViewFailedToLoadImage:self error:[notification userInfo][@"error"]];
	}
}

#pragma mark -
- (void)dealloc {
	[[CMPRCloudImageLoader sharedImageLoader] removeObserver:self];
	delegate = nil;
	imageURL = nil;
	placeholderImage = nil;
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

@end
