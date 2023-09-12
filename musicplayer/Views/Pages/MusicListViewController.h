//
//  MusicListViewController.h
//  musicplayer
//
//  Created by Oscar on 09/09/23.
//

#import <UIKit/UIKit.h>
#import "MusicListViewModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface MusicListViewController : UIViewController
@property MusicListViewModel *viewModel;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBarMusic;
@property (weak, nonatomic) IBOutlet UITableView *tblViewMusic;
@property (weak, nonatomic) IBOutlet UIView *viewMusicControl;
@property (weak, nonatomic) IBOutlet UILabel *lblPlayedSong;
@property (weak, nonatomic) IBOutlet UISlider *sliderSong;
@property (weak, nonatomic) IBOutlet UIButton *btnPrev;
@property (weak, nonatomic) IBOutlet UIButton *btnPlayPause;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@end

NS_ASSUME_NONNULL_END
