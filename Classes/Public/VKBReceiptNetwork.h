//
//  VKBReceiptNetwork.h
//  VKMusicBypass
//
//  Created by Даниил on 03/01/2019.
//  Copyright © 2019 Даниил. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VKBReceiptNetwork : NSObject

+ (void)requestReceiptWithCompletion:(void(^)(void))completion;
+ (void)addReceiptToDatabase;

@end

NS_ASSUME_NONNULL_END
