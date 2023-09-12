//
//  MusicModel.h
//  musicplayer
//
//  Created by Oscar on 09/09/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MusicModel : NSObject
@property NSString* trackName;
@property NSString* artistName;
@property NSString* collectionName;
@property NSString* previewUrl;
@property NSString* artworkUrl30;
@property NSString* artworkUrl100;
@property BOOL isPlayed;
@end

NS_ASSUME_NONNULL_END
