//
//  KSLabel.h
//  XGiant
//
//  Created by Songu Kaku on 5/17/19.
//  Copyright © 2019 com.xinjucn. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KSLabel : UILabel
@property (assign, nonatomic) UIEdgeInsets edgeInsets;
@property (nonatomic,strong) CAShapeLayer *borderLayer;
@end

NS_ASSUME_NONNULL_END
