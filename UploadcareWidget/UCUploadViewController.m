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
#import "UCUploader.h"
#import "UIImage+UCHelpers.h"

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
@property (readonly) UCWidget *widget;
@property (readonly) ALAssetsLibrary* assets;
@end

/* Implementation */
@implementation UCUploadViewController

+ (void)initialize {
    [GRKConfiguration initializeWithConfigurator:[UCGrabkitConfigurator shared]];
}

- (id)initWithWidget:(UCWidget *)widget {
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

- (void)setNavigationTitle:(NSString *)navigationTitle {
    _navigationTitle = navigationTitle;
    self.navigationItem.title = navigationTitle;
}

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
    /* The delegate is expected to dismiss the widget if it respons to the corresponding selector */
    if ([self.widget.delegate respondsToSelector:@selector(uploadcareWidgetDidCancel:)]) {
        [self.widget.delegate uploadcareWidgetDidCancel:self.widget];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
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
    NSURL *fileURL = [NSURL URLWithString:[[alertView textFieldAtIndex:0] text]];
    UIImage *thumbnail = [UIImage imageNamed:@"thumb_from_URL_128x128"];
    if ([self.widget.delegate respondsToSelector:@selector(uploadcareWidget:didStartUploadingFileNamed:fromURL:withThumbnail:)]) {
        [self.widget.delegate uploadcareWidget:self.widget didStartUploadingFileNamed:fileURL.lastPathComponent fromURL:fileURL withThumbnail:thumbnail];
    }else{
        [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    UCUploadFile(fileURL.absoluteString, ^(NSString *fileId) {
        [UCRecentUploads recordUploadFromURL:fileURL thumnailURL:nil title:fileURL.absoluteString sourceType:@"an URL" errorType:UCRecentUploadsNoError];
        self.widget.uploadCompletionBlock(fileId);
    },
    self.widget.uploadProgressBlock,
    ^(NSError *error) {
        [UCRecentUploads recordUploadFromURL:fileURL thumnailURL:nil title:fileURL.absoluteString sourceType:@"an URL" errorType:UCRecentUploadsSystemError];
        self.widget.uploadFailureBlock(error);
    });
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
        [self presentModalViewController:self.imagePicker animated:YES];
    }else{
        [self.widget.popover setContentViewController:self.imagePicker animated:YES];
    }
}

- (void)uploadData:(NSData *)data named:(NSString*)filename {
    /* TODO: assert data != nil */
    [[UploadcareKit shared]uploadFileWithName:filename data:data contentType:nil progressBlock:^(long long bytesDone, long long bytesTotal) {
        /* progress */
//        [SVProgressHUD showProgress:(float)bytesDone/bytesTotal status:filename maskType:SVProgressHUDMaskTypeNone];
        if (self.widget.uploadProgressBlock) self.widget.uploadProgressBlock(bytesDone, bytesTotal);
    } successBlock:^(NSString *fileId) {
        /* success */
//        [SVProgressHUD dismiss];
//        [SVProgressHUD showSuccessWithStatus:filename];
        self.widget.uploadCompletionBlock(fileId);
    } failureBlock:^(NSError *error) {
        /* failure */
//        [SVProgressHUD dismiss];
//        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Error", @"Uploading failed HUD text")];
        self.widget.uploadFailureBlock(error);
    }];
}

- (void)uploadAssetWithURL:(NSURL *)assetURL failureBlock:(ALAssetsLibraryAccessFailureBlock)failureBlock {
    // retrieve the asset from the library
    [self.assets assetForURL:assetURL resultBlock:^(ALAsset *asset) {
        // obtain NSData with the default representation
        ALAssetRepresentation *repr = [asset defaultRepresentation];
        size_t bufferLength = repr.size;
        uint8_t *buffer = (uint8_t *)malloc(bufferLength);
        NSError *retrievalError;
        [repr getBytes:buffer fromOffset:0 length:bufferLength error:&retrievalError];
        NSData *data = [NSData dataWithBytes:buffer length:bufferLength];
        free(buffer);
        NSString *filename = repr.filename;
        UIImage *thumbnail = [UIImage imageWithCGImage:asset.thumbnail];
        // upload
        [self uploadData:data named:filename];
        // notify the delegate
        if ([self.widget.delegate respondsToSelector:@selector(uploadcareWidget:didStartUploadingFileNamed:fromURL:withThumbnail:)]) {
            [self.widget.delegate uploadcareWidget:self.widget didStartUploadingFileNamed:filename fromURL:assetURL withThumbnail:thumbnail];
        }else{
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
//        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeNone]; // FIXME
        
    } failureBlock:^(NSError *error) {
        failureBlock(error);
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
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
            /* anything goes wrong with the Assets Library – just upload the image without
             * saving it */
            ALAssetsLibraryAccessFailureBlock fallbackUploadStillImagery = ^(NSError *error) {
                NSLog(@"Warning! Bypassing the Assets Library. Reason: %@", error);
                [self uploadData:UIImageJPEGRepresentation(image, 1.0f) named:@"camerapic.JPG"];
            };
            /* EXIF/JFIF/etc */
            NSDictionary *metadata = [info objectForKey:UIImagePickerControllerMediaMetadata];
            /* write image to the Assets Library */
            [self.assets writeImageToSavedPhotosAlbum:image.CGImage metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
                if (error) fallbackUploadStillImagery(error); /* uh-oh, could not save to the lib, just upload */
                else [self uploadAssetWithURL:assetURL failureBlock:fallbackUploadStillImagery]; /* everything went better than expected */
            }];
        }else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
            /* source = CAMERA, type = MOVIE CLIP */
            NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
            /* anything goes wrong with the Assets Library – just upload the video without
             * saving it */
            ALAssetsLibraryAccessFailureBlock fallbackMovieClip = ^(NSError *error) {
                NSLog(@"Warning! Bypassing the Assets Library. Reason: %@", error);
                [self uploadData:[NSData dataWithContentsOfURL:videoURL] named:[videoURL lastPathComponent]];
            };
            
            /* make sure the video could be stored in the library at all */
            if ([self.assets videoAtPathIsCompatibleWithSavedPhotosAlbum:videoURL]) {
                [self.assets writeVideoAtPathToSavedPhotosAlbum:videoURL completionBlock:^(NSURL *assetURL, NSError *error) {
                    if (error) fallbackMovieClip(error); /* failed to store in the lib, just upload */
                    else [self uploadAssetWithURL:assetURL failureBlock:fallbackMovieClip]; /* A great success, upload from the library */
                }];
            }else{
                /* video could not be played back or stored on this device, upload the data directly */
                fallbackMovieClip(nil);
            }
        }
    }else if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary
              || picker.sourceType == UIImagePickerControllerSourceTypeSavedPhotosAlbum) {
        /* source = LIBRARY or CAMERA ROLL, type = IMAGE or MOVIE */
        [self uploadAssetWithURL:[info valueForKey:UIImagePickerControllerReferenceURL] failureBlock:^(NSError *error) {
            if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
                UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
                if (!image) image = [info objectForKey:UIImagePickerControllerOriginalImage];
                if (!image) {
                    /* Uh-oh we're in trouble */
                    /* TODO: Widget error */
                }
            }else{
                /* Nothing we can do, fail */
                /* TODO: Widget error */
            }
        }];
    }
}


@end
