//
//  UCGalleryVC.m
//  ExampleProject
//
//  Created by Yury Nechaev on 08.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCGalleryVC.h"
#import "UCGalleryCell.h"
#import "UCSocialEntry.h"

static NSString *const kCellIdentifier = @"UCGalleryVCCellIdentifier";
static NSString *const kBusyCellIdentifyer = @"UCGalleryVCBusyCellIdentifier";

#define ELEMENTS_PER_ROW 3

@interface UCGalleryVC ()
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, assign) BOOL isLastPage;
@property (nonatomic, assign) BOOL nextPageFetchStarted;
@property (nonatomic, copy) void (^completionBlock)(UCSocialEntry *socialEntry);
@end

@implementation UCGalleryVC

- (id)initWithCompletion:(void(^)(UCSocialEntry *socialEntry))completion {
    self = [super initWithCollectionViewLayout:[[self class] layout]];
    if (self) {
        _completionBlock = completion;
    }
    return self;
}

+ (UICollectionViewLayout *)layout {
    NSUInteger inLineCount = ELEMENTS_PER_ROW;
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
    [self.collectionView registerClass:[UCGalleryCell class] forCellWithReuseIdentifier:kCellIdentifier];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kBusyCellIdentifyer];
    self.collectionView.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1.];
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    self.navigationItem.title = self.root.title;
}

- (void)setEntriesCollection:(UCSocialEntriesCollection *)entriesCollection {
    self.isLastPage = !entriesCollection.nextPagePath.length;
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
    
}

- (void)loadNextPage {
    if ([self.delegate respondsToSelector:@selector(fetchNextPagePath:forCollection:)]) {
        [self.delegate fetchNextPagePath:self.root.path forCollection:self.entriesCollection];
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
    UCGalleryCell *cell = (UCGalleryCell*)[collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    UCSocialEntry *entry = self.entriesCollection.entries[indexPath.row];
    [cell setSocialEntry:entry];
    return cell;
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
    if ([self.delegate respondsToSelector:@selector(fetchChunk:forCollection:)]) {
        [self.delegate fetchChunk:entry.action.path.chunks.firstObject forCollection:self.entriesCollection];
    }
}

@end
