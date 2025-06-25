//
//  AttachmentReaderView.h
//  HelloCordova
//
//  Created by lin on 15/8/20.
//
//

#import <CMPLib/CMPBaseView.h>

typedef NS_ENUM(NSInteger, CMPOpenFileErrorType) {
    CMPOpenFileErrorTypeUnknown     = 0,
    CMPOpenFileErrorTypeUnZipFail   = 1,
};


@interface AttachmentReaderView : CMPBaseView


/**
 提示文件打开异常提示
 */
- (void)showOpenFileErrorType:(CMPOpenFileErrorType)type;

@end
