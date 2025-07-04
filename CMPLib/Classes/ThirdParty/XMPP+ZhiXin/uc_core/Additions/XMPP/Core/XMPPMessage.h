#import <Foundation/Foundation.h>
#import "XMPPElement.h"

/**
 * The XMPPMessage class represents a <message> element.
 * It extends XMPPElement, which in turn extends NSXMLElement.
 * All <message> elements that go in and out of the
 * xmpp stream will automatically be converted to XMPPMessage objects.
 * 
 * This class exists to provide developers an easy way to add functionality to message processing.
 * Simply add your own category to XMPPMessage to extend it with your own custom methods.
**/

@interface XMPPMessage : XMPPElement

// Converts an NSXMLElement to an XMPPMessage element in place (no memory allocations or copying)
+ (XMPPMessage *)messageFromElement:(NSXMLElement *)element;

+ (XMPPMessage *)message;
+ (XMPPMessage *)messageWithType:(NSString *)type;
+ (XMPPMessage *)messageWithType:(NSString *)type to:(XMPPJID *)to;

- (id)init;
- (id)initWithType:(NSString *)type;
- (id)initWithType:(NSString *)type to:(XMPPJID *)to;

- (BOOL)isChatMessage;
- (BOOL)isFiletransMessage;
- (BOOL)isMicrotalkMessage;
- (BOOL)isImageMessage;
- (BOOL)isGroupMessage;
- (BOOL)isChatMessageWithBody;
- (BOOL)isErrorMessage;

- (BOOL)isMessageWithBody;
- (BOOL)isMessageWithMicrotalk;
- (BOOL)isMessageWithFiletrans;
- (BOOL)isMessageWithImage;

- (NSError *)errorMessage;

@end
