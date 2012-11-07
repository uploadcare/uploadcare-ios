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

@property (strong) GRKServiceGrabber *grabber;
@property (strong) NSString *serviceName;
@property (strong) NSMutableArray *albums;
@property NSUInteger lastLoadedPageIndex;
@property UCAlbumsListState state;

- (void)grabMoreAlbums;
- (void)addLogoutButton;
@end

NSUInteger kUCNumberOfAlbumsPerPage = kGRKMaximumNumberOfAlbumsPerPage;

@implementation UCAlbumsList

- (id)initWithGrabber:(id)grabber serviceName:(NSString *)serviceName {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _grabber = grabber;
        _serviceName = serviceName;
        _albums = [[NSMutableArray alloc] init];
        _lastLoadedPageIndex = 0;
        _state = UCAlbumsListStateInitial;
    }
    return self;
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
    if ([self.grabber conformsToProtocol:@protocol(GRKServiceGrabberConnectionProtocol)]) [(id<GRKServiceGrabberConnectionProtocol>)self.grabber isConnected:^(BOOL connected) {
        if (!connected) {
            [self setState:UCAlbumsListStateConnecting];
            [(id<GRKServiceGrabberConnectionProtocol>)self.grabber connectWithConnectionIsCompleteBlock:^(BOOL connected) {
                NSLog(@"+%@: line %d", NSStringFromSelector(_cmd), __LINE__);
                if (connected) {
                    [self setState:UCAlbumsListStateConnected];
                    [self setupServiceConnection];
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
    }]; else {
        [self grabMoreAlbums];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
        
    self.title = self.serviceName;
    
    switch (self.state) {
        case UCAlbumsListStateInitial:
            [self setupServiceConnection];
            break;
            
        case UCAlbumsListStateAlbumsGrabbed:
        case UCAlbumsListStateGrabbing:
             /* resume retrieving albums (has been interrupted the last time) */
            [self grabMoreAlbums];
        case UCAlbumsListStateAllAlbumsGrabbed: {
            /* load cover for albums without one */
            NSMutableArray *albumsWithoutCover = [NSMutableArray arrayWithCapacity:self.albums.count];
            [self.albums enumerateObjectsUsingBlock:^(GRKAlbum *album, NSUInteger idx, BOOL *stop) {
                if (!album.coverPhoto) {
                    [albumsWithoutCover addObject:album];
                }
            }];
            [self loadCoverPhotosForAlbums:albumsWithoutCover];
        }
            
        default:
            break;
    }
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
    return self.albums.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const kCellIdentifier = @"AlbumCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    [cell.imageView removeActivityIndicator];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIdentifier];
        cell.imageView.layer.cornerRadius = 4.0f;
        cell.imageView.clipsToBounds = YES;
    }
    
    GRKAlbum * album = (GRKAlbum*)[self.albums objectAtIndex:indexPath.row];
    NSURL *thumbnailURL = [album.coverPhoto.imagesSortedByHeight[0] URL];
    cell.textLabel.text = [album.albumId isEqualToString:@"me"] && !album.name ? @"Photos of You" : album.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Items: %d", nil), album.count];
    CGSize kAlbumCoverThumbnailSize = CGSizeMake(64, 64);
    /* show the activity indicator */
    [cell.imageView showActivityIndicatorWithStyle:UIActivityIndicatorViewStyleGray placeholderSize:kAlbumCoverThumbnailSize];
    if (thumbnailURL != nil) [cell.imageView setImageFromURL:thumbnailURL scaledToSize:kAlbumCoverThumbnailSize successBlock:^(UIImage *image) {
        /* remove the activity indicator on success */
        [cell.imageView removeActivityIndicator];
    } failureBlock:^(NSError *error) {
        /* ...and on error */
        [cell.imageView removeActivityIndicator];
        /* TODO: handle */
    }];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}



#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    
    if (indexPath.row <= [self.albums count] - 1) {
        GRKAlbum * albumAtIndexPath = [self.albums objectAtIndex:indexPath.row];
        UCPhotosList * photosList = [[UCPhotosList alloc] initWithNibName:@"UCPhotosList" bundle:nil andGrabber:self.grabber andAlbum:albumAtIndexPath];
        photosList.albumList = self;
        [self.navigationController pushViewController:photosList animated:YES];
    }
}

#pragma mark -

- (void)loadCoverPhotosForAlbums:(NSArray*)albums {
    NSMutableArray *albumsWithoutCover = [NSMutableArray array];
    for (GRKAlbum *album in albums) {
        if (album.coverPhoto == nil) {
            [albumsWithoutCover addObject:album];
        }
    }
    
    [self.grabber fillCoverPhotoOfAlbums:albumsWithoutCover withCompleteBlock:^(id result) {
        NSArray *albumsUpdated = (NSArray*)result;
        NSMutableArray *indicesToReload = [NSMutableArray arrayWithCapacity:albumsUpdated.count];
        for (GRKAlbum *album in albumsUpdated) {
            NSUInteger idx = [self.albums indexOfObject:album];
            assert(idx != NSNotFound);
            if (album.coverPhoto != nil) [indicesToReload addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
        }
        [self.tableView reloadRowsAtIndexPaths:indicesToReload withRowAnimation:UITableViewRowAnimationFade];
    } andErrorBlock:^(NSError *error) {
        NSLog(@"Failed to retrive cover photos: %@", error);
    }];
}

- (void)grabMoreAlbums {
    [self setState:UCAlbumsListStateGrabbing];
    
    [self.grabber albumsOfCurrentUserAtPageIndex:self.lastLoadedPageIndex
                   withNumberOfAlbumsPerPage:kUCNumberOfAlbumsPerPage
                            andCompleteBlock:^(NSArray *results) {
                                self.lastLoadedPageIndex+=1;
                                
                                [results enumerateObjectsUsingBlock:^(GRKAlbum *album, NSUInteger idx, BOOL *stop) {
                                    if ([album count] != 0) {
                                        [self.albums addObject:album];
                                        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.albums.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                                    }
                                }];
                                
                                [self loadCoverPhotosForAlbums:results];
                                
                                if ( [results count] < kUCNumberOfAlbumsPerPage ){
                                    [self setState:UCAlbumsListStateAllAlbumsGrabbed];
                                } else {
                                    [self setState:UCAlbumsListStateAlbumsGrabbed];
                                    [self grabMoreAlbums];
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
