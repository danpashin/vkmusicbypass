//
//  Swizzle.m
//  VKMusicBypass
//
//  Created by Даниил on 03/01/2019.
//  Copyright © 2019 Даниил. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CaptainHook.h"
#import "VKBMusicReceipt.h"
#import "VKBReceiptNetwork.h"

BOOL vkb_shouldBypassMusic = NO;
NSString *vkb_certificateTID = nil;

void *executeMethod(id target, SEL selector, id arguments, ...) NS_REQUIRES_NIL_TERMINATION;

@interface AuthModel : NSObject
- (NSString *)base64ReceiptString;
@end

@interface MOReceiptRefreshRequest : NSObject
- (void)requestDidFinish:(id)arg1;
@end

CHDeclareClass(AuthModel);
CHDeclareClassMethod(0, NSString *, AuthModel, base64ReceiptString)
{
    NSString *receipt = CHSuper(0, AuthModel, base64ReceiptString);
    
    if (vkb_shouldBypassMusic && !receipt) {
        VKBMusicReceipt *defaultReceipt = VKBMusicReceipt.defaultReceipt;
        if ([defaultReceipt isKindOfClass:[VKBMusicReceipt class]])
            receipt = defaultReceipt.base64receipt;
    }
    
    return receipt;
}

CHDeclareClass(MOReceiptRefreshRequest);
CHDeclareMethod(0, void, MOReceiptRefreshRequest, start)
{
    if (vkb_shouldBypassMusic) {
        [VKBReceiptNetwork requestReceiptWithCompletion:^{
            executeMethod(self, @selector(requestDidFinish:), self, nil);
        }];
        return;
    }
    
    CHSuper(0, MOReceiptRefreshRequest, start);
}




void *executeMethod(id target, SEL selector, id arguments, ...)
{
    if (![target respondsToSelector:selector])
        return nil;
    
    NSMethodSignature *signature = [target methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = target;
    invocation.selector = selector;
    
    if (arguments) {
        [invocation setArgument:&arguments atIndex:2];
        va_list args;
        va_start(args, arguments);
        
        NSInteger argumentIndex = 3;
        id argument = nil;
        while ((argument = va_arg(args,id))) {
            [invocation setArgument:&argument atIndex:argumentIndex];
            argumentIndex++;
        }
        va_end(args);
    }
    [invocation invoke];
    
    void *result = NULL;
    if (strcmp(signature.methodReturnType, "v") != 0)
        [invocation getReturnValue:&result];
    
    return result;
}
