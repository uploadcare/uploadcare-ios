//
//  UploadcareMenu.m
//  WidgetSample
//
//  Created by Zoreslav Khimich on 11/6/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "UCUploadViewController.h"
#import "UCAlbumsList.h"
#import "UploadcareServicesConfigurator.h"

#import "GRKConfiguration.h"
#import "GRKDeviceGrabber.h"
#import "GRKFacebookGrabber.h"
#import "GRKFlickrGrabber.h"
#import "GRKInstagramGrabber.h"

#import "UCUploader.h"
#import "UCHUD.h"

@interface UCUploadViewController ()
@property (strong) GRKServiceGrabber *grabber;
@property (strong) UCAlbumsList *albumList;
@end

@implementation UCUploadViewController

+ (void)initialize {
    [GRKConfiguration initializeWithConfigurator:[[UploadcareServicesConfigurator alloc]init]];
}

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        /* ... */
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
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss)];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Menu declaration

+ (NSArray *)menuItems {
    static NSArray* _menuItems;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _menuItems = @[
                @{@"items": @[
                    @{ @"textLabel.text"          : @"Snap a Photo",
                       @"textLabel.enabled"       : @([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]),
                       @"textLabel.textAlignment" : @(NSTextAlignmentCenter),
                       @"action"                  : @"uploadFromCamera",
                       @"accessoryType"           : @(UITableViewCellAccessoryNone),
                     },

                    @{ @"textLabel.text"          : @"Select from Library",
                       @"textLabel.enabled"       : @([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]),
                       @"textLabel.textAlignment" : @(NSTextAlignmentCenter),
                       @"action"                  : @"uploadFromLibrary",
                     },
                 ],
                },

                @{@"items": @[
                    @{ @"textLabel.text"  : @"Facebook",
                       @"imageView.image" : [UIImage imageNamed:@"icon_facebook"],
                       @"action"          : @"uploadFromFacebook",
                       @"accessoryType"   : @(UITableViewCellAccessoryDisclosureIndicator),
                     },

                    @{ @"textLabel.text"  : @"Flickr",
                       @"imageView.image" : [UIImage imageNamed:@"icon_flickr"],
                       @"action"          : @"uploadFromFlickr",
                       @"accessoryType"   : @(UITableViewCellAccessoryDisclosureIndicator),
                     },

                    @{ @"textLabel.text"  : @"Instagram",
                       @"imageView.image" : [UIImage imageNamed:@"icon_instagram"],
                       @"action"          : @"uploadFromInstagram",
                       @"accessoryType"   : @(UITableViewCellAccessoryDisclosureIndicator),
                     },

                    @{ @"textLabel.text"  : @"Internet Address",
                       @"imageView.image" : [UIImage imageNamed:@"icon_url"],
                       @"action"          : @"uploadFromURL",
                       @"accessoryType"   : @(UITableViewCellAccessoryNone),
                     },

                 ],
                 @"footer" : @"Powered by Uploadcare",
                },
        ];
    });
    return _menuItems;
}

- (NSArray *)menuItems {
    return [self.class menuItems];
}

#pragma mark - Menu handlers

- (void)presentImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.sourceType = sourceType;
    imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    imagePicker.delegate = self;
    [self presentModalViewController:imagePicker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:NO completion:^{
        [self dismissViewControllerAnimated:YES completion:^{
            [UCHUD setProgress:0];
            [UCHUD setText:NSLocalizedString(@"Uploading", @"Upload HUD text")];
            [UCHUD show];
            [[UploadcareKit shared]uploadFileWithName:info[UIImagePickerControllerReferenceURL] data:UIImageJPEGRepresentation(info[UIImagePickerControllerOriginalImage], 1) contentType:@"image/jpeg" progressBlock:^(long long bytesDone, long long bytesTotal) {
                [UCHUD setProgress:(float)bytesDone / bytesTotal];
            } successBlock:^(NSString *fileId) {
                [UCHUD dismiss];
                self.uploadCompletionBlock(fileId);
            } failureBlock:^(NSError *error) {
                [UCHUD dismiss];
                self.uploadFailureBlock(error);
            }];
        }];
     }];
}

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
                                               serviceName:serviceName];
    self.albumList.uploadCompletionBlock = self.uploadCompletionBlock;
    self.albumList.uploadFailureBlock = self.uploadFailureBlock;
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
    [self dismissViewControllerAnimated:YES completion:^{
        NSString *fileURL = [[alertView textFieldAtIndex:0] text];
        UCUploadFile(fileURL, self.uploadCompletionBlock, self.uploadFailureBlock);
    }];
}

@end
