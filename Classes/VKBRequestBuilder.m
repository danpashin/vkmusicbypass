//
//  VKBRequestBuilder.m
//  VKMusicBypass
//
//  Created by Даниил on 03/01/2019.
//  Copyright © 2019 Даниил. All rights reserved.
//

#import "VKBRequestBuilder.h"

@implementation VKBRequestBuilder

- (instancetype)init
{
    return [self initWithURL:@"" arguments:@{}];;
}

- (instancetype)initWithURL:(NSString *)url arguments:(NSDictionary *)arguments
{
    return [self initWithURL:url httpMethod:@"GET" arguments:arguments];
}

- (instancetype)initWithURL:(NSString *)url httpMethod:(NSString *)httpMethod arguments:(NSDictionary *)arguments
{
    self = [super init];
    if (self) {
        _url = url;
        _httpMethod = httpMethod;
        _arguments = arguments;
    }
    
    return self;
}

- (NSURLRequest *)buildRequest
{
    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:self.url];
    
    NSMutableString *stringParameters = [NSMutableString string];
    NSArray *sortedKeys = [self.arguments.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    for (NSString *key in sortedKeys) {
        [stringParameters appendFormat:@"%@=%@&", key, self.arguments[key]];
    }
    
    while ([stringParameters hasSuffix:@"&"]) {
        [stringParameters replaceCharactersInRange:NSMakeRange(stringParameters.length - 1, 1) withString:@""];
    }
    
    NSData *requestBody = nil;
    if ([self.httpMethod.lowercaseString isEqualToString:@"get"]) {
        urlComponents.query = stringParameters;
    } else if ([self.httpMethod.lowercaseString isEqualToString:@"post"]) {
        NSString *query = [stringParameters stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        requestBody = [query dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlComponents.URL];
    request.HTTPMethod = self.httpMethod.uppercaseString;
    request.HTTPBody = requestBody;
    
    return request;
}

@end
