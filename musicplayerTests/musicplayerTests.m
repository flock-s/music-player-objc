//
//  musicplayerTests.m
//  musicplayerTests
//
//  Created by Oscar on 12/09/23.
//

#import <XCTest/XCTest.h>
#import "MusicListViewModel.h"

@interface musicplayerTests : XCTestCase
@property MusicListViewModel* viewModel;
@end

@implementation musicplayerTests

-(void)setupTestCase{
    self.viewModel = [[MusicListViewModel alloc] init];
}

- (void)testSearchByKeyword{
    [self setupTestCase];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Search Music By ArtistName Succeed"];
    self.viewModel.artistName = @"adele";
    [self.viewModel getITunesSongListByArtistNameWithCompletion:^(NSString * result) {
        XCTAssertTrue([result isEqualToString:@"OK"], "API Hit Succeed");
        XCTAssertTrue(self.viewModel.musicList.count > 0, "Search Music By ArtistName Succeed");
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        if (error){
            XCTFail(@"Timeout search artist by name");
        }
    }];
}

- (void)testSearchByEmptyKeyword{
    [self setupTestCase];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Search Music Is Suceed"];
    self.viewModel.artistName = @"";
    [self.viewModel getITunesSongListByArtistNameWithCompletion:^(NSString * result) {
        XCTAssertTrue([result isEqualToString:@"OK"], "API Hit Succeed");
        XCTAssertTrue(self.viewModel.musicList.count <= 0, "Search Music By ArtistName Succeed");
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        if (error){
            XCTFail(@"Timeout search artist by name");
        }
    }];
}


- (void)testSearchBySpecialCharKeyword{
    [self setupTestCase];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Search Music Is Suceed"];
    self.viewModel.artistName = @"@)!*)(S)(CKASDJD";
    [self.viewModel getITunesSongListByArtistNameWithCompletion:^(NSString * result) {
        XCTAssertTrue([result isEqualToString:@"OK"], "API Hit Succeed");
        XCTAssertTrue(self.viewModel.musicList.count <= 0, "Search Music By ArtistName Succeed");
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        if (error){
            XCTFail(@"Timeout search artist by name");
        }
    }];
}
@end
