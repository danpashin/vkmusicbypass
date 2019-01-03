//
//  VKBReceiptNetwork.m
//  VKMusicBypass
//
//  Created by Даниил on 03/01/2019.
//  Copyright © 2019 Даниил. All rights reserved.
//

#import "VKBReceiptNetwork.h"
#import "VKBRequestBuilder.h"
#import "VKBMusicReceipt.h"
#import "VKMusicBypass.h"
#import <StoreKit/SKReceiptRefreshRequest.h>

@implementation VKBReceiptNetwork

+ (BOOL)jailed
{
    NSDictionary *environment = NSProcessInfo.processInfo.environment;
    if (environment[@"DYLD_INSERT_LIBRARIES"] || environment[@"_MSSafeMode"])
        return YES;
    
    return NO;
}

+ (void)requestReceiptWithCompletion:(void(^)(void))completion
{
    VKBReceiptNetwork *receiptNetwork = [VKBReceiptNetwork new];
    [receiptNetwork sendJSONRequest:receiptNetwork.receiptGetRequest completion:^(NSHTTPURLResponse * _Nullable httpResponse, 
                                                                                  NSDictionary * _Nullable json,
                                                                                  NSError * _Nullable error) {
        if (error) {
            completion();
            return;
        }
        
        if (json[@"response"]) {
            VKBMusicReceipt *receipt = [VKBMusicReceipt parse:json[@"response"]];
            [VKBMusicReceipt save:receipt];
        }
        
        completion();
    }];
}

+ (void)addReceiptToDatabase
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSString *prodReceiptPath = [NSHomeDirectory() stringByAppendingString:@"/StoreKit/receipt"];
        NSString *sandboxReceiptPath = [NSHomeDirectory() stringByAppendingString:@"/StoreKit/sandboxReceipt"];
        
        NSData *origReceipt = nil;
        NSString *receiptType = @"production";
        if ([[NSFileManager defaultManager] fileExistsAtPath:prodReceiptPath])
            origReceipt = [NSData dataWithContentsOfFile:prodReceiptPath];
        else if ([[NSFileManager defaultManager] fileExistsAtPath:sandboxReceiptPath]) {
            receiptType = @"sandbox";
            origReceipt = [NSData dataWithContentsOfFile:sandboxReceiptPath];
        }
        
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:vkb_defaultSettingsDomain];
        
        if (!origReceipt) {
            if (self.jailed && ![userDefaults boolForKey:@"receiptRefreshed"]) {
                [userDefaults setBool:YES forKey:@"receiptRefreshed"];
                
                SKReceiptRefreshRequest *refreshRequest = [[SKReceiptRefreshRequest alloc] initWithReceiptProperties:nil];
                [refreshRequest start];
            }
            return;
        }
        
        NSData *cachedReceipt = [userDefaults dataForKey:@"originalReceipt"];
        if ([cachedReceipt isEqual:origReceipt])
            return;
        
        [userDefaults setObject:origReceipt forKey:@"originalReceipt"];
        
        CFBundleRef mainBundle = CFBundleGetMainBundle();
        NSString *appBuild = (__bridge NSString *)CFBundleGetValueForInfoDictionaryKey(mainBundle, kCFBundleVersionKey);
        
        NSString *url = [vkb_apiURL stringByAppendingString:@"receipt/add.php"];
        NSDictionary *params = @{@"type":receiptType, @"app_version":appBuild ?: @"", 
                                 @"receipt":origReceipt, @"bid":[NSBundle mainBundle].bundleIdentifier?:@""};
        
        VKBRequestBuilder *requestBuilder = [[VKBRequestBuilder alloc] initWithURL:url arguments:params];
        
        VKBReceiptNetwork *receiptNetwork = [VKBReceiptNetwork new];
        [receiptNetwork sendJSONRequest:requestBuilder.request completion:nil];
    });
}

- (NSURLRequest *)receiptGetRequest
{
    NSURL *receiptURL = [NSBundle mainBundle].appStoreReceiptURL;
    NSString *receiptType = [receiptURL.absoluteString containsString:@"/sandboxReceipt"] ? @"sandbox" : @"production";
    BOOL jailed = self.class.jailed;
    
    NSString *url = [vkb_apiURL stringByAppendingString:@"receipt/get.php"];
    NSDictionary *params = @{@"tid":vkb_certificateTID ?: @"", @"type":receiptType, @"jailed":@(jailed)};
    
    VKBRequestBuilder *requestBuilder = [[VKBRequestBuilder alloc] initWithURL:url arguments:params];
    return requestBuilder.request;
}

- (void)sendJSONRequest:(NSURLRequest *)request completion:(void(^_Nullable)(NSHTTPURLResponse * _Nullable httpResponse, 
                                                                    NSDictionary * _Nullable json,
                                                                    NSError * _Nullable error))completion
{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if (![httpResponse.MIMEType.lowercaseString containsString:@"json"]) {
                NSError *parseError = [NSError errorWithDomain:NSCocoaErrorDomain code:1003 
                                                      userInfo:@{NSLocalizedDescriptionKey:
                                                                     @"Response has invalid content-type header"}];
                if (completion)
                    completion(httpResponse, nil, parseError);
                
                return;
            }
            
            NSError *jsonError = nil;
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if ([jsonDict isKindOfClass:[NSDictionary class]] && !jsonError) {
                if (completion)
                    completion(httpResponse, jsonDict, nil);
            } else {
                if (completion)
                    completion(httpResponse, nil, jsonError);
            }
        });
    }];
    [task resume];
}


@end
