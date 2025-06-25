//
//  CMPFontModel.m
//  CMPLib
//
//  Created by 程昆 on 2018/12/25.
//  Copyright © 2018 CMPCore. All rights reserved.
//

#import "CMPFontModel.h"
#import "CMPFontProvider.h"

@implementation CMPFontModel

+(instancetype)fontModel{
    
    CMPFontModel *model = [[CMPFontModel alloc]init];

    CGFloat fontSize  = KMinStandardFontSize;
    
    model->_supportingFontSize = fontSize;
    model->_bodyFontSize = fontSize + 2.0f;
    model->_listHeadlinesFontSize = fontSize + 4.0f;
    model->_headlinesFontSize = fontSize + 6.0f;
    model->_headtitleFontSize = fontSize + 8.0f;
    model->_fontType = FontTypeStandard;
    return model;
}

-(void)setMinStandardFontSize:(CGFloat)size{
    
    _supportingFontSize = size;
    _bodyFontSize = size + 2.0f;
    _listHeadlinesFontSize = size + 4.0f;
    _headlinesFontSize = size + 6.0f;
    _headtitleFontSize = size + 8.0f;
    
    if (size == 10.0f) {
        
        _fontType = FontTypeNarrow;
        
    }else if (size == 12.0f){
        
        _fontType = FontTypeStandard;
        
    }else if (size == 14.0f){
        
        _fontType = FontTypeExpandOne;
        
    }else if (size == 16.0f){
        
        _fontType = FontTypeExpandTwo;
        
    }
    
}

@end
