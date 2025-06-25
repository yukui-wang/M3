//
//  MARouteOverlayModel.h
//  MAMapKit
//
//  Created by linshiqing on 2024/1/18.
//  Copyright © 2024 Amap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#if FEATURE_ROUTE_OVERLAY
NS_ASSUME_NONNULL_BEGIN
/**
 * @brief   路线纹理枚举
 */
typedef NS_ENUM(NSInteger, MAMapRouteTexture) {
    MAMapRouteTextureNonavi     = 0,       //!< 非导航道路，步行代表不绘制路段
    MAMapRouteTextureNavi       = 1,       //!< 导航道路，骑步行代表高亮路段
    MAMapRouteTextureDefault    = 2,       //!< 实时交通默认状态，步行代表置灰路段
    MAMapRouteTextureOpen       = 3,       //!< 实时交通畅通状态
    MAMapRouteTextureAmble      = 4,       //!< 实时交通缓行状态
    MAMapRouteTextureJam        = 5,       //!< 实时交通拥堵状态
    MAMapRouteTextureCongested  = 6,       //!< 实时交通极其拥堵状态
    MAMapRouteTextureArrow      = 7,       //!< 路线上鱼骨箭头
    MAMapRouteTextureCustom1    = 8,       //!< 自定义路线纹理1, 与status值对应
    MAMapRouteTextureCustom2    = 9,       //!< 自定义路线纹理2, 与status值对应
    MAMapRouteTextureCustom3    = 10,      //!< 自定义路线纹理3, 与status值对应
    MAMapRouteTextureCustom4    = 11,      //!< 自定义路线纹理4, 与status值对应
    MAMapRouteTextureCustom5    = 12,      //!< 自定义路线纹理5, 与status值对应
    MAMapRouteTextureCustom6    = 13,      //!< 自定义路线纹理6, 与status值对应
    MAMapRouteTextureRapider    = 16,      //!< 自定义路线纹理16,极其畅通
    MAMapRouteTextureRestrain   = 30,      //!< 自定义路线纹理30, 导航抑制状态
    MAMapRouteTextureCustomMax  = 31,      //!< 自定义路线纹理最大值, 与status值对应
    MAMapRouteTextureCharge     = 32,      //!< 收费道路
    MAMapRouteTextureFree       = 33,      //!< 免费道路
    MAMapRouteTextureLimit      = 34,      //!< 限行道路
    MAMapRouteTextureSlower     = 35,      //!< 通勤场景下更拥堵道路
    MAMapRouteTextureFaster     = 36,      //!< 通勤场景下更畅通道路
    MAMapRouteTextureWrong      = 37,      //!< 报错道路
    MAMapRouteTextureFerry      = 38,      //!< 轮渡线
    MAMapRouteTextureNumber,               //!< 纹理个数
};

@interface MAPolylineCapTextureInfo : NSObject
@property (nonatomic, assign) float x1;                                //!< 纹理左上角X
@property (nonatomic, assign) float y1;                                //!< 纹理左上角Y
@property (nonatomic, assign) float x2;                                //!< 纹理右下角X
@property (nonatomic, assign) float y2;                                //!< 纹理右上角Y
@end

@interface MAPolylineTextureInfo : MAPolylineCapTextureInfo
@property (nonatomic, assign) float textureLen;                        //!< 纹理长度，仅在绘制虚线线型时设置
@end

typedef NS_ENUM(NSInteger, MAMapRouteLineWidthType) {
    MAMapRouteLineWidthTypePixel = 0,
    MAMapRouteLineWidthTypeMeter = 1,
};

@interface MARouteOverlayParam : NSObject
@property (nonatomic, assign) BOOL lineExtract;            //!< 是否抽稀
@property (nonatomic, assign) BOOL useColor;               //!< 是否使用颜色
@property (nonatomic, assign) BOOL usePoint;               //!< 是否使用Point点
@property (nonatomic, assign) BOOL useCap;                 //!< 是否使用线帽
@property (nonatomic, assign) BOOL canBeCovered;           //!< 能否被覆盖
@property (nonatomic, assign) BOOL showArrow;              //!< 是否显示箭头 上层控制箭头是否显示
@property (nonatomic, assign) BOOL needColorGradient;      //!< 是否需要渐变
@property (nonatomic, assign) BOOL clickable;               //!< 是否可点击
@property (nonatomic, assign) int32_t lineWidth;          //!< 线宽
@property (nonatomic, assign) int32_t borderLineWidth;    //!< 边线宽
@property (nonatomic, strong) UIImage *fillMarkerImage;     //!< 里线纹理id
@property (nonatomic, strong) UIImage *simple3DFillMarkerImage; //!< 简易三维下里线纹理
@property (nonatomic, strong) UIImage *borderMarkerImage;   //!< 边线纹理id
@property (nonatomic, assign) uint32_t fillColor;          //!< 填充颜色
@property (nonatomic, assign) uint32_t borderColor;        //!< 边颜色
@property (nonatomic, assign) uint32_t selectFillColor;    //!< 选中的填充颜色
@property (nonatomic, assign) uint32_t unSelectFillColor;  //!< 未选中的填充颜色
@property (nonatomic, assign) uint32_t selectBorderColor;  //!< 选中的边线颜色
@property (nonatomic, assign) uint32_t unSelectBorderColor;//!< 未选中的边线颜色
@property (nonatomic, assign) uint32_t pointDistance;      //!< 两点间距离
@property (nonatomic, assign) uint32_t priority;           //!< 设置item的优先级(只有usePoint为true有效)
@property (nonatomic, assign) MAMapRouteTexture routeTexture;           //!< 路线纹理枚举 具体参考MapRouteTexture
@property (nonatomic, strong) MAPolylineTextureInfo *lineTextureInfo;        //!< 纹理坐标参数
@property (nonatomic, strong) MAPolylineTextureInfo *lineSimple3DTextureInfo;//!< 简易三维下纹理坐标参数
@property (nonatomic, strong) MAPolylineCapTextureInfo *lineCapTextureInfo;  //!< 线帽纹理参数
@property (nonatomic, assign) NSString *lineBorderQuery;                //!< 边线纹理资源URL地址
@property (nonatomic, assign) NSString *lineFillQuery;                  //!< 中心线纹理资源URL地址
@property (nonatomic, assign) MAMapRouteLineWidthType lineWidthType;        //!< 线宽类型
@end


typedef NS_ENUM(NSInteger,  MAMapRouteHighLightType) {
    MAMapRouteHighLightTypeNone = 0,        //!< 无高亮效果
    MAMapRouteHighLightTypeSegment          //!< 有一段路高亮，其他路段非高亮显示
};

@interface MARouteOverlayHighLightParam : NSObject
@property (nonatomic, assign) uint32_t fillColorHightLight;              //!< 高亮路段的填充颜色
@property (nonatomic, assign) uint32_t borderColorHightLight;            //!< 高亮路段的边缘颜色
@property (nonatomic, assign) uint32_t fillColorNormal;                  //!< 非高亮路段的填充颜色
@property (nonatomic, assign) uint32_t borderColorNormal;                //!< 非高亮路段的边缘颜色
@property (nonatomic, assign) uint32_t arrowColorNormal;                 //!< 非高亮路段的鱼骨线颜色，高亮路段使用纹理原来的颜色
@end


/**
 * @brief   路线交通状态
 */
@interface  MAMapRouteOverlayTrafficState : NSObject
@property (nonatomic, assign) uint32_t state;                            //!< 路线状态 4B
@property (nonatomic, assign) uint32_t point2DIndex;                     //!< 二维起始坐标点索引 4B
@property (nonatomic, assign) uint32_t point3DIndex;                     //!< 三维起始坐标点索引 4B
@property (nonatomic, assign) uint32_t point3DCount;                     //!< 三维坐标点个数 4B
@end

/**
 * @brief   路线颜色
 */
@interface MAMapRouteOverlayColorIndex : NSObject
@property (nonatomic, assign) uint32_t nColor;                           //!< 路线颜色(ARGB)
@property (nonatomic, assign) uint32_t point2DIndex;                     //!< 二维起始坐标点索引 (如无二维坐标)
@property (nonatomic, assign) uint32_t point3DIndex;                     //!< 三维起始坐标点索引 4B
@property (nonatomic, assign) uint32_t point3DCount;                     //!< 三维坐标点个数 4B
@end

/**
 * @brief   路线道路名称
 */
@interface MAMapRouteOverlayRoadName : NSObject
@property (nonatomic, copy) NSString *name;                          //!< 道路名称字符串, UTF8编码
@property (nonatomic, assign) uint32_t point2DIndex;                     //!< 道路对应的二维形点起始索引 4B
@property (nonatomic, assign) uint32_t point2DSize;                      //!< 道路对应的二维形点个数 4B
@property (nonatomic, assign) uint32_t point3DIndex;                     //!< 道路对应的三维形点起始索引 4B
@property (nonatomic, assign) uint32_t point3DSize;                      //!< 道路对应的三维形点个数 4B
@property (nonatomic, assign) uint32_t roadLength;                       //!< 道路长度 4B
@property (nonatomic, assign) uint32_t roadClass;                        //!< 道路等级 4B
@end

@interface MAMapPoint2I : NSObject
@property (nonatomic, assign) int32_t x;
@property (nonatomic, assign) int32_t y;
@end

@interface MAMapPoint3I : MAMapPoint2I
@property (nonatomic, assign) int32_t z;
@end

@interface MAMapRouteOverlayData : NSObject
@property (nonatomic, assign) uint32_t checkFlag;
@property (nonatomic, assign) uint32_t routeType;
@property (nonatomic, copy) NSArray<MAMapPoint2I *> *point2DArray;
@property (nonatomic, copy) NSArray<MAMapRouteOverlayTrafficState *> *trafficStateArray;
@property (nonatomic, copy) NSArray<MAMapRouteOverlayRoadName *> *roadNameArray;
@property (nonatomic, copy) NSArray<NSNumber *> *point2DFlagArray;
@property (nonatomic, copy) NSArray<MAMapPoint3I *> *point3DArray;
@property (nonatomic, copy) NSArray<NSNumber *> *point3DFlagArray;
@property (nonatomic, copy) NSArray<MAMapRouteOverlayColorIndex *> *colorIndexArray;
@end

NS_ASSUME_NONNULL_END
#endif
