//
//  UPCWidgetMenuViewController.m
//  uShare
//
//  Created by Zoreslav Khimich on 18/03/2013.
//  Copyright (c) 2013 Uploadcare. All rights reserved.
//

#import "UPCWidgetMenuViewController.h"
#import "UPCUploadController.h"
#import "UCRecentUploadsViewController.h"
#import "UPCUpload_Private.h"
#import "UploadcareKit.h"
#import "UploadcareSocialSource.h"
#import "UPCSourceViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>

@interface UPCWidgetMenuViewController ()

@property (readonly, nonatomic) UPCUploadController *enclosingUploadController;
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (readonly, nonatomic) ALAssetsLibrary* assets;
@property (readonly, nonatomic) UPCSocialSourceClient *socialClient;
@property (strong, nonatomic) NSArray *socialSources;

@end

typedef enum {
    UPCWidgetMenuDeviceSourcesSection = 0,
    UPCWidgetMenuSocialSourcesSection,
    UPCWidgetMenuPastUploadsSection,
} UPCWidgetMenuSection;

typedef enum {
    UPCWidgetDeviceMenuItemCamera = 0,
    UPCWidgetDeviceMenuItemLibrary,
} UPCWidgetDeviceMenuItem;

@implementation UPCWidgetMenuViewController

+ (void)load {
    id tableViewProxy = [UITableView appearanceWhenContainedIn:[UPCWidgetMenuViewController class], nil];
    UIView *backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1, 1)];
    backgroundView.backgroundColor = [UIColor colorWithWhite:.9294 alpha:1.];
    [tableViewProxy setBackgroundView:backgroundView];
}

- (UPCUploadController *)enclosingUploadController {
    return (UPCUploadController *)self.navigationController;
}

- (id)initWithUploadcarePublicKey:(NSString *)publicKey
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _assets = [[ALAssetsLibrary alloc]init];
        _socialClient = [[UPCSocialSourceClient alloc]initWithUploadcarePublicKey:publicKey];
        [[UploadcareKit shared] setPublicKey:publicKey];
        
        [_socialClient querySourcesUsingBlock:^(NSArray *sources, NSError *error) {
            self.socialSources = sources;
            [self.tableView reloadData];
        }];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = self.title ? self.title : NSLocalizedString(@"Upload", @"Uploadcare menu default navigation view title");
    
    self.contentSizeForViewInPopover = CGSizeMake(320, 480);
    
    /* Don't show the `Cancel` button when presented in a popover on iPad */
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss)];
    }
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:^{
        /* Notify the delegate */
        if ([self.enclosingUploadController.uploadDelegate respondsToSelector:@selector(uploadControllerDidCancel:)]) {
            [self.enclosingUploadController.uploadDelegate uploadControllerDidCancel:self.enclosingUploadController];
        }
    }];
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case UPCWidgetMenuDeviceSourcesSection:
            return 2;
            
        case UPCWidgetMenuSocialSourcesSection:
            if (self.socialSources.count)
                return self.socialSources.count;
            return 1; // UIActivityIndicator cell
            
        case UPCWidgetMenuPastUploadsSection:
            return 1;
    }
    return 0;
}

- (UIImage *)imageForSourceNamed:(NSString *)sourceName {
    NSLog(@"source %@", sourceName);
    if ([sourceName isEqualToString:@"facebook"]) {
        return [UIImage imageNamed:@"icon_facebook"];
    } else if ([sourceName isEqualToString:@"instagram"]) {
        return [UIImage imageNamed:@"icon_instagram"];
    } else if ([sourceName isEqualToString:@"dropbox"]) {
        return [UIImage imageNamed:@"icon_dropbox"];
    } else if ([sourceName isEqualToString:@"flickr"]) {
        return [UIImage imageNamed:@"icon_flickr"];
    } else if ([sourceName isEqualToString:@"gdrive"]) {
        return [UIImage imageNamed:@"icon_google_drive"];
    } else if ([sourceName isEqualToString:@"vk"]) {
        return [UIImage imageNamed:@"icon_vk"];
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        /* Camera & Library */
        case UPCWidgetMenuDeviceSourcesSection: {
            static NSString *DeviceCellIdentifier = @"UPCWidgetMenuDeviceCellIdentifier";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DeviceCellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DeviceCellIdentifier];
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
            }
            switch (indexPath.row) {
                case UPCWidgetDeviceMenuItemCamera:
                    cell.textLabel.text = NSLocalizedString(@"Take Photo or Video", @"Widget menu `Camera` item");
                    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                        cell.textLabel.enabled = NO;
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    }
                    break;
                    
                case UPCWidgetDeviceMenuItemLibrary:
                    cell.textLabel.text = NSLocalizedString(@"Choose Existing", @"Widget menu `Library` item");
                    break;
            }
            return cell;
        } break;
            
        case UPCWidgetMenuSocialSourcesSection: {
            if (self.socialSources.count) {
                /* Display social source cell */
                static NSString *SocialCellIdentifier = @"UPCWidgetMenuDeviceSocialCellIdentifier";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SocialCellIdentifier];
                if (!cell) {
                    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SocialCellIdentifier];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                USSSource *source = [self.socialSources objectAtIndex:indexPath.row];
                cell.textLabel.text = source.title;
                cell.imageView.image = [self imageForSourceNamed:source.shortName];
                return cell;
            } else {
                /* Display an activity indicator */
                static NSString *BusyCellIdentifier = @"UPCWidgetMenuDeviceBusyCellIdentifier";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BusyCellIdentifier];
                if (!cell) {
                    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BusyCellIdentifier];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                [cell addSubview:activityIndicator];
                activityIndicator.center = CGPointMake(CGRectGetWidth(cell.bounds) * .5, CGRectGetHeight(cell.bounds) * .5);
                activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin;
                [activityIndicator startAnimating];
                
                return cell;
            }
        }break;
        
        /* Past Uploads */
        case UPCWidgetMenuPastUploadsSection: {
            static NSString *PastUploadsCellIdentifier = @"UPCWidgetMenuPastUploadsCellIdentifier";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PastUploadsCellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PastUploadsCellIdentifier];
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            
            cell.textLabel.text = NSLocalizedString(@"Previous Uploads", @"Widget menu `Past Uploads` item");
            return cell;
        }
            
    }
    
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == UPCWidgetMenuPastUploadsSection) {
        return NSLocalizedString(@"Powered by Uploadcare.com", @"Widget menu footer text");
    }
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case UPCWidgetMenuPastUploadsSection:
            [self showRecentUploads];
            break;
            
        case UPCWidgetMenuDeviceSourcesSection:
            if (indexPath.row == UPCWidgetDeviceMenuItemCamera) {
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                    [self presentImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
                }
            } else if (indexPath.row == UPCWidgetDeviceMenuItemLibrary) {
                [self presentImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            }
            break;
            
        case UPCWidgetMenuSocialSourcesSection:
            if (self.socialSources.count) {
                USSSource *source = [self.socialSources objectAtIndex:indexPath.row];
                UPCSourceViewController *sourceController = [[UPCSourceViewController alloc]initWithSocialSourceClient:self.socialClient source:source activeRootChunkIndex:0 path:nil];
                [self.navigationController pushViewController:sourceController animated:YES];
            }
            
        default:
            break;
    }
}

#pragma mark - Recent uploads

- (void)showRecentUploads {
    UCRecentUploadsViewController *recentUploadsViewController = [[UCRecentUploadsViewController alloc]init];
    recentUploadsViewController.widget = self.enclosingUploadController;
    [self.navigationController pushViewController:recentUploadsViewController animated:YES];
}

#pragma mark - Image picker

- (void)presentImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType {
    if (!self.imagePicker) {
        self.imagePicker = [[UIImagePickerController alloc]init];
    }
    self.imagePicker.sourceType = sourceType;
    self.imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    self.imagePicker.delegate = self;
    /* self.imagePicker.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal; */
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone || sourceType == UIImagePickerControllerSourceTypeCamera) {
        [self presentViewController:self.imagePicker animated:YES completion:nil];
    }else{
        [self.enclosingUploadController.popover setContentViewController:self.imagePicker animated:YES];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:^{
        /* A picture or a video clip? */
        NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
        
        /* Camera or library? */
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            /* The user used the camera to snap a new picture or record a video clip */
            if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
                /* source = CAMERA, type = STILL IMAGE */
                UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
                if (!image) {
                    image = [info objectForKey:UIImagePickerControllerOriginalImage];
                }
                /* metadata (JFIF etc) */
                NSDictionary *metadata = [info objectForKey:UIImagePickerControllerMediaMetadata];
                /* write image to the Assets Library */
                [self.assets writeImageToSavedPhotosAlbum:image.CGImage metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
                    if (!error) [UPCUpload uploadAssetForURL:assetURL delegate:self.enclosingUploadController.uploadDelegate];
                    else NSLog(@"Failed to save photo to the assets library.\n\n%@", error);
                }];
            }else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
                /* source = CAMERA, type = MOVIE CLIP */
                NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
                /* make sure the video could be stored in the library at all */
                if ([self.assets videoAtPathIsCompatibleWithSavedPhotosAlbum:videoURL]) {
                    [self.assets writeVideoAtPathToSavedPhotosAlbum:videoURL completionBlock:^(NSURL *assetURL, NSError *error) {
                        if (!error) [UPCUpload uploadAssetForURL:assetURL delegate:self.enclosingUploadController.uploadDelegate];
                        else NSLog(@"Failed to save video to the assets library.\n\n%@", error);
                    }];
                }else{
                    NSLog(@"Video at path %@ is not compativle with the saved photos album on the device.", videoURL);
                }
            }
        }else if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary
                  || picker.sourceType == UIImagePickerControllerSourceTypeSavedPhotosAlbum) {
            [UPCUpload uploadAssetForURL:info[UIImagePickerControllerReferenceURL] delegate:self.enclosingUploadController.uploadDelegate];
        }
    }];
}

@end
