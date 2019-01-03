//
//  VKBRequestBuilder.h
//  VKMusicBypass
//
//  Created by Даниил on 03/01/2019.
//  Copyright © 2019 Даниил. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VKBRequestBuilder : NSObject

/**
 Адрес сервера, на который делается запрос.
 */
@property (strong, nonatomic, readonly) NSString *url;

/**
 Метод запроса. GET или POST.
 */
@property (strong, nonatomic, readonly) NSString *httpMethod;

/**
 Аргументы для запроса.
 */
@property (strong, nonatomic, readonly) NSDictionary *arguments;

- (instancetype)initWithURL:(NSString *)url arguments:(NSDictionary *)arguments;
- (instancetype)initWithURL:(NSString *)url httpMethod:(NSString *)httpMethod arguments:(NSDictionary *)arguments NS_DESIGNATED_INITIALIZER;


/**
 Выполняет построение запроса из предоставленных данных.
 */
@property (nonatomic, readonly, getter=buildRequest) NSURLRequest *request;

@end

NS_ASSUME_NONNULL_END
