//
//  SySegmentedItemAttribute.m
//  M1Core
//
//  Created by guoyl on 12-12-27.
//  Copyright (c) 2012年 北京致远协创软件有限公司. All rights reserved.
//

#import "SySegmentedItemAttribute.h"
#import "UIImage+CMPImage.h"
@implementation SySegmentedItemAttribute
@synthesize title = _title;
@synthesize image = _image;
@synthesize userInfo = _userInfo;
@synthesize rightImage = _rightImage;
@synthesize rightSelectedImage = _rightSelectedImage;
@synthesize titleFont = _titleFont;
@synthesize titleColor = _titleColor; // 标题颜色
@synthesize selectedTitleFont = _selectedTitleFont;
@synthesize selectedTitleColor = _selectedTitleColor;
@synthesize rightImageEdgeInsets = _rightImageEdgeInsets; 
@synthesize selectedBackgroundImage = _selectedBackgroundImage;
@synthesize backgroundImage = _backgroundImage;
@synthesize imageEdgeInsets = _imageEdgeInsets;
@synthesize bottomImage = _bottomImage;
@synthesize selectedBottomImage = _selectedBottomImage;
@synthesize marginTitleAndImage = _marginTitleAndImage;
@synthesize titleEdgeInsets = _titleEdgeInsets;
@synthesize segmentedItemTag = _segmentedItemTag;
@synthesize viewType = _viewType;

- (void)dealloc 
{
    [_title release];
    [_image release];
    [_userInfo release];
    
    [_rightImage release];
    [_rightSelectedImage release];
    [_titleFont release];
    [_titleColor release];
    
    [_selectedTitleFont release];
    [_selectedTitleColor release];
    [_selectedBackgroundImage release];
    [_backgroundImage release];
    
    [_bottomImage release];
    [_selectedBottomImage release];
    
    [super dealloc];
}

- (id)init 
{
    self = [super init];
    if (self) {
        self.titleColor = [UIColor blackColor];
        self.titleFont = [UIFont systemFontOfSize:14.0];
        self.selectedTitleFont = [UIFont boldSystemFontOfSize:14.0];
        self.selectedBackgroundImage = [[UIImage imageWithColor:UIColorFromRGB(0xe7ecf2)] stretchableImageWithLeftCapWidth:10
                                                                                                      topCapHeight:0];
        self.backgroundImage = [[UIImage imageWithColor:UIColorFromRGB(0xe7ecf2)] stretchableImageWithLeftCapWidth:2
                                                                                           topCapHeight:0.0];
        self.marginTitleAndImage = 5.0f;
         _viewType = SySegmentedItemAttribute_Type_Normal;
    }
    return self;
}
- (void)setViewType:(NSInteger)viewType
{
    _viewType = viewType;
    if (_viewType == SySegmentedItemAttribute_Type_Blue) {
        self.backgroundImage = [[UIImage imageNamed:@"SySegmentedControl.bundle/tab_normal.png"] stretchableImageWithLeftCapWidth:2
                                                                                           topCapHeight:0.0];
        self.selectedBackgroundImage = [[UIImage imageNamed:@"SySegmentedControl.bundle/tab_normal_pressdown.png"] stretchableImageWithLeftCapWidth:10
                                                                                                      topCapHeight:0];

    }
    else if (_viewType == SySegmentedItemAttribute_Type_Normal)
    {
        self.backgroundImage = [UIImage imageNamed:@"SySegmentedControl.bundle/seg_bg.png"]/*[[UIImage imageWithColor:UIColorFromRGB(0xe7ecf2)] stretchableImageWithLeftCapWidth:2
                                                                                           topCapHeight:0.0]*/;
        NSString *pngName = nil;
        if(_position == SySegmentedItemAttribute_Position_First){
            pngName = @"SySegmentedControl.bundle/seg_left_selected.png";
        }else if(_position == SySegmentedItemAttribute_Position_Middle){
            pngName = @"SySegmentedControl.bundle/seg_mid_selected.png";
        }else if(_position == SySegmentedItemAttribute_Position_Last){
            pngName = @"SySegmentedControl.bundle/seg_right_selected.png";
        }
        if(pngName){
            self.selectedBackgroundImage = [UIImage imageNamed:pngName] ;
        }
    }else if(_viewType == SySegmentedItemAttribute_Type_Wathet){
        
        self.backgroundImage = [[UIImage imageWithColor:UIColorFromRGB(0xe7ecf2)] stretchableImageWithLeftCapWidth:2
                                                                                                      topCapHeight:0.0];
        
        self.selectedBackgroundImage = [[UIImage imageWithColor:UIColorFromRGB(0xf1f3f7)] stretchableImageWithLeftCapWidth:10
                                                                                                              topCapHeight:0];
    }
}
- (void)setPostion:(SySegmentedItemAttribute_Position )position
{
    if(_viewType == SySegmentedItemAttribute_Type_Wathet){
        
        NSString *pngName = nil;
        if(position == SySegmentedItemAttribute_Position_First){
            pngName = @"SySegmentedControl.bundle/seg_left_selected.png";
        }else if(position == SySegmentedItemAttribute_Position_Middle){
            pngName = @"SySegmentedControl.bundle/seg_mid_selected.png";
        }else if(position == SySegmentedItemAttribute_Position_Last){
            pngName = @"SySegmentedControl.bundle/seg_right_selected.png";
        }
        if(pngName){
            self.selectedBackgroundImage = [UIImage imageNamed:pngName];

        }
    }
}
@end
