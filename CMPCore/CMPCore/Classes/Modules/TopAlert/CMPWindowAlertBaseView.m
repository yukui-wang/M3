//
//  CMPWindowAlertBaseView.m
//  M3
//
//  Created by Kaku Songu on 12/1/22.
//

#import "CMPWindowAlertBaseView.h"

@implementation CMPWindowAlertBaseView

-(void)setup
{
    [super setup];
    _defaultDismissTime = 5;
}

-(CGFloat)defaultHeight
{
    return 140;
}

-(CMPDirection)defaultShowDirection
{
    return CMPDirection_Top;
}

-(CMPDirection)defaultDismissDirection
{
    return CMPDirection_Top;
}

@end
