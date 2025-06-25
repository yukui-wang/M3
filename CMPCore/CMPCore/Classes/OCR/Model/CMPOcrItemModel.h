//
//  CMPOcrItemModel.h
//  M3
//
//  Created by Kaku Songu on 11/23/21.
//

#import <CMPLib/CMPObject.h>

typedef enum {
    //***** 发票上传识别状态码 <=12 是目前已经定好的，就不改了，
    //***** 后续按照交互和接口不同分类进行区分，客户端可以更好的适配各种状态而无需更新修改
    // -- (12,200) 为异常状态, (12,100)可批量删除ocrtask/delete接口
    //   -- (12,80) 有按钮可以重新识别
    //      --（12,40）retry接口
    //      -- [40,80) 预留
    //   -- [80,100) 无按钮不可以重新识别
    //   -- [100,200) 其它预留异常状态,不可批量删除。
    // -- [200,~）正常处理状态
    
    //本地状态
    CMPOcrItemStateNotUpload = -1,//添加图片成功，等待上传图片
    CMPOcrItemStateUploadError = -5,//上传图片失败，可重新上传
    CMPOcrItemStateUploadPause = -6,//上传图片暂停，可以重新上传
    CMPOcrItemStateUploadSuccess = -2, //上传附件图片成功，等待提交服务器
    
    //提交服务
//    CMPOcrItemStateWaitSubmit = -7,//等待提交
    CMPOcrItemStateSubmitSuccess = -3,// 提交服务成功，等待识别
    CMPOcrItemStateSubmitFail = -4,//图片提交数据失败
    //服务端返回状态
    CMPOcrItemStateCheckUploading = 1,//服务器图片上传中...一般不会返回
    CMPOcrItemStateCheckProcessing = 2,//服务器发票识别中
    //识别成功
    CMPOcrItemStateCheckSuccess = 3,//服务器发票识别成功（无数据）
    //识别错误
    CMPOcrItemStateCheckFailed = 4,//服务器返回，云平台识别失败
    CMPOcrItemStateCheckSuspend = 5,//服务器返回，发票识别暂停
    CMPOcrItemStateCheckWaiting = 6,//服务器返回，发票等待识别
    CMPOcrItemStateCheckBlurring = 7,//服务器返回，发票未识别出来
    CMPOcrItemStateCheckRepeat = 8,//服务器返回，发票识别重复
    
    CMPOcrItemStateMixResult = 9,//成功{0}张，失败{1}张。建议重新上传失败发票 
    
    CMPOcrItemStateOcrServerFail = 10,//ocr服务不可用
    CMPOcrItemStateOcrNoAuthCount = 11,//无授权次数
    CMPOcrItemStateOcrSeverNotAuth = 12,//识别服务未授权
} CMPOcrItemState;

@interface CMPOcrItemModel : CMPObject

@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *itemid;//db唯一id
@property (nonatomic, copy) NSString *filePath_id;//组件id（暂时不使用）
@property (nonatomic, copy) NSString *filePath;//copy后的文件路径（Document/）

@property (nonatomic, copy) NSString *fileId; //本地文件唯一名字 md5
@property (nonatomic, copy) NSString *fileUrl; //上传成功后服务器端文件id

@property (nonatomic, copy) NSString *packageId; //卡包id
@property (nonatomic, copy) NSString *servicePath; //上传成功后的完整路径
@property (nonatomic, copy) NSString *userId; //用户id
@property (nonatomic, copy) NSString *serviceId; //服务器id
//@property (nonatomic, assign) CMPOcrItemState itemState;
@property (nonatomic, copy) NSString *md5;//文件的md5值
@property (nonatomic, copy) NSString *fileType;//文件类型

@property (nonatomic, copy) NSString *exit1;
@property (nonatomic, copy) NSString *exit2;
@property (nonatomic, copy) NSString *exit3;

@property (nonatomic, assign) NSTimeInterval createTime;//本地db里面的创建时间
@property (nonatomic, assign) NSTimeInterval updateTime;

//临时存储
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSURL *localFileURL;

//发票识别页面显示
@property (nonatomic, copy) NSString *taskId;
@property (nonatomic, copy) NSString *taskStatusDisplay;//"识别异常\r\n建议重新上传清晰完整的发票图"
@property (nonatomic, copy) NSString *filename;//"增值税发票.jpg"
@property (nonatomic, copy) NSString *invoiceId;
@property (nonatomic, assign) CMPOcrItemState taskStatus;


//其他
@property (nonatomic, copy) NSString *uploadRequestId;//当前上传请求id

@end

