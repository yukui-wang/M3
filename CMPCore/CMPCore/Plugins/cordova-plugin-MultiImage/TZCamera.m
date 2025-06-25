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

#import "TZCamera.h"
#import <CMPLib/UIImage+CropScaleOrientation.h>
#import <ImageIO/CGImageProperties.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/CGImageSource.h>
#import <ImageIO/CGImageProperties.h>
#import <ImageIO/CGImageDestination.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <objc/message.h>
#import <CMPLib/NSString+CMPString.h>
#import <Photos/Photos.h>
#import <CMPLib/UIImage+CMPImage.h>

#import <CMPLib/CMPConstant.h>

#import <CMPLib/CMPDevicePermissionHelper.h>
#ifndef __CORDOVA_4_0_0
    #import <CordovaLib/NSData+Base64.h>
#endif

#define CDV_PHOTO_PREFIX @"photo_"

#import "PureCamera.h"

static NSSet* org_apache_cordova_validArrowDirections;

static NSString* toBase64(NSData* data) {
    SEL s1 = NSSelectorFromString(@"cdv_base64EncodedString");
    SEL s2 = NSSelectorFromString(@"base64EncodedString");
    SEL s3 = NSSelectorFromString(@"base64EncodedStringWithOptions:");
    
    if ([data respondsToSelector:s1]) {
        NSString* (*func)(id, SEL) = (void *)[data methodForSelector:s1];
        return func(data, s1);
    } else if ([data respondsToSelector:s2]) {
        NSString* (*func)(id, SEL) = (void *)[data methodForSelector:s2];
        return func(data, s2);
    } else if ([data respondsToSelector:s3]) {
        NSString* (*func)(id, SEL, NSUInteger) = (void *)[data methodForSelector:s3];
        return func(data, s3, 0);
    } else {
        return nil;
    }
}

@implementation TZPictureOptions

+ (instancetype) createFromTakePictureArguments:(CDVInvokedUrlCommand*)command
{
    TZPictureOptions* pictureOptions = [[TZPictureOptions alloc] init];
    pictureOptions.quality = [command argumentAtIndex:0 withDefault:@(50)];
    pictureOptions.destinationType = [[command argumentAtIndex:1 withDefault:@(DestinationTypeFileUri)] unsignedIntegerValue];
    //pictureOptions.sourceType = [[command argumentAtIndex:2 withDefault:@(UIImagePickerControllerSourceTypeCamera)] unsignedIntegerValue];
    pictureOptions.sourceTypeNumber = [command argumentAtIndex:2 withDefault:nil];
        switch ([pictureOptions.sourceTypeNumber intValue]) {
            case 1:
                pictureOptions.sourceType = UIImagePickerControllerSourceTypeCamera;
                break;
            case 2:
                pictureOptions.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                break;
            case 3:
                pictureOptions.sourceType = UIImagePickerControllerSourceTypeCamera;
                break;
            case 4:
                pictureOptions.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                break;
            default:
                break;
        }

    NSNumber* targetWidth = [command argumentAtIndex:3 withDefault:nil];
    NSNumber* targetHeight = [command argumentAtIndex:4 withDefault:nil];
    pictureOptions.targetSize = CGSizeMake(0, 0);
    if ((targetWidth != nil) && (targetHeight != nil)) {
        pictureOptions.targetSize = CGSizeMake([targetWidth floatValue], [targetHeight floatValue]);
    }

    pictureOptions.encodingType = [[command argumentAtIndex:5 withDefault:@(EncodingTypeJPEG)] unsignedIntegerValue];
    pictureOptions.mediaType =  [[command argumentAtIndex:6 withDefault:@(MediaTypePicture)] unsignedIntegerValue];
    pictureOptions.allowsEditing = [[command argumentAtIndex:7 withDefault:@(NO)] boolValue];
    pictureOptions.correctOrientation = [[command argumentAtIndex:8 withDefault:@(NO)] boolValue];
    pictureOptions.saveToPhotoAlbum = [[command argumentAtIndex:9 withDefault:@(NO)] boolValue];
    pictureOptions.popoverOptions = [command argumentAtIndex:10 withDefault:nil];
    pictureOptions.cameraDirection = [[command argumentAtIndex:11 withDefault:@(UIImagePickerControllerCameraDeviceRear)] unsignedIntegerValue];
    pictureOptions.pictureNum = [[command argumentAtIndex:12 withDefault:@(1)] unsignedIntegerValue];
 
    pictureOptions.popoverSupported = NO;
    pictureOptions.usesGeolocation = NO;
    pictureOptions.isOnlyNeedRatioSquare = YES;
    
    if ([command arguments].count > 13) {
        pictureOptions.maxFileSize = [[command argumentAtIndex:13 withDefault:@(kImageLimitSize)] integerValue];
    }
    
    if ([command arguments].count > 14) {
        pictureOptions.rename = [[command argumentAtIndex:14 withDefault:@(NO)] boolValue];
    }
    
    if ([command arguments].count > 15) {
        id obj = [command argumentAtIndex:15 withDefault:@(YES)];
        if (![obj isKindOfClass:NSDictionary.class]) {
            pictureOptions.isOnlyNeedRatioSquare = [obj boolValue];
        }
    }
    
    if ([[command arguments].lastObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = [[command arguments].lastObject copy];
        pictureOptions.moreParam = dict;
    }

    return pictureOptions;
}

@end

@implementation TZImagePicker

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (UIViewController*)childViewControllerForStatusBarHidden
{
    return nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    SEL sel = NSSelectorFromString(@"setNeedsStatusBarAppearanceUpdate");
    if ([self respondsToSelector:sel]) {
        [self performSelector:sel withObject:nil afterDelay:0];
    }
    
    [super viewWillAppear:animated];
}

+ (instancetype) createFromPictureOptions:(TZPictureOptions*)pictureOptions
{
    TZImagePicker* cameraPicker = [[TZImagePicker alloc] init];
    cameraPicker.pictureOptions = pictureOptions;
    cameraPicker.sourceType = pictureOptions.sourceType;
    cameraPicker.allowsEditing = pictureOptions.allowsEditing;
    
    if (pictureOptions.mediaType == MediaTypePicture && pictureOptions.sourceType == UIImagePickerControllerSourceTypeCamera) {
        // We only allow taking pictures (no video) in this API.
        cameraPicker.mediaTypes = @[(NSString*)kUTTypeImage];
        // We can only set the camera device if we're actually using the camera.
        cameraPicker.cameraDevice = pictureOptions.cameraDirection;
    } else if (pictureOptions.mediaType == MediaTypeAll) {
        cameraPicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:cameraPicker.sourceType];
    } else {
        NSArray* mediaArray = @[(NSString*)(pictureOptions.mediaType == MediaTypeVideo ? kUTTypeMovie : kUTTypeImage)];
        cameraPicker.mediaTypes = mediaArray;
    }
    
    return cameraPicker;
}
@end

@implementation TZCameraPicker

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (UIViewController*)childViewControllerForStatusBarHidden
{
    return nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    SEL sel = NSSelectorFromString(@"setNeedsStatusBarAppearanceUpdate");
    if ([self respondsToSelector:sel]) {
        [self performSelector:sel withObject:nil afterDelay:0];
    }
    
    [super viewWillAppear:animated];
}

+ (instancetype) createFromPictureOptions:(TZPictureOptions*)pictureOptions delegate:(id)delegate;
{
    TZCameraPicker* cameraPicker = [[TZCameraPicker alloc] initWithMaxImagesCount:pictureOptions.pictureNum delegate:delegate];
//    TZCameraPicker* cameraPicker = [[TZCameraPicker alloc] initWithMaxImagesCount:pictureOptions.pictureNum moreParam:pictureOptions.moreParam delegate:delegate];
    BOOL allowPickingVideo = NO;
    BOOL allowTakeVideo = NO;
    NSString *extension = pictureOptions.moreParam[@"type"];
    
    if (!(extension && extension.length > 0) && ([pictureOptions.sourceTypeNumber intValue] == 4)) {
        allowPickingVideo = YES;
    }
    if ([pictureOptions.sourceTypeNumber intValue] == 3) {
        allowTakeVideo = YES;
    }
    cameraPicker.allowPickingVideo = allowPickingVideo;
    cameraPicker.allowTakeVideo = allowTakeVideo;
    cameraPicker.pictureOptions = pictureOptions;
    cameraPicker.allowPickingMultipleVideo = YES;
    
//    cameraPicker.maxFileSize = pictureOptions.maxFileSize;
    cameraPicker.allowCrop = pictureOptions.allowsEditing;
    return cameraPicker;
}
- (UIImagePickerControllerSourceType)sourceType
{
    return self.pictureOptions.sourceType;
}
@end

@interface TZCamera ()<PureCameraDelegate>

@property (readwrite, assign) BOOL hasPendingOperation;

@end

@implementation TZCamera

+ (void)initialize
{
    org_apache_cordova_validArrowDirections = [[NSSet alloc] initWithObjects:[NSNumber numberWithInt:UIPopoverArrowDirectionUp], [NSNumber numberWithInt:UIPopoverArrowDirectionDown], [NSNumber numberWithInt:UIPopoverArrowDirectionLeft], [NSNumber numberWithInt:UIPopoverArrowDirectionRight], [NSNumber numberWithInt:UIPopoverArrowDirectionAny], nil];
}

@synthesize hasPendingOperation, pickerController, locationManager;

- (NSURL*) urlTransformer:(NSURL*)url
{
    NSURL* urlToTransform = url;
    
    // for backwards compatibility - we check if this property is there
    SEL sel = NSSelectorFromString(@"urlTransformer");
    if ([self.commandDelegate respondsToSelector:sel]) {
        // grab the block from the commandDelegate
        NSURL* (^urlTransformer)(NSURL*) = ((id(*)(id, SEL))objc_msgSend)(self.commandDelegate, sel);
        // if block is not null, we call it
        if (urlTransformer) {
            urlToTransform = urlTransformer(url);
        }
    }
    
    return urlToTransform;
}

- (BOOL)usesGeolocation
{
    id useGeo = [self.commandDelegate.settings objectForKey:[@"CameraUsesGeolocation" lowercaseString]];
    return [(NSNumber*)useGeo boolValue];
}

- (BOOL)popoverSupported
{
    return NO;
    return (NSClassFromString(@"UIPopoverController") != nil) &&
           (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}
- (BOOL)authorizationStatusDenied {
    if (iOS8Later) {
        if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusDenied) return YES;
    } else {
        if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusDenied) return YES;
    }
    return NO;
}

- (void)takePicture:(CDVInvokedUrlCommand*)command
{
    NSArray *arguments = command.arguments;
    NSMutableArray *mArr = [NSMutableArray arrayWithArray:arguments];
    for (int i=0; i< mArr.count; i++ ) {
        id arg = mArr[i];
        if (i == 2) {//sourceType,V5-45878 兼容处理，只兼容这一个，因为前端过来的现在有点乱但也改了
            if ([arg isKindOfClass:[NSString class]]) {
                if (((NSString *)arg).length && [NSString isNumber:arg]) {
                    arg = [NSNumber numberWithInteger:((NSString *)arg).integerValue];
                    [mArr replaceObjectAtIndex:i withObject:arg];
                }
            }
        }
        if ([arg isKindOfClass:[NSString class]]) {
            CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"参数错误：参数里包含字符串。"];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            return;
        }
    }
    arguments = mArr;
//    for (id argument in arguments) {
//        if ([argument isKindOfClass:[NSString class]]) {
//            CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"参数错误：参数里包含字符串。"];
//            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
//            return;
//        }
//    }
    
    self.hasPendingOperation = YES;
    
    __weak TZCamera* weakSelf = self;
//    [self.commandDelegate runInBackground:^{
        
        TZPictureOptions* pictureOptions = [TZPictureOptions createFromTakePictureArguments:command];
        pictureOptions.popoverSupported = [weakSelf popoverSupported];
        pictureOptions.usesGeolocation = [weakSelf usesGeolocation];
        pictureOptions.cropToSize = NO;
        
        void (^takePictureBlock)(void) = ^(void) {
            TZCameraPicker* cameraPicker = nil;
            if (pictureOptions.sourceType == UIImagePickerControllerSourceTypeCamera || pictureOptions.mediaType ==MediaTypeVideo ) {
                if (pictureOptions.allowsEditing) {
                    cameraPicker = (TZCameraPicker*)[PureCamera createFromPictureOptions:pictureOptions];
                    cameraPicker.isOnlyNeedRatioSquare = pictureOptions.isOnlyNeedRatioSquare;
                }else{
                    cameraPicker = (TZCameraPicker *)[TZImagePicker createFromPictureOptions:pictureOptions];
                }
            }
            else {
                cameraPicker = [TZCameraPicker createFromPictureOptions:pictureOptions delegate:weakSelf];
            }
            weakSelf.pickerController = cameraPicker;
            cameraPicker.delegate = weakSelf;
            cameraPicker.callbackId = command.callbackId;
            // we need to capture this state for memory warnings that dealloc this object
            cameraPicker.webView = weakSelf.webView;
            
            // Perform UI operations on the main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                // If a popover is already open, close it; we only want one at a time.
                if (([[weakSelf pickerController] pickerPopoverController] != nil) && [[[weakSelf pickerController] pickerPopoverController] isPopoverVisible]) {
                    [[[weakSelf pickerController] pickerPopoverController] dismissPopoverAnimated:YES];
                    [[[weakSelf pickerController] pickerPopoverController] setDelegate:nil];
                    [[weakSelf pickerController] setPickerPopoverController:nil];
                }
                
                if ([weakSelf popoverSupported] && (pictureOptions.sourceType != UIImagePickerControllerSourceTypeCamera)) {
                    if (cameraPicker.pickerPopoverController == nil) {
                        cameraPicker.pickerPopoverController = [[NSClassFromString(@"UIPopoverController") alloc] initWithContentViewController:cameraPicker];
                    }
                    [weakSelf displayPopover:pictureOptions.popoverOptions];
                    weakSelf.hasPendingOperation = NO;
                } else {
                    [weakSelf.viewController presentViewController:cameraPicker animated:YES completion:^{
                        weakSelf.hasPendingOperation = NO;
                    }];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_CameraWillShow object:nil];
            });
        };
        
        
        
        BOOL hasCamera = [UIImagePickerController isSourceTypeAvailable:pictureOptions.sourceType];
        if (!hasCamera) {
            NSLog(@"Camera.getPicture: source type %lu not available.", (unsigned long)pictureOptions.sourceType);
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:56001], @"code",@"No camera available", @"message",@"",@"detail", nil];
            CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
            [weakSelf.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            return;
        }

        // Validate the app has permission to access the camera
        if (pictureOptions.sourceType == UIImagePickerControllerSourceTypeCamera && [AVCaptureDevice respondsToSelector:@selector(authorizationStatusForMediaType:)]) {
//            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
//            if (authStatus == AVAuthorizationStatusDenied ||
//                authStatus == AVAuthorizationStatusRestricted) {
//                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:56003], @"code",@"Has no access to assets", @"message",@"",@"detail", nil];
//                CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
//                [weakSelf.commandDelegate sendPluginResult:result callbackId:command.callbackId];
//            }
//            else {
//                takePictureBlock();
//            }
            [CMPDevicePermissionHelper permissionsForPhotosTrueCompletion:^{
                takePictureBlock();
            } falseCompletion:^{
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:56003], @"code",@"Has no access to assets", @"message",@"",@"detail", nil];
                CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
                [weakSelf.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            } showAlert:NO];
        }
        else  if (pictureOptions.sourceType != UIImagePickerControllerSourceTypeCamera) {
            [CMPDevicePermissionHelper permissionsForPhotosTrueCompletion:^{
                takePictureBlock();
            } falseCompletion:^{
                NSLog(@"Camera.getPicture: source type %lu not available.", (unsigned long)pictureOptions.sourceType);
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:56002], @"code",@"Has no access to camera", @"message",@"",@"detail", nil];
                CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
                [weakSelf.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            } showAlert:NO];
        }
//    }];
}

// Delegate for camera permission UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // If Settings button (on iOS 8), open the settings app
    if (buttonIndex == 1) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wtautological-pointer-compare"
        if (&UIApplicationOpenSettingsURLString != NULL) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
#pragma clang diagnostic pop
    }

    // Dismiss the view
    [[self.pickerController presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:56002], @"code",@"Has no access to camera", @"message",@"",@"detail", nil];
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];   // error callback expects string ATM

    [self.commandDelegate sendPluginResult:result callbackId:self.pickerController.callbackId];

    self.hasPendingOperation = NO;
    self.pickerController = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_CameraWillHide object:nil];
}

- (void)repositionPopover:(CDVInvokedUrlCommand*)command
{
    NSDictionary* options = [command argumentAtIndex:0 withDefault:nil];

    [self displayPopover:options];
}

- (NSInteger)integerValueForKey:(NSDictionary*)dict key:(NSString*)key defaultValue:(NSInteger)defaultValue
{
    NSInteger value = defaultValue;

    NSNumber* val = [dict valueForKey:key];  // value is an NSNumber

    if (val != nil) {
        value = [val integerValue];
    }
    return value;
}

- (void)displayPopover:(NSDictionary*)options
{
    NSInteger x = 0;
    NSInteger y = 32;
    NSInteger width = 320;
    NSInteger height = 480;
    UIPopoverArrowDirection arrowDirection = UIPopoverArrowDirectionAny;

    if (options) {
        x = [self integerValueForKey:options key:@"x" defaultValue:0];
        y = [self integerValueForKey:options key:@"y" defaultValue:32];
        width = [self integerValueForKey:options key:@"width" defaultValue:320];
        height = [self integerValueForKey:options key:@"height" defaultValue:480];
        arrowDirection = [self integerValueForKey:options key:@"arrowDir" defaultValue:UIPopoverArrowDirectionAny];
        if (![org_apache_cordova_validArrowDirections containsObject:[NSNumber numberWithUnsignedInteger:arrowDirection]]) {
            arrowDirection = UIPopoverArrowDirectionAny;
        }
    }

    [[[self pickerController] pickerPopoverController] setDelegate:self];
    [[[self pickerController] pickerPopoverController] presentPopoverFromRect:CGRectMake(x, y, width, height)
                                                                 inView:[self.webView superview]
                                               permittedArrowDirections:arrowDirection
                                                               animated:YES];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if([navigationController isKindOfClass:[UIImagePickerController class]]){
        UIImagePickerController* cameraPicker = (UIImagePickerController*)navigationController;
        
        if(![cameraPicker.mediaTypes containsObject:(NSString*)kUTTypeImage]){
            [viewController.navigationItem setTitle:NSLocalizedString(@"Videos", nil)];
        }
    }
}

- (void)cleanup:(CDVInvokedUrlCommand*)command
{
    // empty the tmp directory
    NSFileManager* fileMgr = [[NSFileManager alloc] init];
    NSError* err = nil;
    BOOL hasErrors = NO;

    // clear contents of NSTemporaryDirectory
    NSString* tempDirectoryPath = NSTemporaryDirectory();
    NSDirectoryEnumerator* directoryEnumerator = [fileMgr enumeratorAtPath:tempDirectoryPath];
    NSString* fileName = nil;
    BOOL result;

    while ((fileName = [directoryEnumerator nextObject])) {
        // only delete the files we created
        if (![fileName hasPrefix:CDV_PHOTO_PREFIX]) {
            continue;
        }
        NSString* filePath = [tempDirectoryPath stringByAppendingPathComponent:fileName];
        result = [fileMgr removeItemAtPath:filePath error:&err];
        if (!result && err) {
            NSLog(@"Failed to delete: %@ (error: %@)", filePath, err);
            hasErrors = YES;
        }
    }

    CDVPluginResult* pluginResult;
    if (hasErrors) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_IO_EXCEPTION messageAsString:@"One or more files failed to be deleted."];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)popoverControllerDidDismissPopover:(id)popoverController
{
    UIPopoverController* pc = (UIPopoverController*)popoverController;

    [pc dismissPopoverAnimated:YES];
    pc.delegate = nil;
    if (self.pickerController && self.pickerController.callbackId && self.pickerController.pickerPopoverController) {
        self.pickerController.pickerPopoverController = nil;
        /*  OA-106396门户前端：意见反馈IOS端，上传截图时没有选择图片继续点击添加按钮+报错
         不会调错误方法了
        NSString* callbackId = self.pickerController.callbackId;
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"no image selected"];   // error callback expects string ATM
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
         */
        NSString* callbackId = self.pickerController.callbackId;
        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:56004], @"code",@"No image selected", @"message",@"",@"detail", nil];
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];

    }
    self.hasPendingOperation = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_CameraWillHide object:nil];
}

- (NSData*)processImage:(UIImage*)image info:(NSDictionary*)info options:(TZPictureOptions*)options
{
    NSData* data = nil;
    
    switch (options.encodingType) {
        case EncodingTypePNG:
            if (options.quality.floatValue >0 && options.quality.floatValue < 100) {
                data = UIImageJPEGRepresentation(image, options.quality.floatValue/100.f);
            }else{
                data = UIImagePNGRepresentation(image);
            }
            break;
        case EncodingTypeJPEG:
        {
//            if ((options.allowsEditing == NO) && (options.targetSize.width <= 0) && (options.targetSize.height <= 0) && (options.correctOrientation == NO) && (([options.quality integerValue] == 100) || (options.sourceType != UIImagePickerControllerSourceTypeCamera))){
//                // use image unedited as requested , don't resize
//                data = UIImageJPEGRepresentation(image, 1.0);
//            } else {
//                data = UIImageJPEGRepresentation(image, [options.quality floatValue] / 100.0f);
//            }
            
            if (options.quality.floatValue >0 && options.quality.floatValue < 100) {
                data = UIImageJPEGRepresentation(image, options.quality.floatValue/100.f);
            }else{
                data = UIImageJPEGRepresentation(image, 1);
            }
            if (options.usesGeolocation) {
                NSDictionary* controllerMetadata = [info objectForKey:@"UIImagePickerControllerMediaMetadata"];
                if (controllerMetadata) {
                    self.data = data;
                    self.metadata = [[NSMutableDictionary alloc] init];
                    
                    NSMutableDictionary* EXIFDictionary = [[controllerMetadata objectForKey:(NSString*)kCGImagePropertyExifDictionary]mutableCopy];
                    if (EXIFDictionary)    {
                        [self.metadata setObject:EXIFDictionary forKey:(NSString*)kCGImagePropertyExifDictionary];
                    }
                    
                    if (IsAtLeastiOSVersion(@"8.0")) {
                        [[self locationManager] performSelector:NSSelectorFromString(@"requestWhenInUseAuthorization") withObject:nil afterDelay:0];
                    }
                    [[self locationManager] startUpdatingLocation];
                }
            }
        }
            break;
        default:
            break;
    };
    //按目标大小做压缩
    if (options.maxFileSize > 0 && data.length > options.maxFileSize){
//        data = [UIImage dataWithCompressImage:image toKbSize:options.maxFileSize/1024.0];
        data = [image compressQualityWithLengthLimit:options.maxFileSize];
    }
    return data;
}

- (NSString *)tempFileWithName:(NSString *)name Path:(NSString *)extension {
    NSString* docsPath = [NSTemporaryDirectory()stringByStandardizingPath];
    NSString* filePath = [NSString stringWithFormat:@"%@/%@.%@", docsPath, name, extension];
    return filePath;
}

- (NSString*)tempFilePath:(NSString*)extension
{
    NSString* docsPath = [NSTemporaryDirectory()stringByStandardizingPath];
    NSFileManager* fileMgr = [[NSFileManager alloc] init]; // recommended by Apple (vs [NSFileManager defaultManager]) to be threadsafe
    NSString* filePath;
    
    // generate unique file name
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    int i = 1;
    do {
        filePath = [NSString stringWithFormat:@"%@/%@%@_%03d.%@", docsPath, CDV_PHOTO_PREFIX, dateStr, i++, extension];
    } while ([fileMgr fileExistsAtPath:filePath]);
    
    return filePath;
}

- (UIImage*)retrieveImage:(NSDictionary*)info options:(TZPictureOptions*)options
{
    // get the image
    UIImage* image = nil;
    if (options.allowsEditing && [info objectForKey:UIImagePickerControllerEditedImage]) {
        image = [info objectForKey:UIImagePickerControllerEditedImage];
    } else {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
//    if (options.correctOrientation) {
        image = [image imageCorrectedForCaptureOrientation];
//    }
    
    UIImage* scaledImage = nil;
    
    if ((options.targetSize.width > 0) && (options.targetSize.height > 0)) {
        // if cropToSize, resize image and crop to target size, otherwise resize to fit target without cropping
        if (options.cropToSize) {
            scaledImage = [image imageByScalingAndCroppingForSize:options.targetSize];
        } else {
            scaledImage = [image imageByScalingNotCroppingForSize:options.targetSize];
        }
    }
    
    return (scaledImage == nil ? image : scaledImage);
}

- (void)resultForImage:(TZPictureOptions*)options info:(NSDictionary*)info completion:(void (^)(CDVPluginResult* res))completion
{
    CDVPluginResult* result = nil;
    BOOL saveToPhotoAlbum = options.saveToPhotoAlbum;
    UIImage* image = nil;

    switch (options.destinationType) {
        case DestinationTypeNativeUri:
        {
            NSURL* url = [info objectForKey:UIImagePickerControllerReferenceURL];
            saveToPhotoAlbum = NO;
            // If, for example, we use sourceType = Camera, URL might be nil because image is stored in memory.
            // In this case we must save image to device before obtaining an URI.
            if (url == nil) {
                image = [self retrieveImage:info options:options];
                ALAssetsLibrary* library = [ALAssetsLibrary new];
                [library writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)(image.imageOrientation) completionBlock:^(NSURL *assetURL, NSError *error) {
                    CDVPluginResult* resultToReturn = nil;
                    if (error) {
                        resultToReturn = [CDVPluginResult resultWithStatus:CDVCommandStatus_IO_EXCEPTION messageAsString:[error localizedDescription]];
                    } else {
                        NSString* nativeUri = [[self urlTransformer:assetURL] absoluteString];
                        resultToReturn = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:nativeUri];
                    }
                    completion(resultToReturn);
                }];
                return;
            } else {
                NSString* nativeUri = [[self urlTransformer:url] absoluteString];
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:nativeUri];
            }
        }
            break;
        case DestinationTypeFileUri:
        {
            
            image = [self retrieveImage:info options:options];
            NSData* data = [self processImage:image info:info options:options];
            
            if (data) {
                
                NSString* extension = options.encodingType == EncodingTypePNG? @"png" : @"jpg";
                
                void(^saveFile)(CDVPluginResult* result, NSString *path) = ^(CDVPluginResult* result, NSString *path) {
                    NSError* err = nil;
                    // save file
                    if (![data writeToFile:path options:NSAtomicWrite error:&err]) {
                        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_IO_EXCEPTION messageAsString:[err localizedDescription]];
                    } else {
                        NSString *str = [@"file://" stringByAppendingString:path];
                        NSString *fileSize = [NSString stringWithFormat:@"%ld",(long)data.length];
                        NSNumber *index = [NSNumber numberWithInteger:0];
                        NSDictionary *aItem = [NSDictionary dictionaryWithObjectsAndKeys:str, @"filepath", fileSize, @"fileSize",  extension, @"type",index,@"index", nil];
                        NSArray *files = [NSArray arrayWithObject:aItem];
                        NSDictionary *aDict = [NSDictionary dictionaryWithObjectsAndKeys:@"true", @"success", files, @"files", nil];
                        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:aDict];
                    }
                    if (saveToPhotoAlbum && image) {
                        ALAssetsLibrary* library = [ALAssetsLibrary new];
                        [library writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)(image.imageOrientation) completionBlock:nil];
                    }
                    
                    completion(result);
                };
                // 拍照图片重命名
                if (options.rename &&
                    options.sourceType == UIImagePickerControllerSourceTypeCamera) {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:SY_STRING(@"common_rename") message:nil preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:SY_STRING(@"common_ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        UITextField *fileNameTextField = alert.textFields.firstObject;
                        NSString *newFileName = fileNameTextField.text;
                        NSString* filePath = nil;
                        if ([NSString isNull:newFileName]) {
                            filePath = [self tempFilePath:extension];
                        } else {
                            filePath = [self tempFileWithName:newFileName Path:extension];
                        }
                        saveFile(result, filePath);
                    }];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:SY_STRING(@"common_cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        NSString* filePath = [self tempFilePath:extension];
                        saveFile(result, filePath);
                    }];
                    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                        textField.placeholder = SY_STRING(@"common_rename_placeholder");
                    }];
                    [alert addAction:cancelAction];
                    [alert addAction:okAction];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.viewController presentViewController:alert animated:YES completion:nil];
                    });
                    return;
                } else {
                    NSString* filePath = [self tempFilePath:extension];
                    saveFile(result, filePath);
                    return;
                }
            }
        }
            break;
        case DestinationTypeDataUrl:
        {
            image = [self retrieveImage:info options:options];
            NSData* data = [self processImage:image info:info options:options];
            if (data)  {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:toBase64(data)];
            }
        }
            break;
        default:
            break;
    };
    
    if (saveToPhotoAlbum && image) {
        ALAssetsLibrary* library = [ALAssetsLibrary new];
        [library writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)(image.imageOrientation) completionBlock:nil];
    }

    completion(result);
}

- (CDVPluginResult*)resultForVideo:(NSDictionary*)info
{
    NSString* moviePath = [[info objectForKey:UIImagePickerControllerMediaURL] absoluteString];
    NSString* filePath = [self tempFilePath:@"MOV"];

    NSString *path = [moviePath replaceCharacter:@"file://" withString:@""];
    [[NSFileManager defaultManager]moveItemAtPath:path toPath:filePath error:nil];
    
    NSDictionary *dic = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    NSInteger size = dic.fileSize;
    NSString *fileSize = [NSString stringWithFormat:@"%ld",(long)size];
    NSNumber *index = [NSNumber numberWithInteger:0];
    NSDictionary *aItem = [NSDictionary dictionaryWithObjectsAndKeys:filePath, @"filepath", fileSize, @"fileSize",  @"mov", @"type",index,@"index", nil];
    NSArray *files = [NSArray arrayWithObject:aItem];
    NSDictionary *aDict = [NSDictionary dictionaryWithObjectsAndKeys:@"true", @"success", files, @"files", nil];
    return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:aDict];
    
//    return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:moviePath];
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    __weak TZCameraPicker* cameraPicker = (TZCameraPicker*)picker;
    __weak TZCamera* weakSelf = self;
    
    dispatch_block_t invoke = ^(void) {
        __block CDVPluginResult* result = nil;
        
        NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
        if ([mediaType isEqualToString:(NSString*)kUTTypeImage]) {
            [weakSelf resultForImage:cameraPicker.pictureOptions info:info completion:^(CDVPluginResult* res) {
                [weakSelf.commandDelegate sendPluginResult:res callbackId:cameraPicker.callbackId];
                weakSelf.hasPendingOperation = NO;
                weakSelf.pickerController = nil;
            }];
        }
        else {
            result = [weakSelf resultForVideo:info];
            [weakSelf.commandDelegate sendPluginResult:result callbackId:cameraPicker.callbackId];
            weakSelf.hasPendingOperation = NO;
            weakSelf.pickerController = nil;
        }
    };
    
    if (cameraPicker.pictureOptions.popoverSupported && (cameraPicker.pickerPopoverController != nil)) {
        [cameraPicker.pickerPopoverController dismissPopoverAnimated:YES];
        cameraPicker.pickerPopoverController.delegate = nil;
        cameraPicker.pickerPopoverController = nil;
        invoke();
    } else {
        [[cameraPicker presentingViewController] dismissViewControllerAnimated:YES completion:invoke];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_CameraWillHide object:nil];
}

// older api calls newer didFinishPickingMediaWithInfo
- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingImage:(UIImage*)image editingInfo:(NSDictionary*)editingInfo
{
    NSDictionary* imageInfo = [NSDictionary dictionaryWithObject:image forKey:UIImagePickerControllerOriginalImage];

    [self imagePickerController:picker didFinishPickingMediaWithInfo:imageInfo];
}

- (void)CMP_imagePickerControllerDidCancel:(CMPImagePickerController *)picker {
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController*)picker
{
    __weak TZCameraPicker* cameraPicker = (TZCameraPicker*)picker;
    __weak TZCamera* weakSelf = self;
    
    dispatch_block_t invoke = ^ (void) {
        CDVPluginResult* result;
        UIImagePickerControllerSourceType sourceType = picker.sourceType;
        if (sourceType == UIImagePickerControllerSourceTypeCamera && [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] != ALAuthorizationStatusAuthorized) {
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:56002], @"code",@"Has no access to camera", @"message",@"",@"detail", nil];

            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
        } else if (sourceType != UIImagePickerControllerSourceTypeCamera && [ALAssetsLibrary authorizationStatus] != ALAuthorizationStatusAuthorized) {
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:56003], @"code",@"Has no access to assets", @"message",@"",@"detail", nil];
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
        } else {
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:56004], @"code",@"No image selected", @"message",@"",@"detail", nil];
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
        }
        
        [weakSelf.commandDelegate sendPluginResult:result callbackId:cameraPicker.callbackId];
        
        weakSelf.hasPendingOperation = NO;
        weakSelf.pickerController = nil;
    };

    if ([cameraPicker presentingViewController]) {
        [[cameraPicker presentingViewController] dismissViewControllerAnimated:YES completion:invoke];
    }
    else {
        invoke();
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_CameraWillHide object:nil];
}


#pragma mark - PureCameraDelegate

-(void)pureCameraController:(PureCamera *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    __weak TZCameraPicker* cameraPicker = (TZCameraPicker*)picker;
    __weak TZCamera* weakSelf = self;
    
    dispatch_block_t invoke = ^(void) {
        __block CDVPluginResult* result = nil;
        
        NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
        if ([mediaType isEqualToString:(NSString*)kUTTypeImage]) {
            [weakSelf resultForImage:cameraPicker.pictureOptions info:info completion:^(CDVPluginResult* res) {
                [weakSelf.commandDelegate sendPluginResult:res callbackId:cameraPicker.callbackId];
                weakSelf.hasPendingOperation = NO;
                weakSelf.pickerController = nil;
            }];
        }
        else {
            result = [weakSelf resultForVideo:info];
            [weakSelf.commandDelegate sendPluginResult:result callbackId:cameraPicker.callbackId];
            weakSelf.hasPendingOperation = NO;
            weakSelf.pickerController = nil;
        }
    };
    
    if (cameraPicker.pictureOptions.popoverSupported && (cameraPicker.pickerPopoverController != nil)) {
        [cameraPicker.pickerPopoverController dismissPopoverAnimated:YES];
        cameraPicker.pickerPopoverController.delegate = nil;
        cameraPicker.pickerPopoverController = nil;
        invoke();
    } else {
        [[cameraPicker presentingViewController] dismissViewControllerAnimated:YES completion:invoke];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_CameraWillHide object:nil];
    
    
}

-(void)pureCameraControllerDidCancel:(PureCamera *)picker{
    
    __weak TZCameraPicker* cameraPicker = (TZCameraPicker*)picker;
    __weak TZCamera* weakSelf = self;
    
    dispatch_block_t invoke = ^ (void) {
        CDVPluginResult* result;
        UIImagePickerControllerSourceType sourceType = picker.sourceType;
        if (sourceType == UIImagePickerControllerSourceTypeCamera && [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] != ALAuthorizationStatusAuthorized) {
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:56002], @"code",@"Has no access to camera", @"message",@"",@"detail", nil];
            
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
        } else if (sourceType != UIImagePickerControllerSourceTypeCamera && [ALAssetsLibrary authorizationStatus] != ALAuthorizationStatusAuthorized) {
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:56003], @"code",@"Has no access to assets", @"message",@"",@"detail", nil];
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
        } else {
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:56004], @"code",@"No image selected", @"message",@"",@"detail", nil];
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
        }
        
        [weakSelf.commandDelegate sendPluginResult:result callbackId:cameraPicker.callbackId];
        
        weakSelf.hasPendingOperation = NO;
        weakSelf.pickerController = nil;
    };
    
    if ([cameraPicker presentingViewController]) {
        
        [[cameraPicker presentingViewController] dismissViewControllerAnimated:YES completion:invoke];

    }
    else {
        invoke();
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_CameraWillHide object:nil];
    
    
}


#pragma mark TZImagePickerControllerDelegate
- (void)imagePickerController:(CMPImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos
{
    __weak TZCameraPicker* cameraPicker = (TZCameraPicker*)picker;
    __weak TZCamera* weakSelf = self;
    dispatch_block_t invoke = ^(void) {
        NSLog(@"选择完成，开始获取图片");
        NSMutableArray *newDictArray = [NSMutableArray array];
        dispatch_group_t group = dispatch_group_create();
        int index = 0;
        for (PHAsset *asset in assets) {
            if (!isSelectOriginalPhoto && asset.mediaType == PHAssetMediaTypeImage) {
                NSData *imageData = UIImageJPEGRepresentation(photos[index], 0.4);
                NSString *fileSize = [NSString stringWithFormat:@"%ld",(unsigned long)imageData.length];
                NSNumber *indexNum = [NSNumber numberWithInteger:index];
                NSString *extension = @"png";
                NSString *filePath = [self tempFilePath:extension];
                NSString *str = [[self urlTransformer:[NSURL fileURLWithPath:filePath]] absoluteString];
                NSError* err = nil;
                if (![imageData writeToFile:filePath options:NSAtomicWrite error:&err]) {
                    NSLog(@"图片写入失败:%@",err);
                } else {
                    NSDictionary *aItem = [NSDictionary dictionaryWithObjectsAndKeys:str, @"filepath", fileSize, @"fileSize",  extension, @"type",indexNum,@"index",  nil];
                    [newDictArray addObject:aItem];
                }
            }else {
                dispatch_group_enter(group);
                [weakSelf requestMediaInfo:asset index:index completion:^(NSDictionary * _Nullable info) {
                    if (info) {
                        [newDictArray addObject:info];
                    }
                    dispatch_group_leave(group);
                }];
            }
            index++;
        }
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            NSLog(@"一组上传完成!");
            CDVPluginResult* result;
            if (newDictArray) {
                NSDictionary *aDict = @{@"success" : @"true", @"files" : newDictArray};
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:aDict];
            }else {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_IO_EXCEPTION messageAsString:@"Failed to get image"];
            }
            [weakSelf.commandDelegate sendPluginResult:result callbackId:cameraPicker.callbackId];
            weakSelf.hasPendingOperation = NO;
            weakSelf.pickerController = nil;
        });
//        [weakSelf resultForImage:cameraPicker.pictureOptions imagePaths:photoPaths isSelectOriginalPhoto:isSelectOriginalPhoto completion:^(CDVPluginResult *res) {
//            [weakSelf.commandDelegate sendPluginResult:res callbackId:cameraPicker.callbackId];
//            weakSelf.hasPendingOperation = NO;
//            weakSelf.pickerController = nil;
//        }];
    };
    
    if (cameraPicker.pictureOptions.popoverSupported && (cameraPicker.pickerPopoverController != nil)) {
        [cameraPicker.pickerPopoverController dismissPopoverAnimated:YES];
        cameraPicker.pickerPopoverController.delegate = nil;
        cameraPicker.pickerPopoverController = nil;
        invoke();
    } else {
        if ([cameraPicker presentingViewController]) {
            [[cameraPicker presentingViewController] dismissViewControllerAnimated:YES completion:invoke];
        }else {
            invoke();
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_CameraWillHide object:nil];
}

- (void)imagePickerController:(CMPImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset
{
    __weak TZCamera* weakSelf = self;
    __weak TZCameraPicker* cameraPicker = (TZCameraPicker*)picker;
    PHCachingImageManager *manager =  [[PHCachingImageManager alloc] init];
    [manager requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        if ([asset isKindOfClass:[AVURLAsset class]]) {
            AVURLAsset *avAsset = (AVURLAsset *)asset;
            NSNumber *size;
            [avAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
            NSString* extension = @"mp4";
            NSString* filePath = [self tempFilePath:extension];
            NSURL *outputURL = [NSURL fileURLWithPath:filePath];
            AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetHighestQuality];
            session.outputURL = outputURL;
            session.outputFileType = AVFileTypeMPEG4;
            [session exportAsynchronouslyWithCompletionHandler:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *aItem = @{@"filepath": outputURL.absoluteString, @"fileSize" : size, @"type" : @"mp4", @"index" : @(0)};
                    if (aItem != nil) {
                        NSDictionary *aDict = @{@"success" : @"true", @"files" : @[aItem]};
                        NSLog(@"VIDEO:%@,URL:%@",aDict,avAsset.URL);
                        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:aDict];
                        [weakSelf.commandDelegate sendPluginResult:result callbackId:cameraPicker.callbackId];
                        weakSelf.hasPendingOperation = NO;
                        weakSelf.pickerController = nil;
                    }
                });
            }];
        }
    }];
}

- (UIImage *)tzImageForPath:(NSString *)path options:(TZPictureOptions*)options
{
    UIImage*  image = [UIImage imageWithContentsOfFile:path];
    UIImage* scaledImage = nil;
    
    if ((options.targetSize.width > 0) && (options.targetSize.height > 0)) {
        if (options.cropToSize) {
            scaledImage = [image imageByScalingAndCroppingForSize:options.targetSize];
        } else {
            scaledImage = [image imageByScalingNotCroppingForSize:options.targetSize];
        }
    }
    image = scaledImage?scaledImage :image;
    return image;
}

- (void)resultForImage:(TZPictureOptions*)options imagePaths:(NSArray*)imagePaths isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto completion:(void (^)(CDVPluginResult* res))completion
{
    CDVPluginResult* result = nil;
    BOOL saveToPhotoAlbum = options.saveToPhotoAlbum;
    switch (options.destinationType) {
        case DestinationTypeNativeUri:
        {
            saveToPhotoAlbum = NO;
            // If, for example, we use sourceType = Camera, URL might be nil because image is stored in memory.
            // In this case we must save image to device before obtaining an URI.
            ALAssetsLibrary* library = [ALAssetsLibrary new];
         
            NSMutableArray *nativeUrLList = [NSMutableArray array];
            for (NSInteger t = 0 ; t < imagePaths.count; t++) {
                NSString *path = [imagePaths objectAtIndex:t];
                UIImage *image = [self tzImageForPath:path options:options];
                [library writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)(image.imageOrientation) completionBlock:^(NSURL *assetURL, NSError *error) {
                    CDVPluginResult* resultToReturn = nil;
                    if (error) {
                        resultToReturn = [CDVPluginResult resultWithStatus:CDVCommandStatus_IO_EXCEPTION messageAsString:[error localizedDescription]];
                        //把之前暂存的删除掉
                        [[NSFileManager defaultManager]removeItemAtPath:path error:nil];
                        completion(resultToReturn);
                    } else {
                        NSString* nativeUri = [[self urlTransformer:assetURL] absoluteString];
                        [nativeUrLList addObject:nativeUri];
                    }
                    //把之前暂存的删除掉
                    [[NSFileManager defaultManager]removeItemAtPath:path error:nil];
                    if (t == imagePaths.count-1) {
                        resultToReturn = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:nativeUrLList];
                        completion(resultToReturn);
                    }
                }];
            }
        }
            break;
        case DestinationTypeFileUri:
        {
            
            NSMutableArray *fileArray = [NSMutableArray array];
            for (NSInteger i = 0 ; i <imagePaths.count; i++) {
                NSString *path = [imagePaths objectAtIndex:i];
                BOOL isGif = [path.pathExtension.lowercaseString isEqualToString:@"gif"];
                NSData* data = [NSData dataWithContentsOfFile:path];
                //将上传的图片进行压缩
                if (!isSelectOriginalPhoto && !isGif){
                    data = [self processImage:[UIImage imageWithData:data] info:nil options:options];
                }
                if (data) {
                    NSString* extension = isGif? @"gif": options.encodingType == EncodingTypePNG? @"png" : @"jpg";
                    NSString* filePath = [self tempFilePath:extension];
                    NSError* err = nil;
                    
                    if (![data writeToFile:filePath options:NSAtomicWrite error:&err]) {
                        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_IO_EXCEPTION messageAsString:[err localizedDescription]];
                    } else {
                        NSString *str = [[self urlTransformer:[NSURL fileURLWithPath:filePath]] absoluteString];
                        NSString *fileSize = [NSString stringWithFormat:@"%ld",(unsigned long)data.length];
//                        NSString *index = [NSString stringWithFormat:@"%ld",(long)i];
                        NSNumber *index = [NSNumber numberWithInteger:i];
                        NSDictionary *aItem = [NSDictionary dictionaryWithObjectsAndKeys:str, @"filepath", fileSize, @"fileSize",  extension, @"type",index,@"index",  nil];
                        [fileArray addObject:aItem];
                    }
                }
                if (saveToPhotoAlbum) {
                    UIImage*  image = [UIImage imageWithContentsOfFile:path];
                    if (image) {
                        ALAssetsLibrary* library = [ALAssetsLibrary new];
                        [library writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)(image.imageOrientation) completionBlock:nil];
                    }
                }
                //把之前暂存的删除掉
                [[NSFileManager defaultManager]removeItemAtPath:path error:nil];
            }
            
            NSDictionary *aDict = [NSDictionary dictionaryWithObjectsAndKeys:@"true", @"success", fileArray, @"files", nil];
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:aDict];

        }
            break;
        case DestinationTypeDataUrl:
        {
            NSMutableArray *toBase64Array = [NSMutableArray array];
            for (NSString *path in imagePaths) {
                NSData* data = [NSData dataWithContentsOfFile:path];
                if (data)  {
                    [toBase64Array addObject:toBase64(data)];
                }
                if (saveToPhotoAlbum) {
                    UIImage*  image = [UIImage imageWithContentsOfFile:path];
                    if (image) {
                        ALAssetsLibrary* library = [ALAssetsLibrary new];
                        [library writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)(image.imageOrientation) completionBlock:nil];
                    }
                }
                //把之前暂存的删除掉
                [[NSFileManager defaultManager]removeItemAtPath:path error:nil];
            }
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:toBase64Array];

        }
            break;
        default:
            break;
    };
    
    completion(result);
}

- (BOOL)imageHelcOrHelfDatasWriteToFile:(NSData *)imageData filePath:(NSString *)filePath
{
    if (@available(iOS 10.0, *)) {
        CIImage *ciImage = [CIImage imageWithData:imageData];
        CIContext *context = [CIContext context];
        NSData *jpgData = [context JPEGRepresentationOfImage:ciImage colorSpace:ciImage.colorSpace options:@{}];
        return [jpgData writeToFile:filePath atomically:YES];
    } else {
        UIImage *image = [UIImage imageWithData:imageData];
        NSData *data = UIImageJPEGRepresentation(image, 1);
        return [data writeToFile:filePath atomically:YES];
    }
    return NO;
}

- (void)requestMediaInfo:(PHAsset *)phAsset index:(int)index completion:(void (^)(NSDictionary *__nullable info))completion {
    switch (phAsset.mediaType) {
        case PHAssetMediaTypeImage:{
            PHCachingImageManager *manager =  [[PHCachingImageManager alloc] init];
            
            PHImageRequestOptions *options = [PHImageRequestOptions new];
            options.networkAccessAllowed = YES;
            options.resizeMode = PHImageRequestOptionsResizeModeNone;
            
            [manager requestImageDataForAsset:phAsset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                NSLog(@"info:%@",info);
                //将上传的图片进行压缩
                if (imageData) {
                    BOOL isGif = [dataUTI containsString:@"gif"];
                    BOOL isJPG = [dataUTI containsString:@"jpg"];
                    BOOL containsHEI = [dataUTI containsString:@"heif"] || [dataUTI containsString:@"heic"];
                    NSString *extension = isGif ? @"gif" : isJPG ? @"jpg" : @"png";
                    NSString *filePath = [self tempFilePath:extension];
                    NSString *fileSize = [NSString stringWithFormat:@"%ld",(unsigned long)imageData.length];
                    NSNumber *indexNum = [NSNumber numberWithInteger:index];
                    NSString *str = [[self urlTransformer:[NSURL fileURLWithPath:filePath]] absoluteString];
                    NSError* err = nil;
                    if (containsHEI) {
                        if ([self imageHelcOrHelfDatasWriteToFile:imageData filePath:filePath]) {
                            NSDictionary *aItem = [NSDictionary dictionaryWithObjectsAndKeys:str, @"filepath", fileSize, @"fileSize",  extension, @"type",indexNum,@"index",  nil];
                            completion(aItem);
                            return;
                        }
                    }else {
                        if (![imageData writeToFile:filePath options:NSAtomicWrite error:&err]) {
                            completion(nil);
                            return;
                            
                        } else {
                            NSDictionary *aItem = [NSDictionary dictionaryWithObjectsAndKeys:str, @"filepath", fileSize, @"fileSize",  extension, @"type",indexNum,@"index",  nil];
                            completion(aItem);
                            return;
                        }
                    }
                }
                completion(nil);
            }];
        }
            break;
        case PHAssetMediaTypeVideo: {
            PHCachingImageManager *manager =  [[PHCachingImageManager alloc] init];
            
            PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc]init];
            options.version = PHVideoRequestOptionsVersionOriginal;
            options.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
            options.networkAccessAllowed = YES;
            
            [manager requestAVAssetForVideo:phAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                if ([asset isKindOfClass:[AVURLAsset class]]) {
                    AVURLAsset *avAsset = (AVURLAsset *)asset;
                    NSNumber *size;
                    [avAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
                    NSString* extension = @"mp4";
                    NSString* filePath = [self tempFilePath:extension];
                    NSURL *outputURL = [NSURL fileURLWithPath:filePath];
                    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetHighestQuality];
                    session.outputURL = outputURL;
                    session.outputFileType = AVFileTypeMPEG4;
                    [session exportAsynchronouslyWithCompletionHandler:^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSDictionary *aItem = @{@"filepath": outputURL.absoluteString, @"fileSize" : size, @"type" : @"mp4", @"index" : @(0)};
                            completion(aItem);
                        });
                    }];
                }else {
                    completion(nil);
                }
            }];
        }
            break;
        default:
            completion(nil);
            break;
    }
}

- (CLLocationManager*)locationManager
{
    if (locationManager != nil) {
        return locationManager;
    }
    
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    [locationManager setDelegate:self];
    
    return locationManager;
}

- (void)locationManager:(CLLocationManager*)manager didUpdateToLocation:(CLLocation*)newLocation fromLocation:(CLLocation*)oldLocation
{
    if (locationManager == nil) {
        return;
    }
    
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
    
    NSMutableDictionary *GPSDictionary = [[NSMutableDictionary dictionary] init];
    
    CLLocationDegrees latitude  = newLocation.coordinate.latitude;
    CLLocationDegrees longitude = newLocation.coordinate.longitude;
    
    // latitude
    if (latitude < 0.0) {
        latitude = latitude * -1.0f;
        [GPSDictionary setObject:@"S" forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
    } else {
        [GPSDictionary setObject:@"N" forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
    }
    [GPSDictionary setObject:[NSNumber numberWithFloat:latitude] forKey:(NSString*)kCGImagePropertyGPSLatitude];
    
    // longitude
    if (longitude < 0.0) {
        longitude = longitude * -1.0f;
        [GPSDictionary setObject:@"W" forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
    }
    else {
        [GPSDictionary setObject:@"E" forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
    }
    [GPSDictionary setObject:[NSNumber numberWithFloat:longitude] forKey:(NSString*)kCGImagePropertyGPSLongitude];
    
    // altitude
    CGFloat altitude = newLocation.altitude;
    if (!isnan(altitude)){
        if (altitude < 0) {
            altitude = -altitude;
            [GPSDictionary setObject:@"1" forKey:(NSString *)kCGImagePropertyGPSAltitudeRef];
        } else {
            [GPSDictionary setObject:@"0" forKey:(NSString *)kCGImagePropertyGPSAltitudeRef];
        }
        [GPSDictionary setObject:[NSNumber numberWithFloat:altitude] forKey:(NSString *)kCGImagePropertyGPSAltitude];
    }
    
    // Time and date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss.SSSSSS"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [GPSDictionary setObject:[formatter stringFromDate:newLocation.timestamp] forKey:(NSString *)kCGImagePropertyGPSTimeStamp];
    [formatter setDateFormat:@"yyyy:MM:dd"];
    [GPSDictionary setObject:[formatter stringFromDate:newLocation.timestamp] forKey:(NSString *)kCGImagePropertyGPSDateStamp];
    
    [self.metadata setObject:GPSDictionary forKey:(NSString *)kCGImagePropertyGPSDictionary];
    [self imagePickerControllerReturnImageResult];
}

- (void)locationManager:(CLLocationManager*)manager didFailWithError:(NSError*)error
{
    if (locationManager == nil) {
        return;
    }

    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
    
    [self imagePickerControllerReturnImageResult];
}

- (void)imagePickerControllerReturnImageResult
{
    TZPictureOptions* options = self.pickerController.pictureOptions;
    CDVPluginResult* result = nil;
    
    if (self.metadata) {
        CGImageSourceRef sourceImage = CGImageSourceCreateWithData((__bridge CFDataRef)self.data, NULL);
        CFStringRef sourceType = CGImageSourceGetType(sourceImage);
        
        CGImageDestinationRef destinationImage = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)self.data, sourceType, 1, NULL);
        CGImageDestinationAddImageFromSource(destinationImage, sourceImage, 0, (__bridge CFDictionaryRef)self.metadata);
        CGImageDestinationFinalize(destinationImage);
        
        CFRelease(sourceImage);
        CFRelease(destinationImage);
    }
    
    switch (options.destinationType) {
        case DestinationTypeFileUri:
        {
            NSError* err = nil;
            NSString* extension = self.pickerController.pictureOptions.encodingType == EncodingTypePNG ? @"png":@"jpg";
            NSString* filePath = [self tempFilePath:extension];
            
            // save file
            if (![self.data writeToFile:filePath options:NSAtomicWrite error:&err]) {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_IO_EXCEPTION messageAsString:[err localizedDescription]];
            }
            else {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[[self urlTransformer:[NSURL fileURLWithPath:filePath]] absoluteString]];
            }
        }
            break;
        case DestinationTypeDataUrl:
        {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:toBase64(self.data)];
        }
            break;
        case DestinationTypeNativeUri:
        default:
            break;
    };
    
    if (result) {
        [self.commandDelegate sendPluginResult:result callbackId:self.pickerController.callbackId];
    }
    
    self.hasPendingOperation = NO;
    self.pickerController = nil;
    self.data = nil;
    self.metadata = nil;
    
    if (options.saveToPhotoAlbum) {
        ALAssetsLibrary *library = [ALAssetsLibrary new];
        [library writeImageDataToSavedPhotosAlbum:self.data metadata:self.metadata completionBlock:nil];
    }
}

@end

