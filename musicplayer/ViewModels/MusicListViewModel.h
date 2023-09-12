//
//  MusicListViewModel.h
//  musicplayer
//
//  Created by Oscar on 09/09/23.
//

#import <Foundation/Foundation.h>
#import "ITunesService.h"
#import "MusicModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface MusicListViewModel : NSObject
@property ITunesService *itunesService;
@property NSString* artistName;
@property NSString* artistNameTemp;
@property NSMutableArray<MusicModel*> *musicList;
@property MusicModel* selectedMusic;
@property MusicModel* tempSelectedMusic;
@property NSNumber* selectedIndexPath;


-(void) getITunesSongListByArtistNameWithCompletion:(void (^) (NSString *result)) onComplete;
@end

NS_ASSUME_NONNULL_END
