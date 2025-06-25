//
//  BFBaseViewController.h
//  M3
//
//  Created by wujiansheng on 2018/12/12.
//  


#import <UIKit/UIKit.h>
#import "BFCircleView.h"
#import "BFVideoCaptureDevice.h"
#import "BFParameterConfig.h"

typedef enum : NSUInteger {
    CommonStatus,
    PoseStatus,
    occlusionStatus
} WarningStatus;

//百度人脸库处理结果
typedef void (^BFaceFinishBlock)(NSDictionary* sucessDict, NSError* error);
typedef void (^BFaceCancelBlock)(void);


typedef enum : NSUInteger {
    BFaceHandleTypeCreate = 1,//创建上传人脸连数据
    BFaceHandleTypeUpdate = 2,//更新人脸数据，会覆盖对应人员的数据
    BFaceHandleTypeObtain = 3,//判断识别人员是谁（返回userid）
    BFaceHandleTypeCheck =4 //判断识别人员是否是某个人员（通过userId返回bool）
} BFaceHandleType;


@interface BFBaseViewController : UIViewController
@property (nonatomic, readwrite, retain) BFVideoCaptureDevice *videoCapture;
@property (nonatomic, readwrite, retain) UIImageView *displayImageView;
@property (nonatomic, readwrite, assign) BOOL hasFinished;
@property (nonatomic, readwrite, retain) UIImage* coverImage;
@property (nonatomic, readwrite, assign) CGRect previewRect;
@property (nonatomic, readwrite, assign) CGRect detectRect;
@property (nonatomic, readwrite, retain) BFCircleView * circleView;
@property (nonatomic, readwrite, copy) BFaceFinishBlock finishBlock;
@property (nonatomic, readwrite, copy) BFaceCancelBlock cancelBlock;


@property (nonatomic, assign)BFaceHandleType handleType;
@property (nonatomic, retain) NSString *groupId;
@property (nonatomic, retain) NSString *userId;
@property (nonatomic, retain) NSString *userInfo;
@property (nonatomic, assign) BOOL enableSound;


- (void)faceProcesss:(UIImage *)image;

- (void)startCapture;
- (void)stopCapture;

- (void)startAnimation;
- (void)stopAnimation;

- (void)closeAction;

- (void)onAppWillResignAction;
- (void)onAppBecomeActive;

- (void)warningStatus:(WarningStatus)status warning:(NSString *)warning;
- (void)singleActionSuccess:(BOOL)success;


#pragma mark baidu face library action
- (void)createFace:(NSString *)imageStr;
- (void)updateFace:(NSString *)imageStr;
- (void)removeFace;
- (void)checkFace:(NSString *)imageStr;
- (void)obtainFace:(NSString *)imageStr;

@end
