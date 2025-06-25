//
//  SyHandWriteSignatureView.h
//  M1IPhone
//
//  Created by guoyl on 13-5-7.
//  Copyright (c) 2013年 北京致远协创软件有限公司. All rights reserved.
//


#define kSegmentedItemTag_DeleteSignatureButton 10003
#define kSegmentedItemTag_SignatureButton 10004


#import "CMPBaseView.h"
#import "SyHandWriteView.h"
#import "SySegmentedControl.h"
#import "SyColorPickerView.h"

@interface SyHandWriteSignatureView : CMPBaseView
{
    SyHandWriteView *_handWriteView;
    SySegmentedControl *_bottomSegControl;
    SyColorPickerView *_colorPickerView;
}

@property (nonatomic, readonly)SyHandWriteView *handWriteView;
@property (nonatomic, readonly)SySegmentedControl *bottomSegControl;
@property (nonatomic, assign)BOOL deleteSignatureButtonHidden;
@property (nonatomic, assign)BOOL signatureButtonHidden;

- (void)setupWithInitSize:(CGSize )aInitSize;
+ (void)removeUserColorsRecord;
- (void)addSignatureImageWithBase64Str:(NSString *)value;
- (void)showColorPickerView:(id)sender;
- (void)deleteSignatureImage;
- (void)clear;

@end
