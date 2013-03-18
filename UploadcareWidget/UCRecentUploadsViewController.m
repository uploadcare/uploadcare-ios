//
//  UCRecentUploadsViewController.m
//  WidgetExample
//
//  Created by Zoreslav Khimich on 11/18/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "UCRecentUploadsViewController.h"
#import "UCRecentUploads.h"
#import "UIImageView+UCHelpers.h"
#import "QuartzCore/QuartzCore.h"
#import "UPCUploadController.h"
#import "UPCUpload_Private.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIImage+UCHelpers.h"

@interface UCRecentUploadsViewController ()
@end

@implementation UCRecentUploadsViewController

- (id)init {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.contentSizeForViewInPopover = CGSizeMake(320, 480);
        self.tableView.backgroundColor = [UIColor colorWithWhite:.95f alpha:1.f];
        self.tableView.rowHeight = 88.f;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Previous", @"Title for the recent uploads view controller");
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[UCRecentUploads sortedUploads] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reusableIdentifier = @"UCRecentUploadsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reusableIdentifier];

        cell.imageView.layer.cornerRadius = 4.0f;
        cell.imageView.clipsToBounds = YES;
        cell.imageView.bounds = CGRectMake(0, 0, 75, 75);
        
        
        /* "Long tex...re" */
        cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        
        /* Title shadow */
        cell.textLabel.shadowColor = [UIColor whiteColor];
        cell.textLabel.shadowOffset = CGSizeMake(0, 1);
        
        /* Subtitle shadow */
        cell.detailTextLabel.shadowColor = [UIColor whiteColor];
        cell.detailTextLabel.shadowOffset = CGSizeMake(0, 1);
    }

    NSDictionary *uploadInfo = [[UCRecentUploads sortedUploads] objectAtIndex:indexPath.row];

    /* title */
    cell.textLabel.text = uploadInfo[UCRecentUploadsTitleKey];
    if (![cell.textLabel.text length] && ![uploadInfo[UCRecentUploadsThumbnailURLKey] length]) cell.textLabel.text = uploadInfo[UCRecentUploadsURLKey];
    
    /* subtitle */
    NSDate *uploadDate = uploadInfo[UCRecentUploadsDateKey];
    NSString *uploadSource = uploadInfo[UCRecentUploadsSourceTypeKey];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    dateFormatter.doesRelativeDateFormatting = YES;
    NSString *dateString = [dateFormatter stringFromDate:uploadDate];
    NSString *detailFormatString = NSLocalizedString(@"%@ from %@", "Recent uploads item subtitle format string, %1 gets substituted with the relative date and %2 with the source e.g. `Yesterday from Facebook`, `22.09.2012 from an URL");
    cell.detailTextLabel.text = [NSString stringWithFormat:detailFormatString, dateString, uploadSource];
    
    NSURL *sourceURL = [NSURL URLWithString:uploadInfo[UCRecentUploadsURLKey]];
    if ([sourceURL.scheme isEqualToString:@"assets-library"]) {
        cell.imageView.image = [UIImage blankImageWithSize:CGSizeMake(75, 75)];
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc]init];
        [assetsLibrary assetForURL:sourceURL resultBlock:^(ALAsset *asset) {
            cell.imageView.image = [UIImage imageWithCGImage:asset.thumbnail];
        } failureBlock:^(NSError *error) {
            /* ignore for now */
        }];
    }else{
        NSURL *thumbnailURL = ([uploadInfo[UCRecentUploadsThumbnailURLKey] length]) ? [NSURL URLWithString:uploadInfo[UCRecentUploadsThumbnailURLKey]] : [[NSBundle mainBundle]URLForResource:@"thumb_from_URL_128x128" withExtension:@"png"];
        [cell.imageView showActivityIndicatorWithStyle:UIActivityIndicatorViewStyleGray placeholderSize:CGSizeMake(75, 75)];
        __weak UITableViewCell *weakCell = cell;
        if (thumbnailURL) [cell.imageView setImageFromURL:thumbnailURL scaledToSize:CGSizeMake(75, 75) successBlock:^(UIImage *image) {
            /* remove the activity indicator on success */
            [weakCell.imageView removeActivityIndicator];
        } failureBlock:^(NSError *error) {
            /* ^ or error */
            [weakCell.imageView removeActivityIndicator];
        }];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [UCRecentUploads deleteRecordWithSortedIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *uploadInfo = [[UCRecentUploads sortedUploads] objectAtIndex:indexPath.row];
    UIImage *thumbnailImage = [self.tableView cellForRowAtIndexPath:indexPath].imageView.image;

    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:^{
        NSURL *uploadURL = [NSURL URLWithString:uploadInfo[UCRecentUploadsURLKey]];
        if (![uploadURL.scheme isEqualToString:@"assets-library"]) {
            [UPCUpload uploadRemoteForURL:uploadURL title:uploadInfo[UCRecentUploadsTitleKey] thumbnailURL:[NSURL URLWithString:uploadInfo[UCRecentUploadsThumbnailURLKey]] thumbnailImage:thumbnailImage delegate:self.widget.uploadDelegate source:uploadInfo[UCRecentUploadsSourceTypeKey]];
        }else{
            [UPCUpload uploadAssetForURL:uploadURL delegate:self.widget.uploadDelegate];
        }
    }];
}

@end
