//
//  CMPOcrInvoiceModel.h
//  CMPOcr
//
//  Created by 张艳 on 2021/11/25.
//

#import <Foundation/Foundation.h>
#import <CMPLib/CMPObject.h>
NS_ASSUME_NONNULL_BEGIN


@class CMPOcrInvoiceItemModel;
@interface CMPOcrInvoiceModel : NSObject

@property (nonatomic, strong) CMPOcrInvoiceItemModel *mainInvoice;

@property (nonatomic, strong) NSArray <CMPOcrInvoiceItemModel *> *deputyInvoiceList;

@end

@interface CMPOcrInvoiceItemModel : NSObject

/// 发票ID
@property (nonatomic, copy) NSString *invoiceID;

//发票状态 0：未报销 1.已删除  2.报销中 3.已报销
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, copy) NSString *statusDisplay;

//发票验真状态 已作废、未验真、已验真、无需验真、查无此票
@property (nonatomic, assign) NSInteger verifyStatus;
@property (nonatomic, copy) NSString *verifyStatusDisplay;

///被关联的主发票ID
@property (nonatomic, copy) NSString *relationInvoiceId;

///发票确认状态
@property (nonatomic, copy) NSString *comfirmStatus;

@property (nonatomic, copy) NSString *confirmStatusDisplay;

///发票开票日期，来源语ocr识别后的字段
@property (nonatomic, copy) NSString *date;

///发票总金额，来源于ocr识别后的字段
@property (nonatomic, copy) NSString *total;

///报销包ID
@property (nonatomic, copy) NSString *rPackageId;

///发票图片缩率图地址
@property (nonatomic, copy) NSString *tPath;

///主副发票的标识：1：主发票；2：副发票
@property (nonatomic, assign) NSInteger mainDeputyTag;

/// 发票ID
@property (nonatomic, copy) NSString *filename;

@property (nonatomic, copy) NSString *modelId;
@property (nonatomic, copy) NSString *modelName;
@property (nonatomic, copy) NSString *fileId;
@property (nonatomic, copy) NSString *fileType;
@property (nonatomic, copy) NSString *details;
@property (nonatomic, copy) NSString *confirmStatus;
@property (nonatomic, assign) NSInteger isComplete;
@property (nonatomic, copy) NSString *createDateDisplay;
@property (nonatomic, copy) NSString *createDate;
@property (nonatomic, copy) NSString *isRepeat;

/// 当前cell是否选中
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, strong) NSArray *displayFields;//字段字典

@property (nonatomic, assign) BOOL isBad;//
/*
"id": "7675243933566518380",
"modelId": null,
"modelName": null,
"fileId": "-4209715195858500942",
"filename": null,
"fileType": null,
"tPath": null,
"details": null,
"confirmStatus": "未确认",
"date": "1510502400000",
"total": "241.95",
"mainDeputyTag": "1",
"relationInvoiceId": null,
"rPackageId": null,
"isComplete": null,
"createDateDisplay": "2021年12月15日",
"createDate": "2021-12-15",
"isRepeat": null
 */

@end

@interface CMPOcrDefaultInvoiceCategoryModel : NSObject

///包id
@property (nonatomic, copy) NSString *packageID;
/// 模型ID
@property (nonatomic, copy) NSString *modelID;
/// 模型图片
@property (nonatomic, copy) NSString *imageUrl;
/// 子类ID
@property (nonatomic, copy) NSString *groupId;
/// 模型名称
@property (nonatomic, copy) NSString *modelName;
@property (nonatomic, copy) NSString *name;

//关联的发票列表
@property (nonatomic, strong) NSArray *invoiceGroupArray;
@property (nonatomic, assign) NSInteger invoiceCount;

@end

@interface CMPOcrInvoiceGroupListModel : CMPObject

//分组日期
@property (nonatomic, copy) NSString *uploadDate;
//包含主副发票
@property (nonatomic, strong) NSArray<CMPOcrInvoiceItemModel *> *invoiceItemArray;

@end


NS_ASSUME_NONNULL_END
