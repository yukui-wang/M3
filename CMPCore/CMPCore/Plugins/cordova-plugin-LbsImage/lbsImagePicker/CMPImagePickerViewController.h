//
//  ViewController.h
//  photographDemo
//
//  Created by liguohuai on 16/4/3.
//  Copyright © 2015年 Renford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "SyReverseGeocoder.h"

@protocol CMPImagePickerViewControllerDelegate;
@interface CMPImagePickerViewController : UIViewController
@property(nonatomic, weak)id<CMPImagePickerViewControllerDelegate> delegate;
@property(nonatomic, copy)NSString *userName;
@property(nonatomic, copy)NSString *serverDateUrl;
@property(nonatomic, copy)NSString *serverDate;
@property(nonatomic, copy)NSString *location;
+ (BOOL)canUserCamear;
@end

@protocol CMPImagePickerViewControllerDelegate <NSObject>

- (void)imagePickerController:(CMPImagePickerViewController *)picker didFinishPickingImagePath:(NSString *)imagePath  withAddress:(SyAddress *)aAddress currentLoaction:(CLLocation *)aLocation ;
- (void)imagePickerControllerDidCancel:(CMPImagePickerViewController *)picker;
- (void)imagePickerControllerHasNotLocationPermission:(CMPImagePickerViewController *)picker;


@end
