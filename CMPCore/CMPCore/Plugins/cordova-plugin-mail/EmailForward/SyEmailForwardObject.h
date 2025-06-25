//
//  SyEmailForwardObject.h
//  M1Core
//
//  Created by kaku_songu on 14-11-4.
//
//

#import <Foundation/Foundation.h>

@interface SyEmailForwardObject : NSObject

@property (nonatomic,retain) NSString   *subjectString;
@property (nonatomic,retain) NSString   *messageBodyString;
@property (nonatomic,retain) NSData     *attachmentData;
@property (nonatomic,retain) NSString   *attachmentType;
@property (nonatomic,retain) NSString   *attaName;
@property (nonatomic,retain) NSString   *receiver;//接收者

@end
