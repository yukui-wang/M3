//
//  CMPIconFont.m
//  iconfont
//
//  Created by yang on 2017/2/13.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "CMPIconFont.h"
#import <CoreText/CoreText.h>
#import <CMPLib/CMPDBAppInfo.h>
#import <CMPLib/CMPAppManager.h>
@implementation CMPIconFont

static NSString *_fontName;

+ (void)registerFontWithURL:(NSURL *)url {
    
    NSAssert([[NSFileManager defaultManager] fileExistsAtPath:[url path]], @"Font file doesn't exist");
    CGDataProviderRef fontDataProvider = CGDataProviderCreateWithURL((__bridge CFURLRef)url);
    CGFontRef newFont = CGFontCreateWithDataProvider(fontDataProvider);
    CGDataProviderRelease(fontDataProvider);
    CTFontManagerRegisterGraphicsFont(newFont, nil);
    CGFontRelease(newFont);
}

+ (UIFont *)fontWithSize:(CGFloat)size {
    UIFont *font = [UIFont fontWithName:[self fontName] size:size];
    
    if (font == nil) {
        //        NSURL *fontFileUrl = [[NSBundle mainBundle] URLForResource:[self fontName] withExtension:@"ttf"];
        CMPDBAppInfo *appInfo = [CMPAppManager appInfoWithAppId:@"53"
                                                        version:@"v"
                                                       serverId:kCMP_ServerID
                                                         owerId:kCMP_OwnerID];
        NSString *aRootPath = [CMPAppManager documentWithPath:appInfo.path];
        if (aRootPath) {
            NSString *aPath = aRootPath;
            NSString *iconfontPath = [aPath stringByAppendingPathComponent:@"fonts/iconfont.ttf"];
            NSURL *fontFileUrl = [NSURL fileURLWithPath:iconfontPath];
            [self registerFontWithURL: fontFileUrl];
            font = [UIFont fontWithName:[self fontName] size:size];
            
            NSAssert(font, @"UIFont object should not be nil, check if the font file is added to the application bundle and you're using the correct font name.");
        }
    }
    return font;
}

+ (void)setFontName:(NSString *)fontName {
    
    _fontName = fontName;
    
}

+ (NSString *)fontName {
    return _fontName ? : @"iconfont";
}

@end
