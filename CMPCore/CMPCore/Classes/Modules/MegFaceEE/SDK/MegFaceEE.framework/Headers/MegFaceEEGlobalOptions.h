//
//  MegFaceEEGlobalOptions.h
//  MegFaceEE
//
//  Created by Megvii on 2023/2/23.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MegFaceEE/MegLiveV5DetectItem.h>

NS_ASSUME_NONNULL_BEGIN

@interface MegFaceEEGlobalOptions : NSObject

@property (nonatomic, strong) UIColor *themeColor;
@property (nonatomic, strong) MegLiveV5DetectUIConfigItem *v5UIConfig;

@end

NS_ASSUME_NONNULL_END
