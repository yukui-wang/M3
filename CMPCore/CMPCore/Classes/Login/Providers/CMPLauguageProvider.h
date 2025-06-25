//
//  CMPLauguageProvider.h
//  M3
//
//  Created by 程昆 on 2019/6/17.
//

#import <CMPLib/CMPObject.h>

typedef void(^GetLauguageListDidSuccess)(NSArray *languageList,NSString *seccessMesssage);
typedef void(^GetLauguageListDidFail)(NSError *failError);


@interface CMPLauguageProvider : CMPObject

- (void)getLanguageListSuccess:(GetLauguageListDidSuccess)success
                          fail:(GetLauguageListDidFail)fail;

@end

