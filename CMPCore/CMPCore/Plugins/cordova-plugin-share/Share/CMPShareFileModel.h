//
//  CMPShareFileModel.h
//  M3
//
//  Created by MacBook on 2019/11/4.
//

#import <Foundation/Foundation.h>
#import <CordovaLib/CDVCommandDelegate.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPShareFileModel : NSObject

/* shareBtnList */
@property (strong, nonatomic) NSArray *shareBtnList;
/* 回调的commandId */
@property (copy, nonatomic) NSString *commandId;
/* commandDelegate */
@property (strong, nonatomic) id<CDVCommandDelegate> commandDelegate;

/* shareOtherBtnList */
@property (strong, nonatomic) NSArray *shareOtherBtnList;

/* businessBtnList */
@property (strong, nonatomic) NSArray *businessBtnList;

@end

@interface CMPShareBtnModel : NSObject

/* appId */
@property (copy, nonatomic) NSString *appId;
/* icon */
@property (copy, nonatomic) NSString *icon;
/* shareToH5App/download/collect/print/wechat/QQ/otherApp */
@property (copy, nonatomic) NSString *type;
/* img */
@property (copy, nonatomic) NSString *img;
/* title */
@property (copy, nonatomic) NSString *title;
/* key */
@property (copy, nonatomic) NSString *key;

@property (copy, nonatomic) NSDictionary *param;

@end

NS_ASSUME_NONNULL_END
