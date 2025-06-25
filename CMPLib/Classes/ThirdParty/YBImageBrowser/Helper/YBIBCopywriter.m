//
//  YBIBCopywriter.m
//  YBImageBrowserDemo
//
//  Created by 杨波 on 2018/9/13.
//  Copyright © 2018年 杨波. All rights reserved.
//

#import "YBIBCopywriter.h"
#import "CMPConstant.h"

@implementation YBIBCopywriter

#pragma mark - life cycle

+ (instancetype)shareCopywriter {
    YBIBCopywriter *copywriter = [YBIBCopywriter new];
    return copywriter;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        YBIBCopywriterType type = YBIBCopywriterTypeSimplifiedChinese;
        NSArray *appleLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
        if (appleLanguages && appleLanguages.count > 0) {
            NSString *languages = appleLanguages[0];
            if (![languages isEqualToString:@"zh-Hans-CN"]) {
                type = YBIBCopywriterTypeEnglish;
            }
        }
        self.type = type;
            
        [self initCopy];
    }
    return self;
}

#pragma mark - private

- (void)initCopy {
    self.videoIsInvalid =  SY_STRING(@"review_image_videoIsInvalid");
    self.videoError = SY_STRING(@"review_image_videoError");
    self.unableToSave = SY_STRING(@"review_image_unableToSave");
    self.imageIsInvalid = SY_STRING(@"review_image_imageIsInvalid");
    self.downloadImageFailed = SY_STRING(@"review_image_downloadImageFailed");
    self.getPhotoAlbumAuthorizationFailed = SY_STRING(@"review_image_getPhotoAlbumAuthorizationFailed");
    self.saveToPhotoAlbumSuccess = SY_STRING(@"review_image_saveToPhotoAlbumSuccess");
    self.saveToPhotoAlbumFailed = SY_STRING(@"review_image_saveToPhotoAlbumFailed");
    self.saveToPhotoAlbum = SY_STRING(@"common_save");
    self.cancel = SY_STRING(@"common_cancel");
    self.viewOriginalPhoto = SY_STRING(@"review_image_viewOriginalPhoto");
    self.printPhoto = SY_STRING(@"print_action");
    self.collectPhoto = SY_STRING(@"share_btn_collect");
    self.forwardPhoto = SY_STRING(@"share_btn_share");
    self.indentifyQRCode = SY_STRING(@"review_image_recognizeQRCode_in_pic");
}

#pragma mark - public

- (void)setType:(YBIBCopywriterType)type {
    _type = type;
    [self initCopy];
}


@end
