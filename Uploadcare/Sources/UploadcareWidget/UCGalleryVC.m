//
//  UCGalleryVC.m
//  ExampleProject
//
//  Created by Yury Nechaev on 08.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCGalleryVC.h"
#import "UCGridGalleryCell.h"
#import "UCListGalleryCell.h"
#import "UCSocialEntry.h"
#import "UCWebViewController.h"
#import "UCSocialSource.h"
#import "UCConstantsHeader.h"
#import "UCSocialConstantsHeader.h"
#import "UCClient+Social.h"
#import "UCSocialEntriesRequest.h"
#import "UCSocialEntryRequest.h"
#import "UCSocialEntry.h"
#import "UCRemoteFileUploadRequest.h"
#import "NSString+EncodeRFC3986.h"
#import "UCNavButton.h"
#import "UCPersonGalleryCell.h"
#import "UCAlbumGalleryCell.h"
@import SafariServices;

static NSString *const UCBusyCellIdentifyer = @"UCBusyCellIdentifyer";


#define GRID_ELEMENTS_PER_ROW 3
#define ALBUMS_ELEMENTS_PER_ROW 2
#define LIST_ROW_HEIGHT 43.0
#define MAX_RETRY_COUNT 2
#define DEFAULT_SPACING 1.0
#define ALBUM_SPACING 20.0

@interface UCCollectionViewFlowLayout : UICollectionViewFlowLayout
@end

@implementation UCCollectionViewFlowLayout

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

@end

@interface UCGalleryVC () <UISearchBarDelegate, SFSafariViewControllerDelegate>

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, assign) BOOL isLastPage;
@property (nonatomic, assign) BOOL nextPageFetchStarted;
@property (nonatomic, strong) UCSocialSource *source;
@property (nonatomic, strong) UCSocialChunk *rootChunk;
@property (nonatomic, strong) UCSocialEntriesCollection *entriesCollection;
@property (nonatomic, strong) UIViewController *webVC;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, assign) NSUInteger retryCount;
@property (nonatomic, strong) UIActivityIndicatorView *loadingSpinner;

@property (nonatomic, copy) UCWidgetCompletionBlock completionBlock;
@property (nonatomic, copy) UCProgressBlock progressBlock;

@end

@implementation UCGalleryVC

- (id)initWithSource:(UCSocialSource *)source
           rootChunk:(UCSocialChunk *)rootChunk
            progress:(UCProgressBlock)progress
          completion:(UCWidgetCompletionBlock)completion
{
    self = [super initWithCollectionViewLayout:[[UCCollectionViewFlowLayout alloc] init]];
    if (self) {
        _completionBlock = completion;
        _progressBlock = progress;
        _source = source;
        _rootChunk = rootChunk;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupCollectionView];
    [self setupLoadingSpinner];
    [self setupSearchBarIfNeeded];
    [self setupCenterButtonIfNeeded];
    [self initialFetch];
    [self registerObservers];
}

- (void)setupLoadingSpinner {
    self.loadingSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.loadingSpinner.color = [UIColor lightGrayColor];
    self.loadingSpinner.hidesWhenStopped = YES;
    self.loadingSpinner.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.loadingSpinner];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.loadingSpinner
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.loadingSpinner
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1 constant:0]];
}

- (void)setupCollectionView {
    self.collectionView.delegate = self;
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    for (UCGalleryMode mode = UCGalleryModeGrid; mode <= UCGalleryModeAlbumsGrid; mode++) {
        Class<UCGalleryCellProtocol> cellClass = [self cellClassForMode:mode];
        [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:[cellClass cellIdentifier]];
    }
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:UCBusyCellIdentifyer];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.refreshControl.superview sendSubviewToBack:self.refreshControl];
}

- (void)registerObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveSuccessURLSchemeNotification:) name:UCURLSchemeDidReceiveSuccessCallbackNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveFailureURLSchemeNotification:) name:UCURLSchemeDidReceiveFailureCallbackNotification object:nil];
}

- (void)unregisterObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveFailureURLSchemeNotification:(NSNotification *)notification {
    [self.webVC dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)didReceiveSuccessURLSchemeNotification:(NSNotification *)notification {
    [self.webVC dismissViewControllerAnimated:YES completion:nil];
    [self initialFetch];
}

- (Class<UCGalleryCellProtocol>)cellClassForMode:(UCGalleryMode)mode {
    switch (mode) {
        case UCGalleryModeGrid: {
            return [UCGridGalleryCell class];
            break;
        }
        case UCGalleryModeList: {
            return [UCListGalleryCell class];
            break;
        }
        case UCGalleryModePersonList: {
            return [UCPersonGalleryCell class];
            break;
        }
        case UCGalleryModeAlbumsGrid: {
            return [UCAlbumGalleryCell class];
            break;
        }
    }
}

- (void)initialFetch {
    [self queryObjectOrLoginAddressForSource:self.source
                                   rootChunk:self.rootChunk
                                        path:self.entry ? self.entry.action.path.fullPath : nil
                                 showSpinner:YES];
}

- (void)setupSearchBarIfNeeded {
    if ([self.rootChunk.path isEqualToString:@"search"] && !self.searchBar) {

        CGFloat const searchBarHeight = 44;

        UISearchBar *searchBar = self.searchBar = [UISearchBar new];
        self.searchBar.translatesAutoresizingMaskIntoConstraints = NO;
        self.searchBar.placeholder = @"Search";
        [self.view addSubview:self.searchBar];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[searchBar]|"
                                                                          options:0
                                                                          metrics:0
                                                                            views:NSDictionaryOfVariableBindings(searchBar)]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.searchBar
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.topLayoutGuide
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.searchBar
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1 constant:searchBarHeight]];

        self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
        self.searchBar.delegate = self;
        self.collectionView.scrollIndicatorInsets =
        self.collectionView.contentInset = UIEdgeInsetsMake(self.topLayoutGuide.length + searchBarHeight, 0, 0, 0);


        [self.searchBar becomeFirstResponder];

    } else {
        if (self.searchBar) {
            [self.searchBar removeFromSuperview];
            self.searchBar = nil;
            self.collectionView.scrollIndicatorInsets =
            self.collectionView.contentInset = UIEdgeInsetsMake(self.topLayoutGuide.length, 0, 0, 0);

            [self.searchBar resignFirstResponder];
        }
    }
}

- (void)handleError:(NSError *)error {
    if ([self.refreshControl isRefreshing]) [self.refreshControl endRefreshing];
    NSLog(@"Gallery error: %@", error.localizedDescription);
    if ([error.localizedDescription isEqualToString:@"service error"]) {
        if (self.retryCount < MAX_RETRY_COUNT) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self initialFetch];
            });
            self.retryCount += 1;
        }
    }
}

- (void)loginUsingAddress:(NSString *)loginAddress {
    __weak __typeof(self) weakSelf = self;
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_8_4) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            SFSafariViewController *svc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:loginAddress] entersReaderIfAvailable:NO];
            svc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            svc.delegate = self;
            self.webVC = svc;
            [strongSelf presentViewController:self.webVC animated:YES completion:nil];
        });
    } else {
        self.webVC = [[UCWebViewController alloc] initWithURL:[NSURL URLWithString:loginAddress] cancelBlock:^{
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.navigationController popToRootViewControllerAnimated:YES];
        }];
        UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:self.webVC];
        navc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self presentViewController:navc animated:YES completion:nil];
    }
}

- (void)queryObjectOrLoginAddressForSource:(UCSocialSource *)source
                                 rootChunk:(UCSocialChunk *)rootChunk
                                      path:(NSString *)path
                               showSpinner:(BOOL)showSpinner
{
    if (showSpinner) [self.loadingSpinner startAnimating];

    __weak __typeof(self) weakSelf = self;
    [[UCClient defaultClient] performUCSocialRequest:[UCSocialEntriesRequest requestWithSource:source chunk:rootChunk path:path]
                                          completion:^(id response, NSError *error)
    {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                NSString *loginAddress = [response objectForKey:@"inapp_login_link"];
                if (loginAddress) {
                    [strongSelf loginUsingAddress:loginAddress];
                } else if ([response[@"obj_type"] isEqualToString:@"error"]) {
                    NSError *error = [NSError errorWithDomain:[UCClient socialErrorDomain] code:UCErrorUploadcare
                                                     userInfo:@{NSLocalizedDescriptionKey : response[@"error"]}];
                    [strongSelf handleError:error];
                } else {
                    [strongSelf processData:response];
                }

            } else {
                [strongSelf handleError:error];
            }
        });
    }];
}

- (void)processData:(id)responseData {
    UCSocialEntriesCollection *collection = [[UCSocialEntriesCollection alloc] initWithSerializedObject:responseData];
    self.entriesCollection = collection;
}

- (void)setupCenterButtonIfNeeded {

    if (self.source.rootChunks.count > 1 && !self.entry && ![self.navigationItem.titleView isKindOfClass:[UIButton class]]) {
        UCNavButton *button = [[UCNavButton alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
        NSString *title = nil;
        if (self.entry)
            title = self.entry.action.path.chunks.lastObject.title;
        else
            title = self.rootChunk.title;
        [button setTitle:title forState:UIControlStateNormal];
        self.navigationItem.titleView = button;
        [button addTarget:self action:@selector(expandButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        self.navigationItem.title = self.entry.action.path.chunks.lastObject.title ?: self.rootChunk.title;
    }
}

- (void)expandButtonPressed:(UIButton *)sender {
    [self didPressChunkSelector];
}

- (void)didPressChunkSelector {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Choose option" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

    for (UCSocialChunk *chunk in self.source.rootChunks) {
        __block UCSocialChunk *blockChunk = chunk;
        UCGalleryVC * __weak weakSelf = self;
        [actionSheet addAction:[UIAlertAction actionWithTitle:chunk.title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            self->_entriesCollection = nil;
            weakSelf.rootChunk = blockChunk;
            Class<UCGalleryCellProtocol> cellClass = [weakSelf cellClassForMode:weakSelf.entriesCollection.galleryMode];
            [weakSelf.collectionView registerClass:cellClass forCellWithReuseIdentifier:[cellClass cellIdentifier]];
            [weakSelf updateNavigationTitle];
            [weakSelf setupSearchBarIfNeeded];
            [weakSelf.collectionView reloadData];
            [weakSelf queryObjectOrLoginAddressForSource:weakSelf.source
                                               rootChunk:blockChunk
                                                    path:weakSelf.entriesCollection.path.fullPath
                                             showSpinner:YES];
        }]];
    }
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)updateNavigationTitle {
    UIButton *button = (UIButton *)self.navigationItem.titleView;
    if ([button isKindOfClass:[UIButton class]]) {
        [button setTitle:self.rootChunk.title forState:UIControlStateNormal];
    }
}

- (void)setEntriesCollection:(UCSocialEntriesCollection *)entriesCollection {
    if ([self.refreshControl isRefreshing]) [self.refreshControl endRefreshing];
    [self.loadingSpinner stopAnimating];
    self.isLastPage = !entriesCollection.nextPage.fullPath.length;

    if (self.nextPageFetchStarted) {
        [self appendDataFromCollection:entriesCollection];
    } else {
        _entriesCollection = entriesCollection;
        [self.collectionView reloadData];
    }
}

- (void)appendDataFromCollection:(UCSocialEntriesCollection *)entriesCollection {
    self.nextPageFetchStarted = NO;

    NSUInteger index = 0;
    if (_entriesCollection.entries.count) index = _entriesCollection.entries.count;
    NSUInteger length = entriesCollection.entries.count;

    _entriesCollection = [self collectionMergedWith:entriesCollection];

    [self.collectionView performBatchUpdates:^{
        NSMutableArray *indexPaths = @[].mutableCopy;
        for (NSUInteger i = index; i < index + length; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
        }
        [self.collectionView insertItemsAtIndexPaths:indexPaths];

    } completion:nil];
}

- (UCSocialEntriesCollection *)collectionMergedWith:(UCSocialEntriesCollection *)collection {
    NSArray *entries = [self.entriesCollection.entries ?: @[] arrayByAddingObjectsFromArray:collection.entries];
    collection.entries = entries;
    return collection;
}

- (void)refresh {
    _entriesCollection = nil;

    [self queryObjectOrLoginAddressForSource:self.source
                                   rootChunk:self.rootChunk
                                        path:self.entry ? self.entry.action.path.fullPath : nil
                                 showSpinner:NO];
}

- (void)search:(NSString *)text {
    [self queryObjectOrLoginAddressForSource:self.source
                                   rootChunk:self.entriesCollection.root
                                        path:[NSString stringWithFormat:@"-/%@", text]
                                 showSpinner:YES];
    self.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeNone;
    if (self.entriesCollection) {
        _entriesCollection = nil;
        [self.collectionView reloadData];
    }
    self.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
}

- (void)loadNextPage {
    [self queryObjectOrLoginAddressForSource:self.source
                                   rootChunk:self.entriesCollection.root
                                        path:self.entriesCollection.nextPage.fullPath
                                 showSpinner:NO];
}

- (void)uploadSocialEntry:(UCSocialEntry *)entry withThumbnail:(UIImage *)thumbnail {
    if (self.progressBlock) self.progressBlock (0, NSUIntegerMax);
    [self uploadSocialEntry:entry
              withThumbnail:thumbnail
                  forSource:self.source];
}

- (void)uploadSocialEntry:(UCSocialEntry *)entry
            withThumbnail:(UIImage *)thumbnail
                forSource:(UCSocialSource *)source
{
    UCSocialEntryRequest *req = [UCSocialEntryRequest requestWithSource:source file:entry.action.urlString.encodedRFC3986];

    __weak __typeof(self) weakSelf = self;
    [[UCClient defaultClient] performUCSocialRequest:req completion:^(id response, NSError *error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;

        if (!error && [response isKindOfClass:[NSDictionary class]]) {
            NSString *fileURL = response[@"url"];
            UCRemoteFileUploadRequest *request = [UCRemoteFileUploadRequest requestWithRemoteFileURL:fileURL];

            [[UCClient defaultClient] performUCRequest:request progress:^(NSUInteger totalBytesSent, NSUInteger totalBytesExpectedToSend) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (strongSelf.progressBlock) strongSelf.progressBlock (totalBytesSent, totalBytesExpectedToSend);
                });

            } completion:^(id response, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!error) {
                        NSDictionary *result = response;
                        if (thumbnail) {
                            NSMutableDictionary *responseWithThumbnail = [@{UCWidgetResponseLocalThumbnailResponseKey : thumbnail} mutableCopy];
                            [responseWithThumbnail addEntriesFromDictionary:result];
                            result = responseWithThumbnail.copy;
                        }
                        if (strongSelf.completionBlock) strongSelf.completionBlock(response[@"file_id"], result, nil);
                    } else {
                        if (strongSelf.completionBlock) strongSelf.completionBlock(nil, response, error);
                    }
                });
            }];

        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (strongSelf.completionBlock) strongSelf.completionBlock(nil, nil, error);
            });
        }
    }];
}

- (void)dealloc {
    [self unregisterObservers];
}

#pragma mark - <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize bounds = self.view.bounds.size;
    switch (self.entriesCollection.galleryMode) {
        case UCGalleryModeGrid: {
            CGFloat spacing = DEFAULT_SPACING;
            NSUInteger perRow = GRID_ELEMENTS_PER_ROW;
            CGFloat size = ceil(MIN(bounds.width, bounds.height) / perRow - spacing);
            return CGSizeMake(size, size);
            break;
        }
        case UCGalleryModeList: {
            return [self listItemSizeForBounds:bounds];
            break;
        }
        case UCGalleryModePersonList: {
            return [self listItemSizeForBounds:bounds];
            break;
        }
        case UCGalleryModeAlbumsGrid: {
            CGFloat spacing = ALBUM_SPACING;
            NSUInteger perRow = ALBUMS_ELEMENTS_PER_ROW;
            CGFloat size = ceil((MIN(bounds.width, bounds.height) - spacing * 2) / perRow - spacing);
            return CGSizeMake(size, size + [UCAlbumGalleryCell heightFromWidthConstant:size]);
            break;
        }
    }
}

- (CGSize)listItemSizeForBounds:(CGSize)bounds {
    return CGSizeMake(bounds.width, LIST_ROW_HEIGHT);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    if (self.entriesCollection.galleryMode == UCGalleryModeAlbumsGrid) {
        CGFloat spacing = ALBUM_SPACING;
        return UIEdgeInsetsMake(self.searchBar ? spacing + 44.0 : spacing, spacing, spacing, spacing);
    } else {
        return UIEdgeInsetsZero;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    if (self.entriesCollection.galleryMode == UCGalleryModeAlbumsGrid) {
        CGFloat spacing = ALBUM_SPACING;
        return spacing;
    } else {
        CGFloat spacing = DEFAULT_SPACING;
        return spacing;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    if (self.entriesCollection.galleryMode == UCGalleryModeAlbumsGrid) {
        CGFloat spacing = ALBUM_SPACING;
        return spacing;
    } else if (self.entriesCollection.galleryMode == UCGalleryModeGrid) {
        CGFloat spacing = DEFAULT_SPACING;
        return spacing;
    } else {
        return 0;
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.entriesCollection.entries.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UCSocialEntry *entry = self.entriesCollection.entries[indexPath.row];
    UICollectionViewCell<UCGalleryCellProtocol> *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[[self cellClassForMode:self.entriesCollection.galleryMode] cellIdentifier] forIndexPath:indexPath];
    [cell setSocialEntry:entry];
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.isLastPage && indexPath.row == self.entriesCollection.entries.count - 1 && !self.nextPageFetchStarted && self.entriesCollection) {
        self.nextPageFetchStarted = YES;
        [self loadNextPage];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    UCSocialEntry *entry = self.entriesCollection.entries[indexPath.row];
    UCSocialEntryActionType actionType = entry.action.actionType;

    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    UIImage *localFileThumbnail;
    if ([cell isKindOfClass:UCGalleryCell.class]) {
        UCGalleryCell *galleryCell = (UCGalleryCell *)cell;
        localFileThumbnail = galleryCell.imageView.image;
    }

    switch (actionType) {
        case UCSocialEntryActionTypeUnknown:
        case UCSocialEntryActionTypeSelectFile:
            [self uploadSocialEntry:entry withThumbnail:localFileThumbnail];
            break;
        case UCSocialEntryActionTypeOpenPath:
            [self openGalleryWithEntry:entry];
            break;
    }
}

- (void)openGalleryWithEntry:(UCSocialEntry *)entry {
    UCGalleryVC *gallery = [[UCGalleryVC alloc] initWithSource:self.source
                                                     rootChunk:self.rootChunk
                                                      progress:self.progressBlock
                                                    completion:self.completionBlock];
    gallery.entry = entry;
    [self.navigationController pushViewController:gallery animated:YES];
}

#pragma mark - <UISearchBarDelegate>

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    if ([searchBar.text rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet].invertedSet].location != NSNotFound) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self search:searchBar.text];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

#pragma mark - <SFSafariViewControllerDelegate>

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    [self.navigationController popToRootViewControllerAnimated:NO];
}

@end
