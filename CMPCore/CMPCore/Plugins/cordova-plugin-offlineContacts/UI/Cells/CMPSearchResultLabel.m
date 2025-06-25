//
//  CMPSearchResultLabel.m
//  CMPCore
//
//  Created by wujiansheng on 2017/1/7.
//
//

#import "CMPSearchResultLabel.h"
#import <CMPLib/CMPConstant.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>

@interface CMPSearchResultLabel ()
@property (nonatomic,retain)NSMutableAttributedString          *attString;
@property (nonatomic,retain)CATextLayer          *textLayer;

@end

@implementation CMPSearchResultLabel
- (void)dealloc
{
    SY_RELEASE_SAFELY(_attString);
    SY_RELEASE_SAFELY(_textLayer);
    SY_RELEASE_SAFELY(_keyColor);
    [super dealloc];
}
- (void)setText:(NSString *)text key:(NSString *)key
{
    self.attString = nil;
    if (text) {
        _attString = [[NSMutableAttributedString alloc] initWithString:text];
    }
    [self setTitle:text keyWord:key keyWordColor:self.keyColor font:self.font];

}

- (void)drawRect:(CGRect)rect{
    
    if (!self.attString) {
        [super drawRect:rect];
        return;
    }
    if (!self.textLayer) {
        CATextLayer *textLayer = [CATextLayer layer];
        textLayer.string = _attString;
        textLayer.transform = CATransform3DMakeScale(0.5,0.5,1);
        textLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        self.textLayer = textLayer;
        [self.layer addSublayer:textLayer];
    }
    else {
        self.textLayer.string = _attString;
        self.textLayer.transform = CATransform3DMakeScale(0.5,0.5,1);
        self.textLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    }
}


- (void)setTitle:(NSString *)title keyWord:(NSString *)keyWord keyWordColor:(UIColor *)color font:(UIFont *)font
{
    if (!title || !color || !keyWord || !font) {
        return;
    }
    self.text = title;
    NSRange r = [title rangeOfString:keyWord];
    if (r.location == NSNotFound) {
        r = [title.uppercaseString rangeOfString:keyWord.uppercaseString];
    }
    if (r.location != NSNotFound) {
        if (r.location>0) {
            [self setColor:self.textColor fromIndex: 0 length:r.location];
        }
        [self setColor:color fromIndex: r.location length:r.length];
        CGFloat y = title.length - (r.length +r.location);
        if (y>0) {
            [self setColor:self.textColor fromIndex: r.location+r.length length:y];
        }
        [self setFont:font fromIndex:0 length:title.length];
    }
    else {
        [self setFont:font fromIndex:0 length:title.length];
        [self setColor:self.textColor fromIndex: 0 length:title.length];
    }
    [self setNeedsDisplay];
    
}

// 设置某段字的颜色
- (void)setColor:(UIColor *)color fromIndex:(NSInteger)location length:(NSInteger)length{
    if (location < 0||location>self.text.length-1||length+location>self.text.length) {
        return;
    }
    [_attString addAttribute:(NSString *)kCTForegroundColorAttributeName
                       value:(id)color.CGColor
                       range:NSMakeRange(location, length)];
}

// 设置某段字的字体
- (void)setFont:(UIFont *)font fromIndex:(NSInteger)location length:(NSInteger)length{
    if (location < 0||location>self.text.length-1||length+location>self.text.length) {
        return;
    }
    CTFontRef ctFont = CTFontCreateWithName((CFStringRef)font.fontName,
                                            font.pointSize*2,
                                            NULL);
    
    [_attString addAttribute:(NSString *)kCTFontAttributeName
                       value:(id)ctFont
                       range:NSMakeRange(location, length)];
    CFRelease(ctFont);
}

// 设置某段字的风格ager
- (void)setStyle:(CTUnderlineStyle)style fromIndex:(NSInteger)location length:(NSInteger)length{
    if (location < 0||location>self.text.length-1||length+location>self.text.length) {
        return;
    }
    [_attString addAttribute:(NSString *)kCTUnderlineStyleAttributeName
                       value:(id)[NSNumber numberWithInt:style]
                       range:NSMakeRange(location, length)];
}


@end
