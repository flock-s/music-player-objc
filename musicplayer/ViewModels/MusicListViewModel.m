//
//  MusicListViewModel.m
//  musicplayer
//
//  Created by Oscar on 09/09/23.
//

#import "MusicListViewModel.h"

@implementation MusicListViewModel
-(id)init{
    
    if(self == [super init]){
        self.itunesService = [ITunesService new];
        self.musicList = [NSMutableArray<MusicModel*> new];
        self.artistName = @"";
        self.artistNameTemp = @"";
        self.selectedMusic = [MusicModel new];
        self.tempSelectedMusic = [MusicModel new];
    }
    return self;
}


- (void)getITunesSongListByArtistNameWithCompletion:(nonnull void (^)(NSString * _Nonnull))onComplete {
    [self.itunesService getITunesSongListByArtistName:self.artistName onComplete:^(BaseAPIResponse<NSDictionary *> * result) {
        if([result.responseCode isEqualToString:@"200"]){
            if([result.data objectForKey:@"resultCount"] > 0){
                for(id music in [result.data objectForKey:@"results"]){
                    MusicModel* musicModel = [MusicModel new];
                    musicModel.artistName = [music objectForKey:@"artistName"];
                    musicModel.trackName = [music objectForKey:@"trackName"];
                    musicModel.collectionName = [music objectForKey:@"collectionName"];
                    musicModel.previewUrl = [music objectForKey:@"previewUrl"];
                    musicModel.artworkUrl30 = [music objectForKey:@"artworkUrl30"];
                    musicModel.artworkUrl100 = [music objectForKey:@"artworkUrl100"];
                    [self.musicList addObject:musicModel];
                }
                onComplete(@"OK");
            }else{
                onComplete(@"NO Data");
            }
        }else{
            onComplete(@"NOK");
        }
    }];
}

@end
