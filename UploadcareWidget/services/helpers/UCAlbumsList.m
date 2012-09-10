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
#import "UCAlbumsListCell.h"

@interface UCAlbumsList()
- (void)grabMoreAlbums;
- (void)setState:(UCAlbumsListState)newState;
- (void)addLogoutButton;
@end

NSUInteger kNumberOfAlbumsPerPage = 8;

@implementation UCAlbumsList

- (void) dealloc {
    for(GRKAlbum *album in _albums) {
        [album removeObserver:self forKeyPath:@"count"];
    }
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (id)initWithGrabber:(id)grabber andServiceName:(NSString *)serviceName {
    self = [super initWithNibName:@"UCAlbumsList" bundle:nil];
    if (self) {
        _grabber = grabber;
        _serviceName = serviceName;
        _albums = [[NSMutableArray alloc] init];
        _lastLoadedPageIndex = 0;
        allAlbumsGrabbed = NO;
        [self setState:UCAlbumsListStateInitial];
    }
    return self;
}

- (void)setState:(UCAlbumsListState)newState {
    state = newState;
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

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)addLogoutButton {
    if (self.navigationItem.rightBarButtonItem == nil) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Log out", nil)
                                                                                  style:UIBarButtonItemStyleDone
                                                                                 target:self action:@selector(logoutGrabberAndPopToRoot)];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.title = _serviceName;
    if (state != UCAlbumsListStateInitial) {
        return;
    }
    
    if ([_grabber conformsToProtocol:@protocol(GRKServiceGrabberConnectionProtocol)]) {
        [(id<GRKServiceGrabberConnectionProtocol>)_grabber isConnected:^(BOOL connected) {
            NSLog(@" grabber connected ? %d", connected);
            
            if (!connected) {
                NSString * connectMessage = [NSString stringWithFormat:
                                             NSLocalizedString(@"Uploadcare needs to open Safari to authentificate you on %@. ", nil),
                                             _serviceName];
                
                UIAlertView * grabberNeedToConnect = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection", nil)
                                                                                message:connectMessage
                                                                               delegate:self
                                                                      cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                                      otherButtonTitles:NSLocalizedString(@"Ok", nil), nil];
                [grabberNeedToConnect show];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [self addLogoutButton];
                    [self grabMoreAlbums];
                });
            }
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self grabMoreAlbums];
        });
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_grabber cancelAll];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger res = [_albums count];
    if (state == UCAlbumsListStateAlbumsGrabbed || state == UCAlbumsListStateAllAlbumsGrabbed) {
        res++;
    }
    
    return res;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if (indexPath.row >= [_albums count]) {
        static NSString *CellIdentifier = @"ExtraCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        if (!allAlbumsGrabbed) {
            cell.textLabel.text = [NSString stringWithFormat:
                                   NSLocalizedString(@"%d Albums - Load More", nil),
                                   [_albums count]];
            cell.textLabel.font = [UIFont fontWithName:@"System" size:8];
        } else {
            cell.textLabel.text = [NSString stringWithFormat:
                                   NSLocalizedString(@"%d Albums", nil),
                                   [_albums count]];
            cell.textLabel.font = [UIFont fontWithName:@"System" size:8];
        }
    } else {
        static NSString *CellIdentifier = @"AlbumCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"UCAlbumsListCell" owner:nil options:nil] objectAtIndex:0];
        }
        
        GRKAlbum * albumAtIndexPath = (GRKAlbum*)[_albums objectAtIndex:indexPath.row];
        [(UCAlbumsListCell*)cell setAlbum:albumAtIndexPath];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    
    if (indexPath.row == [_albums count]  && !allAlbumsGrabbed) {
        [self grabMoreAlbums];
    } else if (indexPath.row <= [_albums count] - 1) {
        GRKAlbum * albumAtIndexPath = [_albums objectAtIndex:indexPath.row];
        UCPhotosList * photosList = [[UCPhotosList alloc] initWithNibName:@"UCPhotosList" bundle:nil andGrabber:_grabber andAlbum:albumAtIndexPath];
        [self.navigationController pushViewController:photosList animated:YES];
    }
}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.cancelButtonIndex) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self setState:UCAlbumsListStateConnecting];
        [(id<GRKServiceGrabberConnectionProtocol>)_grabber connectWithConnectionIsCompleteBlock:^(BOOL connected) {
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
    }
}

#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"count"]) {
        NSInteger indexOfAlbum = [_albums indexOfObject:object];
        if (indexOfAlbum != NSNotFound){
            NSArray * indexPathsToReload = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexOfAlbum inSection:0]];
            [self.tableView reloadRowsAtIndexPaths:indexPathsToReload withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

- (void)loadCoverPhotoForAlbums:(NSArray*)albums {
    NSMutableArray *albumsWithoutCover = [NSMutableArray array];
    for (GRKAlbum *album in albums) {
        if (album.coverPhoto == nil) {
            [albumsWithoutCover addObject:album];
        }
    }
    
    [_grabber fillCoverPhotoOfAlbums:albumsWithoutCover withCompleteBlock:^(id result) {
        [self.tableView reloadData];
    } andErrorBlock:^(NSError *error) {
    }];
}

- (void)grabMoreAlbums {
    [self setState:UCAlbumsListStateGrabbing];
    
    NSLog(@" load albums for page %d", _lastLoadedPageIndex);
    [_grabber albumsOfCurrentUserAtPageIndex:_lastLoadedPageIndex
                   withNumberOfAlbumsPerPage:kNumberOfAlbumsPerPage
                            andCompleteBlock:^(NSArray *results) {
                                _lastLoadedPageIndex+=1;
                                [_albums addObjectsFromArray:results];
                                
                                for( GRKAlbum * newAlbum in results ){
                                    [newAlbum addObserver:self forKeyPath:@"count" options:NSKeyValueObservingOptionNew context:nil];
                                }
                                [self loadCoverPhotoForAlbums:results];
                                
                                if ( [results count] < kNumberOfAlbumsPerPage ){
                                    allAlbumsGrabbed = YES;
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
    [_grabber cancelAllWithCompleteBlock:^(NSArray *results) {
        if ([_grabber conformsToProtocol:@protocol(GRKServiceGrabberConnectionProtocol)]) {
            [(id<GRKServiceGrabberConnectionProtocol>)_grabber disconnectWithDisconnectionIsCompleteBlock:^(BOOL disconnected) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }];
        } else {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }];        
}

@end
