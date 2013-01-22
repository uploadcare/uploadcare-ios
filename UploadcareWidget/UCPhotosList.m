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

static NSString *const kUploadcarePhotoListCell = @"kUploadcarePhotoListCell";
static NSString *const kUploadcarePhotoListSpinnerCell = @"kUploadcarePhotoListSpinnerCell";

@interface UCPhotosList()
- (NSArray *)photosForCellAtIndexPath:(NSIndexPath *)indexPath;
- (void)fillAlbumWithMorePhotos;
- (void)setState:(UCPhotosListState)newState;
@end

@implementation UCPhotosList

- (void)dealloc {
    [_album removeObserver:self forKeyPath:@"count"];
}

- (id)initWithGrabber:(GRKServiceGrabber *)grabber album:(GRKAlbum *)album {
    self = [super initWithNibName:@"UCPhotosList" bundle:nil];
    if (self != nil) {
        _grabber = grabber;
        _album = album;
        _lastLoadedPageIndex = 0;
        _nextPageIndexToLoad = 0;
        [self setState:UCPhotosListStateInitial];
        self.contentSizeForViewInPopover = CGSizeMake(320, 480);
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
    self.navigationItem.title = [_album.name isEqualToString:@"self"] ? self.albumList.serviceName : _album.name;
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
                if ([self.navigationController.topViewController isEqual:self]) [self.tableView reloadData];
            });
            break;
        }
        case UCPhotosListStateAllPhotosGrabbed:{
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.navigationController.topViewController isEqual:self]) [self.tableView reloadData];
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
    if (state == UCPhotosListStateAllPhotosGrabbed) return;
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
        NSLog(@" Failed to load page %d : %@", pageToLoad,  error);
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger res = 0;
    if (state == UCPhotosListStateAllPhotosGrabbed && section == _lastLoadedPageIndex) {
        NSInteger photosCount = [_album count];

        if (photosCount <= section*kNumberOfRowsPerSection*kNumberOfPhotosPerCell) return 0;
        NSInteger numberOfCompleteCell = (photosCount - section*kNumberOfRowsPerSection*kNumberOfPhotosPerCell) / kNumberOfPhotosPerCell;
        
        NSInteger thereIsALastCellWithLessThenFourPhotos = (photosCount % kNumberOfPhotosPerCell)?1:0;

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
        cell = [tableView dequeueReusableCellWithIdentifier:kUploadcarePhotoListSpinnerCell];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kUploadcarePhotoListSpinnerCell];
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [cell addSubview:spinner];
            [spinner setTag:0x1];
            [spinner setCenter:CGPointMake(CGRectGetWidth(cell.bounds) * .5f, CGRectGetHeight(cell.bounds) * .5f)];
        }
        [(UIActivityIndicatorView *)[cell viewWithTag:0x1] startAnimating];
    } else {        
        cell = [tableView dequeueReusableCellWithIdentifier:kUploadcarePhotoListCell];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"UCPhotosListCell" owner:self options:nil] objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [(UCPhotosListCell *)cell setPhotoList:self];
            [(UCPhotosListCell *)cell setServiceName:self.albumList.serviceName];
        }
        NSArray * photosAtIndexPath = [self photosForCellAtIndexPath:indexPath];
        [(UCPhotosListCell*)cell setPhotos:photosAtIndexPath];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell.reuseIdentifier isEqualToString:kUploadcarePhotoListSpinnerCell]) {
        if (state != UCPhotosListStateAllPhotosGrabbed) {
            [self fillAlbumWithMorePhotos];
        }
    }
}

@end
