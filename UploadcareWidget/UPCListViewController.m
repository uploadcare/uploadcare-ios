//
//  UPCListViewController.m
//  Social Source
//
//  Created by Zoreslav Khimich on 09/03/2013.
//  Copyright (c) 2013 zrxq. All rights reserved.
//

#import "UPCListViewController.h"
#import "UploadcareSocialSource.h"
#import "UPCSourceViewController.h"
#import "UPCListViewCell.h"
#import "UPCSocialStyle.h"
#import "UPCListViewBusyCell.h"

#import <UIImageView+AFNetworking.h>
#import <QuartzCore/QuartzCore.h>

@interface UPCListViewController ()
@property (assign, nonatomic) UPCListStyle listStyle;
@property (assign, nonatomic) BOOL isLastPage;
@property (assign, nonatomic) BOOL nextPageFetchStarted;
@end

@implementation UPCListViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.tableView.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1.];
        
        if ([self respondsToSelector:@selector(setRefreshControl:)]) {
            
            self.refreshControl = [[UIRefreshControl alloc]init];
            [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
            
        }
        
        _isLastPage = YES;
    }
    return self;
}

- (void)setStylePath:(NSString *)stylePath {
    _stylePath = stylePath;
    _listStyle = [UPCSocialStyle listStyleForPath:_stylePath];
    
    switch (_listStyle) {
        case UPCListStyle16x16:
        case UPCListStyle24x24:
            self.tableView.rowHeight = 44;
            break;
            
        case UPCListStyle48x48:
            self.tableView.rowHeight = 66;
            break;
            
        case UPCListStyle80x80:
            self.tableView.rowHeight = 88;
            break;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    self.things = things;
    self.isLastPage = isLastPage;
    self.nextPageFetchStarted = NO;
    [self.tableView reloadData];
    
    if ([self respondsToSelector:@selector(refreshControl)]) {
        
        if (self.refreshControl.isRefreshing)
            [self.refreshControl endRefreshing];
        
    }
}

- (USSThing *)thingForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.things[indexPath.row];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.things.count + (self.isLastPage ? 0 : 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier;
    
    switch (self.listStyle) {
        case UPCListStyle16x16:
            CellIdentifier = UPCListCell16x16;
            break;
            
        case UPCListStyle24x24:
            CellIdentifier = UPCListCell24x24;
            break;
            
        case UPCListStyle48x48:
            CellIdentifier = UPCListCell48x48;
            break;
            
        case UPCListStyle80x80:
            CellIdentifier = UPCListCell80x80;
            break;
    }
    
    if (indexPath.row == self.things.count) {
        /* An empty cell with an activity indicator, shown to indicate that the next page is being loaded */
        UPCListViewBusyCell *busyCell = [tableView dequeueReusableCellWithIdentifier:UPCListViewBusyCellIdentifier];
        if (!busyCell) {
            busyCell = [[UPCListViewBusyCell alloc]init];
        }
        [busyCell.activityIndicator startAnimating];
        return busyCell;
    } else {
        /* Content cell */
        
        UPCListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UPCListViewCell alloc]initWithReuseIdentifier:CellIdentifier];
        }
        
        USSThing *thing = [self thingForRowAtIndexPath:indexPath];
        
        /* configure cell content */
        
        /* thumbnail */
        __weak UPCListViewCell *weakCell = cell;
        [cell.thumnailView setImageWithURLRequest:[NSURLRequest requestWithURL:thing.thumbnailURL] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            /* AFNetworking category on UIImageView sets the image scale to that of the screen by default, which doesn't work well with 16x16 icons. Hence the override. */
            [weakCell.thumnailView setImage:[UIImage imageWithCGImage:image.CGImage scale:1 orientation:UIImageOrientationUp]];
        } failure:nil];
        
        /* title */
        cell.titleLabel.text = thing.title;
        
        /* display a discosure indicator for openable items */
        switch (thing.action.type) {
            case USSActionTypeOpenPath:
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
                
            case USSActionTypeSelectFile:
                cell.accessoryType = UITableViewCellAccessoryNone;
                break;
        }
        
        return cell;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    const NSUInteger kPrefetchStartsAtRow = 6;
    if (!self.isLastPage && self.things.count - indexPath.row <= kPrefetchStartsAtRow && !self.nextPageFetchStarted) {
        self.nextPageFetchStarted = YES;
        [self.sourceViewController fetchNextThingsPage];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= self.things.count)
        return;
    UPCListViewCell *cell = (UPCListViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    USSThing *thing = [self thingForRowAtIndexPath:indexPath];
    [self.sourceViewController performSocialSourceAction:thing.action forItemTitled:thing.title withThumbnailURL:thing.thumbnailURL thumbnailImage:cell.thumnailView.image];
}

@end
