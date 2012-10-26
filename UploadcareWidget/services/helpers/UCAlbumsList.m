//
//  UploadcareWidget.m
//  WidgetExample
//
//  Created by Artyom Loenko on 8/3/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "UCAlbumsList.h"
#import "GRKServiceGrabberConnectionProtocol.h"
#import "UCPhotosList.h"
#import "UIImageView+UCHelpers.h"
#import "UIImage+UCHelpers.h"
#import "QuartzCore/QuartzCore.h"

enum {
    UCAlbumsListStateInitial = 0,
    UCAlbumsListStateConnecting,
    UCAlbumsListStateConnected,
    UCAlbumsListStateGrabbing,
    UCAlbumsListStateAlbumsGrabbed,
    UCAlbumsListStateAllAlbumsGrabbed,
    UCAlbumsListStateError = 99
};
typedef NSUInteger UCAlbumsListState;

@interface UCAlbumsList()

@property GRKServiceGrabber *grabber;
@property NSString *serviceName;
@property NSMutableArray *albums;
@property NSUInteger lastLoadedPageIndex;
@property BOOL allAlbumsGrabbed;
@property (nonatomic)  UCAlbumsListState state;

- (void)grabMoreAlbums;
- (void)setState:(UCAlbumsListState)newState;
- (void)addLogoutButton;
@end

NSUInteger kNumberOfAlbumsPerPage = 8;

@implementation UCAlbumsList

- (id)initWithGrabber:(id)grabber serviceName:(NSString *)serviceName {
    self = [super initWithNibName:@"UCAlbumsList" bundle:nil];
    if (self) {
        _grabber = grabber;
        _serviceName = serviceName;
        _albums = [[NSMutableArray alloc] init];
        _lastLoadedPageIndex = 0;
        _allAlbumsGrabbed = NO;
        [self setState:UCAlbumsListStateInitial];
    }
    return self;
}

- (void)setState:(UCAlbumsListState)newState {
    _state = newState;
    switch (newState) {
        case UCAlbumsListStateAlbumsGrabbed:
            [self.tableView reloadData];
            break;
        case UCAlbumsListStateAllAlbumsGrabbed:
            [self.tableView reloadData];
            break;
        default:
            break;
    }
}

#pragma mark - View lifecycle

- (void)addLogoutButton {
    if (self.navigationItem.rightBarButtonItem == nil) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Sign out", nil)
                                                                                  style:UIBarButtonItemStyleDone
                                                                                 target:self action:@selector(logoutGrabberAndPopToRoot)];
    }
}

- (void)setupServiceConnection {
    [(id<GRKServiceGrabberConnectionProtocol>)self.grabber isConnected:^(BOOL connected) {
        if (!connected) {
            [self setState:UCAlbumsListStateConnecting];
            [(id<GRKServiceGrabberConnectionProtocol>)self.grabber connectWithConnectionIsCompleteBlock:^(BOOL connected) {
                NSLog(@"+%@: line %d", NSStringFromSelector(_cmd), __LINE__);
                if (connected) {
                    [self setState:UCAlbumsListStateConnected];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self addLogoutButton];
                        [self grabMoreAlbums];
                    });
                }
            } andErrorBlock:^(NSError *error) {
                [self setState:UCAlbumsListStateError];
                NSLog(@" an error occured trying to connect the grabber : %@", error);
            }];
        } else {
            /* already connected */
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [self addLogoutButton];
                [self grabMoreAlbums];
            });
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.title = self.serviceName;
    if (self.state != UCAlbumsListStateInitial) {
        return;
    }
    
    [self setupServiceConnection];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.grabber cancelAll];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger res = [self.albums count];
    if (self.state == UCAlbumsListStateAlbumsGrabbed || self.state == UCAlbumsListStateAllAlbumsGrabbed) {
        res++;
    }
    
    return res;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if (indexPath.row >= [self.albums count]) {
        static NSString *CellIdentifier = @"ExtraCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        if (!self.allAlbumsGrabbed) {
            cell.textLabel.text = [NSString stringWithFormat:
                                   NSLocalizedString(@"%d Albums - Load More", nil),
                                   [self.albums count]];
            cell.textLabel.font = [UIFont fontWithName:@"System" size:8];
        } else {
            cell.textLabel.text = [NSString stringWithFormat:
                                   NSLocalizedString(@"%d Albums", nil),
                                   [self.albums count]];
            cell.textLabel.font = [UIFont fontWithName:@"System" size:8];
        }
    } else {
        static NSString *CellIdentifier = @"AlbumCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.imageView.layer.cornerRadius = 4.0f;
            cell.imageView.clipsToBounds = YES;
        }
        
        GRKAlbum * album = (GRKAlbum*)[self.albums objectAtIndex:indexPath.row];
        NSURL *thumbnailURL = [album.coverPhoto.imagesSortedByHeight[0] URL];
        cell.textLabel.text = album.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Items: %d", nil), album.count];
        [cell.imageView setImage:[[UIImage imageNamed:@"icon_url@2x.png"] imageByScalingToSize:CGSizeMake(64, 64)]];
        if (thumbnailURL != nil) [cell.imageView setImageFromURL:thumbnailURL scaledToSize:CGSizeMake(64, 64)];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    
    if (indexPath.row == [self.albums count]  && !self.allAlbumsGrabbed) {
        [self grabMoreAlbums];
    } else if (indexPath.row <= [self.albums count] - 1) {
        GRKAlbum * albumAtIndexPath = [self.albums objectAtIndex:indexPath.row];
        UCPhotosList * photosList = [[UCPhotosList alloc] initWithNibName:@"UCPhotosList" bundle:nil andGrabber:self.grabber andAlbum:albumAtIndexPath];
        [self.navigationController pushViewController:photosList animated:YES];
    }
}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.cancelButtonIndex) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
    }
}

#pragma mark -

- (void)loadCoverPhotoForAlbums:(NSArray*)albums {
    NSMutableArray *albumsWithoutCover = [NSMutableArray array];
    for (GRKAlbum *album in albums) {
        if (album.coverPhoto == nil) {
            [albumsWithoutCover addObject:album];
        }
    }
    
    [self.grabber fillCoverPhotoOfAlbums:albumsWithoutCover withCompleteBlock:^(id result) {
        [self.tableView reloadData];
    } andErrorBlock:^(NSError *error) {
    }];
}

- (void)grabMoreAlbums {
    [self setState:UCAlbumsListStateGrabbing];
    
    NSLog(@" load albums for page %d", self.lastLoadedPageIndex);
    [self.grabber albumsOfCurrentUserAtPageIndex:self.lastLoadedPageIndex
                   withNumberOfAlbumsPerPage:kNumberOfAlbumsPerPage
                            andCompleteBlock:^(NSArray *results) {
                                self.lastLoadedPageIndex+=1;
                                
                                [results enumerateObjectsUsingBlock:^(id album, NSUInteger idx, BOOL *stop) {
                                    NSLog(@"albums %@", album);
                                    if ([album count] != 0) {
                                        [self.albums addObject:album];
                                    }
                                }];
                                
                                [self loadCoverPhotoForAlbums:results];
                                
                                if ( [results count] < kNumberOfAlbumsPerPage ){
                                    self.allAlbumsGrabbed = YES;
                                    [self setState:UCAlbumsListStateAllAlbumsGrabbed];
                                } else {
                                    [self setState:UCAlbumsListStateAlbumsGrabbed];
                                }
                            } andErrorBlock:^(NSError *error) {
                                NSLog(@" error ! %@", error);
                            }];
}

#pragma mark - Logout

- (void)logoutGrabberAndPopToRoot {
    [self.grabber cancelAllWithCompleteBlock:^(NSArray *results) {
        if ([self.grabber conformsToProtocol:@protocol(GRKServiceGrabberConnectionProtocol)]) {
            [(id<GRKServiceGrabberConnectionProtocol>)self.grabber disconnectWithDisconnectionIsCompleteBlock:^(BOOL disconnected) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }];
        } else {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }];        
}

@end
