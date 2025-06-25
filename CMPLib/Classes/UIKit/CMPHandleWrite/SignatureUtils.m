//
//  SignatureUtils.m
//  SeeyonFlow
//
//  Created by administrator on 11-8-27.
//  Copyright 2011年 北京致远协创软件有限公司. All rights reserved.
//

#import "SignatureUtils.h"
#import "SyBase64.h"
#import <QuartzCore/QuartzCore.h>
#import "CMPFileManager.h"
#import <CMPLib/NSData+Base64.h>

@implementation SignatureUtils

+ (NSString *)createUUID 
{
    CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidStr = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidObject);
    CFRelease(uuidObject);
    return [uuidStr autorelease];
}

+ (NSString *)encodeBase64:(NSData *)theData 
{
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
}

+ (NSData *)decodeBase64:(NSString *)input 
{
    Byte inputData[[input lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
    [[input dataUsingEncoding:NSUTF8StringEncoding] getBytes:inputData];
    size_t inputDataSize = (size_t)[input length];
    size_t outputDataSize = EstimateBas64DecodedDataSize(inputDataSize);
    Byte outputData[outputDataSize];
    Base64DecodeData(inputData, inputDataSize, outputData, &outputDataSize);
    NSData *resultData = [[[NSData alloc] initWithBytes:outputData length:outputDataSize] autorelease];
    return  resultData;
}

+ (NSString *)encodeBase64_str:(NSString *)aStr
{
	NSData *data = [aStr dataUsingEncoding:NSUTF8StringEncoding];
	return [SignatureUtils encodeBase64:data];
}

+ (NSString *)decodeBase64_str:(NSString *)input 
{
//    Byte inputData[[input lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
//    [[input dataUsingEncoding:NSUTF8StringEncoding] getBytes:inputData];
//    size_t inputDataSize = (size_t)[input length];
//    size_t outputDataSize = EstimateBas64DecodedDataSize(inputDataSize);
//    Byte outputData[outputDataSize];
//    Base64DecodeData(inputData, inputDataSize, outputData, &outputDataSize);
//    NSString *str = [[[NSString alloc] initWithBytes:outputData length:outputDataSize
//                                            encoding:NSUTF8StringEncoding] autorelease];
//    return  str;
    NSData *data = [NSData base64Decode:input];
    NSString *str = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    return str;
}

+ (NSString *)getSignatureResult:(NSString *)initValue image:(UIImage *)aImage userName:(NSString *)aName 
                            layoutType:(NSInteger)iType initSize:(CGSize)initSize
{
    if (initValue.length == 0 && !aImage) {
        return @"";
    }
    
    NSString *dataStr = [SignatureUtils decodeBase64_str:initValue];
    if (dataStr == nil || dataStr.length == 0) {
        dataStr = @"";
    }
    NSMutableString *nstr = [[[NSMutableString alloc] initWithString:dataStr] autorelease];
    [nstr replaceOccurrencesOfString:@"\r" withString:@""
                                  options:NSBackwardsSearch range:NSMakeRange(0, [nstr length])];
    
    NSMutableDictionary *pairs = [[NSMutableDictionary alloc] init];
    NSArray *array = [nstr componentsSeparatedByString:@"\n"];
    for (NSString *pairString in array) {
        NSArray *pair = [pairString componentsSeparatedByString:@"="];
        if ([pair count] > 1) {
            [pairs setObject:[pair objectAtIndex:1] forKey:[pair objectAtIndex:0]]; 
        }
    }
    
    CGSize imageSize = aImage.size;
    CGSize newFrame = CGSizeMake(imageSize.width, imageSize.height);
    NSInteger stX = 0;
    NSInteger stY = 0;
    NSInteger endX = 0;
    NSInteger endY = 0;
    NSString *allPositionStr = [pairs objectForKey:@"AllPosition"];
	// add by guoyl for bug
	NSString *oldValue = [pairs objectForKey:aName];
	UIImage *oldImage = nil;
	if (oldValue) {
		NSData *oldData = [SignatureUtils decodeBase64:oldValue];
		oldImage = [UIImage imageWithData:oldData];
	}
	// add end
    NSUInteger tHeight = 0;
    if (allPositionStr && allPositionStr.length > 0) {
        NSArray *pts = [allPositionStr componentsSeparatedByString:@","];
        stX = [[pts objectAtIndex:0] integerValue];
        endX = [[pts objectAtIndex:1] integerValue];
        stY = [[pts objectAtIndex:2] integerValue];
        endY = [[pts objectAtIndex:3] integerValue];
        
//        endX = initSize.width + stX;
		
        if (iType == kLayoutSignatureImageType_Vertical) {
            tHeight = endY - stY;
			if (oldImage.size.height > tHeight) {
				tHeight = oldImage.size.height;
			}
			if (tHeight == 0) {
				newFrame.height = imageSize.height + oldImage.size.height;
			}
			else {
				newFrame.height = tHeight + imageSize.height;
				endY = newFrame.height;
			}
        }
        if (iType == kLayoutSignatureImageType_Cover && (imageSize.height + stY) > endY) {
            endY = initSize.height + stY;
        }
        NSString *aStr = [NSString stringWithFormat:@"%ld,%ld,%ld,%ld,", (long)stX, (long)endX, (long)stY, (long)endY];
        [pairs setObject:aStr forKey:@"AllPosition"];  
    }
    
    if ([pairs objectForKey:@"UserCount"] == nil) {
         [pairs setObject:@"0" forKey:@"UserCount"];
    }
    if ([pairs objectForKey:@"UserList"] == nil) {
        [pairs setObject:@"" forKey:@"UserList"];
    }
    if ([pairs objectForKey:@"AllPosition"] == nil) {
        NSInteger allPtX = initSize.width;
        //表单中同一个控件如果多余1个人手写签名，多出的人的签名在PC端看不到
        NSInteger allPtY = imageSize.height;
		if (initSize.height == 0) {
			allPtY = initSize.height;
		}
        NSString *allPtStr = [NSString stringWithFormat:@"%d,%ld,%d,%ld,", 0, (long)allPtX, 0, (long)allPtY];
        [pairs setObject:allPtStr forKey:@"AllPosition"];
    }
    if ([pairs objectForKey:@"Version"] == nil) {
        [pairs setObject:@"6.0.0.96" forKey:@"Version"];
    }
    
    UIImage *resultImage = aImage;
    if (oldImage) {
        if (newFrame.width < oldImage.size.width) {
            newFrame.width = oldImage.size.width;
        }
        if (newFrame.height < oldImage.size.height && iType == kLayoutSignatureImageType_Cover) {
            newFrame.height = oldImage.size.height;
        }
        UIGraphicsBeginImageContext(newFrame);
        [oldImage drawInRect:CGRectMake(0, 0, oldImage.size.width, oldImage.size.height)];
		// add by guoyl for bug OA-81866 at 20150528
		if (iType == kLayoutSignatureImageType_Vertical && tHeight < oldImage.size.height) {
			tHeight = oldImage.size.height;
		}
		// add end
        [aImage drawInRect:CGRectMake(0, tHeight, imageSize.width, imageSize.height)];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    else {
		//
		if (tHeight == 0) {
			NSString *userListStr = [pairs objectForKey:@"UserList"];
			NSArray *userList = [userListStr componentsSeparatedByString:@","];
			if (userList.count > 1) {
				// 找最高的UIIamge
				for (int i = 0; i < userList.count; i ++) {
					NSString *user = [userList objectAtIndex:i];
					NSString *picStr = [pairs objectForKey:user];
					if (picStr == nil || picStr.length == 0) {
						continue;
					}
					NSData *picData = [SignatureUtils decodeBase64:picStr];
					UIImage *picImage = [UIImage imageWithData:picData];
					if (picImage.size.height > tHeight) {
						tHeight = picImage.size.height;
					}
				}
				newFrame.height += tHeight;
			}
		}
		// end
        NSInteger userCount = [[pairs objectForKey:@"UserCount"] integerValue];
        userCount ++;
        [pairs setObject:[NSString stringWithFormat:@"%ld",(long)userCount] forKey:@"UserCount"];
        NSMutableString *userNames = [NSMutableString stringWithString:[pairs objectForKey:@"UserList"]];
        [userNames appendFormat:@"%@,", aName];
        [pairs setObject:userNames forKey:@"UserList"];
        
        [pairs setObject:@"-1" 
                  forKey:[NSString stringWithFormat:@"%@Modified", aName]];
        
        [pairs setObject:@"0" 
                  forKey:[NSString stringWithFormat:@"%@HasCASign", aName]];
        // add by guoyl at 2016/8/17
//        [pairs setObject:@"1"
//                  forKey:[NSString stringWithFormat:@"%@Phone", aName]];
        // add end
		UIGraphicsBeginImageContext(newFrame);
        [aImage drawInRect:CGRectMake(0, tHeight, imageSize.width, imageSize.height)];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
   
    NSData *data = UIImagePNGRepresentation(resultImage);
    NSString *str = [SignatureUtils encodeBase64:data];
    [pairs setObject:str forKey:aName];
    NSInteger w = newFrame.width;
    NSInteger h = newFrame.height;
    NSString *sizeStr = [NSString stringWithFormat:@"%ld,%ld,%ld,%ld,", (long)stX, (long)w+stX, (long)stY, (long)h+stY];
    [pairs setObject:sizeStr forKey:[NSString stringWithFormat:@"%@Position", aName]];
    
    NSMutableString *result = [[NSMutableString alloc] init];
    NSArray *allKeys = [pairs allKeys];
    for (NSString *aKey in allKeys) {
        NSString *aValue = [pairs objectForKey:aKey];
        [result appendString:aKey];
        [result appendString:@"="];
        [result appendString:aValue];
        [result appendString:@"\n"];
    }
    
    NSString *base64Str = [SignatureUtils encodeBase64:[result dataUsingEncoding:NSUTF8StringEncoding]];
    
    [result release];
    [pairs removeAllObjects];
    [pairs release];
    
    return base64Str;
}


+ (NSDictionary *)picDataStrWithInitValue:(NSString *)value
{
    if (value.length == 0) {
        return nil;
    }
    
    NSString *dataStr = [SignatureUtils decodeBase64_str:value];
    if (dataStr == nil || dataStr.length == 0) {
        dataStr = @"";
    }
    NSMutableString *nstr = [[[NSMutableString alloc] initWithString:dataStr] autorelease];
    [nstr replaceOccurrencesOfString:@"\r" withString:@""
                             options:NSBackwardsSearch range:NSMakeRange(0, [nstr length])];
    NSMutableDictionary *pairs = [[NSMutableDictionary alloc] init];
    NSArray *array = [nstr componentsSeparatedByString:@"\n"];
    for (NSString *pairStr in array) {
        NSArray *pair = [pairStr componentsSeparatedByString:@"="];
        if ([pair count] > 1){
            [pairs setObject:[pair objectAtIndex:1] forKey:[pair objectAtIndex:0]]; 
        }
    }
    
    NSString *userListStr = [pairs objectForKey:@"UserList"];
    NSArray *userList = [userListStr componentsSeparatedByString:@","];
    if (userList.count <= 1) {
        [pairs release];
        return nil;
    }
    
    NSString *allPositionStr = [pairs objectForKey:@"AllPosition"];
    NSArray *points = [allPositionStr componentsSeparatedByString:@","];
//    CGFloat X0 = [[points objectAtIndex:0] floatValue];
    CGFloat X1 = [[points objectAtIndex:1] floatValue];
//    CGFloat Y0 = [[points objectAtIndex:2] floatValue];
    CGFloat Y1 = [[points objectAtIndex:3] floatValue];
    CGRect frame = CGRectMake(0, 0, X1, Y1);
	
	NSMutableArray *imageList = [[NSMutableArray alloc] init];
    CGFloat maxWidth = 0;
    for (int i = 0; i < userList.count; i ++) {
        NSString *user = [userList objectAtIndex:i]; 
        NSString *picStr = [pairs objectForKey:user];
        if (picStr == nil || picStr.length == 0) {
            continue;
        }
        NSData *picData = [SignatureUtils decodeBase64:picStr];
        UIImage *picImage = [UIImage imageWithData:picData];
		if (frame.size.height < picImage.size.height) {
			frame.size.height = picImage.size.height;
		}
		if (frame.size.width < picImage.size.width) {
			frame.size.width = picImage.size.width;
		}
		[imageList addObject:picImage];
        if (picImage.size.width > maxWidth) {
            maxWidth = picImage.size.width;
        }
    }
    
    UIGraphicsBeginImageContext(CGSizeMake(maxWidth, frame.size.height));
	for (UIImage *picImage in imageList) {
		CGRect picFrame = CGRectMake(0, 0, picImage.size.width, picImage.size.height);
		[picImage drawInRect:picFrame];
	}
	[imageList release];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [pairs removeAllObjects];
    [pairs release];
    
    NSData *data = UIImageJPEGRepresentation(resultingImage, 0.5);
    NSString *aSizeStr = NSStringFromCGSize(frame.size);
    NSString *aValue = [SignatureUtils encodeBase64:data];
    return [NSDictionary dictionaryWithObjectsAndKeys:aSizeStr, @"size", aValue, @"value", nil];
}

+ (BOOL)isBase64Data:(NSString *)input
{
	if ([NSString isNull:input]) {
		return NO;
	}
    input=[[input componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsJoinedByString:@""];
    if ([input length] % 4 == 0) {
		NSCharacterSet *invertedBase64CharacterSet = nil;
        if (invertedBase64CharacterSet == nil) {
            invertedBase64CharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="]invertedSet];
        }
        return [input rangeOfCharacterFromSet:invertedBase64CharacterSet options:NSLiteralSearch].location == NSNotFound;
    }
    return NO;
}

@end
