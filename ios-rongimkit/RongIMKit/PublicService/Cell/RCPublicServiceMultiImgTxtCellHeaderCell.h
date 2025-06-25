//
//  RCPublicServiceMultiImgTxtCellHeaderCell.h
//  RongIMKit
//
//  Created by litao on 15/4/15.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCMessageCellDelegate.h"
#import <RongIMLib/RongIMLib.h>
#import <UIKit/UIKit.h>

@protocol RCPublicServiceMultiImgTxtCellHeaderCellDelegate <NSObject>

- (void)longPressAction:(UITableViewCell *)cell;

@end

@interface RCPublicServiceMultiImgTxtCellHeaderCell : UITableViewCell
@property (nonatomic, weak) id<RCPublicServiceMessageCellDelegate> publicServiceDelegate;
@property (nonatomic, weak) id<RCPublicServiceMultiImgTxtCellHeaderCellDelegate> delegate;
@property (nonatomic, strong) RCMessageModel *model;
- (instancetype)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier;
@property (strong, nonatomic) RCRichContentMessage *richContent;
+ (CGFloat)getHeaderCellHeightWithWidth:(CGFloat)width;
@end
