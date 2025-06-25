//
//  CMPOcrPackageModel.h
//  M3
//
//  Created by Kaku Songu on 11/23/21.
//

#import <CMPLib/CMPObject.h>

//数据模型
@interface CMPOcrPackageModel : CMPObject
/**
 id    number
 必须
 报销包id
 name    string
 必须
 报销包名称
 status    number
 必须
 发票识别状态code
 statusDisplay    string
 必须
 发票识别状态展示名称
 templateId    string
 必须
 模板id
 formId    string
 必须
 表单id
 invoiceAmount    number
 必须
 发票总金额
 invoiceCount    integer
 必须
 发票张数
 */
@property (nonatomic,copy) NSString *pid;
@property (nonatomic,copy) NSString *name;
//0: 新建(报销包新建)
//1：识别中（报销包的发票只要有没有识别成功的情况）；
//2：被回退（流程被回退了）；
//3：被终止（流程被终止）；
//4：被撤销（流程被撤销）；
//5：报销成功（流程完成）
//6: 处理中；
//7: 可报销
//8: 保存待发，显示一键报销，可点击
@property (nonatomic,assign) NSInteger status;
@property (nonatomic,assign) NSInteger type;//// 0:用户创建，1：默认票夹，2：系统创建
@property (nonatomic,copy) NSString *statusDisplay;
@property (nonatomic,copy) NSString *templateId;
@property (nonatomic,copy) NSString *formId;
@property (nonatomic, copy) NSString *summaryId;
@property (nonatomic,assign) double invoiceAmount;
@property (nonatomic,assign) NSUInteger invoiceCount;

@property (nonatomic,assign) NSInteger lastUsedTag;

@property (nonatomic,assign) BOOL isHistory;//如果是我的页面数据，则为YES

@property (nonatomic, strong) NSArray *invoiceIdList;//非包内所有发票

@end

/*
 包详情提示model
 */
@interface CMPOcrPackageTipModel : CMPObject

//0：代表不提示信息，1：代表提示信息
@property (nonatomic, assign) NSInteger code;
//用于点击一键报销的提示
//"重复识别发票2张，已删除！",
@property (nonatomic, copy) NSString *message;

@property (nonatomic, copy) NSString *title;
//额外信息，未识别完成的发票数量，用于在右上角显示红点数量
@property (nonatomic, assign) NSInteger unDistinguishCount;
@end


/*
 包分类model
 */
@interface CMPOcrPackageClassifyModel : CMPObject

@property (nonatomic,copy) NSString *templateName;
@property (nonatomic, strong) NSArray<CMPOcrPackageModel*> *rPackageList;

@end

