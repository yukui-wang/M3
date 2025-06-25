//
//  CMPNetworkTipView.h
//  M3
//
//  Created by youlin on 2018/1/4.
//

#import <CMPLib/CMPBaseView.h>

@interface CMPNetworkTipView : CMPBaseView

- (instancetype)initWithFrame:(CGRect)frame andTip:(NSString *)tip;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UILabel *tipInfoLbl;


@end
