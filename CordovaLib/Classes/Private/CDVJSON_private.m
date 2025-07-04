/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import "CDVJSON_private.h"
#import <Foundation/NSJSONSerialization.h>
//#import <CMPLib/YYModel.h>

@implementation NSArray (CDVJSONSerializingPrivate)

- (NSString*)cdv_JSONString
{
    @autoreleasepool {
        
        
        NSData* jsonData = [self performSelector:@selector(yy_modelToJSONData)];
        if (jsonData) {
            return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }else {
            NSLog(@"NSArray JSONString error");
            return nil;
        }
        
        
//    dataWithJSONObject这个方法的第一个参数不能为空,否则，会导致crash。还有如果第一个参数很大的话，会导致crash
//        NSError* error = nil;
//        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:self
//                                                           options:NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments
//                                                             error:&error];
//        if (error != nil) {
//            NSLog(@"NSArray JSONString error: %@", [error localizedDescription]);
//            return nil;
//        } else {
//            return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        }
    }
}

@end

@implementation NSDictionary (CDVJSONSerializingPrivate)

- (NSString*)cdv_JSONString
{
    @autoreleasepool {
        NSError* error = nil;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        
        if (error != nil) {
            NSLog(@"NSDictionary JSONString error: %@", [error localizedDescription]);
            return nil;
        } else {
            return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
    }
}

@end

@implementation NSString (CDVJSONSerializingPrivate)

- (id)cdv_JSONObject
{
    @autoreleasepool {
        NSError* error = nil;
        id object = [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:NSJSONReadingMutableContainers
                                                      error:&error];
        
        if (error != nil) {
            NSLog(@"NSString JSONObject error: %@", [error localizedDescription]);
        }
        
        return object;
    }
}

- (id)cdv_JSONFragment
{
    @autoreleasepool {
        NSError* error = nil;
        id object = [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:NSJSONReadingAllowFragments
                                                      error:&error];
        
        if (error != nil) {
            NSLog(@"NSString JSONObject error: %@", [error localizedDescription]);
        }
        
        return object;
    }
}

@end
