//
//  RCPluginBoardView+RTL.m
//  M3
//
//  Created by Shoujian Rao on 2024/5/10.
//

#import "RCPluginBoardView+RTL.h"
#import <objc/runtime.h>
#import <CMPLib/UIView+RTL.h>
@implementation RCPluginBoardView (RTL)
- (void)setFrame:(CGRect)frame {
    
    if ([UIView isRTL]) {
        [super setFrame:frame];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.contentView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated: NO];
        });
    }
    else {
        
//        NSLog(@"ViewController+test  %@", NSStringFromSelector(_cmd));

        unsigned int methodCount;

        Method *methodList = class_copyMethodList([self class], &methodCount);

        for (int i = methodCount - 1; i > 0; i--) {

            Method method = methodList[i];

            SEL sel = method_getName(method);

            IMP imp = method_getImplementation(method);

//            NSLog(@"方法名称： %@", [NSString stringWithUTF8String:sel_getName(sel)]);

            if (sel == _cmd) {
                void (*function)(id, SEL, CGRect) = (void *)imp;
                function(self, sel, frame);
                break;
            }
        }

        free(methodList);
    }
    
//    _pageCtrl.currentPage = 0;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *returnCell;
    unsigned int methodCount;

    Method *methodList = class_copyMethodList([self class], &methodCount);

    for (int i = methodCount - 1; i > 0; i--) {

        Method method = methodList[i];

        SEL sel = method_getName(method);

        IMP imp = method_getImplementation(method);
        if (sel == _cmd) {
            if (sel == _cmd) {
                id (*function)(id, SEL, id, id) = (id (*)(id, SEL, id, id))imp;
                returnCell = function(self, sel, collectionView, indexPath);
           
                break;
            }
            break;
        }
    }

    free(methodList);
    if ([UIView isRTL]) {
        [returnCell setTransform:CGAffineTransformMakeScale(-1, 1)];
    }
    return  returnCell;
}

- (instancetype)initWithFrame:(CGRect)frame {
    RCPluginBoardView *pluView;
    unsigned int methodCount;

    Method *methodList = class_copyMethodList([self class], &methodCount);

    for (int i = methodCount - 1; i > 0; i--) {

        Method method = methodList[i];

        SEL sel = method_getName(method);

        IMP imp = method_getImplementation(method);

        if (sel == _cmd) {
            if (sel == _cmd) {
                id (*function)(id, SEL, CGRect) = (id (*)(id, SEL, CGRect))imp;
                pluView = function(self, sel, frame);
           
                break;
            }
            break;
        }
    }

    free(methodList);
    
    if ([UIView isRTL]) {
        [self.contentView setTransform:CGAffineTransformMakeScale(-1, 1)];
    }
    return  pluView;
}

@end
