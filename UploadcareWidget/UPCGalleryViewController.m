//
//  UPCGalleryViewController.m
//  Social Source
//
//  Created by Zoreslav Khimich on 03/03/2013.
//  Copyright (c) 2013 zrxq. All rights reserved.
//

#import "UPCGalleryViewController.h"
#import "UPCGalleryViewCell.h"
#import "UploadcareSocialSource.h"
#import "UPCSourceViewController.h"

#import <UIImageView+AFNetworking.h>

@interface UPCGalleryViewController ()
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) UPCSocialSourceClient *socialSource;
@property (strong, nonatomic) NSString *serviceBase;
@property (assign, nonatomic) BOOL isLastPage;
@property (assign, nonatomic) BOOL nextPageFetchStarted;

- (UPCSourceViewController *)sourceViewController;

@end

@implementation UPCGalleryViewController

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {        
        self.gridView.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1.];
        
        /* Always allow bouncing (to enable pull to refresh) */
        self.gridView.bounces = YES;
        self.gridView.alwaysBounceVertical = YES;
        
        self.refreshControl = [[UIRefreshControl alloc]init];
        [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
        [self.gridView addSubview:self.refreshControl];
        
        _isLastPage = YES;
    }
    return self;
}

#pragma mark - parent = UPCSourceViewController

- (void)willMoveToParentViewController:(UIViewController *)parent {
    NSAssert([parent isKindOfClass:[UPCSourceViewController class]] || !parent, @"%@ expects a %@ as it parent view controller, got %@ instead", self, [UPCSourceViewController class], parent);
}

- (UPCSourceViewController *)sourceViewController {
    return (UPCSourceViewController *)self.parentViewController;
}

#pragma mark - fetch data

- (void)refresh {
    [self.sourceViewController refreshThings];
}

- (void)setThings:(NSArray *)things isLastPage:(BOOL)isLastPage {
    if (self.refreshControl.isRefreshing) {
        [self.refreshControl endRefreshing];
    }

    self.isLastPage = isLastPage;
    self.nextPageFetchStarted = NO;
    
    _things = things;
    
    [self.gridView reloadData];
    
    if ([self.stylePath.lastPathComponent isEqualToString:@"search"]) {
        UISearchBar *searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.gridView.bounds), 44)];
        searchBar.delegate = self;
        searchBar.tintColor = self.navigationController.navigationBar.tintColor;
        self.gridView.gridHeaderView = searchBar;
        if (things.count == 0) {
            [searchBar becomeFirstResponder];
        }
    } else {
        /* a spacer to make the grid look neat */
        self.gridView.gridHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.gridView.frame), 3)];
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.sourceViewController search:searchBar.text];
}

#pragma mark - AQGridView stuff

- (CGSize)portraitGridCellSizeForGridView:(AQGridView *)gridView {
    return CGSizeMake(80, 80);
}

- (NSUInteger)numberOfItemsInGridView:(AQGridView *)gridView {
    return self.things.count + (self.isLastPage ? 0 : 1);
}

- (void)gridView:(AQGridView *)gridView willDisplayCell:(AQGridViewCell *)cell forItemAtIndex:(NSUInteger)index {
    const NSUInteger kPrefetchStartsAtCell = 20;
        
    if (!self.isLastPage && self.things.count - index <= kPrefetchStartsAtCell && !self.nextPageFetchStarted) {
        self.nextPageFetchStarted = YES;
        [self.sourceViewController fetchNextThingsPage];
    }
}

- (AQGridViewCell*)gridView:(AQGridView *)gridView cellForItemAtIndex:(NSUInteger)index {
    static NSString *const kCellIdentifier = @"UPCGalleryViewCellIdentifier";
    static NSString *const kBusyCellIdentifyer = @"UPCGalleryViewBusyCellIdentifier";
    if (index < self.things.count) {
        /* content cell */
        UPCGalleryViewCell *cell = (UPCGalleryViewCell*)[gridView dequeueReusableCellWithIdentifier:kCellIdentifier];
        if (!cell) {
            cell = [[UPCGalleryViewCell alloc]initWithFrame:CGRectMake(0, 0, 75, 75) reuseIdentifier:kCellIdentifier];
        }
        
        USSThing *thing = self.things[index];
        
        [cell.imageView setImageWithURL:thing.thumbnailURL];
        
        return cell;
    } else {
        /* activity indicator cell */
        AQGridViewCell *cell = [gridView dequeueReusableCellWithIdentifier:kBusyCellIdentifyer];
        if (!cell) {
            cell = [[AQGridViewCell alloc]initWithFrame:CGRectMake(0, 0, 75, 75) reuseIdentifier:kBusyCellIdentifyer];
            cell.contentView.backgroundColor = self.gridView.backgroundColor;
            
            UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [cell addSubview:activityIndicator];
            [activityIndicator setCenter:CGPointMake(CGRectGetWidth(cell.bounds) * .5, CGRectGetHeight(cell.bounds) * .5)];
            [activityIndicator setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
            [activityIndicator startAnimating];
        }
        return cell;
    }
}

- (NSUInteger)gridView:(AQGridView *)gridView willSelectItemAtIndex:(NSUInteger)index {
    if (index >= self.things.count) return;
    
    USSThing *thing = self.things[index];
    UPCGalleryViewCell *cell = (UPCGalleryViewCell *)[self.gridView cellForItemAtIndex:index];
    [self.sourceViewController performSocialSourceAction:thing.action forItemTitled:thing.title withThumbnailURL:thing.thumbnailURL thumbnailImage:cell.imageView.image];

    return NSNotFound;
}

@end
