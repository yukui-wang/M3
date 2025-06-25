/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManager.h>
#import <CordovaLib/CDVPlugin.h>
//#import "TZImagePickerController.h"
#import <CMPLib/CMPImagePickerController.h>

#define iOS7Later ([UIDevice currentDevice].systemVersion.floatValue >= 7.0f)
#define iOS8Later ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f)
#define iOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)
#define iOS9_1Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.1f)

#define kImageLimitSize  10*1024*1024

enum CDVDestinationType {
    DestinationTypeDataUrl = 0,
    DestinationTypeFileUri,
    DestinationTypeNativeUri
};
typedef NSUInteger CDVDestinationType;

enum CDVEncodingType {
    EncodingTypeJPEG = 0,
    EncodingTypePNG
};
typedef NSUInteger CDVEncodingType;

enum CDVMediaType {
    MediaTypePicture = 0,
    MediaTypeVideo,
    MediaTypeAll
};
typedef NSUInteger CDVMediaType;

@interface TZPictureOptions : NSObject

@property (strong) NSNumber* quality;
@property (assign) CDVDestinationType destinationType;
@property (assign) UIImagePickerControllerSourceType sourceType;
@property (strong) NSNumber* sourceTypeNumber;
@property (assign) CGSize targetSize;
@property (assign) CDVEncodingType encodingType;
@property (assign) CDVMediaType mediaType;
@property (assign) BOOL allowsEditing;
@property (assign) BOOL correctOrientation;
@property (assign) BOOL saveToPhotoAlbum;
@property (strong) NSDictionary* popoverOptions;
@property (assign) UIImagePickerControllerCameraDevice cameraDirection;

@property (assign) BOOL popoverSupported;
@property (assign) BOOL usesGeolocation;
@property (assign) BOOL cropToSize;
@property (assign) NSInteger pictureNum;
@property (assign) NSInteger maxFileSize;//图片大小限制，默认5M

@property (nonatomic, strong) NSDictionary *moreParam;

@property (assign, nonatomic) BOOL rename; // 是否可以重命名图片

@property (nonatomic,assign)BOOL isOnlyNeedRatioSquare;// 是否正方形等比例裁剪

+ (instancetype) createFromTakePictureArguments:(CDVInvokedUrlCommand*)command;

@end


@interface TZImagePicker : UIImagePickerController

@property (strong) TZPictureOptions* pictureOptions;

@property (copy)   NSString* callbackId;
@property (copy)   NSString* postUrl;
@property (strong) UIPopoverController* pickerPopoverController;
@property (assign) BOOL cropToSize;
@property (strong) UIView* webView;

+ (instancetype) createFromPictureOptions:(TZPictureOptions*)pictureOptions;

@end

@interface TZCameraPicker : CMPImagePickerController

@property (strong) TZPictureOptions* pictureOptions;

@property (copy)   NSString* callbackId;
@property (copy)   NSString* postUrl;
@property (strong) UIPopoverController* pickerPopoverController;
@property (assign) BOOL cropToSize;
@property (strong) UIView* webView;
@property (nonatomic,assign)BOOL isOnlyNeedRatioSquare;
//@property (nonatomic,weak)id delegate;

- (UIImagePickerControllerSourceType)sourceType;

+ (instancetype) createFromPictureOptions:(TZPictureOptions*)pictureOptions delegate:(id)delegate;

@end

// ======================================================================= //

@interface TZCamera : CDVPlugin <UIImagePickerControllerDelegate,
                       UINavigationControllerDelegate,
                       UIPopoverControllerDelegate,
                       CLLocationManagerDelegate,
                       CMPImagePickerControllerDelegate>
{}

@property (strong) TZCameraPicker* pickerController;
@property (strong) NSMutableDictionary *metadata;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong) NSData* data;

/*
 * getPicture
 *
 * arguments:
 *    1: this is the javascript function that will be called with the results, the first parameter passed to the
 *        javascript function is the picture as a Base64 encoded string
 *  2: this is the javascript function to be called if there was an error
 * options:
 *    quality: integer between 1 and 100
 */
- (void)takePicture:(CDVInvokedUrlCommand*)command;
- (void)cleanup:(CDVInvokedUrlCommand*)command;
- (void)repositionPopover:(CDVInvokedUrlCommand*)command;

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info;
- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingImage:(UIImage*)image editingInfo:(NSDictionary*)editingInfo;
- (void)imagePickerControllerDidCancel:(UIImagePickerController*)picker;
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated;

- (void)locationManager:(CLLocationManager*)manager didUpdateToLocation:(CLLocation*)newLocation fromLocation:(CLLocation*)oldLocation;
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error;

@end
