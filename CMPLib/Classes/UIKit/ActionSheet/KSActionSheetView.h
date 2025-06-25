//
//  KSActionSheetView.h
//  XGiant
//
//  Created by Songu Kaku on 2018/6/13.
//  Copyright © 2018年 com.xinjucn. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KSActionSheetView;

@interface KSActionSheetViewItem : NSObject

@property (nonatomic,copy,readonly) NSString *title;
@property (nonatomic,assign,readonly) NSUInteger key;
@property (nonatomic,copy,readonly) NSString *identifier;
@property (nonatomic,strong) id ext;

-(KSActionSheetViewItem *)setTitle:(NSString *)title;
-(KSActionSheetViewItem *)setKey:(NSUInteger)key;
-(KSActionSheetViewItem *)setIdentifier:(NSString *)identifier;

@end


typedef void (^KSActionSheetViewItemSelectedBlock)(KSActionSheetView *actionSheetView, KSActionSheetViewItem* actionItem,id ext);


@interface KSActionSheetView : UIView

@property (nonatomic,copy) void(^willDismissBlk)(void);//nimeide


+ (KSActionSheetView *)showActionSheetWithTitle:(NSString *)title
                              cancelButtonTitle:(NSString *)cancelButtonTitle
                         destructiveButtonTitle:(NSString *)destructiveButtonTitle
                          otherButtonTitleItems:(NSArray<KSActionSheetViewItem *> *)otherButtonTitleItems
                                        handler:(KSActionSheetViewItemSelectedBlock)block;


- (void)show;
- (void)dismiss;
- (void)updateEnableState:(BOOL)enable
               byIndexes:(NSArray<NSNumber *> *)indexes;

@end
