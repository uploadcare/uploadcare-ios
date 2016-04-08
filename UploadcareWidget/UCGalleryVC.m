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

@interface UCGalleryVC ()
@property (nonatomic, strong) UCSocialEntriesCollection *entriesCollection;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, assign) BOOL isLastPage;
@property (nonatomic, assign) BOOL nextPageFetchStarted;
@end

@implementation UCGalleryVC

- (id)initWitSocialEntriesCollection:(UCSocialEntriesCollection *)collection {
    self = [super initWithCollectionViewLayout:[[self class] layout]];
    if (self) {
        _entriesCollection = collection;
    }
    return self;
}

+ (UICollectionViewLayout *)layout {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.itemSize = CGSizeMake(100.0, 106.0);
    layout.minimumInteritemSpacing = 1.0;
    layout.minimumLineSpacing = 3.0;
    return layout;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [super viewDidLoad];
    [self.collectionView registerClass:[UCGalleryCell class] forCellWithReuseIdentifier:kCellIdentifier];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kBusyCellIdentifyer];
    self.collectionView.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1.];
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    _isLastPage = YES;
}


- (void)refresh {
    
}

- (void)loadNextPage {
    
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
    return self.entriesCollection.entries.count + (self.isLastPage ? 0 : 1);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < self.entriesCollection.entries.count) {
        UCGalleryCell *cell = (UCGalleryCell*)[collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
        UCSocialEntry *entry = self.entriesCollection.entries[indexPath.row];
        [cell setSocialEntry:entry];
        return cell;
    } else {
        /* activity indicator cell */
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kBusyCellIdentifyer forIndexPath:indexPath];
        if (!cell.contentView.subviews.count) {
            cell.contentView.backgroundColor = collectionView.backgroundColor;
            
            UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [cell.contentView addSubview:activityIndicator];
            [activityIndicator setCenter:CGPointMake(CGRectGetWidth(cell.bounds) * .5, CGRectGetHeight(cell.bounds) * .5)];
            [activityIndicator setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
            [activityIndicator startAnimating];
        }
        return cell;
    }
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    const NSUInteger kPrefetchStartsAtCell = 20;
    
    if (!self.isLastPage && self.entriesCollection.entries.count - indexPath.row <= kPrefetchStartsAtCell && !self.nextPageFetchStarted) {
        self.nextPageFetchStarted = YES;
        [self loadNextPage];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UCSocialEntry *entry = self.entriesCollection.entries[indexPath.row];
    NSLog(@"Entry selected: %@", entry);
//    UPCGalleryViewCell *cell = (UPCGalleryViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
//    [self.sourceViewController performSocialSourceAction:thing.action forItemTitled:thing.title withThumbnailURL:thing.thumbnailURL thumbnailImage:cell.imageView.image];
}

@end
