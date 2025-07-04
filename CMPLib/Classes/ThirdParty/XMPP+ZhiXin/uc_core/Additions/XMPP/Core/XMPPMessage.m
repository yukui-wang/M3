#import "XMPPMessage.h"
#import "XMPPJID.h"
#import "NSXMLElement+XMPP.h"

#import <objc/runtime.h>

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif


@implementation XMPPMessage

+ (void)initialize
{
	// We use the object_setClass method below to dynamically change the class from a standard NSXMLElement.
	// The size of the two classes is expected to be the same.
	// 
	// If a developer adds instance methods to this class, bad things happen at runtime that are very hard to debug.
	// This check is here to aid future developers who may make this mistake.
	// 
	// For Fearless And Experienced Objective-C Developers:
	// It may be possible to support adding instance variables to this class if you seriously need it.
	// To do so, try realloc'ing self after altering the class, and then initialize your variables.
	
	size_t superSize = class_getInstanceSize([NSXMLElement class]);
	size_t ourSize   = class_getInstanceSize([XMPPMessage class]);
	
	if (superSize != ourSize)
	{
		NSLog(@"Adding instance variables to XMPPMessage is not currently supported!");
		exit(15);
	}
}

+ (XMPPMessage *)messageFromElement:(NSXMLElement *)element
{
	object_setClass(element, [XMPPMessage class]);
	
	return (XMPPMessage *)element;
}

+ (XMPPMessage *)message
{
	return [[XMPPMessage alloc] init];
}

+ (XMPPMessage *)messageWithType:(NSString *)type
{
	return [[XMPPMessage alloc] initWithType:type to:nil];
}

+ (XMPPMessage *)messageWithType:(NSString *)type to:(XMPPJID *)to
{
	return [[XMPPMessage alloc] initWithType:type to:to];
}

- (id)init
{
	self = [super initWithName:@"message"];
	return self;
}

- (id)initWithType:(NSString *)type
{
	return [self initWithType:type to:nil];
}

- (id)initWithType:(NSString *)type to:(XMPPJID *)to
{
	if ((self = [super initWithName:@"message"]))
	{
		if (type)
			[self addAttributeWithName:@"type" stringValue:type];
		
		if (to)
			[self addAttributeWithName:@"to" stringValue:[to description]];
	}
	return self;
}

- (BOOL)isChatMessage
{
	return [[[self attributeForName:@"type"] stringValue] isEqualToString:@"chat"]||[[[self attributeForName:@"type"] stringValue] isEqualToString:@"groupchat"];
}

- (BOOL)isFiletransMessage
{
	return [[[self attributeForName:@"type"] stringValue] isEqualToString:@"filetrans"];
}

- (BOOL)isMicrotalkMessage
{
	return [[[self attributeForName:@"type"] stringValue] isEqualToString:@"microtalk"];
}

- (BOOL)isImageMessage
{
	return [[[self attributeForName:@"type"] stringValue] isEqualToString:@"image"];
}

- (BOOL)isGroupMessage
{
	return [[[self attributeForName:@"type"] stringValue] isEqualToString:@"groupchat"];
}

- (BOOL)isChatMessageWithBody
{
	if([self isChatMessage])
	{
		return [self isMessageWithBody];
	}
	
	return NO;
}

- (BOOL)isErrorMessage {
    return [[[self attributeForName:@"type"] stringValue] isEqualToString:@"error"];
}

- (NSError *)errorMessage {
    if (![self isErrorMessage]) {
        return nil;
    }
    
    NSXMLElement *error = [self elementForName:@"error"];
    return [NSError errorWithDomain:@"urn:ietf:params:xml:ns:xmpp-stanzas" 
                               code:[error attributeIntValueForName:@"code"] 
                           userInfo:[NSDictionary dictionaryWithObject:[error compactXMLString] forKey:NSLocalizedDescriptionKey]];

}

- (BOOL)isMessageWithBody
{
	NSString *body = [[self elementForName:@"body"] stringValue];
	
	return ([body length] > 0);
}


- (BOOL)isMessageWithMicrotalk
{
	NSString *microtalk = [[self elementForName:@"microtalk"] stringValue];
	
	return ([microtalk length] > 0);
}


- (BOOL)isMessageWithFiletrans
{
	NSString *filetrans = [[self elementForName:@"filetrans"] stringValue];
	
	return ([filetrans length] > 0);
}

- (BOOL)isMessageWithImage{
    NSString *image = [[self elementForName:@"image"] stringValue];
	
	return ([image length] > 0);
}

@end
