//
//  CMPShareViewLayout.m
//  M3
//
//  Created by MacBook on 2019/10/28.
//

#import "CMPShareViewLayout.h"

@implementation CMPShareViewLayout

- (void)prepareLayout {
    [super prepareLayout];
    
    self.minimumLineSpacing = 0;
    self.minimumInteritemSpacing = 0;
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
}


@end
