//
//  CMPAssociateAccountListCell.h
//  M3
//
//  Created by CRMO on 2018/6/11.
//

#import <UIKit/UIKit.h>

@interface CMPAssociateAccountListCell : UITableViewCell

@property (strong, nonatomic) NSString *shortName;
@property (strong, nonatomic) NSString *fullUrl;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *note;
@property (assign, nonatomic) BOOL showEdit;

@end
