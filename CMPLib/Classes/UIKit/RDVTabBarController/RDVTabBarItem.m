// RDVTabBarItem.h
// RDVTabBarController
//
// Copyright (c) 2013 Robert Dimitrov
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "RDVTabBarItem.h"
#import "UIColor+Hex.h"

@interface RDVTabBarItem () {
    NSString *_title;
    UIOffset _imagePositionAdjustment;
    NSDictionary *_unselectedTitleAttributes;
    NSDictionary *_selectedTitleAttributes;
}

@property (nonatomic) UIImage *unselectedBackgroundImage;
@property (nonatomic) UIImage *selectedBackgroundImage;
@property (nonatomic) UIImage *unselectedImage;
@property (nonatomic) UIImage *selectedImage;

@property (nonatomic,strong) UILabel *lable;

@property (nonatomic, assign) CGPoint beginPoint;
@property (nonatomic, assign) CGFloat deltaY;

@end

@implementation RDVTabBarItem

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
    
    _title = @"";
    _titlePositionAdjustment = UIOffsetMake(0, 4);
    _unselectedTitleAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:10],
                                   NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#7A7E83"]};
    _selectedTitleAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:10],
                                 NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#3AADFB"]};
    _badgeBackgroundColor = [UIColor colorWithHexString:@"0xff5c5c"];
    [self addSubview:self.lable];
}

- (void)drawRect:(CGRect)rect {
    CGSize frameSize = self.frame.size;
    CGSize imageSize = CGSizeMake(22, 22);
    NSDictionary *titleAttributes = nil;
    UIImage *backgroundImage = nil;
    UIImage *image = nil;
    
    if ([self isSelected]) {
        image = [self selectedImage];
        backgroundImage = [self selectedBackgroundImage];
        titleAttributes = [self selectedTitleAttributes];
    } else {
        image = [self unselectedImage];
        backgroundImage = [self unselectedBackgroundImage];
        titleAttributes = [self unselectedTitleAttributes];
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    [backgroundImage drawInRect:self.bounds];
    
    if (![_title length]) {
        [image drawInRect:CGRectMake(roundf(frameSize.width / 2 - imageSize.width / 2) +
                                     _imagePositionAdjustment.horizontal,
                                     roundf(frameSize.height / 2 - imageSize.height / 2) +
                                     _imagePositionAdjustment.vertical,
                                     imageSize.width, imageSize.height)];
    } else {
        
        [image drawInRect:CGRectMake((frameSize.width - imageSize.width) / 2 +
                                     _imagePositionAdjustment.horizontal,
                                     self.imageStartingY + _imagePositionAdjustment.vertical,
                                     imageSize.width, imageSize.height)];
        
        
    }
    
    // Draw badges
    
    if (self.showBadge) {
        CGSize badgeSize = CGSizeMake(9, 9);
    CGRect badgeBackgroundFrame = CGRectMake((frameSize.width - imageSize.width) / 2 +
                                             _imagePositionAdjustment.horizontal + imageSize.width - 5,
                                                 self.imageStartingY,
                                                 badgeSize.width, badgeSize.height);
    CGContextSetFillColorWithColor(context, [_badgeBackgroundColor CGColor]);
    CGContextFillEllipseInRect(context, badgeBackgroundFrame);
        CGContextSetFillColorWithColor(context, [[UIColor redColor] CGColor]);
    }
    
    CGContextRestoreGState(context);
}

- (void)setTitle:(NSString *)title {
    _title = title;
    if (_title && _title.length > 0) {
        [self setupLable:self.selected];
    }
}

#pragma mark - Image configuration

- (UIImage *)finishedSelectedImage {
    return [self selectedImage];
}

- (UIImage *)finishedUnselectedImage {
    return [self unselectedImage];
}

- (void)setSelectedImage:(UIImage *)image {
    _selectedImage = image;
    [self setNeedsDisplay];
}

- (void)setUnselectedImage:(UIImage *)image {
    _unselectedImage = image;
    [self setNeedsDisplay];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize frameSize = self.frame.size;
    CGSize imageSize = CGSizeMake(22, 22);
    self.lable.frame = CGRectMake(0 + _titlePositionAdjustment.horizontal,self.imageStartingY + imageSize.height + _titlePositionAdjustment.vertical,frameSize.width - _titlePositionAdjustment.horizontal, 12);
}

- (void)setSelectedTitleAttributes:(NSDictionary *)selectedTitleAttributes {
    _selectedTitleAttributes = selectedTitleAttributes;
    self.selected = self.isSelected;
}

-(void)setUnselectedTitleAttributes:(NSDictionary *)unselectedTitleAttributes {
    _unselectedTitleAttributes = unselectedTitleAttributes;
    self.selected = self.selected;
}

-(void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self setupLable:selected];
}

- (void)setupLable:(BOOL)selected {
    NSDictionary *titleAttributes = nil;
    if ([self isSelected]) {
        titleAttributes = [self selectedTitleAttributes];
    } else {
        titleAttributes = [self unselectedTitleAttributes];
    }
    self.lable.attributedText = [[NSAttributedString alloc] initWithString:_title ?: @"" attributes:titleAttributes];

}

- (void)setFinishedSelectedImage:(UIImage *)selectedImage withFinishedUnselectedImage:(UIImage *)unselectedImage {
    if (selectedImage && (selectedImage != [self selectedImage])) {
        [self setSelectedImage:selectedImage];
    }
    
    if (unselectedImage && (unselectedImage != [self unselectedImage])) {
        [self setUnselectedImage:unselectedImage];
    }
}

- (void)setBadgeValue:(NSString *)badgeValue {
    [self setNeedsDisplay];
}

#pragma mark - Background configuration

- (UIImage *)backgroundSelectedImage {
    return [self selectedBackgroundImage];
}

- (UIImage *)backgroundUnselectedImage {
    return [self unselectedBackgroundImage];
}

- (void)setBackgroundSelectedImage:(UIImage *)selectedImage withUnselectedImage:(UIImage *)unselectedImage {
    if (selectedImage && (selectedImage != [self selectedBackgroundImage])) {
        [self setSelectedBackgroundImage:selectedImage];
    }
    
    if (unselectedImage && (unselectedImage != [self unselectedBackgroundImage])) {
        [self setUnselectedBackgroundImage:unselectedImage];
    }
}

- (void)setShowBadge:(BOOL)showBadge {
    if (_showBadge == showBadge) {
        return;
    }
    _showBadge = showBadge;
    [self setNeedsDisplay];
}

#pragma mark - Accessibility

- (NSString *)accessibilityLabel {
    return @"tabbarItem";
}

- (BOOL)isAccessibilityElement {
    return YES;
}

- (UILabel *)lable {
    if (!_lable) {
        _lable = [[UILabel alloc] init];
        _lable.textAlignment = NSTextAlignmentCenter;
        _lable.backgroundColor = [UIColor clearColor];
    }
    return _lable;
}


@end
