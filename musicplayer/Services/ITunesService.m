//
//  ITunesService.m
//  musicplayer
//
//  Created by Oscar on 09/09/23.
//

#import "ITunesService.h"
#import "AFNetworking.h"

@implementation ITunesService

- (void)getITunesSongListByArtistName:(nonnull NSString *)artistName onComplete:(nonnull void (^)(BaseAPIResponse<NSDictionary *> * _Nonnull))onFinish {
    NSString* apiUrlString = [@"https://itunes.apple.com/search?media=music&entity=musicTrack&limit=20&term=" stringByAppendingString:artistName];
    
    NSCharacterSet *allowedCharacters = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *encodedString = [apiUrlString stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
    NSURL *apiUrl = [NSURL URLWithString:encodedString];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSMutableDictionary *headerDictionary = [NSMutableDictionary new];
    [headerDictionary setValue:@"application/json" forKey:@"Accept"];
    [headerDictionary setValue:@"application/json" forKey:@"Content-Type"];
    [headerDictionary setValue:@"UTF-8" forKey:@"charset"];
    
    BaseAPIResponse<NSDictionary*>* responseData = [BaseAPIResponse<NSDictionary*> new];
    [manager GET:[apiUrl absoluteString] parameters:@"" headers:headerDictionary progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        responseData.responseCode = @"200";
        responseData.responseMessage = @"Success";
        responseData.data = responseObject;
        onFinish(responseData);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        responseData.responseCode = @"99";
        responseData.responseMessage = @"Failed to fetch data from server";
        onFinish(responseData);
    }];
}


@end
