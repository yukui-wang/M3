//
//  BFCircleView.h
//  M3
//
//  Created by wujiansheng on 2018/12/12.
//

#import <UIKit/UIKit.h>

//#define OutSideColor [UIColor colorWithRed:0.0 green:0.6 blue:1.0 alpha:1]
#define OutSideColor [UIColor colorWithRed:246/255.0 green:166/255.0 blue:35/255.0 alpha:1]
//#define BackgroundColor [UIColor colorWithRed:47/255.0 green:47/255.0 blue:51/255.0 alpha:1]
#define BackgroundColor [UIColor whiteColor]
@interface BFCircleView : UIView

@property (nonatomic, assign) CGRect circleRect;

@property (nonatomic, assign) BOOL conditionStatusFit;

@end
