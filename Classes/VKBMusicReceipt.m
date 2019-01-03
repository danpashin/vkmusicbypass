//
//  VKBMusicReceipt.m
//  VKMusicBypass
//
//  Created by Даниил on 03/01/2019.
//  Copyright © 2019 Даниил. All rights reserved.
//

#import "VKBMusicReceipt.h"
#import "VKMusicBypass.h"

@implementation VKBMusicReceipt

+ (VKBMusicReceipt * _Nullable)defaultReceipt
{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:vkb_defaultSettingsDomain];
    NSData *receiptData = [userDefaults dataForKey:@"cachedReceipt"];
    if (!receiptData)
        return nil;
    
    if (@available(iOS 11.0, *)) {
        return [NSKeyedUnarchiver unarchivedObjectOfClass:[VKBMusicReceipt class] fromData:receiptData error:nil];
    } else {
        return [NSKeyedUnarchiver unarchiveObjectWithData:receiptData];
    }
}

+ (void)save:(VKBMusicReceipt * _Nullable)receipt
{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:vkb_defaultSettingsDomain];
    
    NSData *receiptData = nil;
    if (receipt) {
        if (@available(iOS 11.0, *)) {
            receiptData = [NSKeyedArchiver archivedDataWithRootObject:receipt requiringSecureCoding:YES error:nil];
        } else {
            receiptData = [NSKeyedArchiver archivedDataWithRootObject:receipt];
        }
    }
    
    [userDefaults setObject:receiptData forKey:@"cachedReceipt"];
}

+ (VKBMusicReceipt * _Nullable)parse:(NSDictionary *)dict
{
    NSDictionary *receiptInfo = dict[@"receipt"];
    if ([receiptInfo isKindOfClass:[NSString class]]) {
        NSString *appBundleID = @"";
        NSString *appBuild = @"";
        
        NSDictionary *applicationInfo = dict[@"application"];
        if ([applicationInfo isKindOfClass:[NSDictionary class]]) {
            appBundleID = applicationInfo[@"bundle_id"] ?: appBundleID;
            appBuild = applicationInfo[@"version"] ?: appBuild;
        }
        
        NSString *base64receipt = receiptInfo[@"string_repr"] ?: @"";
        
        NSString *strType = [receiptInfo[@"type"] lowercaseString];
        VKBMusicReceiptType type = VKBMusicReceiptTypeUnknown;
        if ([strType isEqualToString:@"production"])
            type = VKBMusicReceiptTypeProduction;
        else if ([strType isEqualToString:@"sandbox"])
            type = VKBMusicReceiptTypeSandbox;
        
        
        return [[VKBMusicReceipt alloc] initWithBase64receipt:base64receipt type:type
                                                  appBundleID:appBundleID appBuild:appBuild];
    }
    
    return nil;
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (instancetype)initWithBase64receipt:(NSString *)base64receipt type:(VKBMusicReceiptType)type 
                          appBundleID:(NSString *)appBundleID appBuild:(NSString *)appBuild
{
    self = [super init];
    if (self) {
        _type = type;
        _appBuild = appBuild;
        _appBundleID = appBundleID;
        _base64receipt = base64receipt;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _type = [aDecoder decodeIntegerForKey:@"type"];
        _appBuild = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"appBuild"];
        _appBundleID = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"appBundleID"];
        _base64receipt = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"base64receipt"];
    }
    return self;
}

- (instancetype)init
{
    return [self initWithCoder:nil];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:self.type forKey:@"type"];
    [aCoder encodeObject:self.appBuild forKey:@"appBuild"];
    [aCoder encodeObject:self.appBundleID forKey:@"appBundleID"];
    [aCoder encodeObject:self.base64receipt forKey:@"base64receipt"];
}

@end
