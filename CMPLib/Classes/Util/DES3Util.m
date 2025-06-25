//
//  DES3Util.m
//  CMPLib
//
//  Created by youlin on 2016/9/14.
//  Copyright © 2016年 CMPCore. All rights reserved.
//

#import "DES3Util.h"
#import <CommonCrypto/CommonCryptor.h>

#define kAES128BlockSize	    kCCBlockSizeAES128
#define kAES128KeySize	        kCCKeySizeAES128

@implementation DES3Util

CCOptions encryptPadding = kCCOptionPKCS7Padding;

+ (NSData*) hexToBytes:(NSString*)strHex {
    NSMutableData* data = [[[NSMutableData alloc] init] autorelease];
    int idx;
    for (idx = 0; idx+2 <= strHex.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [strHex substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}

/*解密数据forAES128*/
+ (NSString *)decryptDataAES128:(NSString *)str passwordKey:(NSString *)aKey
{
    NSData *decryptData = [self doCipherAES128:[DES3Util hexToBytes:str] key:[aKey dataUsingEncoding:NSASCIIStringEncoding] context:kCCDecrypt padding:&encryptPadding];
    NSString *strText = [[[NSString alloc] initWithData:decryptData encoding:NSUTF8StringEncoding] autorelease];
    return strText;
}

+ (NSData*) doCipherAES128:(NSData *)plainText key:(NSData *)aSymmetricKey
                   context:(CCOperation)encryptOrDecrypt padding:(CCOptions *)pkcs7
{
    CCCryptorStatus ccStatus = kCCSuccess;
    // Symmetric crypto reference.
    CCCryptorRef thisEncipher = NULL;
    // Cipher Text container.
    NSData * cipherOrPlainText = nil;
    // Pointer to output buffer.
    uint8_t * bufferPtr = NULL;
    // Total size of the buffer.
    size_t bufferPtrSize = 0;
    // Remaining bytes to be performed on.
    size_t remainingBytes = 0;
    // Number of bytes moved to buffer.
    size_t movedBytes = 0;
    // Length of plainText buffer.
    size_t plainTextBufferSize = 0;
    // Placeholder for total written.
    size_t totalBytesWritten = 0;
    // A friendly helper pointer.
    uint8_t * ptr;
    
    // Initialization vector; dummy in this case 0's.
    uint8_t iv[kAES128BlockSize];
    memset((void *) iv, 0x0, (size_t) sizeof(iv));
    
    //NSLog(@"doCipher AES128: plaintext: %@", plainText);
    NSLog(@"doCipher AES128: key length: %lu", (unsigned long)[aSymmetricKey length]);
    
    plainTextBufferSize = [plainText length];
    
    NSLog(@"AES128 pkcs7: %d", *pkcs7);
    // We don't want to toss padding on if we don't need to
    if(encryptOrDecrypt == kCCEncrypt) {
        if(*pkcs7 != kCCOptionECBMode) {
            if((plainTextBufferSize % kAES128BlockSize) == 0) {
                *pkcs7 = 0x0000;
            } else {
                *pkcs7 = kCCOptionPKCS7Padding;
            }
        }
    } else if(encryptOrDecrypt != kCCDecrypt) {
        NSLog(@"Invalid CCOperation parameter [%d] for AES128 cipher context.", *pkcs7 );
    }
    
    // Create and Initialize the crypto reference.
    ccStatus = CCCryptorCreate(encryptOrDecrypt,
                               kCCAlgorithmAES128,
                               *pkcs7 + kCCOptionECBMode,
                               (const void *)[aSymmetricKey bytes],
                               kAES128KeySize,
                               (const void *)iv,
                               &thisEncipher
                               );
    
    
    //LOGGING_FACILITY1( ccStatus == kCCSuccess, @"Problem creating the context, ccStatus == %d.", ccStatus );
    
    // Calculate byte block alignment for all calls through to and including final.
    bufferPtrSize = CCCryptorGetOutputLength(thisEncipher, plainTextBufferSize, true);
    
    // Allocate buffer.
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t) );
    
    // Zero out buffer.
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    // Initialize some necessary book keeping.
    
    ptr = bufferPtr;
    
    // Set up initial size.
    remainingBytes = bufferPtrSize;
    
    // Actually perform the encryption or decryption.
    ccStatus = CCCryptorUpdate(thisEncipher,
                               (const void *) [plainText bytes],
                               plainTextBufferSize,
                               ptr,
                               remainingBytes,
                               &movedBytes
                               );
    
    //LOGGING_FACILITY1( ccStatus == kCCSuccess, @"Problem with CCCryptorUpdate, ccStatus == %d.", ccStatus );
    
    // Handle book keeping.
    ptr += movedBytes;
    remainingBytes -= movedBytes;
    totalBytesWritten += movedBytes;
    
    // Finalize everything to the output buffer.
    ccStatus = CCCryptorFinal(thisEncipher,
                              ptr,
                              remainingBytes,
                              &movedBytes
                              );
    
    totalBytesWritten += movedBytes;
    
    if(thisEncipher) {
        (void) CCCryptorRelease(thisEncipher);
        thisEncipher = NULL;
    }
    
    //LOGGING_FACILITY1( ccStatus == kCCSuccess, @"Problem with encipherment ccStatus == %d", ccStatus );
    
    if (ccStatus == kCCSuccess)
        cipherOrPlainText = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)totalBytesWritten];
    else
        cipherOrPlainText = nil;
    
    if(bufferPtr) free(bufferPtr);
    
    return cipherOrPlainText;
}

@end
