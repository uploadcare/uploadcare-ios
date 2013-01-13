//
//  UCRecentUploadsViewController.m
//  WidgetExample
//
//  Created by Zoreslav Khimich on 11/18/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "UCRecentUploadsViewController.h"
#import "UCRecentUploads.h"
#import "UCUploader.h"
#import "UIImageView+UCHelpers.h"
#import "QuartzCore/QuartzCore.h"
#import "UPCUploadController.h"

@interface UCRecentUploadsViewController ()

@end

@implementation UCRecentUploadsViewController

- (id)init {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.contentSizeForViewInPopover = CGSizeMake(320, 480);
        self.tableView.backgroundColor = [UIColor colorWithWhite:.95f alpha:1.f];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Recent", @"Title for the recent uploads view controller");
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        
        /* TODO: Share the code with the album view cells */
        cell.imageView.layer.cornerRadius = 4.0f;
        cell.imageView.clipsToBounds = YES;
        
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
    
    /* subtitle */
    NSDate *uploadDate = uploadInfo[UCRecentUploadsDateKey];
    NSString *uploadSource = uploadInfo[UCRecentUploadsSourceTypeKey];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    dateFormatter.doesRelativeDateFormatting = YES;
    NSString *dateString = [dateFormatter stringFromDate:uploadDate];
    NSString *detailFormatString = NSLocalizedString(@"%@ from %@", "Recent uploads item subtitle, e.g. `Yesterday from Facebook`, or `22.09.2012 from an URL");
    cell.detailTextLabel.text = [NSString stringWithFormat:detailFormatString, dateString, uploadSource];
    
    /* thumbnail */
    NSURL *thumbnailURL = ([uploadInfo[UCRecentUploadsThumbnailURLKey] length]) ? [NSURL URLWithString:uploadInfo[UCRecentUploadsThumbnailURLKey]] : [[NSBundle mainBundle]URLForResource:@"thumb_from_URL_128x128" withExtension:@"png"];
    [cell.imageView showActivityIndicatorWithStyle:UIActivityIndicatorViewStyleGray placeholderSize:CGSizeMake(75, 75)];
    if (thumbnailURL) [cell.imageView setImageFromURL:thumbnailURL scaledToSize:CGSizeMake(75, 75) successBlock:^(UIImage *image) {
        /* remove the activity indicator on success */
        [cell.imageView removeActivityIndicator];
    } failureBlock:^(NSError *error) {
        /* ^ or error */
        [cell.imageView removeActivityIndicator];
    }];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.f;
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
    UIImage *thumbnail = [self.tableView cellForRowAtIndexPath:indexPath].imageView.image;
    if ([self.widget.delegate respondsToSelector:@selector(uploadcareWidget:didStartUploadingFileNamed:fromURL:withThumbnail:)]) {
        NSURL *photoURL = [NSURL URLWithString:uploadInfo[UCRecentUploadsURLKey]];
        [self.widget.delegate uploadcareWidget:self.widget didStartUploadingFileNamed:photoURL.lastPathComponent fromURL:photoURL withThumbnail:thumbnail];
    }else{
        [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }

    UCUploadFile(uploadInfo[UCRecentUploadsURLKey],
                 ^(NSString *fileId) {
                     [UCRecentUploads recordUploadFromURL:[NSURL URLWithString:uploadInfo[UCRecentUploadsURLKey]] thumnailURL:[NSURL URLWithString:uploadInfo[UCRecentUploadsThumbnailURLKey]] title:uploadInfo[UCRecentUploadsTitleKey] sourceType:uploadInfo[UCRecentUploadsSourceTypeKey] errorType:UCRecentUploadsNoError];
                     if (self.widget.uploadCompletionBlock) self.widget.uploadCompletionBlock(fileId);
                 },
                 self.widget.uploadProgressBlock,
                 ^(NSError *error) {
                     [UCRecentUploads recordUploadFromURL:[NSURL URLWithString:uploadInfo[UCRecentUploadsURLKey]] thumnailURL:[NSURL URLWithString:uploadInfo[UCRecentUploadsThumbnailURLKey]] title:uploadInfo[UCRecentUploadsTitleKey] sourceType:uploadInfo[UCRecentUploadsSourceTypeKey] errorType:UCRecentUploadsNoError];
                     if (self.widget.uploadFailureBlock) self.widget.uploadFailureBlock(error);
                 });
}

@end
