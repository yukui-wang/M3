//
//  AttachmentReaderParam.h
//  M3
//
//  Created by youlin on 2019/7/4.
//

#import <CMPLib/CMPObject.h>
#import <CMPLib/CMPStringConst.h>

@interface AttachmentReaderParam : CMPObject

@property (nonatomic, strong)NSString *url;  // 文件下载url地址
@property (nonatomic, strong)NSString *origin; // 原始路径
@property (nonatomic, strong)NSDictionary *header; // 文件下载请求头
@property (nonatomic, strong)NSString *filePath;  // 文件本地路径
@property (nonatomic, strong)NSString *fileId;  // 文件唯一标志，非V5附件ID
@property (nonatomic, strong)NSString *fileName; // 文件名称
@property (nonatomic, strong)NSString *fileType; // 文件类型 指定文件类型打开文件，有效值 doc, xls, ppt, pdf, docx, xlsx, pptx
@property (nonatomic, strong)NSString *fileSize;  // 文件大小
@property(nonatomic, strong)NSString *lastModified; // 最后修改时间

@property (nonatomic,assign) BOOL editMode; // 是否为编辑状态
@property (nonatomic,assign) BOOL autoSave; // 是否自动保存到我的文件
/** 第三发应用打开权限控制 **/
@property (assign, nonatomic) BOOL canShowInThirdApp;
/** 附件下载权限控制 **/
@property (assign, nonatomic) BOOL canDownload; // 是否支持下载
@property (assign, nonatomic) BOOL isShowPrintBtn; // 是否显示打印按钮
@property (assign, nonatomic) BOOL isShowShareBtn; // 是否显示分享按钮
/* 来源 */
@property (copy, nonatomic) NSString *from;
/* 来源类型 */
@property (copy, nonatomic) CMPFileFromType fromType;
/* 是否是来自致信 */
@property (assign, nonatomic) BOOL isUc;

@property (nonatomic, strong)NSDictionary *logParams;//附件下载的日志参数，uc

@property(nonatomic, strong) id extra;

- (id)initWithDict:(NSDictionary *)parameter;

@end

