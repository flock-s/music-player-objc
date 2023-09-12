//
//  MusicTableViewCell.h
//  musicplayer
//
//  Created by Oscar on 09/09/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MusicTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgViewAlbum;
@property (weak, nonatomic) IBOutlet UILabel *lblSongTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblSongArtist;
@property (weak, nonatomic) IBOutlet UILabel *lblSongAlbum;
@property (weak, nonatomic) IBOutlet UIButton *btnSongPlayed;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewPlayed;


@property (nonatomic, strong) NSURLSessionDataTask *imageDownloadTask;
@end

NS_ASSUME_NONNULL_END
