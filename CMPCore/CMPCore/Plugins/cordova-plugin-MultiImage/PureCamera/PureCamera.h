/*!
 @abstract

 */
#import <UIKit/UIKit.h>
#import "TOCropViewController.h"
#import "TZCamera.h"

@class PureCamera;

@protocol PureCameraDelegate <NSObject>

- (void)pureCameraController:(PureCamera *)picker didFinishPickingMediaWithInfo:(NSDictionary*)info;
- (void)pureCameraControllerDidCancel:(PureCamera*)picker;

@end

typedef void (^fininshcapture)(UIImage *image);

@interface PureCamera : UIViewController

@property (nonatomic,copy)fininshcapture fininshcapture;
@property (nonatomic, assign)TOCropViewControllerAspectRatio aspectRatioStle;
@property (nonatomic,assign)BOOL isOnlyNeedRatioSquare;
@property (nonatomic,weak)id<PureCameraDelegate> delegate;

@property (strong) TZPictureOptions* pictureOptions;
@property (copy)   NSString* callbackId;
@property (copy)   NSString* postUrl;
@property (strong) UIPopoverController* pickerPopoverController;
@property (assign) BOOL cropToSize;
@property (strong) UIView* webView;

@property(nonatomic,copy)NSArray<NSString *>*mediaTypes;
@property(nonatomic)UIImagePickerControllerSourceType sourceType;
@property(nonatomic)BOOL allowsEditing;
@property(nonatomic) UIImagePickerControllerCameraDevice cameraDevice;

+ (instancetype) createFromPictureOptions:(TZPictureOptions*)pictureOptions;

@end
