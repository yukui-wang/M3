//
//  RDVTabBarShortcutItem.m
//  RDVTabBarController
//
//  Created by CRMO on 2019/4/28.
//  Copyright © 2019 Robert Dimitrov. All rights reserved.
//

#import "RDVTabBarShortcutItem.h"

@interface RDVTabBarShortcutItem()
@end

@implementation RDVTabBarShortcutItem

- (instancetype)initWithUnselectImage:(UIImage *)unselectImage
                        selectedImage:(UIImage *)selectedImage
                            canSelect:(BOOL)canSelect
                             didClick:(RDVTabBarShortcutItemDidClick)didClick {
    self = [self initWithFrame:CGRectZero];
    self.unselectImage = unselectImage;
    self.selectedImage = selectedImage;
    self.canSelect = canSelect;
    self.didClick = didClick;
    self.shortcutType = RDVTabBarShortcutType_Common;
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitialization];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInitialization];
    }
    return self;
}

- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (void)commonInitialization {
    [self setBackgroundColor:[UIColor clearColor]];
}

- (void)drawRect:(CGRect)rect {
    CGSize frameSize = self.frame.size;
    CGFloat imageHeight = 24;
    CGFloat imageWidth = imageHeight;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    UIImage *image = self.selected ? _selectedImage : _unselectImage;
    [image drawInRect:CGRectMake(roundf(frameSize.width - imageWidth) / 2, roundf(frameSize.height - imageHeight) / 2, imageWidth, imageHeight)];
    
    CGContextRestoreGState(context);
}

@end
