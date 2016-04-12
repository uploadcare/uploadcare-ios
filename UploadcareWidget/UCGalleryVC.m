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

static NSString *const kCellIdentifier = @"UCGalleryVCCellIdentifier";
static NSString *const kBusyCellIdentifyer = @"UCGalleryVCBusyCellIdentifier";

#define GRID_ELEMENTS_PER_ROW 3
#define LIST_ROW_HEIGHT 40

@interface UCGalleryVC ()
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, assign) BOOL isLastPage;
@property (nonatomic, assign) BOOL nextPageFetchStarted;
@property (nonatomic, assign) UCGalleryMode currentMode;
@property (nonatomic, copy) void (^completionBlock)(UCSocialEntry *socialEntry);
@end

@implementation UCGalleryVC

- (id)initWithMode:(UCGalleryMode)mode completion:(void(^)(UCSocialEntry *socialEntry))completion {
    self = [super initWithCollectionViewLayout:[[self class] layoutForMode:mode]];
    if (self) {
        _completionBlock = completion;
        _currentMode = mode;
    }
    return self;
}

+ (UICollectionViewLayout *)layoutForMode:(UCGalleryMode)mode {
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

+ (UICollectionViewLayout *)listLayout {
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

+ (UICollectionViewLayout *)gridLayout {
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
    [self.collectionView registerClass:self.currentMode == UCGalleryModeGrid ? [UCGalleryCell class] : [UCFlatGalleryCell class] forCellWithReuseIdentifier:kCellIdentifier];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kBusyCellIdentifyer];
    self.collectionView.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1.];
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    [self setupNavigationButtons];
}

- (void)setupNavigationButtons {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Source" style:UIBarButtonItemStylePlain target:self action:@selector(didPressChunkSelector)];
}

- (void)didPressChunkSelector {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Choose option" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];
    
    NSArray<UCSocialChunk*> *availableChunks = nil;
    if ([self.delegate respondsToSelector:@selector(availableSocialChunks)]) {
        availableChunks = [self.delegate availableSocialChunks];
    }
    
    for (UCSocialChunk *chunk in availableChunks) {
        __block UCSocialChunk *blockChunk = chunk;
        [actionSheet addAction:[UIAlertAction actionWithTitle:chunk.title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if ([self.delegate respondsToSelector:@selector(fetchChunk:path:newWindow:)]) {
                [self.delegate fetchChunk:blockChunk path:self.entriesCollection.path newWindow:YES];
            }
        }]];

    }
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)setEntriesCollection:(UCSocialEntriesCollection *)entriesCollection {
    if ([self.refreshControl isRefreshing]) [self.refreshControl endRefreshing];
    self.navigationItem.title = entriesCollection.root.title;
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
    if ([self.delegate respondsToSelector:@selector(fetchChunk:path:newWindow:)]) {
        [self.delegate fetchChunk:self.entriesCollection.root path:self.entriesCollection.path newWindow:NO];
    }
}

- (void)loadNextPage {
    if ([self.delegate respondsToSelector:@selector(fetchNextPageWithChunk:nextPagePath:)]) {
        [self.delegate fetchNextPageWithChunk:self.entriesCollection.root nextPagePath:self.entriesCollection.nextPage.fullPath];
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
//    [self.sourceViewController search:searchBar.text];
}

#pragma mark <UICollectionViewDataSource>

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
            if (self.completionBlock) self.completionBlock (entry);
            break;
        }
        case UCSocialEntryActionTypeSelectFile: {
            if (self.completionBlock) self.completionBlock (entry);
            break;
        }
        case UCSocialEntryActionTypeOpenPath: {
            [self openGalleryWithEntry:entry];
            break;
        }
    }
}

- (void)openGalleryWithEntry:(UCSocialEntry *)entry {
    if ([self.delegate respondsToSelector:@selector(fetchChunk:path:newWindow:)]) {
        [self.delegate fetchChunk:self.entriesCollection.root path:entry.action.path newWindow:YES];
    }
}

@end
