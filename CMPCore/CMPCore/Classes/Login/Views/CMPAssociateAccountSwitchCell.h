//
//  CMPAssociateAccountSwitchCell.h
//  M3
//
//  Created by CRMO on 2018/6/19.
//

#import <UIKit/UIKit.h>

@interface CMPAssociateAccountSwitchCell : UITableViewCell

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *server;
@property (assign, nonatomic) BOOL showCheck;

- (void)showBottomLine;
- (void)hideBottomLine;

@end
