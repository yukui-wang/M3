//
//  CMPVideoSelectView.h
//  CMPLib
//
//  Created by MacBook on 2019/12/23.
//  Copyright © 2019 crmo. All rights reserved.
//

#import <CMPLib/CMPTopCornerView.h>
#import <CMPLib/CMPStringConst.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPVideoSelectView : CMPTopCornerView

- (void)setCanNotShare:(BOOL)canNotShare canNotCollect:(BOOL)canNotCollect canNotSave:(BOOL)canNotSave isUc:(BOOL)isUc;

/* 取消点击 */
@property (copy, nonatomic) void(^cancelClicked)(void);
/* msgMode用于转发、收藏 */
@property (weak, nonatomic) id msgModel;
/* url */
@property (copy, nonatomic) NSString *url;
/* 来源 */
@property (copy, nonatomic) NSString *from;
/* 来源类型 */
@property (copy, nonatomic) CMPFileFromType fromType;
/* fileId用于收藏 */
@property (copy, nonatomic) NSString *fileId;
/* fileName */
@property (copy, nonatomic) NSString *fileName;
/* vc */
@property (weak, nonatomic) UIViewController *vc;



@end

NS_ASSUME_NONNULL_END
