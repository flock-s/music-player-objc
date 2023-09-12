//
//  MusicListViewController.m
//  musicplayer
//
//  Created by Oscar on 09/09/23.
//

#import "MusicListViewController.h"
#import "MusicTableViewCell.h"
#import <AVFoundation/AVFoundation.h>

@interface MusicListViewController ()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
//@property (weak, nonatomic) IBOutlet UISearchBar *searchBarMusic;
//@property (weak, nonatomic) IBOutlet UITableView *tblViewMusic;
//@property (weak, nonatomic) IBOutlet UIView *viewMusicControl;
//@property (weak, nonatomic) IBOutlet UILabel *lblPlayedSong;
//@property (weak, nonatomic) IBOutlet UISlider *sliderSong;
//@property (weak, nonatomic) IBOutlet UIButton *btnPrev;
//@property (weak, nonatomic) IBOutlet UIButton *btnPlayPause;
//@property (weak, nonatomic) IBOutlet UIButton *btnNext;

@property (strong, nonatomic) IBOutlet NSURLSession *session;
@property (strong, nonatomic) IBOutlet NSURLSessionConfiguration *sessionConfig;
@property NSMutableArray<MusicModel*> *dataSource;
@property NSIndexPath* indexSelected;
@property bool pauseClicked;
@property bool musicEnded;
@property (strong,nonatomic) AVPlayer *audioPlayer;

@end

@implementation MusicListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.viewModel == nil){
        self.viewModel = [MusicListViewModel new];
    }
    
    self.sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:self.sessionConfig];
    
    //// Search Bar
    self.searchBarMusic.delegate = self;
    self.searchBarMusic.placeholder = @"Search Song by Artist";
    
    //// Table View
    self.tblViewMusic.dataSource = self;
    self.tblViewMusic.delegate = self;
    [self.tblViewMusic registerNib:[UINib nibWithNibName:@"MusicTableViewCell" bundle:nil] forCellReuseIdentifier:@"MusicCell"];
    self.dataSource = [NSMutableArray<MusicModel*> new];
    
    //// Keyboard Dismissal
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = false;
    [self.view addGestureRecognizer:tap];
    
    //// Music
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object: self.audioPlayer.currentItem];
    
    self.view.accessibilityIdentifier = @"songList";
    
    self.tblViewMusic.accessibilityLabel = @"table";
    self.searchBarMusic.isAccessibilityElement = false;
    self.searchBarMusic.accessibilityIdentifier = @"searchBar";
}

#pragma mark - Search Bar View Delegate
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    self.viewModel.artistName = searchText;
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    if(![self.viewModel.artistName isEqualToString:self.viewModel.artistNameTemp]){
        self.viewModel.musicList = [NSMutableArray<MusicModel*> new];
    }
    
    [self.viewModel getITunesSongListByArtistNameWithCompletion:^(NSString * _Nonnull result) {
        self.viewModel.artistNameTemp = self.viewModel.artistName;
        self.dataSource = self.viewModel.musicList;
        [self refreshMusicControlView];
        [self.tblViewMusic reloadData];
    }];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    searchBar.showsCancelButton = NO;
    [searchBar resignFirstResponder];
}

#pragma mark - Table View Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MusicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MusicCell" forIndexPath:indexPath];
    
    if(!cell){
        cell = [[MusicTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MusicCell"];
    }
    cell.lblSongTitle.text = [self.dataSource objectAtIndex:indexPath.row].trackName;
    cell.lblSongArtist.text = [self.dataSource objectAtIndex:indexPath.row].artistName;
    cell.lblSongAlbum.text = [self.dataSource objectAtIndex:indexPath.row].collectionName;
    
    
    if([self.dataSource objectAtIndex:indexPath.row].isPlayed){
        [cell.btnSongPlayed setImage:[UIImage systemImageNamed:@"pause.fill"] forState:UIControlStateNormal];
    }else{
        [cell.btnSongPlayed setImage:[UIImage systemImageNamed:@"play.fill"] forState:UIControlStateNormal];
    }
    
    if(cell.imageDownloadTask){
        [cell.imageDownloadTask cancel];
    }
    
    NSURL *imageURL = [NSURL URLWithString:[self.dataSource objectAtIndex:indexPath.row].artworkUrl30];
    
    if(imageURL){
        cell.imageDownloadTask = [self.session dataTaskWithURL:imageURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if(error){
                [self showErrorWithString:@"Error Downloading Image"];
                NSLog(@"Error: %@", error);
            }else{
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                if(httpResponse.statusCode == 200){
                    UIImage *image = [UIImage imageWithData:data];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        cell.imgViewAlbum.image = image;
                    });
                }else{
                    [self showErrorWithString:@"Couldn't load image"];
                    NSLog(@"Couldn't load image at URL: %@", imageURL);
                }
            }
        }];
        [cell.imageDownloadTask resume];
    }
    
    cell.isAccessibilityElement = YES;
    cell.accessibilityIdentifier = @"songCell";
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.viewModel.tempSelectedMusic = [self.dataSource objectAtIndex:indexPath.row];
    
    //// Same Track Chosen
    if([self.viewModel.tempSelectedMusic.trackName isEqualToString:self.viewModel.selectedMusic.trackName]){
        [self.dataSource objectAtIndex:indexPath.row].isPlayed = ![self.dataSource objectAtIndex:indexPath.row].isPlayed;
        [self.tblViewMusic reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
    }else{
        [self.dataSource objectAtIndex:indexPath.row].isPlayed = ![self.dataSource objectAtIndex:indexPath.row].isPlayed;
        [self.tblViewMusic reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
        
        if(self.pauseClicked){
            self.pauseClicked = NO;
        }else{
            if(self.indexSelected != nil){
                [self.dataSource objectAtIndex:self.indexSelected.row].isPlayed = ![self.dataSource objectAtIndex:self.indexSelected.row].isPlayed;
                [self.tblViewMusic reloadRowsAtIndexPaths:[NSArray arrayWithObjects:self.indexSelected, nil] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
    }
    self.viewModel.selectedMusic = self.viewModel.tempSelectedMusic;
    self.indexSelected = indexPath;
    if([self.dataSource objectAtIndex:indexPath.row].isPlayed){
        [self.btnPlayPause setImage:[UIImage systemImageNamed:@"pause.fill"] forState:UIControlStateNormal];
        [self playMusic];
    }else{
        [self.btnPlayPause setImage:[UIImage systemImageNamed:@"play.fill"] forState:UIControlStateNormal];
        [self pauseMusic];
    }
    [self setUpMusicControl];
}


#pragma mark - Music Control
- (IBAction)btnPrevOnClick:(id)sender {
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:self.indexSelected.row-1 inSection:self.indexSelected.section];
    if((newIndexPath.row) > -1){
        self.viewModel.tempSelectedMusic = [self.dataSource objectAtIndex:newIndexPath.row];
        [self.dataSource objectAtIndex:newIndexPath.row].isPlayed = ![self.dataSource objectAtIndex:newIndexPath.row].isPlayed;
        [self.tblViewMusic reloadRowsAtIndexPaths:[NSArray arrayWithObjects:newIndexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
        if(self.pauseClicked){
            self.pauseClicked = NO;
        }else{
            if(newIndexPath != nil){
                [self.dataSource objectAtIndex:self.indexSelected.row].isPlayed = ![self.dataSource objectAtIndex:self.indexSelected.row].isPlayed;
                [self.tblViewMusic reloadRowsAtIndexPaths:[NSArray arrayWithObjects:self.indexSelected, nil] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
        self.viewModel.selectedMusic = self.viewModel.tempSelectedMusic;
        self.indexSelected = newIndexPath;
        if([self.dataSource objectAtIndex:newIndexPath.row].isPlayed){
            [self.btnPlayPause setImage:[UIImage systemImageNamed:@"pause.fill"] forState:UIControlStateNormal];
            [self playMusic];
        }else{
            [self.btnPlayPause setImage:[UIImage systemImageNamed:@"play.fill"] forState:UIControlStateNormal];
            [self pauseMusic];
        }
        [self setUpMusicControl];
    }
}

- (IBAction)btnPlayPauseOnClick:(id)sender {
    [self.dataSource objectAtIndex:self.indexSelected.row].isPlayed = ![self.dataSource objectAtIndex:self.indexSelected.row].isPlayed;
    [self.tblViewMusic reloadRowsAtIndexPaths:[NSArray arrayWithObjects:self.indexSelected, nil] withRowAnimation:UITableViewRowAnimationNone];
    if([self.dataSource objectAtIndex:self.indexSelected.row].isPlayed){
        [self.btnPlayPause setImage:[UIImage systemImageNamed:@"pause.fill"] forState:UIControlStateNormal];
        [self playMusic];
    }else{
        [self.btnPlayPause setImage:[UIImage systemImageNamed:@"play.fill"] forState:UIControlStateNormal];
        [self pauseMusic];
    }
    
}

- (IBAction)btnNextOnClick:(id)sender {
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:self.indexSelected.row+1 inSection:self.indexSelected.section];
    if((newIndexPath.row) <= [self.dataSource count]){
        self.viewModel.tempSelectedMusic = [self.dataSource objectAtIndex:newIndexPath.row];
        [self.dataSource objectAtIndex:newIndexPath.row].isPlayed = ![self.dataSource objectAtIndex:newIndexPath.row].isPlayed;
        [self.tblViewMusic reloadRowsAtIndexPaths:[NSArray arrayWithObjects:newIndexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
        if(self.pauseClicked){
            self.pauseClicked = NO;
        }else{
            if(newIndexPath != nil){
                [self.dataSource objectAtIndex:self.indexSelected.row].isPlayed = ![self.dataSource objectAtIndex:self.indexSelected.row].isPlayed;
                [self.tblViewMusic reloadRowsAtIndexPaths:[NSArray arrayWithObjects:self.indexSelected, nil] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
        self.viewModel.selectedMusic = self.viewModel.tempSelectedMusic;
        self.indexSelected = newIndexPath;
        if([self.dataSource objectAtIndex:newIndexPath.row].isPlayed){
            [self.btnPlayPause setImage:[UIImage systemImageNamed:@"pause.fill"] forState:UIControlStateNormal];
            [self playMusic];
        }else{
            [self.btnPlayPause setImage:[UIImage systemImageNamed:@"play.fill"] forState:UIControlStateNormal];
            [self pauseMusic];
        }
        [self setUpMusicControl];
    }
}

-(void)setUpMusicControl{
    if(self.viewMusicControl.isHidden){
        [UIView transitionWithView:self.viewMusicControl duration:2.0 options:UIViewAnimationOptionShowHideTransitionViews animations:^{
            self.viewMusicControl.hidden = NO;
            self.sliderSong.value = 0;
        } completion:nil];
    }
    self.lblPlayedSong.text = self.viewModel.selectedMusic.trackName;
}

-(void)refreshMusicControlView{
    self.viewMusicControl.hidden = YES;
    self.lblPlayedSong.text = @"";
    self.sliderSong.value = 0;
    self.indexSelected = 0;
    [self.audioPlayer pause];
}

-(void)playMusic{
    if(!self.pauseClicked){
        NSURL *audioURL = [NSURL URLWithString:self.viewModel.selectedMusic.previewUrl];
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:audioURL];
        self.audioPlayer = [AVPlayer playerWithPlayerItem:playerItem];
        
        CMTime duration = playerItem.asset.duration;
        float seconds = CMTimeGetSeconds(duration);
        
        self.sliderSong.maximumValue =seconds;
        
        __weak typeof(self) weakSelf = self;
        [self.audioPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            float currentTime = CMTimeGetSeconds(time);
            weakSelf.sliderSong.value = currentTime;
        }];
    }
    [self.audioPlayer play];
}

-(void)pauseMusic{
    if(self.audioPlayer){
        self.pauseClicked = YES;
        [self.audioPlayer pause];
    }
}

- (IBAction)sliderSongValueChanged:(UISlider*)slider {
    CMTime seekTime = CMTimeMakeWithSeconds(slider.value, NSEC_PER_SEC);
    [self.audioPlayer seekToTime:seekTime];
}


#pragma mark - Selector
-(void)dismissKeyboard{
    [self.searchBarMusic resignFirstResponder];
}


-(void) playerItemDidReachEnd:(NSNotification*)notification{
    if(notification.object == self.audioPlayer.currentItem){
        [self.dataSource objectAtIndex:self.indexSelected.row].isPlayed = ![self.dataSource objectAtIndex:self.indexSelected.row].isPlayed;
        [self.tblViewMusic reloadRowsAtIndexPaths:[NSArray arrayWithObjects:self.indexSelected, nil] withRowAnimation:UITableViewRowAnimationNone];
        
        [self.audioPlayer seekToTime:kCMTimeZero];
        self.musicEnded = YES;
        [self.btnPlayPause setImage:[UIImage systemImageNamed:@"play.fill"] forState:UIControlStateNormal];
    }
}

#pragma mark - Alert UI
-(void)showErrorWithString:(NSString*)string{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:string preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok =[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}
@end
