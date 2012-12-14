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

#import "GRKConfiguration.h"
#import "GRKDeviceGrabber.h"
#import "GRKFacebookGrabber.h"
#import "GRKFlickrGrabber.h"
#import "GRKInstagramGrabber.h"

#import "SVProgressHUD.h"

#import "UCUploader.h"

/* Private parts */
@interface UCUploadViewController ()
@property (strong) GRKServiceGrabber *grabber;
@property (strong) UCAlbumsList *albumList;
@property (readonly) UCWidget *widget;
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
    [self.widget.delegate uploadcareWidgetDidCancel:self.widget];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Menu declaration

+ (NSArray *)menuItems {
    static NSMutableArray* _menuItems;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _menuItems = [NSMutableArray arrayWithArray:@[
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
          ]];
        
        NSMutableArray *serviceSectionItems = [NSMutableArray array];
        UCGrabkitConfigurator *config = [UCGrabkitConfigurator shared];
        
        if ([config facebookIsEnabled]) {
            [serviceSectionItems addObject:
                    @{ @"textLabel.text"  : @"Facebook",
                       @"imageView.image" : [UIImage imageNamed:@"icon_facebook"],
                       @"action"          : @"uploadFromFacebook",
                       @"accessoryType"   : @(UITableViewCellAccessoryDisclosureIndicator),
                     }
             ];
        }
            
        if ([config flickrIsEnabled]) {
            [serviceSectionItems addObject:
                    @{ @"textLabel.text"  : @"Flickr",
                       @"imageView.image" : [UIImage imageNamed:@"icon_flickr"],
                       @"action"          : @"uploadFromFlickr",
                       @"accessoryType"   : @(UITableViewCellAccessoryDisclosureIndicator),
                     }
             ];
         }
        
        if ([config instagramIsEnabled]) {
            [serviceSectionItems addObject:
                    @{ @"textLabel.text"  : @"Instagram",
                       @"imageView.image" : [UIImage imageNamed:@"icon_instagram"],
                       @"action"          : @"uploadFromInstagram",
                       @"accessoryType"   : @(UITableViewCellAccessoryDisclosureIndicator),
                     }
             ];
        }
        
        [serviceSectionItems addObject:
                    @{ @"textLabel.text"  : @"Internet Address",
                       @"imageView.image" : [UIImage imageNamed:@"icon_url"],
                       @"action"          : @"uploadFromURL",
                       @"accessoryType"   : @(UITableViewCellAccessoryNone),
                     }
         ];
        
        [_menuItems addObject:@{@"items":serviceSectionItems}];
        [_menuItems addObject:@{@"items":@[
                    @{ @"textLabel.text"  : @"Recent Uploads",
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
             /* TODO: Move everything to UCUploader */
            NSString *const kUploadingText = NSLocalizedString(@"Uploading", @"Upload HUD text");
            NSData *data;
            NSString *filename;
            if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeImage]) {
                /* a picture */
                /* TODO: If UIImagePickerControllerReferenceURL presents, upload [NSData fromURL] */
                UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
                if (!image) image = [info objectForKey:UIImagePickerControllerOriginalImage];
                filename = info[UIImagePickerControllerReferenceURL];
                if (!filename) filename = @"untitled.jpg";
                data = UIImageJPEGRepresentation(image, 1);
                NSLog(@"METADATA %@", [info objectForKey:UIImagePickerControllerMediaMetadata]);
            } else if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeMovie]) {
                /* a movie */
                filename = info[UIImagePickerControllerMediaURL];
                if (!filename) filename = @"untitled.mov";
                data = [NSData dataWithContentsOfURL:[info objectForKey:UIImagePickerControllerMediaURL]];
            }
            /* TODO: Save image/video to the library? */
            [[UploadcareKit shared]uploadFileWithName:filename data: data contentType:nil progressBlock:^(long long bytesDone, long long bytesTotal) {
                [SVProgressHUD showProgress:(float)bytesDone / bytesTotal status:kUploadingText maskType:SVProgressHUDMaskTypeNone];
            } successBlock:^(NSString *fileId) {
                [SVProgressHUD dismiss];
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Done", @"Uploading done HUD text")];
                self.uploadCompletionBlock(fileId);
            } failureBlock:^(NSError *error) {
                [SVProgressHUD dismiss];
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Error", @"Uploading failed HUD text")];
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
        UCUploadFile(fileURL, ^(NSString *fileId) {
            [UCRecentUploads recordUploadFromURL:[NSURL URLWithString:fileURL] thumnailURL:nil title:fileURL sourceType:@"an URL" errorType:UCRecentUploadsNoError];
            self.uploadCompletionBlock(fileId);
        }, ^(NSError *error) {
            [UCRecentUploads recordUploadFromURL:[NSURL URLWithString:fileURL] thumnailURL:nil title:fileURL sourceType:@"an URL" errorType:UCRecentUploadsSystemError];
            self.uploadFailureBlock(error);
        });
    }];
}

- (void)showRecentUploads {
    UCRecentUploadsViewController *recentUploadsViewController = [[UCRecentUploadsViewController alloc]initWithStyle:UITableViewStylePlain];
    recentUploadsViewController.uploadCompletionBlock = self.uploadCompletionBlock;
    recentUploadsViewController.uploadFailureBlock = self.uploadFailureBlock;
    [self.navigationController pushViewController:recentUploadsViewController animated:YES];
}

@end
