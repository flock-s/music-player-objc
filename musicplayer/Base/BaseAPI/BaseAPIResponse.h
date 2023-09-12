//
//  BaseAPIResponse.h
//  musicplayer
//
//  Created by Oscar on 09/09/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseAPIResponse<ObjectType> : NSObject
@property NSString* responseMessage;
@property NSString* responseCode;
@property ObjectType data;

@end

NS_ASSUME_NONNULL_END
