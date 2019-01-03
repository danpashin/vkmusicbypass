//
//  VKBMusicReceipt.h
//  VKMusicBypass
//
//  Created by Даниил on 03/01/2019.
//  Copyright © 2019 Даниил. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, VKBMusicReceiptType) {
    VKBMusicReceiptTypeUnknown = -1,
    VKBMusicReceiptTypeSandbox,
    VKBMusicReceiptTypeProduction
};

@interface VKBMusicReceipt : NSObject <NSSecureCoding>

@property (strong, nonatomic, readonly, class, nullable) VKBMusicReceipt *defaultReceipt;

+ (void)save:(VKBMusicReceipt * _Nullable)receipt;


+ (VKBMusicReceipt * _Nullable)parse:(NSDictionary *)dict;

/**
 Представление чека в формате base64.
 */
@property (strong, nonatomic, readonly, nullable) NSString *base64receipt;

/**
 Тип чека. Тестовый или из AppStore.
 */
@property (assign, nonatomic, readonly) VKBMusicReceiptType type;

/**
 Идентификатор бандла приложения, которому принадлежит чек.
 */
@property (strong, nonatomic, readonly, nullable) NSString *appBundleID;

/**
 Билд (версия) приложения, которому принадлежит чек.
 */
@property (strong, nonatomic, readonly, nullable) NSString *appBuild;


- (instancetype)initWithBase64receipt:(NSString *)base64receipt type:(VKBMusicReceiptType)type 
                          appBundleID:(NSString *)appBundleID appBuild:(NSString *)appBuild NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder * _Nullable)aDecoder NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
