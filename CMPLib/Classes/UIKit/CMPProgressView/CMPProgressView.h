//
//  UIProgressBar.h
//  
//
//  Created by xiangwei.ma
//  
//

#import <UIKit/UIKit.h>

@interface CMPProgressView : UIView
{
	float minValue, maxValue;
	float currentValue;
	UIColor *lineColor, *progressRemainingColor, *progressColor;
}

@property (nonatomic, assign) float minValue, maxValue, currentValue;
@property (nonatomic, retain) UIColor *lineColor, *progressRemainingColor, *progressColor;
@property(nonatomic) float progress;

- (void)setNewRect:(CGRect)newFrame;

@end
