//
//  CMPFontModel.h
//  CMPLib
//
//  Created by 程昆 on 2018/12/25.
//  Copyright © 2018 CMPCore. All rights reserved.
//

typedef NS_ENUM(NSUInteger,FontType){
    
    FontTypeNarrow,
    FontTypeStandard,
    FontTypeExpandOne,
    FontTypeExpandTwo
};

#import "CMPObject.h"

@interface CMPFontModel : CMPObject

@property (nonatomic,assign,readonly)CGFloat headtitleFontSize;
@property (nonatomic,assign,readonly)CGFloat headlinesFontSize;
@property (nonatomic,assign,readonly)CGFloat listHeadlinesFontSize;
@property (nonatomic,assign,readonly)CGFloat bodyFontSize;
@property (nonatomic,assign,readonly)CGFloat supportingFontSize;
@property (nonatomic,assign,readonly)FontType fontType;

+(instancetype)fontModel;

-(void)setMinStandardFontSize:(CGFloat)size;

@end


