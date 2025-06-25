//
//  NSBundle+CMPImagePicker.h
//  CMPImagePickerController
//
//  Created by 谭真 on 16/08/18.
//  Copyright © 2016年 谭真. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSBundle (CMPImagePicker)

+ (NSBundle *)CMP_imagePickerBundle;

+ (NSString *)CMP_localizedStringForKey:(NSString *)key value:(NSString *)value;
+ (NSString *)CMP_localizedStringForKey:(NSString *)key;

@end

