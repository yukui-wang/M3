//
//  CMPOcrInvoiceDetailModel.h
//  M3
//
//  Created by 张艳 on 2021/12/14.
//

#import <CMPLib/CMPObject.h>

NS_ASSUME_NONNULL_BEGIN

@class CMPOcrInvoiceDetailDetailsModel;
@interface CMPOcrInvoiceDetailModel : CMPObject

@property (nonatomic, copy) NSString *invoiceID;
/// ai识别模型ID
@property (nonatomic, copy) NSString *modelId;
/// ai识别模型名称  增值税发票
@property (nonatomic, copy) NSString *modelName;
/// 发票文件ID
@property (nonatomic, copy) NSString *fileId;
/// 发票文件名称
@property (nonatomic, copy) NSString *filename;
/// 发票文件类型
@property (nonatomic, copy) NSString *fileType;//png
/// 发票确认状态，1：确认了；0：未确认
@property (nonatomic, assign) NSInteger confirmStatus;
@property (nonatomic, copy) NSString *confirmStatusDisplay;
//ks add
@property (nonatomic, assign) NSInteger verifyStatus;
@property (nonatomic, copy) NSString *verifyStatusDisplay;

/// 发票开票日期
@property (nonatomic, copy) NSString *date;//2021-11-29
/// 发票总金额
@property (nonatomic, copy) NSString *total;//2003.8
/// 主副发票区分：1：主发票；2：副发票
@property (nonatomic, assign) NSInteger mainDeputyTag;
/// 被关联主发票ID，副发票才有此值
@property (nonatomic, assign) NSInteger relationInvoiceId;
/// 报销包ID
@property (nonatomic, copy) NSString *rPackageId;
/// 是否识别完成
@property (nonatomic, assign) NSInteger isComplete;

@property (nonatomic, copy) NSString *createDateDisplay;
@property (nonatomic, assign) NSInteger isRepeat;
@property (nonatomic, assign) NSInteger deputyInvoiceNum;
@property (nonatomic, assign) BOOL hasSchedule;//是否有明细表

/*{"date":{
        "value":"1510502400000",
        "desc" :"开票日期",
        "type" :6
    },
    "seller":{
        "value": "联邦快递(中国)有限公司上海分公司",
        "desc": "销售方名称",
        "type": 4
    },
    xxxx
 }
 */
@property (nonatomic, strong) NSDictionary *details;
/**
 "verifyInfo" : {
   "msg" : "已验真",
   "code" : "0",
   "paramFields" : [ "type", "code", "number", "check_code", "pretax_amount", "date" ]
 }
 */
@property (nonatomic, strong) NSDictionary *verifyInfo;
@property (nonatomic, strong) NSDictionary *validInfo;
@property (nonatomic, copy) NSString *type;//发票子类型

@end


@class CMPOcrInvoiceDetailItemModel;
@interface CMPOcrInvoiceDetailListModel : CMPObject

@property (nonatomic, assign) NSInteger code;

@property (nonatomic, copy) NSString *message;

/// 发票列表
@property (nonatomic, strong) NSArray <CMPOcrInvoiceDetailItemModel *> *data;

@end

@interface CMPOcrInvoiceDetailItemModel : CMPObject

/// 发票ID
@property (nonatomic, copy) NSString *invoiceId;
/// 文件地址
@property (nonatomic, copy) NSString *fileId;
/// 类型
@property (nonatomic, copy) NSString *type;
/// 发票名称
@property (nonatomic, copy) NSString *filename;

@end
NS_ASSUME_NONNULL_END
