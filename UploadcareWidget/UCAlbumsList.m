//
//  UploadcareWidget.m
//  WidgetExample
//
//  Created by Artyom Loenko on 8/3/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "UCAlbumsList.h"
#import "GRKServiceGrabberConnectionProtocol.h"
#import "GRKFacebookGrabber.h"
#import "GRKInstagramGrabber.h"
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
@property (strong) NSMutableArray *albums;
@property NSUInteger lastLoadedPageIndex;
@property UCAlbumsListState state;
@property (strong) UIActivityIndicatorView *activityIndicator;
@property (strong) UILabel *loadingLabel;

- (void)grabMoreAlbums;
- (void)addLogoutButton;
@end

NSUInteger kUCNumberOfAlbumsPerPage = kGRKMaximumNumberOfAlbumsPerPage;

@implementation UCAlbumsList

- (id)initWithGrabber:(id)grabber serviceName:(NSString *)serviceName widget:(UPCUploadController *)widget {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _grabber = grabber;
        _serviceName = serviceName;
        _albums = [[NSMutableArray alloc] init];
        _lastLoadedPageIndex = 0;
        _state = UCAlbumsListStateInitial;
        _widget = widget;
        self.contentSizeForViewInPopover = CGSizeMake(320, 480);
        self.tableView.rowHeight = 88.f; 
        self.tableView.backgroundColor = [UIColor colorWithWhite:.95f alpha:1.f];
        
        [self setupLoadingIndicator];
    }
    return self;
}

/* loading indicator */
- (void)setupLoadingIndicator {
    _loadingLabel = [[UILabel alloc]init];
    _loadingLabel.text = NSLocalizedString(@"Loading...", @"Activity indicator label (\"Loading...\")");
    _loadingLabel.backgroundColor = [UIColor clearColor];
    _loadingLabel.textColor = [UIColor colorWithWhite:.33f alpha:1.f];
    _loadingLabel.shadowColor = [UIColor whiteColor];
    _loadingLabel.shadowOffset = CGSizeMake(0, 1);
    _loadingLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]*0.9];
    [_loadingLabel sizeToFit];
    [self.tableView addSubview:_loadingLabel];
    
    _activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.tableView addSubview:_activityIndicator];
    
    CGFloat loadingWidth = CGRectGetWidth(_activityIndicator.bounds)+5.f+CGRectGetWidth(_loadingLabel.bounds);
    CGFloat loadingHeight = CGRectGetHeight(_activityIndicator.bounds);
    CGFloat statusBarHeight = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
    UIScreen *screen = [UIScreen mainScreen];
    CGPoint screenCenter = CGPointMake(CGRectGetWidth(screen.bounds) * .5f - CGRectGetMinX(self.tableView.frame), CGRectGetHeight(screen.bounds) * .5f - CGRectGetMinY(self.tableView.frame) - statusBarHeight);
    _activityIndicator.center = CGPointMake(screenCenter.x - loadingWidth * .5f + CGRectGetWidth(_activityIndicator.bounds) * .5f, self.tableView.rowHeight * .5f);
    _loadingLabel.center = CGPointMake(_activityIndicator.center.x+CGRectGetWidth(_activityIndicator.bounds) * .5f + 5.f + CGRectGetWidth(_loadingLabel.bounds) * .5f, self.tableView.rowHeight * .5f);

    [self hideLoadingIndicator];
}

- (void)showLoadingIndicator {
    self.loadingLabel.hidden = NO;
    [self.activityIndicator startAnimating];
}

- (void)hideLoadingIndicator {
    self.loadingLabel.hidden = YES;
    [self.activityIndicator stopAnimating];
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
            [self showLoadingIndicator];
            [self setupServiceConnection];
            break;
            
        case UCAlbumsListStateAlbumsGrabbed:
        case UCAlbumsListStateGrabbing:
            [self showLoadingIndicator];
             /* resume retrieving albums (has been interrupted the last time) */
            [self grabMoreAlbums];
            /* ..fall-through.. */
        case UCAlbumsListStateAllAlbumsGrabbed: {
            /* load cover for albums without one */
            NSMutableArray *albumsWithoutCover = [NSMutableArray arrayWithCapacity:self.albums.count];
            [self.albums enumerateObjectsUsingBlock:^(GRKAlbum *album, NSUInteger idx, BOOL *stop) {
                if (!album.coverPhoto) {
                    [albumsWithoutCover addObject:album];
                }
            }];
            if ([albumsWithoutCover count]) [self loadCoverPhotosForAlbums:albumsWithoutCover];
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
        
        /* Title shadow */
        cell.textLabel.shadowColor = [UIColor whiteColor];
        cell.textLabel.shadowOffset = CGSizeMake(0, 1);
        
        /* Subtitle shadow */
        cell.detailTextLabel.shadowColor = [UIColor whiteColor];
        cell.detailTextLabel.shadowOffset = CGSizeMake(0, 1);
    }
    
    GRKAlbum * album = (GRKAlbum*)[self.albums objectAtIndex:indexPath.row];
    NSURL *thumbnailURL = [album.coverPhoto.imagesSortedByHeight[0] URL];
    cell.textLabel.text = album.name;
    if ([self.grabber isKindOfClass:[GRKInstagramGrabber class]]) {
        /* Workaround for Instagram: Replace the default album name
           (`self`) with something better.
           TODO: Don't show the albums list for the Instagram at all */
        cell.textLabel.text = NSLocalizedString(@"Photos", "The Instagram's only album name");
    }
    cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Items: %d", nil), album.count];
    CGSize kAlbumCoverThumbnailSize = CGSizeMake(75, 75);
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    
    if (indexPath.row <= [self.albums count] - 1) {
        GRKAlbum * albumAtIndexPath = [self.albums objectAtIndex:indexPath.row];
        UCPhotosList * photosList = [[UCPhotosList alloc] initWithGrabber:self.grabber album:albumAtIndexPath];
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
            if (idx == NSNotFound) {
                if (album.coverPhoto != nil)
                    NSLog(@"Warning: Received a cover photo for an unknown album '%@'", album.name);
                continue;
            }
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            /* there's a cover photo, update the row */
            if (album.coverPhoto != nil) [indicesToReload addObject:indexPath];
            else {
                /* coverPhoto == nil, take the first album picture instead */
                [self.grabber fillAlbum:album withPhotosAtPageIndex:0 withNumberOfPhotosPerPage:1 andCompleteBlock:^(NSArray *photos) {
                    GRKPhoto *firstPhoto = photos.lastObject;
                    if (firstPhoto) {
                        album.coverPhoto = firstPhoto;
                        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    }
                } andErrorBlock:^(NSError *error) {
                    NSLog(@"Error grabbing photos: %@", error);
                }];
            }
        }
        [self.tableView reloadRowsAtIndexPaths:indicesToReload withRowAnimation:UITableViewRowAnimationFade];
        [self hideLoadingIndicator];
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
                                        /* FIXME: This is just fugly, get rid of it ASAP */
                                        if ([_grabber isKindOfClass:[GRKFacebookGrabber class]] && [album.albumId length] > 16) return;
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
                                [self hideLoadingIndicator];
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
