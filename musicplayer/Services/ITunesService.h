//
//  ITunesService.h
//  musicplayer
//
//  Created by Oscar on 09/09/23.
//

#import <Foundation/Foundation.h>
#import "BaseAPIResponse.h"
NS_ASSUME_NONNULL_BEGIN

@interface ITunesService : NSObject
-(void)getITunesSongListByArtistName:(NSString*)artistName onComplete: (void(^)(BaseAPIResponse<NSDictionary*>*))onFinish;
@end

NS_ASSUME_NONNULL_END
