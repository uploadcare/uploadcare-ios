//
//  UCGalleryVC.m
//  ExampleProject
//
//  Created by Yury Nechaev on 08.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCGalleryVC.h"
#import "UCGalleryCell.h"
#import "UCFlatGalleryCell.h"
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

static NSString *const kCellIdentifier = @"UCGalleryVCCellIdentifier";
static NSString *const kBusyCellIdentifyer = @"UCGalleryVCBusyCellIdentifier";

#define GRID_ELEMENTS_PER_ROW 3
#define LIST_ROW_HEIGHT 40
#define MAX_RETRY_COUNT 2

@interface UCGalleryVC () <UISearchBarDelegate>
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, assign) BOOL isLastPage;
@property (nonatomic, assign) BOOL nextPageFetchStarted;
@property (nonatomic, assign) UCGalleryMode currentMode;
@property (nonatomic, strong) UCSocialSource *source;
@property (nonatomic, strong) UCSocialChunk *rootChunk;
@property (nonatomic, strong) UCSocialEntriesCollection *entriesCollection;
@property (nonatomic, strong) UCWebViewController *webVC;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, assign) NSUInteger retryCount;

@property (nonatomic, copy) void (^completionBlock)(NSString *fileId, NSError *error);
@property (nonatomic, copy) void (^progressBlock)(NSUInteger bytesSent, NSUInteger bytesExpectedToSend);

@property (nonatomic, copy) void (^responseBlock)(id response, NSError *error);
@end

@implementation UCGalleryVC

- (id)initWithMode:(UCGalleryMode)mode
            source:(UCSocialSource *)source
         rootChunk:(UCSocialChunk *)rootChunk
          progress:(void(^)(NSUInteger bytesSent, NSUInteger bytesExpectedToSend))progress
        completion:(void(^)(NSString *fileId, NSError *error))completion {
    self = [super initWithCollectionViewLayout:[[self class] layoutForMode:mode]];
    if (self) {
        _completionBlock = completion;
        _progressBlock = progress;
        _currentMode = mode;
        _source = source;
        _rootChunk = rootChunk;
    }
    return self;
}

+ (UICollectionViewFlowLayout *)layoutForMode:(UCGalleryMode)mode {
    switch (mode) {
        case UCGalleryModeGrid: {
            return [[self class] gridLayout];
            break;
        }
        case UCGalleryModeList: {
            return [[self class] listLayout];
            break;
        }
    }
}

+ (UICollectionViewFlowLayout *)listLayout {
    CGFloat rowHeight = LIST_ROW_HEIGHT;
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat horizontalOffset = 1.0;
    CGFloat verticalOffset = 4.0;
    CGFloat width = floor(screenSize.width) - horizontalOffset * 2;
    CGFloat height = rowHeight;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(verticalOffset, horizontalOffset, verticalOffset, horizontalOffset);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.itemSize = CGSizeMake(width, height);
    layout.minimumInteritemSpacing = horizontalOffset;
    layout.minimumLineSpacing = verticalOffset;
    return layout;
}

+ (UICollectionViewFlowLayout *)gridLayout {
    NSUInteger inLineCount = GRID_ELEMENTS_PER_ROW;
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat horizontalOffset = 1.0;
    CGFloat verticalOffset = 1.0;
    CGFloat width = floor(screenSize.width / inLineCount) - horizontalOffset * 2;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(verticalOffset, horizontalOffset, verticalOffset, horizontalOffset);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.itemSize = CGSizeMake(width, width);
    layout.minimumInteritemSpacing = horizontalOffset;
    layout.minimumLineSpacing = verticalOffset;
    return layout;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.delegate = self;
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.collectionView registerClass:self.currentMode == UCGalleryModeGrid ? [UCGalleryCell class] : [UCFlatGalleryCell class] forCellWithReuseIdentifier:kCellIdentifier];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kBusyCellIdentifyer];
    self.collectionView.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1.];
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    [self setupSearchBarIfNeeded];
    [self setupNavigationButtons];
    [self initialFetch];
}

- (void)initialFetch {
    [self queryObjectOrLoginAddressForSource:self.source rootChunk:self.rootChunk path:self.entry ? self.entry.action.path.fullPath : nil];
}

- (void)setupSearchBarIfNeeded {
    if ([self.rootChunk.path isEqualToString:@"search"] && !self.searchBar) {
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.collectionView.frame), 44)];
        self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
        self.searchBar.delegate = self;
        [self.collectionView addSubview:self.searchBar];
        [self.collectionView setContentOffset:CGPointMake(0, 44)];
    } else {
        if (self.searchBar) {
            [self.searchBar removeFromSuperview];
            self.searchBar = nil;
        }
    }
}

- (void(^)(id response, NSError *error))responseBlock {
    if (!_responseBlock) {
        __weak __typeof(self) weakSelf = self;
        _responseBlock = ^(id response, NSError *error){
            __strong __typeof__(weakSelf) strongSelf = weakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) {
                    NSString *loginAddress = [response objectForKey:@"login_link"];
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
        };
    }
    return _responseBlock;
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
    
    //    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_8_4) {
    //        SFSafariViewController *svc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:loginAddress]];
    //        svc.delegate = self;
    //        [self.navigationController pushViewController:svc animated:YES];
    //    } else {
    self.webVC = [[UCWebViewController alloc] initWithURL:[NSURL URLWithString:loginAddress] loadingBlock:^(NSURL *url) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        NSLog(@"URL: %@", url);
        if ([url.host isEqual:UCSocialAPIRoot] && [url.lastPathComponent isEqual:@"endpoint"]) {
            [strongSelf.webVC dismissViewControllerAnimated:YES completion:nil];
            [strongSelf initialFetch];
        }
    } cancelBlock:^{
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [strongSelf.navigationController popToRootViewControllerAnimated:YES];
    }];
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:self.webVC];
    [self.navigationController presentViewController:navc animated:YES completion:nil];
    //    }
}

- (void)queryObjectOrLoginAddressForSource:(UCSocialSource *)source rootChunk:(UCSocialChunk *)rootChunk path:(NSString *)path {
    [[UCClient defaultClient] performUCSocialRequest:[UCSocialEntriesRequest requestWithSource:source chunk:rootChunk path:path] completion:self.responseBlock];
}

- (void)processData:(id)responseData {
    UCSocialEntriesCollection *collection = [[UCSocialEntriesCollection alloc] initWithSerializedObject:responseData];
    self.entriesCollection = collection;
}

- (void)setupNavigationButtons {
    if (self.entry) self.navigationItem.title = self.entry.action.path.chunks.lastObject.title;
    else self.navigationItem.title = self.rootChunk.title;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Source" style:UIBarButtonItemStylePlain target:self action:@selector(didPressChunkSelector)];
}

- (void)didPressChunkSelector {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Choose option" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];
    for (UCSocialChunk *chunk in self.source.rootChunks) {
        __block UCSocialChunk *blockChunk = chunk;
        [actionSheet addAction:[UIAlertAction actionWithTitle:chunk.title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            _entriesCollection = nil;
            self.rootChunk = blockChunk;
            [self updateNavigationTitle];
            [self setupSearchBarIfNeeded];
            [self.collectionView reloadData];
            [self queryObjectOrLoginAddressForSource:self.source rootChunk:blockChunk path:self.entriesCollection.path.fullPath];
        }]];
    }
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)updateNavigationTitle {
    self.navigationItem.title = self.rootChunk.title;
}

- (void)setEntriesCollection:(UCSocialEntriesCollection *)entriesCollection {
    if ([self.refreshControl isRefreshing]) [self.refreshControl endRefreshing];
    self.isLastPage = !entriesCollection.nextPage.fullPath.length;
    [self appendDataFromCollection:entriesCollection];
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

    } completion:^(BOOL finished) {
        
    }];
}

- (UCSocialEntriesCollection *)collectionMergedWith:(UCSocialEntriesCollection *)collection {
    NSArray *entries = [self.entriesCollection.entries ?: @[] arrayByAddingObjectsFromArray:collection.entries];
    collection.entries = entries;
    return collection;
}

- (void)refresh {
    _entriesCollection = nil;
    [self.collectionView reloadData];
    [self initialFetch];
}

- (void)search:(NSString *)text {
    [self queryObjectOrLoginAddressForSource:self.source rootChunk:self.entriesCollection.root path:[NSString stringWithFormat:@"-/%@", text]];
    self.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeNone;
    if (self.entriesCollection) {
        _entriesCollection = nil;
        [self.collectionView reloadData];
    }
    self.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
}

- (void)loadNextPage {
    [self queryObjectOrLoginAddressForSource:self.source rootChunk:self.entriesCollection.root path:self.entriesCollection.nextPage.fullPath];
}

- (void)uploadSocialEntry:(UCSocialEntry *)entry {
    if (self.progressBlock) self.progressBlock (0, NSUIntegerMax);
    [self uploadSocialEntry:entry forSource:self.source progress:self.progressBlock completion:self.completionBlock];
}

- (void)uploadSocialEntry:(UCSocialEntry *)entry
                forSource:(UCSocialSource *)source
                 progress:(void(^)(NSUInteger bytesSent, NSUInteger bytesExpectedToSend))progressBlock
               completion:(void(^)(NSString *fileId, NSError *error))completionBlock {
    UCSocialEntryRequest *req = [UCSocialEntryRequest requestWithSource:source file:entry.action.urlString.encodedRFC3986];
    [[UCClient defaultClient] performUCSocialRequest:req completion:^(id response, NSError *error) {
        if (!error && [response isKindOfClass:[NSDictionary class]]) {
            NSString *fileURL = response[@"url"];
            UCRemoteFileUploadRequest *request = [UCRemoteFileUploadRequest requestWithRemoteFileURL:fileURL];
            [[UCClient defaultClient] performUCRequest:request progress:^(NSUInteger totalBytesSent, NSUInteger totalBytesExpectedToSend) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (progressBlock) progressBlock (totalBytesSent, totalBytesExpectedToSend);
                });
            } completion:^(id response, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!error) {
                        if (completionBlock) completionBlock(response[@"file_id"], nil);
                    } else {
                        if (completionBlock) completionBlock(nil, error);
                    }
                });
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock) completionBlock(nil, error);
            });
        }
    }];
}

#pragma mark <UICollectionViewDataSource>

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    UICollectionViewFlowLayout *layout = [[self class] layoutForMode:self.currentMode];
    UIEdgeInsets insets = layout.sectionInset;
    if (self.searchBar) insets.top = insets.top + 44.0;
    return insets;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.entriesCollection.entries.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UCSocialEntry *entry = self.entriesCollection.entries[indexPath.row];
    if (self.currentMode == UCGalleryModeGrid) {
        UCGalleryCell *cell = (UCGalleryCell*)[collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
        [cell setSocialEntry:entry];
        return cell;
    } else {
        UCFlatGalleryCell *cell = (UCFlatGalleryCell*)[collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
        [cell setSocialEntry:entry];
        return cell;
    }
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
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
    switch (actionType) {
        case UCSocialEntryActionTypeUnknown: {
            [self uploadSocialEntry:entry];
            break;
        }
        case UCSocialEntryActionTypeSelectFile: {
            [self uploadSocialEntry:entry];
            break;
        }
        case UCSocialEntryActionTypeOpenPath: {
            [self openGalleryWithEntry:entry];
            break;
        }
    }
}

- (void)openGalleryWithEntry:(UCSocialEntry *)entry {
    UCGalleryVC *gallery = [[UCGalleryVC alloc] initWithMode:self.currentMode source:self.source rootChunk:self.rootChunk progress:self.progressBlock completion:self.completionBlock];
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

@end
