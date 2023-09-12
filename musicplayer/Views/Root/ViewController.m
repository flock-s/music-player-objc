//
//  ViewController.m
//  musicplayer
//
//  Created by Oscar Edward on 09/09/23.
//

#import "ViewController.h"
#import "MusicListViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    MusicListViewController *musicListViewController = [[MusicListViewController alloc] initWithNibName:@"MusicListViewController" bundle:[NSBundle bundleWithIdentifier:[[NSBundle mainBundle] bundleIdentifier]]];
    musicListViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController pushViewController:musicListViewController animated:NO];
}


@end
