//
//  UploadcareWidget.m
//  WidgetExample
//
//  Created by Artyom Loenko on 8/3/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "UCPhotosList.h"
#import "UCPhotosListCell.h"

NSUInteger kNumberOfRowsPerSection = 7;
NSUInteger kNumberOfPhotosPerCell = 4;
NSUInteger kNumberOfPhotosPerPage = 7 * 4;

@interface UCPhotosList()
- (NSArray *)photosForCellAtIndexPath:(NSIndexPath *)indexPath;
- (void)fillAlbumWithMorePhotos;
- (void)setState:(UCPhotosListState)newState;
@end

@implementation UCPhotosList

- (void)dealloc {
    [_album removeObserver:self forKeyPath:@"count"];
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andGrabber:(GRKServiceGrabber *)grabber andAlbum:(GRKAlbum *)album {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self != nil) {
        _grabber = grabber;
        _album = album;
        _lastLoadedPageIndex = 0;
        _nextPageIndexToLoad = 0;
        [self setState:UCPhotosListStateInitial];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = 79.0;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fillAlbumWithMorePhotos];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationItem.title = _album.name;
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"count"] && object == _album) {
        [self.tableView reloadData];
    }
}

- (void)setState:(UCPhotosListState)newState {
    state = newState;
    switch (newState) {
        case UCPhotosListStateInitial:{
            [_album addObserver:self forKeyPath:@"count" options:NSKeyValueObservingOptionNew context:nil];
            break;
        }
            
        case UCPhotosListStatePhotosGrabbed:{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            break;
        }
            
        case UCPhotosListStateAllPhotosGrabbed:{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            break;
        }
            
        default:
            break;
    }
}


#pragma mark - Helpers

- (NSArray *)photosForCellAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger rowIndex = indexPath.section * kNumberOfRowsPerSection + indexPath.row ;
    NSMutableArray * photosAtIndexPath = [NSMutableArray array];
    [photosAtIndexPath addObjectsFromArray:[_album photosAtPageIndex:rowIndex withNumberOfPhotosPerPage:kNumberOfPhotosPerCell]];
    
    for (int i = 0; i < [photosAtIndexPath count]; i++) {
        if ([photosAtIndexPath objectAtIndex:i] == [NSNull null]) {
            [photosAtIndexPath removeObjectAtIndex:i];
            i--;
        }
    }
    return [NSArray arrayWithArray:photosAtIndexPath];
}

- (void)fillAlbumWithMorePhotos {
    NSUInteger pageToLoad = _nextPageIndexToLoad;
    [self setState:UCPhotosListStateGrabbing];
    [_grabber fillAlbum:_album withPhotosAtPageIndex:pageToLoad withNumberOfPhotosPerPage:kNumberOfPhotosPerPage andCompleteBlock:^(NSArray *results) {
        _lastLoadedPageIndex = pageToLoad;
        if ([results count] < kNumberOfPhotosPerPage) {
            [self setState:UCPhotosListStateAllPhotosGrabbed];
        } else {
            [self setState:UCPhotosListStatePhotosGrabbed];
        }
    } andErrorBlock:^(NSError *error) {
        NSLog(@" error for page %d : %@", pageToLoad,  error);
    }];
    
    _nextPageIndexToLoad++;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSUInteger res = _lastLoadedPageIndex + 1;
    if (state != UCPhotosListStateAllPhotosGrabbed) {
        res++;
    }
    return res;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (state > UCPhotosListStatePhotosGrabbed) {
        NSUInteger numberOfPhotos = [[_album photosAtPageIndex:section withNumberOfPhotosPerPage:kNumberOfPhotosPerPage] count];
        return [NSString stringWithFormat:NSLocalizedString(@"Page %d ( %d photos )", nil), section, numberOfPhotos];
    }
    return [NSString stringWithFormat:@"Page %d", section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger res = 0;
    if (state == UCPhotosListStateAllPhotosGrabbed && section == _lastLoadedPageIndex) {
        NSUInteger photosCount = [_album count];
        
        NSUInteger numberOfCompleteCell = (photosCount - section*kNumberOfRowsPerSection*kNumberOfPhotosPerCell) / kNumberOfPhotosPerCell;
        NSUInteger thereIsALastCellWithLessThenFourPhotos = (photosCount % kNumberOfPhotosPerCell)?1:0;
        res =  numberOfCompleteCell + thereIsALastCellWithLessThenFourPhotos  +1 ;
    } else if (section > _lastLoadedPageIndex) {
        res = 1;
    } else {
        res = kNumberOfRowsPerSection;
    }
    
    return res;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if (indexPath.section > _lastLoadedPageIndex) {
        static NSString *extraCellIdentifier = @"ExtraCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:extraCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:extraCellIdentifier];
        }
        
        cell.textLabel.text = NSLocalizedString(@"load more", nil);
        cell.textLabel.font = [UIFont fontWithName:@"System" size:8];
    } else {
        static NSString *photoCellIdentifier = @"photoCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:photoCellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"UCPhotosListCell" owner:self options:nil] objectAtIndex:0];
            [(UCPhotosListCell *)cell setPhotoList:self];
        }
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell.reuseIdentifier isEqualToString:@"ExtraCell"]) {
        if (state == UCPhotosListStateAllPhotosGrabbed) {
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@" %d photos", nil), [[_album photos] count] ];
        } else {
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Loading page %d", nil), _lastLoadedPageIndex+1];
            [self fillAlbumWithMorePhotos];
        }
    } else {
        NSArray * photosAtIndexPath = [self photosForCellAtIndexPath:indexPath];
        [(UCPhotosListCell*)cell setPhotos:photosAtIndexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSLog(@"+%@: line %d", NSStringFromSelector(_cmd), __LINE__);
}

@end
