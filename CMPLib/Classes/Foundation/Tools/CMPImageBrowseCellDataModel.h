//
//  CMPImageBrowseCellDataModel.h
//  CMPLib
//
//  Created by wujiansheng on 2019/9/2.
//  Copyright © 2019 crmo. All rights reserved.
//

#import <CMPLib/CMPObject.h>
#import <CMPLib/CMPStringConst.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPImageBrowseCellDataModel : CMPObject
/* fileSize */
@property (assign, nonatomic) long long fileSize;
/* 视频本地地址 */
@property (copy, nonatomic) NSString *videoLocalPath;
@property (nonatomic,copy) NSString *showUrlStr;
@property (nonatomic,copy) NSString *originUrlStr;
@property (nonatomic,strong) id thumbObject;
/* fileName图片文件名，用于存储图片 */
@property (copy, nonatomic) NSString *filenName;
/* 来源，用于存储到本地文件 */
@property (copy, nonatomic) NSString *from;
/* 来源类型 */
@property (copy, nonatomic) CMPFileFromType fromType;
/* 图片时间 */
@property (copy, nonatomic) NSString *time;
/* fileId */
@property (copy, nonatomic) NSString *fileId;

//是否不能自动保存，比如说从我的文件打开的图片就不用自动保存
@property (assign, nonatomic) BOOL canNotAutoSave;

@end

NS_ASSUME_NONNULL_END
