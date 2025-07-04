//
//  EGOImageView.h
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

#import <UIKit/UIKit.h>
#import "CMPRCloudImageLoader.h"

@protocol CMPRCloudImageViewDelegate;
@interface CMPRCloudImageView : UIImageView<CMPRCloudImageLoaderObserver> {
@private
	NSURL* imageURL;
	UIImage* placeholderImage;
	__weak id<CMPRCloudImageViewDelegate> delegate;
}

- (instancetype)initWithPlaceholderImage:(UIImage*)anImage; // delegate:nil
- (instancetype)initWithPlaceholderImage:(UIImage*)anImage delegate:(id<CMPRCloudImageViewDelegate>)aDelegate;

- (void)cancelImageLoad;

@property(nonatomic,retain) NSURL* imageURL;
@property(nonatomic,retain) UIImage* placeholderImage;
@property(nonatomic,retain) NSData* originalImageData;
@property(nonatomic,weak) id<CMPRCloudImageViewDelegate> delegate;

-(void)setPlaceholderImage:(UIImage *)__placeholderImage;

@end

@protocol CMPRCloudImageViewDelegate<NSObject>
@optional
- (void)imageViewLoadedImage:(CMPRCloudImageView*)imageView;
- (void)imageViewFailedToLoadImage:(CMPRCloudImageView*)imageView error:(NSError*)error;
@end
