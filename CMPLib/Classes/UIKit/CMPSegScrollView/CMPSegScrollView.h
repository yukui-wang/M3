//
//  CMPSegScrollView.h
//  CMPLib
//
//  Created by Kaku Songu on 4/7/21.
//  Copyright © 2021 crmo. All rights reserved.
//

#import "CMPBaseView.h"
@protocol CMPSegScrollViewDelegate;
NS_ASSUME_NONNULL_BEGIN

@interface CMPSegScrollViewItem : NSObject
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *identifier;
@property (nonatomic,copy) NSString *extra;
@end


@interface CMPSegScrollView : CMPBaseView
@property (nonatomic,strong) NSArray<CMPSegScrollViewItem *> *itemsArr;
@property (nonatomic,assign) NSInteger index;
@property (nonatomic,weak) id<CMPSegScrollViewDelegate> delegate;
@end


@protocol CMPSegScrollViewDelegate <NSObject>

-(void)cmpSegScrollView:(CMPSegScrollView *)segScrollView didClickItem:(CMPSegScrollViewItem *)itemModel;

@end

NS_ASSUME_NONNULL_END
