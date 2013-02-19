//
//  UploadcareMenu.m
//  WidgetSample
//
//  Created by Zoreslav Khimich on 11/6/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "UCUploadViewController.h"
#import "UCAlbumsList.h"
#import "UCGrabkitConfigurator.h"
#import "UCRecentUploads.h"
#import "UCRecentUploadsViewController.h"
#import "UIImage+UCHelpers.h"
#import "UPCUpload_Private.h"

#import "GRKConfiguration.h"
#import "GRKDeviceGrabber.h"
#import "GRKFacebookGrabber.h"
#import "GRKFlickrGrabber.h"
#import "GRKInstagramGrabber.h"

//#import "SVProgressHUD.h"
/* Private parts */
@interface UCUploadViewController ()
@property (strong) GRKServiceGrabber *grabber;
@property (strong) UCAlbumsList *albumList;
@property (readonly) UPCUploadController *widget;
@property (readonly) ALAssetsLibrary* assets;
@end

/* Implementation */
@implementation UCUploadViewController

+ (void)initialize {
    [GRKConfiguration initializeWithConfigurator:[UCGrabkitConfigurator shared]];
}

- (id)initWithWidget:(UPCUploadController *)widget {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _widget = widget;
        _assets = [[ALAssetsLibrary alloc]init];
        _imagePicker = [[UIImagePickerController alloc]init];
        self.contentSizeForViewInPopover = CGSizeMake(320, 480);
   }
    return self;
}

#pragma mark - Public interfaces

#pragma mark - UITableViewController doodad

- (void)viewDidLoad {
    self.navigationItem.title = self.title ? self.title : NSLocalizedString(@"Upload", @"Uploadcare menu default navigation view title");
    
    /* Don't show the `Cancel` button when presented in a popover on iPad */
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss)];
    }
}

- (void)viewDidAppear:(BOOL)animated {
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.widget.uploadDelegate respondsToSelector:@selector(uploadControllerDidCancel:)]) {
            [self.widget.uploadDelegate uploadControllerDidCancel:self.widget];
        }
    }];
}

#pragma mark - Menu declaration

+ (NSArray *)menuItems {
    static NSMutableArray* _menuItems;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _menuItems = [NSMutableArray arrayWithArray:@[
                @{@"items": @[
                    @{ @"textLabel.text"          : NSLocalizedString(@"Camera", @"Camera menu item"),
                       @"textLabel.enabled"       : @([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]),
                       @"textLabel.textAlignment" : @(NSTextAlignmentCenter),
                       @"action"                  : @"uploadFromCamera",
                       @"accessoryType"           : @(UITableViewCellAccessoryNone),
                     },

                    @{ @"textLabel.text"          : NSLocalizedString(@"Media Library", @"Media Library menu item"),
                       @"textLabel.enabled"       : @([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]),
                       @"textLabel.textAlignment" : @(NSTextAlignmentCenter),
                       @"action"                  : @"uploadFromLibrary",
                       @"accessoryType"           : @(UITableViewCellAccessoryNone),
                     },
                 ],
                },
          ]];
        
        NSMutableArray *serviceSectionItems = [NSMutableArray array];
        UCGrabkitConfigurator *config = [UCGrabkitConfigurator shared];
        
        if ([config facebookIsEnabled]) {
            [serviceSectionItems addObject:
                    @{ @"textLabel.text"  : NSLocalizedString(@"Facebook", @"Facebook menu item"),
                       @"imageView.image" : [UIImage imageNamed:@"icon_facebook"],
                       @"action"          : @"uploadFromFacebook",
                       @"accessoryType"   : @(UITableViewCellAccessoryDisclosureIndicator),
                     }
             ];
        }
            
        if ([config flickrIsEnabled]) {
            [serviceSectionItems addObject:
                    @{ @"textLabel.text"  : NSLocalizedString(@"Flickr", @"Flickr menu item"),
                       @"imageView.image" : [UIImage imageNamed:@"icon_flickr"],
                       @"action"          : @"uploadFromFlickr",
                       @"accessoryType"   : @(UITableViewCellAccessoryDisclosureIndicator),
                     }
             ];
         }
        
        if ([config instagramIsEnabled]) {
            [serviceSectionItems addObject:
                    @{ @"textLabel.text"  : NSLocalizedString(@"Instagram", @"Instagram menu item"),
                       @"imageView.image" : [UIImage imageNamed:@"icon_instagram"],
                       @"action"          : @"uploadFromInstagram",
                       @"accessoryType"   : @(UITableViewCellAccessoryDisclosureIndicator),
                     }
             ];
        }
        
        [serviceSectionItems addObject:
                    @{ @"textLabel.text"  : NSLocalizedString(@"Internet Address", @"Upload from URL menu item"),
                       @"imageView.image" : [UIImage imageNamed:@"icon_url"],
                       @"action"          : @"uploadFromURL",
                       @"accessoryType"   : @(UITableViewCellAccessoryNone),
                     }
         ];
        
        [_menuItems addObject:@{@"items":serviceSectionItems}];
        [_menuItems addObject:@{@"items":@[
                    @{ @"textLabel.text"  : NSLocalizedString(@"Recent Uploads", @"Recent Uploads menu item"),
                       @"action"          : @"showRecentUploads",
                       @"accessoryType"   : @(UITableViewCellAccessoryDisclosureIndicator),
                       @"textLabel.textAlignment" : @(NSTextAlignmentCenter),
                     }
            
         ], @"footer":@"Powered by Uploadcare.com"}];
        
        
    });
    return _menuItems;
}

- (NSArray *)menuItems {
    return [self.class menuItems];
}

#pragma mark - Menu handlers

- (void)uploadFromCamera {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) return;
    [self presentImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
}

- (void)uploadFromLibrary {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) return;
    [self presentImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)uploadFromServiceNamed:(NSString*)serviceName withGrabberClass:(Class)grabberClass  {
    /* TODO: reuse grabbers? like, NSDictonary of class:singletonInstance */
    self.grabber = [[grabberClass alloc]init];
    self.albumList = [[UCAlbumsList alloc] initWithGrabber:self.grabber
                                               serviceName:serviceName widget:self.widget];
    [self.navigationController pushViewController:self.albumList animated:YES];
}

- (void)uploadFromFacebook {
    [self uploadFromServiceNamed:@"Facebook" withGrabberClass:[GRKFacebookGrabber class]];
}

- (void)uploadFromFlickr {
    [self uploadFromServiceNamed:@"Flickr" withGrabberClass:[GRKFlickrGrabber class]];
}

- (void)uploadFromInstagram {
    [self uploadFromServiceNamed:@"Instagram" withGrabberClass:[GRKInstagramGrabber class]];
}

- (void)uploadFromURL {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Upload from the Internet", @"Upload from URL dialog title") message:NSLocalizedString(@"Where do you want it uploaded from?", @"Upload from URL subtitle/message text") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Upload from URL dialog CANCEL button") otherButtonTitles: NSLocalizedString(@"Upload", @"Upload from URL dialog ACTION button"), nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField * URLTextField = [alert textFieldAtIndex:0];
    URLTextField.keyboardType = UIKeyboardTypeURL;
    URLTextField.placeholder = NSLocalizedString(@"http://", @"Placeholder for the Upload from URL dialog");
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (!buttonIndex) return; // cancelled
    NSString *addressString = [[alertView textFieldAtIndex:0]text];
    NSURL *remoteURL = [NSURL URLWithString:addressString];
    if (!remoteURL) {
        UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Failed to process the address", @"Senseless URL error alert title") message:[NSString stringWithFormat:NSLocalizedString(@"\"%@\" does not seem to be a valid internet address.", @"Senseless URL error alert message body, %@ gets substituted with the causal URL"), addressString] delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", @"Dismiss button title") otherButtonTitles: nil];
        [errorAlert show];
        return;
    }
    UIImage *thumbnail = [UIImage imageNamed:@"thumb_from_URL_128x128"];
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [UPCUpload uploadRemoteForURL:remoteURL title:nil thumbnailURL:nil thumbnailImage:nil delegate:self.widget.uploadDelegate source:@"an URL"];
    }];
}

- (void)showRecentUploads {
    UCRecentUploadsViewController *recentUploadsViewController = [[UCRecentUploadsViewController alloc]init];
    recentUploadsViewController.widget = self.widget;
    [self.navigationController pushViewController:recentUploadsViewController animated:YES];
}

#pragma mark -

- (void)presentImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType {
    self.imagePicker.sourceType = sourceType;
    self.imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    self.imagePicker.delegate = self;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone || sourceType == UIImagePickerControllerSourceTypeCamera) {
        [self presentViewController:self.imagePicker animated:YES completion:nil];
    }else{
        [self.widget.popover setContentViewController:self.imagePicker animated:YES];
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
                    if (!error) [UPCUpload uploadAssetForURL:assetURL delegate:self.widget.uploadDelegate];
                    else NSLog(@"Failed to save photo to the assets library.\n\n%@", error);
                }];
            }else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
                /* source = CAMERA, type = MOVIE CLIP */
                NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
                /* make sure the video could be stored in the library at all */
                if ([self.assets videoAtPathIsCompatibleWithSavedPhotosAlbum:videoURL]) {
                    [self.assets writeVideoAtPathToSavedPhotosAlbum:videoURL completionBlock:^(NSURL *assetURL, NSError *error) {
                        if (!error) [UPCUpload uploadAssetForURL:assetURL delegate:self.widget.uploadDelegate];
                        else NSLog(@"Failed to save video to the assets library.\n\n%@", error);
                    }];
                }else{
                    NSLog(@"Video at path %@ is not compativle with the saved photos album on the device.", videoURL);
                }
            }
        }else if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary
                  || picker.sourceType == UIImagePickerControllerSourceTypeSavedPhotosAlbum) {
            [UPCUpload uploadAssetForURL:info[UIImagePickerControllerReferenceURL] delegate:self.widget.uploadDelegate];
        }
    }];
}


@end
