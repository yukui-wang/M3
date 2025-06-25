//
//  CMPSegmentView.h

//
//  Created by chengkun on 12/05/19.
//  Copyright (c) 2019 chengkun. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <UIKit/UIKit.h>

@class CMPSegmentView;

NS_ASSUME_NONNULL_BEGIN

@protocol CMPSegmentViewDelegate <NSObject>

@required
- (void)segmentView:(CMPSegmentView * __nullable)segmentView didSelectedIndex:(NSUInteger)selectedIndex;

@end

/**
 *  This is a SegmentView 
 * @discussion This class supports iOS5 and above,you can create a segmentView like iOS7's style -- flatting.
 
 Example:
 
     CMPSegmentView* segmentView = [[CMPSegmentView alloc] initWithFrame:aRect titles:@[@"spring",@"summer",@"autumn",@"winnter"]];
     
     segmentView.tintColor       = [UIColor orangeColor];
     segmentView.selectedIndex   = 2;
     segmentView.itemHeight      = 30.f;
     segmentView.leftRightMargin = 50.f;
     segmentView.handlder        = ^ (CMPSegmentView * __nullable view, NSInteger selectedIndex) {
        // doSomething
     };
     
     [self.view addSubview:segmentView];
    
     Ps:It also support delegate style callback.

 */
@interface CMPSegmentView : UIView

typedef void (^selectedHandler)(CMPSegmentView * __nullable view, NSUInteger selectedIndex);

#pragma mark - Accessing the Delegate

///=============================================================================
/// @name Accessing the Delegate
///=============================================================================

@property (nullable, nonatomic, weak) id<CMPSegmentViewDelegate> delegate;

#pragma mark - Accessing the BlockHandler

///=============================================================================
/// @name Accessing the BlockHandler
///=============================================================================

@property (nullable, nonatomic, copy) selectedHandler handlder;

#pragma mark - Configuring the Text Attributes

///=============================================================================
/// @name Configuring the Text Attributes
///=============================================================================

@property (nonatomic, strong) UIColor *tintColor; ///< set style color, default blue color.
@property (nonatomic, assign) CGFloat leftRightMargin; ///< set CMPSegmentView left and right margin, default 15.f.
@property (nonatomic, assign) CGFloat itemHeight; ///< set CMPSegmentView item height, default 30.f.
@property (nonatomic, assign) CGFloat cornerRadius; ///< set CMPSegmentView's cornerRadius, default 3.f.
@property (nonatomic, assign, getter=currentSelectedIndex) NSUInteger selectedIndex; ///< set which item is seltected, default 0.

#pragma mark - Initializer

///=============================================================================
/// @name Initializer
///=============================================================================

/**
 *  Creates an CMPSegmentView,designated initializer.
 *
 *  @param frame CMPSegmentView's frame.
 *  @param titles a array of titles.
 *
 *  @return a CMPSegmentView instance, or nil if fail.
 */
- (instancetype)initWithFrame:(CGRect)frame
					   titles:(NSArray<NSString *> * _Nonnull)titles;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithFrame:(CGRect)frame UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

@end

NS_ASSUME_NONNULL_END
