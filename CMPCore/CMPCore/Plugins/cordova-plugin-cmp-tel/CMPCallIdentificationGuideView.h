//
//  CMPCallIdentificationGuideView.h
//  M3
//
//  Created by CRMO on 2018/4/12.
//

#import <CMPLib/CMPBaseView.h>

@interface CMPCallIdentificationGuideView : CMPBaseView

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *firstStepLabel;
@property (strong, nonatomic) UIImageView *firstStepImage;
@property (strong, nonatomic) UILabel *secondStepLabel;
@property (strong, nonatomic) UIImageView *secondStepImage;
@property (strong, nonatomic) UIButton *closeButton;
@property (strong, nonatomic) UIButton *kownButton;

@end
